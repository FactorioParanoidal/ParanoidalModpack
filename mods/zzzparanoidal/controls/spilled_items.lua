-- Высыпание содержимого сущности на землю при её разрушении (порт фичи 1.1 «SpilledItems»).
-- Гейт — startup-настройка "item-drop" (settings.lua). В 1.1 жила в control.lua, при порте на 2.0 выпала,
-- хотя настройка и локаль остались — игрок видел включённую опцию, которая ничего не делала.
-- 2.0-API: spill_item_stack принимает табличную форму {position=, stack=, enable_looted=}.
-- Стек с гридом (броня с модулями) отдаём как LuaItemStack, иначе теряется установленная экипировка.

-- Набор инвентарей повторяет 1.1: сундук, багажник, боезапас турели + output/модули/топливо/прогар.
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
			if stack.grid then
				-- броня/сетка: передаём сам LuaItemStack, иначе потеряются установленные модули
				surface.spill_item_stack({ position = position, stack = stack, enable_looted = false })
			else
				surface.spill_item_stack({
					position = position,
					stack = { name = stack.name, count = stack.count },
					enable_looted = false,
				})
			end
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

	-- экипировка, установленная в саму сущность (её grid)
	local grid = entity.grid
	if grid then
		for _, equipment in pairs(grid.equipment) do
			local take_result = equipment.prototype.take_result
			if take_result then
				surface.spill_item_stack({
					position = position,
					stack = { name = take_result.name, count = 1 },
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

-- startup-настройка читается один раз при загрузке control-стадии: нет галки — нет обработчика
if settings.startup["item-drop"].value then
	script.on_event(defines.events.on_entity_died, spill_on_death)
end
