-- Item and fluid memory units: one scheduler and one set of event handlers for both kinds.
--   storage.units        - item units (plain and logistic), see scripts/item-unit.lua
--   storage.fluid_units  - fluid units, see scripts/fluid-unit.lua

local shared = require "scripts.shared"
local item_unit = require "scripts.item-unit"
local fluid_unit = require "scripts.fluid-unit"
local variants = require "scripts.variants"
local gui = require "scripts.gui"
local takeover = require "scripts.takeover"

local update_slots = shared.update_slots

local function setup()
	storage.units = storage.units or {}
	storage.fluid_units = storage.fluid_units or {}
	storage.renames = storage.renames or {}
	storage.blank_gui_inventories = storage.blank_gui_inventories or {}
	storage.open_guis = storage.open_guis or {}

	if remote.interfaces["PickerDollies"] then
		for _, name in ipairs(item_unit.names) do
			remote.call("PickerDollies", "add_blacklist_name", name, true)
		end
		remote.call("PickerDollies", "add_blacklist_name", item_unit.combinator_name, true)
		remote.call("PickerDollies", "add_blacklist_name", fluid_unit.name, true)
		remote.call("PickerDollies", "add_blacklist_name", fluid_unit.combinator_name, true)
	end
end

-- Units grouped by update slot, both kinds in one pass. Rebuilt from storage only when the set of units
-- changes, so the update visits only the units due this tick.
local buckets
local function invalidate_buckets() buckets = nil end
local function rebuild_buckets()
	buckets = {}
	for slot = 0, update_slots - 1 do buckets[slot] = {items = {}, fluids = {}} end
	for unit_number, unit_data in pairs(storage.units) do
		local bucket = buckets[unit_data.lag_id]
		if bucket then bucket.items[#bucket.items + 1] = unit_number end
	end
	for unit_number, unit_data in pairs(storage.fluid_units) do
		local bucket = buckets[unit_data.lag_id]
		if bucket then bucket.fluids[#bucket.fluids + 1] = unit_number end
	end
end

local function update_list(list, units, kind)
	for i = 1, #list do
		local unit_number = list[i]
		local unit_data = units[unit_number]
		if unit_data then
			kind.update(unit_data, unit_number)
		else
			invalidate_buckets()
		end
	end
end

script.on_nth_tick(shared.update_rate, function(event)
	if not buckets then rebuild_buckets() end
	local bucket = buckets[event.tick % update_slots]
	update_list(bucket.items, storage.units, item_unit)
	update_list(bucket.fluids, storage.fluid_units, fluid_unit)
end)

script.on_init(setup)
script.on_load(gui.on_load)

script.on_configuration_changed(function(changes)
	setup()
	invalidate_buckets()
	shared.reset_power_multiplier()
	shared.record_migrations(changes)

	-- Render objects are rebuilt from scratch.
	rendering.clear(script.mod_name)
	for unit_number, unit_data in pairs(storage.units) do
		item_unit.migrate(unit_number, unit_data)
	end
	for unit_number, unit_data in pairs(storage.fluid_units) do
		fluid_unit.migrate(unit_number, unit_data)
	end
	takeover.run()
end)

-- Event filters.
local unit_filter = {}
for _, name in ipairs(item_unit.names) do unit_filter[#unit_filter + 1] = {filter = "name", name = name} end
unit_filter[#unit_filter + 1] = {filter = "name", name = fluid_unit.name}

-- Built events also see item unit ghosts (player and script placement), for the ghost cleanup below.
local build_filter = {}
for _, filter in ipairs(unit_filter) do build_filter[#build_filter + 1] = filter end
for _, name in ipairs(item_unit.names) do build_filter[#build_filter + 1] = {filter = "ghost_name", name = name} end

local clone_filter = {}
for _, filter in ipairs(unit_filter) do clone_filter[#clone_filter + 1] = filter end
for _, name in ipairs({item_unit.powersource_name, item_unit.combinator_name, fluid_unit.powersource_name, fluid_unit.combinator_name}) do
	clone_filter[#clone_filter + 1] = {filter = "name", name = name}
end

-- A ghost placed from a packed item unit inherits its tags. Any ghost-mediated build (robots with a plain unit,
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
	local name = entity.name
	if name == "entity-ghost" then
		if variants.variants[entity.ghost_name] then clear_ghost_tags(entity) end
		return
	end
	local kind, units
	if variants.variants[name] then
		kind, units = item_unit, storage.units
	elseif name == fluid_unit.name then
		kind, units = fluid_unit, storage.fluid_units
	else
		return
	end
	if units[entity.unit_number] then return end

	-- Packed unit: tags of the item used (player: consumed_items, robot/platform: stack).
	local tags = event.tags
	local inventory = event.consumed_items
	local stack = event.stack or (inventory and inventory.valid and not inventory.is_empty() and inventory[1]) or nil
	if not tags and stack and stack.valid_for_read and stack.is_item_with_tags then tags = stack.tags end
	kind.register(entity, tags)
	invalidate_buckets()
end

script.on_event(defines.events.on_built_entity, on_created, build_filter)
script.on_event(defines.events.on_robot_built_entity, on_created, unit_filter)
script.on_event(defines.events.script_raised_built, on_created, build_filter)
script.on_event(defines.events.script_raised_revive, on_created, unit_filter)
script.on_event(defines.events.on_space_platform_built_entity, on_created, unit_filter)

local fluid_parts = {[fluid_unit.name] = true, [fluid_unit.powersource_name] = true, [fluid_unit.combinator_name] = true}
script.on_event(defines.events.on_entity_cloned, function(event)
	local source, destination = event.source, event.destination
	if fluid_parts[source.name] then
		fluid_unit.on_cloned(source, destination)
	else
		item_unit.on_cloned(source, destination)
	end
	invalidate_buckets()
end, clone_filter)

-- The record of a unit entity and its kind; nil if it is not ours.
local function find_unit(unit_number)
	local unit_data = storage.units[unit_number]
	if unit_data then return unit_data, item_unit end
	unit_data = storage.fluid_units[unit_number]
	if unit_data then return unit_data, fluid_unit end
	return nil
end

-- Mined units keep their contents in a packed item; destroyed units lose everything.
local function on_removed(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local unit_number = entity.unit_number
	local unit_data, kind = find_unit(unit_number)
	if not unit_data then return end
	kind.forget(unit_number, unit_data)
	invalidate_buckets()
	kind.pack(unit_number, unit_data, entity, event.buffer)
end

script.on_event(defines.events.on_player_mined_entity, on_removed, unit_filter)
script.on_event(defines.events.on_robot_mined_entity, on_removed, unit_filter)
script.on_event(defines.events.on_space_platform_mined_entity, on_removed, unit_filter)
script.on_event(defines.events.on_entity_died, on_removed, unit_filter)
script.on_event(defines.events.script_raised_destroy, on_removed, unit_filter)

-- Units removed without an event (chunk or surface deletion, destroy() by a script).
script.on_event(defines.events.on_object_destroyed, function(event)
	if event.type ~= defines.target_type.entity then return end
	local unit_data, kind = find_unit(event.useful_id)
	if unit_data then
		kind.forget(event.useful_id, unit_data, true)
		invalidate_buckets()
	end
end)

-- Before mining or deconstruction the chest or tank is emptied into the counter.
local function pre_mined(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local unit_data, kind = find_unit(entity.unit_number)
	if unit_data then kind.pre_mined(unit_data) end
end

script.on_event(defines.events.on_pre_player_mined_item, pre_mined, unit_filter)
script.on_event(defines.events.on_robot_pre_mined, pre_mined, unit_filter)
script.on_event(defines.events.on_marked_for_deconstruction, pre_mined, unit_filter)
script.on_event(defines.events.on_space_platform_pre_mined, pre_mined, unit_filter)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting ~= shared.power_setting then return end
	shared.reset_power_multiplier()
	for unit_number, unit_data in pairs(storage.units) do
		if item_unit.ensure_valid(unit_data, unit_number) then
			shared.update_power_usage(unit_data, item_unit.total(unit_data))
		end
	end
	for unit_number, unit_data in pairs(storage.fluid_units) do
		if fluid_unit.ensure_valid(unit_data, unit_number) then
			shared.update_power_usage(unit_data, fluid_unit.total(unit_data))
		end
	end
end)

script.on_event(defines.events.on_player_removed, function(event)
	local inventories = storage.blank_gui_inventories
	local inventory = inventories[event.player_index]
	if inventory and inventory.valid then inventory.destroy() end
	inventories[event.player_index] = nil
	gui.on_player_removed(event)
end)

script.on_event(defines.events.on_gui_click, gui.on_gui_click)
script.on_event(defines.events.on_gui_elem_changed, gui.on_gui_elem_changed)
script.on_event(defines.events.on_gui_opened, gui.on_gui_opened)
script.on_event(defines.events.on_gui_closed, gui.on_gui_closed)
script.on_event(defines.events.on_player_changed_surface, gui.on_player_changed_surface)
