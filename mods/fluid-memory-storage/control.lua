local shared = require "shared"
local unit = require "unit"
require "gui"

local update_slots = shared.update_slots

local function setup()
	storage.units = storage.units or {}
	storage.renames = storage.renames or {}

	if remote.interfaces["PickerDollies"] then
		remote.call("PickerDollies", "add_blacklist_name", "fluid-memory-unit", true)
		remote.call("PickerDollies", "add_blacklist_name", "fluid-memory-unit-combinator", true)
	end
end

script.on_init(setup)

script.on_configuration_changed(function(changes)
	setup()
	shared.record_migrations(changes)

	-- Render objects are rebuilt from scratch: older versions did not keep the animation ids.
	rendering.clear(script.mod_name)
	for unit_number, unit_data in pairs(storage.units) do
		unit.migrate(unit_number, unit_data)
	end
end)

script.on_nth_tick(shared.update_rate, function(event)
	local smooth_ups = event.tick % update_slots

	for unit_number, unit_data in pairs(storage.units) do
		if unit_data.lag_id == smooth_ups then
			unit.update(unit_data, unit_number)
		end
	end
end)

local unit_filter = {{filter = "name", name = "fluid-memory-unit"}}

local function on_created(event)
	local entity = event.entity
	if not (entity and entity.valid) or entity.name ~= "fluid-memory-unit" then return end
	if storage.units[entity.unit_number] then return end

	-- Packed unit: tags of the item used (player: consumed_items, robot/platform: stack).
	local tags = event.tags
	local inventory = event.consumed_items
	local stack = event.stack or (inventory and inventory.valid and not inventory.is_empty() and inventory[1]) or nil
	if not tags and stack and stack.valid_for_read and stack.is_item_with_tags then tags = stack.tags end
	unit.register(entity, tags)
end

script.on_event(defines.events.on_built_entity, on_created, unit_filter)
script.on_event(defines.events.on_robot_built_entity, on_created, unit_filter)
script.on_event(defines.events.script_raised_built, on_created, unit_filter)
script.on_event(defines.events.script_raised_revive, on_created, unit_filter)
script.on_event(defines.events.on_space_platform_built_entity, on_created, unit_filter)

script.on_event(defines.events.on_entity_cloned, function(event)
	unit.on_cloned(event.source, event.destination)
end, {
	{filter = "name", name = "fluid-memory-unit"},
	{filter = "name", name = "fluid-memory-unit-powersource"},
	{filter = "name", name = "fluid-memory-unit-combinator"}
})

-- Mined units keep their contents in a packed item; destroyed units lose everything.
local function on_removed(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local unit_number = entity.unit_number
	local unit_data = storage.units[unit_number]
	if not unit_data then return end
	unit.forget(unit_number, unit_data)

	local item = unit_data.item
	local count = unit_data.count or 0
	local buffer = event.buffer
	if not (buffer and item and count > shared.epsilon) then return end

	local quality = entity.quality.name
	if buffer.remove {name = "fluid-memory-unit", count = 1, quality = quality} == 0 then
		log("fluid memory unit " .. unit_number .. ": mined unit item not found in the buffer")
	end
	local temperature = unit_data.temperature or prototypes.fluid[item].default_temperature
	buffer.insert {
		name = "fluid-memory-unit-with-tags",
		count = 1,
		quality = quality,
		health = entity.health / entity.max_health,
		tags = {name = item, count = count, temperature = temperature},
		custom_description = {
			"item-description.fluid-memory-unit-with-tags",
			shared.compactify(count),
			item,
			string.format("%.1f", temperature)
		}
	}
end

script.on_event(defines.events.on_player_mined_entity, on_removed, unit_filter)
script.on_event(defines.events.on_robot_mined_entity, on_removed, unit_filter)
script.on_event(defines.events.on_space_platform_mined_entity, on_removed, unit_filter)
script.on_event(defines.events.on_entity_died, on_removed, unit_filter)
script.on_event(defines.events.script_raised_destroy, on_removed, unit_filter)

-- Units removed without an event (chunk or surface deletion, destroy() by a script).
script.on_event(defines.events.on_object_destroyed, function(event)
	if event.type ~= defines.target_type.entity then return end
	local unit_data = storage.units[event.useful_id]
	if unit_data then unit.forget(event.useful_id, unit_data, true) end
end)

-- Before mining or deconstruction the tank is emptied into the counter.
local function pre_mined(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local unit_data = storage.units[entity.unit_number]
	if unit_data then unit.store_buffer(unit_data) end
end

script.on_event(defines.events.on_pre_player_mined_item, pre_mined, unit_filter)
script.on_event(defines.events.on_robot_pre_mined, pre_mined, unit_filter)
script.on_event(defines.events.on_marked_for_deconstruction, pre_mined, unit_filter)
script.on_event(defines.events.on_space_platform_pre_mined, pre_mined, unit_filter)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting ~= "memory-unit-power-usage" then return end
	for unit_number, unit_data in pairs(storage.units) do
		if unit.ensure_valid(unit_data, unit_number) then
			shared.update_power_usage(unit_data, unit_data.count + unit.buffer(unit_data))
		end
	end
end)
