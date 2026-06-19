-- Порт фичи 1.1 «SpilledItems»: при разрушении сущности высыпает её содержимое на землю.
-- Гейт — startup-настройка "item-drop".

local inventory_ids = {
	defines.inventory.chest,
	defines.inventory.car_trunk,
	defines.inventory.turret_ammo,
}

local function spill_inventory(surface, position, inventory)
	if not inventory then
		return
	end
	for i = 1, #inventory do
		local stack = inventory[i]
		if stack and stack.valid_for_read then
			-- сам LuaItemStack сохраняет качество/прочность/grid/теги
			surface.spill_item_stack({ position = position, stack = stack, enable_looted = false })
		end
	end
	inventory.clear()
end

local function spill_on_death(event)
	local entity = event.entity
	if not (entity and entity.valid) then
		return
	end
	local surface = entity.surface
	local position = entity.position

	local grid = entity.grid
	if grid then
		for _, equipment in pairs(grid.equipment) do
			local take_result = equipment.prototype.take_result
			if take_result then
				surface.spill_item_stack({
					position = position,
					stack = { name = take_result.name, count = 1, quality = equipment.quality.name },
					enable_looted = false,
				})
			end
		end
		grid.clear()
	end

	for _, id in pairs(inventory_ids) do
		spill_inventory(surface, position, entity.get_inventory(id))
	end
	spill_inventory(surface, position, entity.get_output_inventory())
	spill_inventory(surface, position, entity.get_module_inventory())
	spill_inventory(surface, position, entity.get_fuel_inventory())
	spill_inventory(surface, position, entity.get_burnt_result_inventory())
end

if settings.startup["item-drop"].value then
	script.on_event(defines.events.on_entity_died, spill_on_death)
end
