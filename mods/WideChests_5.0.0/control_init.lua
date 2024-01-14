--- @alias chest_merged_event { player_index: number, surface: LuaSurface, split_chests: LuaEntity[], merged_chest: LuaEntity }

--- @param entity LuaEntity
--- @return integer
local function non_blank_inventory_slots_count(entity)
	local count = 0
	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory then
		for i = 1, #inventory do
			if inventory[i].valid_for_read then
				count = count + 1
			end
		end
	end

	return count
end

--- @param from_entities LuaEntity[]
--- @param to_entity_name string
--- @param to_entity_count integer
--- @return boolean
function MergingChests.can_move_inventories(from_entities, to_entity_name, to_entity_count)
	local from_item_count = 0
	for _, from_entity in ipairs(from_entities) do
		from_item_count = from_item_count + non_blank_inventory_slots_count(from_entity)
	end

	local to_inventory_size = game.entity_prototypes[to_entity_name].get_inventory_size(defines.inventory.chest) or 0

	local is_merged_chest, _, _ = MergingChests.get_merged_chest_info(to_entity_name)

	return from_item_count <= (is_merged_chest and MergingChests.get_inventory_size(to_inventory_size, to_entity_count, to_entity_name) or to_inventory_size * to_entity_count)
end

--- @param from_entities LuaEntity[]
--- @param to_entities LuaEntity[]
function MergingChests.move_inventories(from_entities, to_entities)
	local to_entity_index = 1
	local to_inventory_index = 1

	for _, from_entity in ipairs(from_entities) do
		local from_inventory = from_entity.get_inventory(defines.inventory.chest)
		if from_inventory then
			for i = 1, #from_inventory do
				local item = from_inventory[i]
				if item.valid_for_read then
					local to_inventory = to_entities[to_entity_index].get_inventory(defines.inventory.chest)
					if to_inventory then
						to_inventory[to_inventory_index].set_stack(item)
						to_inventory_index = to_inventory_index + 1

						if to_inventory_index > #to_inventory then
							to_entity_index = to_entity_index + 1
							to_inventory_index = 1
						end
					end
				end
			end
		end
	end
end

--- @param from_entities LuaEntity[]
--- @param to_entities LuaEntity[]
function MergingChests.move_inventory_bar(from_entities, to_entities)
	local bar_count = 0
	local bar_entities = 0

	for _, entity in ipairs(from_entities) do
		local inventory = entity.get_inventory(defines.inventory.chest)
		if inventory and inventory.supports_bar() then
			bar_count = bar_count + inventory.get_bar() - 1
			bar_entities = bar_entities + 1
		end
	end

	for _, entity in ipairs(to_entities) do
		local inventory = entity.get_inventory(defines.inventory.chest)
		if inventory and inventory.supports_bar() then
			local bar = math.round(bar_count / bar_entities)
			inventory.set_bar(bar + 1)
			bar_count = bar_count - bar
			bar_entities = bar_entities - 1
		end
	end
end

--- @param from_entities LuaEntity[]
--- @param to_entities LuaEntity[]
function MergingChests.reconnect_circuits(from_entities, to_entities)
	local from_entities_set = { }
	for _, from_entity in ipairs(from_entities) do
		from_entities_set[from_entity] = from_entity
	end

	local connections = { }
	local red = false
	local green = false
	for _, from_entity in ipairs(from_entities) do
		for _, connection in ipairs(from_entity.circuit_connection_definitions) do
			if not from_entities_set[connection.target_entity] then
				table.insert(connections, connection)

				red = red or connection.wire == defines.wire_type.red
				green = green or connection.wire == defines.wire_type.green
			end
		end
	end

	if #connections > 0 then
		-- connect all "to_entities" entities together
		local grid = MergingChests.entities_to_grid(to_entities)
		for x = grid.min_x, grid.max_x do
			for y = grid.min_y, grid.max_y do
				if red then
					if x + 1 <= grid.max_x then
						grid[x][y].connect_neighbour{wire = defines.wire_type.red, target_entity = grid[x + 1][y]}
					end
					if y + 1 <= grid.max_y then
						grid[x][y].connect_neighbour{wire = defines.wire_type.red, target_entity = grid[x][y + 1]}
					end
				end

				if green then
					if x + 1 <= grid.max_x then
						grid[x][y].connect_neighbour{wire = defines.wire_type.green, target_entity = grid[x + 1][y]}
					end
					if y + 1 <= grid.max_y then
						grid[x][y].connect_neighbour{wire = defines.wire_type.green, target_entity = grid[x][y + 1]}
					end
				end
			end
		end


		-- connect to all outside entities
		for _, connection in ipairs(connections) do
			local closest_entity = nil
			local min = nil

			for _, to_entity in ipairs(to_entities) do
				local diffX = to_entity.position.x - connection.target_entity.position.x
				local diffY = to_entity.position.y - connection.target_entity.position.y

				if not min or (diffX * diffX + diffY * diffY < min) then
					min = diffX * diffX + diffY * diffY
					closest_entity = to_entity
				end
			end

			if closest_entity then
				closest_entity.connect_neighbour(connection)
			end
		end
	end
end

MergingChests.on_chest_merged_event_name = script.generate_event_name()
MergingChests.on_chest_split_event_name = script.generate_event_name()

local function get_chest_merged_event_name()
	return MergingChests.on_chest_merged_event_name
end

local function get_chest_split_event_name()
	return MergingChests.on_chest_split_event_name
end

remote.add_interface('MergingChests', {
	get_chest_merged_event_name = get_chest_merged_event_name,
	get_chest_split_event_name = get_chest_split_event_name
})
