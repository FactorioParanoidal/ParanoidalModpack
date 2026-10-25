-- Paranoidal Autofill: fuel/ammo for hand-placed buildings by the player's own rules.

local compat = require("__paranoidal-autofill__/scripts/compat")
local state = require("__paranoidal-autofill__/scripts/state")
local fill = require("__paranoidal-autofill__/scripts/fill")
local gui = require("__paranoidal-autofill__/scripts/gui")

local L = "paranoidal-autofill."
local REFILL = "paranoidal-autofill-refill"

---------------------------------------------------------------------------
-- Notices

local function item_text(it)
	if it.quality and it.quality ~= "normal" then
		return "[item=" .. it.name .. ",quality=" .. it.quality .. "]"
	end
	return "[item=" .. it.name .. "]"
end

local function show_result(player, entity, moved, missing)
	local parts = {}
	for _, it in ipairs(moved) do
		parts[#parts + 1] = "+" .. it.count .. " " .. item_text(it)
	end
	if #parts > 0 then
		player.create_local_flying_text({
			text = table.concat(parts, "  "), position = entity.position, surface = entity.surface,
		})
	elseif #missing > 0 then
		local icons = {}
		for _, it in ipairs(missing) do icons[#icons + 1] = item_text(it) end
		player.create_local_flying_text({
			text = { L .. "missing", table.concat(icons, " ") }, position = entity.position,
			surface = entity.surface, color = { 1, 0.6, 0.4 },
		})
	end
end

---------------------------------------------------------------------------
-- Filling

local function source_inventory(player)
	local character = player.character
	if character and character.valid then
		return character.get_main_inventory()
	end
	return player.get_main_inventory()
end

local function enabled_rule(data, entity_name)
	local rule = state.rule_for(data, entity_name)
	if rule and rule.enabled and #rule.items > 0 then return rule end
end

-- Returns true if something was moved.
local function fill_entity(player, data, entity, quiet_missing)
	local rule = enabled_rule(data, entity.name)
	if not rule then return false end
	local source = source_inventory(player)
	if not source then return false end
	local moved, missing = fill.fill(entity, rule.items, source)
	if quiet_missing then missing = {} end
	show_result(player, entity, moved, missing)
	return #moved > 0
end

---------------------------------------------------------------------------
-- Built by hand: filled on the next tick, after other mods have handled the event
-- (some of them replace or fill buildings on build).

local on_tick

local function update_tick_handler()
	if storage.pending and next(storage.pending) then
		script.on_event(defines.events.on_tick, on_tick)
	else
		script.on_event(defines.events.on_tick, nil)
	end
end

on_tick = function()
	local pending = storage.pending
	storage.pending = {}
	for _, job in pairs(pending) do
		local player = game.get_player(job.player)
		local entity = job.entity
		if player and player.connected and entity and entity.valid then
			local data = storage.players[player.index]
			if data and data.on_build then
				fill_entity(player, data, entity, false)
			end
		end
	end
	update_tick_handler()
end

local function on_built(event)
	local entity = event.entity
	if not (entity and entity.valid and event.player_index) then return end
	local data = storage.players[event.player_index]
	if not (data and data.on_build and enabled_rule(data, entity.name)) then return end
	table.insert(storage.pending, { player = event.player_index, entity = entity })
	update_tick_handler()
end

---------------------------------------------------------------------------
-- Refill nearby (hotkey and shortcut).

local function refill(player)
	local character = player.character
	if not (character and character.valid) then
		player.create_local_flying_text({ text = { L .. "no-character" }, create_at_cursor = true })
		return
	end
	local data = state.player(player.index)
	local names = {}
	for _, rule in ipairs(data.rules) do
		if rule.enabled and #rule.items > 0 and prototypes.entity[rule.entity] then
			names[#names + 1] = rule.entity
			for _, variant in ipairs(compat.variants(rule.entity) or {}) do
				names[#names + 1] = variant
			end
		end
	end
	local any = false
	if #names > 0 then
		local found = character.surface.find_entities_filtered({
			position = character.position, radius = character.reach_distance + 2,
			name = names, force = character.force,
		})
		for _, entity in ipairs(found) do
			if entity.valid and not entity.to_be_deconstructed() and character.can_reach_entity(entity) then
				if fill_entity(player, data, entity, true) then any = true end
			end
		end
	end
	if not any then
		player.create_local_flying_text({ text = { L .. "nothing-nearby" }, create_at_cursor = true })
	end
end

---------------------------------------------------------------------------
-- Lifecycle

local function setup_player(player)
	state.player(player.index)
	gui.ensure_button(player)
end

script.on_init(function()
	state.init()
	for _, player in pairs(game.players) do setup_player(player) end
end)

script.on_configuration_changed(function()
	state.init()
	compat.reset()
	state.validate_all()
	for _, player in pairs(game.players) do
		gui.close(player)
		state.player(player.index)
		gui.recreate_button(player)
	end
	update_tick_handler()
end)

script.on_load(function()
	-- Only re-register the dynamic handler; storage is not touched here.
	if storage.pending and next(storage.pending) then
		script.on_event(defines.events.on_tick, on_tick)
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	local player = game.get_player(event.player_index)
	if player then setup_player(player) end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	local player = game.get_player(event.player_index)
	if player then gui.ensure_button(player) end
end)

script.on_event(defines.events.on_player_removed, function(event)
	storage.players[event.player_index] = nil
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "gu_button_style_setting" and event.player_index then
		local player = game.get_player(event.player_index)
		if player then gui.recreate_button(player) end
	end
end)

script.on_event(defines.events.on_built_entity, on_built)

script.on_event(REFILL, function(event)
	local player = game.get_player(event.player_index)
	if player then refill(player) end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
	if event.prototype_name ~= REFILL then return end
	local player = game.get_player(event.player_index)
	if player then refill(player) end
end)

script.on_event(defines.events.on_gui_click, gui.on_click)
script.on_event(defines.events.on_gui_elem_changed, gui.on_elem_changed)
script.on_event(defines.events.on_gui_text_changed, gui.on_text_changed)
script.on_event(defines.events.on_gui_confirmed, gui.on_confirmed)
script.on_event(defines.events.on_gui_checked_state_changed, gui.on_checked)
script.on_event(defines.events.on_gui_switch_state_changed, gui.on_switch)
script.on_event(defines.events.on_gui_closed, gui.on_closed)
