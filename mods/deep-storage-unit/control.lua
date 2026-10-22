local shared = require "shared"
local unit = require "unit"
local variants = require "variants"
require "gui"

local update_slots = shared.update_slots

local function setup()
	storage.units = storage.units or {}
	storage.renames = storage.renames or {}
	storage.blank_gui_inventories = storage.blank_gui_inventories or {}

	if remote.interfaces["PickerDollies"] then
		for _, name in ipairs(variants.names) do
			remote.call("PickerDollies", "add_blacklist_name", name, true)
		end
		remote.call("PickerDollies", "add_blacklist_name", "memory-unit-combinator", true)
	end
end

-- Units grouped by update slot (unit numbers), rebuilt from storage only when the set of units
-- changes: the update no longer walks every unit to find the few due this tick.
local buckets
local function invalidate_buckets() buckets = nil end
local function rebuild_buckets()
	buckets = {}
	for slot = 0, update_slots - 1 do buckets[slot] = {} end
	for unit_number, unit_data in pairs(storage.units) do
		local bucket = buckets[unit_data.lag_id]
		if bucket then bucket[#bucket + 1] = unit_number end
	end
end

script.on_init(setup)

script.on_configuration_changed(function(changes)
	setup()
	invalidate_buckets()
	storage.items_with_metadata = nil -- leftover of 1.x
	storage.empty_gui_item = nil -- leaked by older versions, see cleanup below
	shared.record_migrations(changes)
	shared.cleanup_script_inventories()

	-- Render objects are rebuilt from scratch: older versions did not keep all their ids.
	rendering.clear(script.mod_name)
	for unit_number, unit_data in pairs(storage.units) do
		unit.migrate(unit_number, unit_data)
	end
end)

script.on_nth_tick(shared.update_rate, function(event)
	if not buckets then rebuild_buckets() end
	local bucket = buckets[event.tick % update_slots]
	local units = storage.units
	for i = 1, #bucket do
		local unit_number = bucket[i]
		local unit_data = units[unit_number]
		if unit_data then
			unit.update(unit_data, unit_number)
		else
			invalidate_buckets()
		end
	end
end)

local unit_filter = {}
for _, name in ipairs(variants.names) do
	unit_filter[#unit_filter + 1] = {filter = "name", name = name}
end

-- Built events also see unit ghosts (player and script placement), for the ghost cleanup below.
local build_filter = {}
for _, filter in ipairs(unit_filter) do build_filter[#build_filter + 1] = filter end
for _, name in ipairs(variants.names) do
	build_filter[#build_filter + 1] = {filter = "ghost_name", name = name}
end

-- A ghost placed from a packed unit inherits its tags. Any ghost-mediated build (robots with a plain unit,
-- blueprint, undo, super-force build) would then restore the contents while the packed item stays in the
-- inventory. Only our keys are dropped; tags of other mods stay.
local function clear_ghost_tags(ghost)
	local tags = ghost.tags
	if not (tags and (tags.name ~= nil or tags.count ~= nil)) then return end
	tags.name, tags.count, tags.quality = nil, nil, nil
	ghost.tags = next(tags) and tags or nil
end

local function on_created(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.type == "entity-ghost" then
		if variants.variants[entity.ghost_name] then clear_ghost_tags(entity) end
		return
	end
	if not variants.variants[entity.name] then return end
	if storage.units[entity.unit_number] then return end

	-- Packed unit: tags of the item used (player: consumed_items, robot/platform: stack).
	local tags = event.tags
	local inventory = event.consumed_items
	local stack = event.stack or (inventory and inventory.valid and not inventory.is_empty() and inventory[1]) or nil
	if not tags and stack and stack.valid_for_read and stack.is_item_with_tags then tags = stack.tags end
	unit.register(entity, tags)
	invalidate_buckets()
end

script.on_event(defines.events.on_built_entity, on_created, build_filter)
script.on_event(defines.events.on_robot_built_entity, on_created, unit_filter)
script.on_event(defines.events.script_raised_built, on_created, build_filter)
script.on_event(defines.events.script_raised_revive, on_created, unit_filter)
script.on_event(defines.events.on_space_platform_built_entity, on_created, unit_filter)

local clone_filter = {
	{filter = "name", name = "memory-unit-powersource"},
	{filter = "name", name = "memory-unit-combinator"}
}
for _, filter in ipairs(unit_filter) do clone_filter[#clone_filter + 1] = filter end

script.on_event(defines.events.on_entity_cloned, function(event)
	unit.on_cloned(event.source, event.destination)
	invalidate_buckets()
end, clone_filter)

-- Mined units keep their contents in a packed item; destroyed units lose everything.
local function on_removed(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local unit_number = entity.unit_number
	local unit_data = storage.units[unit_number]
	if not unit_data then return end
	unit.forget(unit_number, unit_data)
	invalidate_buckets()

	local item = unit_data.item
	local count = unit_data.count or 0
	local buffer = event.buffer
	if not (buffer and item and count > 0) then return end

	-- Only the unit item is replaced: anything else in the buffer (chest contents) stays.
	local quality = entity.quality.name
	if buffer.remove {name = entity.name, count = 1, quality = quality} == 0 then
		log("memory unit " .. unit_number .. ": mined unit item not found in the buffer")
	end
	buffer.insert {
		name = variants.packed_name(entity.name),
		count = 1,
		quality = quality,
		health = entity.health / entity.max_health,
		tags = {name = item, count = count, quality = unit_data.quality},
		custom_description = {
			"item-description.memory-unit-with-tags",
			shared.compactify(count),
			item,
			unit_data.quality or "normal"
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
	if unit_data then
		unit.forget(event.useful_id, unit_data, true)
		invalidate_buckets()
	end
end)

-- Before mining or deconstruction the chest is emptied into the counter.
local function pre_mined(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local unit_data = storage.units[entity.unit_number]
	if not unit_data then return end
	local item = unit_data.item
	if not item or unit_data.output_only then return end

	local inventory = unit_data.inventory
	local quality = unit_data.quality
	local in_inventory = inventory.get_item_count {name = item, quality = quality}
	if in_inventory > 0 then
		unit_data.count = unit_data.count + inventory.remove {name = item, count = in_inventory, quality = quality}
	end
end

script.on_event(defines.events.on_pre_player_mined_item, pre_mined, unit_filter)
script.on_event(defines.events.on_robot_pre_mined, pre_mined, unit_filter)
script.on_event(defines.events.on_marked_for_deconstruction, pre_mined, unit_filter)
script.on_event(defines.events.on_space_platform_pre_mined, pre_mined, unit_filter)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting ~= "memory-unit-power-usage" then return end
	for unit_number, unit_data in pairs(storage.units) do
		if unit.ensure_valid(unit_data, unit_number) then
			shared.update_power_usage(unit_data, unit_data.count + unit.inventory_count(unit_data))
		end
	end
end)

script.on_event(defines.events.on_player_removed, function(event)
	local inventories = storage.blank_gui_inventories
	local inventory = inventories and inventories[event.player_index]
	if inventory and inventory.valid then inventory.destroy() end
	if inventories then inventories[event.player_index] = nil end
end)
