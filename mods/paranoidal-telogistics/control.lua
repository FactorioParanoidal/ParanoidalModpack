-- Cargo teleporters (Space Age branch of Paranoidal). Rewritten from scratch after Telogistics by S6X (GPLv3): the
-- teleporter never swaps entities; a hidden charger under it holds one send of energy, senders are checked every 10
-- ticks, cargo moves stack by stack to every receiver of the channel on the target planet.
local tiers = require("shared.tiers")
local registry = require("scripts.registry")
local transfer = require("scripts.transfer")
local gui = require("scripts.gui")

local TAG = "ptl"

---------------------------------------------------------------------------------------------- lifecycle
local function full_rescan()
	registry.rescan()
	for _, rec in pairs(storage.units) do
		if rec.mode == "send" then transfer.process(rec) else transfer.passive_status(rec) end
	end
	for _, player in pairs(game.players) do gui.close(player) end
	-- The planet counter of the first test version (tiers by visited planets) is gone.
	storage.explored = nil
end

script.on_init(full_rescan)
script.on_configuration_changed(full_rescan)

---------------------------------------------------------------------------------------------- building
local function built(entity, tags)
	if not (entity and entity.valid and registry.is_teleporter(entity.name)) then return end
	local pos_key = registry.position_key(entity.surface.index, entity.position)
	-- Fast replace / upgrade: the teleporter that stood here this tick passes on its settings and charge.
	local carry = registry.take_pending(pos_key)
	local old_unit = storage.positions[pos_key]
	if not carry and old_unit and old_unit ~= entity.unit_number then
		local old = storage.units[old_unit]
		if old and not (old.entity and old.entity.valid) then
			registry.stash(old)
			carry = registry.take_pending(pos_key)
		end
	end
	if old_unit and old_unit ~= entity.unit_number then registry.remove(old_unit) end
	local settings = tags and tags[TAG] or (carry and carry.settings) or nil
	local rec = registry.add(entity, settings, carry)
	if rec.mode == "send" then transfer.process(rec) else transfer.passive_status(rec) end
end

local filters = {}
for _, name in ipairs(tiers.names) do filters[#filters + 1] = {filter = "name", name = name} end

script.on_event(defines.events.on_built_entity, function(e) built(e.entity, e.tags) end, filters)
script.on_event(defines.events.on_robot_built_entity, function(e) built(e.entity, e.tags) end, filters)
script.on_event(defines.events.on_space_platform_built_entity, function(e) built(e.entity, e.tags) end, filters)
script.on_event(defines.events.script_raised_built, function(e) built(e.entity) end, filters)
script.on_event(defines.events.script_raised_revive, function(e) built(e.entity, e.tags) end, filters)
script.on_event(defines.events.on_entity_cloned, function(e)
	local source = e.source and e.source.valid and storage.units[e.source.unit_number]
	built(e.destination, source and {[TAG] = registry.settings_of(source)} or nil)
end, filters)

---------------------------------------------------------------------------------------------- removal
local function removing(entity)
	if not (entity and entity.valid and entity.unit_number) then return end
	local rec = storage.units[entity.unit_number]
	if not rec then return end
	registry.stash(rec)
	registry.remove(entity.unit_number)
	gui.refresh_unit(entity.unit_number)
end

for _, event in ipairs({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity,
	defines.events.on_space_platform_mined_entity, defines.events.on_entity_died, defines.events.script_raised_destroy}) do
	script.on_event(event, function(e) removing(e.entity) end, filters)
end

-- Destroyed without an event (another mod's destroy(), a deleted chunk or surface): the charger goes too.
script.on_event(defines.events.on_object_destroyed, function(e)
	if e.type ~= defines.target_type.entity then return end
	if storage.units[e.useful_id] then
		local rec = storage.units[e.useful_id]
		if not (rec.entity and rec.entity.valid) then registry.remove(e.useful_id) end
	end
end)

-- A ghost left by a destroyed teleporter keeps its settings for the rebuild.
script.on_event(defines.events.on_post_entity_died, function(e)
	local ghost = e.ghost
	if not (ghost and ghost.valid and registry.is_teleporter(e.prototype.name)) then return end
	local pending = storage.pending[registry.position_key(e.surface_index, ghost.position)]
	if pending and pending.tick == game.tick then
		local tags = ghost.tags or {}
		tags[TAG] = pending.settings
		ghost.tags = tags
	end
end, {{filter = "type", type = "container"}})

script.on_event(defines.events.on_surface_deleted, function() registry.validate() end)
script.on_event(defines.events.on_forces_merged, function() registry.validate() end)

---------------------------------------------------------------------------------------------- copy, blueprints
script.on_event(defines.events.on_entity_settings_pasted, function(e)
	local source, destination = e.source, e.destination
	if not (source and source.valid and destination and destination.valid) then return end
	if not (registry.is_teleporter(source.name) and registry.is_teleporter(destination.name)) then return end
	local from = registry.get(source.unit_number)
	local to = registry.get(destination.unit_number) or registry.add(destination)
	if not from then return end
	registry.apply_settings(to, registry.settings_of(from))
	if to.mode == "send" then transfer.process(to) else transfer.passive_status(to) end
	gui.refresh_unit(to.unit)
end)

local function blueprint_of(e, player)
	for _, candidate in ipairs({e.stack, e.record, player.blueprint_to_setup, player.cursor_stack}) do
		if candidate and candidate.valid then
			local ok, usable = pcall(function()
				if candidate.object_name == "LuaItemStack" then
					return candidate.valid_for_read and candidate.is_blueprint and candidate.get_blueprint_entity_count() > 0
				end
				return candidate.type == "blueprint" and candidate.get_blueprint_entity_count() > 0
			end)
			if ok and usable then return candidate end
		end
	end
end

script.on_event(defines.events.on_player_setup_blueprint, function(e)
	local player = game.get_player(e.player_index)
	if not player then return end
	local mapping = e.mapping and e.mapping.valid and e.mapping.get() or nil
	if not mapping then return end
	local blueprint
	for index, entity in pairs(mapping) do
		if entity.valid and registry.is_teleporter(entity.name) then
			local rec = registry.get(entity.unit_number)
			blueprint = blueprint or blueprint_of(e, player)
			if not blueprint then return end
			if rec then blueprint.set_blueprint_entity_tag(index, TAG, registry.settings_of(rec)) end
		end
	end
end)

---------------------------------------------------------------------------------------------- GUI
script.on_event(defines.events.on_gui_opened, function(e)
	local player = game.get_player(e.player_index)
	if not player then return end
	local entity = e.entity
	if entity and entity.valid and registry.is_teleporter(entity.name) then
		gui.open(player, entity)
	elseif storage.players[e.player_index] then
		gui.close(player)
	end
end)
script.on_event(defines.events.on_gui_closed, function(e)
	local entity = e.entity
	if entity and entity.valid and registry.is_teleporter(entity.name) then
		local player = game.get_player(e.player_index)
		if player then gui.close(player) end
	end
end)
script.on_event(defines.events.on_gui_selection_state_changed, gui.on_gui_event)
script.on_event(defines.events.on_gui_elem_changed, gui.on_gui_event)
script.on_event(defines.events.on_gui_text_changed, gui.on_gui_event)
script.on_event(defines.events.on_player_removed, function(e) storage.players[e.player_index] = nil end)

---------------------------------------------------------------------------------------------- timers
script.on_nth_tick(10, function()
	transfer.tick()
	registry.purge_pending()
end)
script.on_nth_tick(15, gui.refresh_all)

---------------------------------------------------------------------------------------------- remote (tests)
local function copy_record(rec)
	if not rec then return nil end
	local charger = rec.charger
	return {unit = rec.unit, name = rec.entity.name, settings = registry.settings_of(rec), sent = rec.sent,
		received = rec.received, last_moved = rec.last_moved, status = rec.status_key, status_label = rec.status_label,
		charger_valid = charger ~= nil and charger.valid, energy = charger and charger.valid and charger.energy or 0,
		buffer = charger and charger.valid and charger.electric_buffer_size or 0, rkey = rec.rkey,
		usage = charger and charger.valid and charger.power_usage or 0, powered = registry.powered(rec),
		sender = storage.senders[rec.unit] == true}
end

remote.add_interface("paranoidal-telogistics", {
	get = function(unit) return copy_record(registry.get(unit)) end,
	configure = function(unit, settings)
		local rec = registry.get(unit)
		if not rec then return false end
		registry.apply_settings(rec, settings)
		if rec.mode == "send" then transfer.process(rec) else transfer.passive_status(rec) end
		gui.refresh_unit(unit)
		return true
	end,
	process = function() transfer.tick() end,
	rescan = function() full_rescan() end,
	count = function() return table_size(storage.units) end,
	tags_of = function(unit)
		local rec = registry.get(unit)
		return rec and registry.settings_of(rec) or nil
	end,
	gui_apply = function(player_index, field, value) return gui.apply(game.get_player(player_index), field, value) end,
	gui_state = function(player_index) return gui.describe(game.get_player(player_index)) end,
})
