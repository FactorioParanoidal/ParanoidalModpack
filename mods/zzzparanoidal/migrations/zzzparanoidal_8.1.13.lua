-- При смене container/logistic-container нужен промежуточный прототип того же типа.
-- Потери типа, проводов и не поместившегося содержимого силосов согласованы.
local token = "paranoidal-storage-silo-migration"
local target = "WideChests_steel-chest-warehouse-4x4"
local silos, discarded, compensated = 0, 0, 0

local function spill(surface, position, stack)
	if stack.count > 0 then
		surface.spill_item_stack({ position = position, stack = stack, enable_looted = true, allow_belts = false })
	end
end

local convert_inventory
local function convert_stack(stack, inventory, surface, position)
	if not (stack and stack.valid_for_read) then return end
	if stack.name == token then
		local count, quality = stack.count * 16, stack.quality.name
		stack.clear()
		local output = { name = "steel-chest", count = count, quality = quality }
		if inventory then
			output.count = count - inventory.insert(output)
		else
			local kept = math.min(count, prototypes.item["steel-chest"].stack_size)
			stack.set_stack({ name = "steel-chest", count = kept, quality = quality })
			output.count = count - kept
		end
		spill(surface, position, output)
		compensated = compensated + count
	elseif stack.is_item_with_inventory then
		convert_inventory(stack.get_inventory(defines.inventory.item_main), surface, position)
	end
end

convert_inventory = function(inventory, surface, position)
	if not inventory then return end
	-- Сначала освобождаем все слоты компенсации, затем вставляем сундуки.
	local pending = {}
	for index = 1, #inventory do
		local stack = inventory[index]
		if stack.valid_for_read and stack.name == token then
			pending[#pending + 1] = { name = "steel-chest", count = stack.count * 16, quality = stack.quality.name }
			stack.clear()
			if inventory.supports_filters() then inventory.set_filter(index, nil) end
		elseif stack.valid_for_read and stack.is_item_with_inventory then
			convert_inventory(stack.get_inventory(defines.inventory.item_main), surface, position)
		end
	end
	for _, output in ipairs(pending) do
		compensated = compensated + output.count
		output.count = output.count - inventory.insert(output)
		spill(surface, position, output)
	end
end

for _, surface in pairs(game.surfaces) do
	for _, old in pairs(surface.find_entities_filtered({ name = {
		token, "paranoidal-storage-logistic-silo-migration", "paranoidal-storage-warehouse-migration",
	} })) do
		local is_warehouse = old.name == "paranoidal-storage-warehouse-migration"
		local inventory = old.get_inventory(defines.inventory.chest)
		local cargo = game.create_inventory(#inventory)
		for index = 1, #inventory do cargo[index].transfer_stack(inventory[index]) end
		local position, force, quality = old.position, old.force, old.quality
		local health_ratio = old.health / old.prototype.get_max_health(quality)
		old.destroy()
		local replacement = assert(surface.create_entity({ name = is_warehouse and "warehouse-storage" or target,
			position = position, force = force, quality = quality }), "Cannot migrate Angels storage")
		replacement.health = replacement.prototype.get_max_health(quality) * health_ratio
		local destination = replacement.get_inventory(defines.inventory.chest)
		for index = 1, #cargo do
			local stack = cargo[index]
			if stack.valid_for_read then
				local lost = stack.count - destination.insert(stack)
				assert(not is_warehouse or lost == 0, "Warehousing storage cannot hold the migrated warehouse cargo")
				discarded = discarded + lost
			end
		end
		cargo.destroy()
		if not is_warehouse then silos = silos + 1 end
	end
end

-- Обход инвентарей включает персонажей, вагоны, машины, роботов и трупы.
local inventory_ids = {}
for _, id in pairs(defines.inventory) do inventory_ids[id] = true end
for _, surface in pairs(game.surfaces) do
	for _, entity in pairs(surface.find_entities()) do
		for id in pairs(inventory_ids) do
			convert_inventory(entity.get_inventory(id), surface, entity.position)
		end
		if entity.type == "item-entity" then
			local stack = entity.stack
			if stack.valid_for_read and stack.name == token then
				local output = { name = "steel-chest", count = stack.count * 16, quality = stack.quality.name }
				spill(surface, entity.position, output)
				compensated = compensated + output.count
				entity.destroy()
			end
		elseif entity.type == "inserter" then
			convert_stack(entity.held_stack, nil, surface, entity.position)
		end
		if entity.type == "transport-belt" or entity.type == "underground-belt"
			or entity.type == "splitter" or entity.type == "loader" or entity.type == "loader-1x1" then
			for index = 1, entity.get_max_transport_line_index() do
				local line = entity.get_transport_line(index)
				local count = line.get_item_count(token)
				if count > 0 then
					count = line.remove_item({ name = token, count = count })
					spill(surface, entity.position, { name = "steel-chest", count = count * 16 })
					compensated = compensated + count * 16
				end
			end
		end
	end
end
for _, player in pairs(game.players) do
	for id in pairs(inventory_ids) do convert_inventory(player.get_inventory(id), player.surface, player.position) end
	convert_stack(player.cursor_stack, player.get_main_inventory(), player.surface, player.position)
end
log("Storage migration: silos=" .. silos .. ", discarded silo items=" .. discarded .. ", compensated steel chests=" .. compensated)
