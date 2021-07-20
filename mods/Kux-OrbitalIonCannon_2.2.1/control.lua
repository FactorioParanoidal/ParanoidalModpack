if script.active_mods["gvv"] then require("__gvv__.gvv")() end
require "tools"
require "util"
-- require("__stdlib__/stdlib/core")
local Chunk = require("__stdlib__/stdlib/area/chunk")
local Position = require("__stdlib__/stdlib/area/position")
require "modules.autotargeter"
require "modules.gui"
require "modules.Permissions"

local fLog = function (functionName)
	print("control."..functionName)
end

local this = {}

_G.when_ion_cannon_targeted = nil

remote.add_interface("orbital_ion_cannon",
	{
		on_ion_cannon_targeted = function() return getIonCannonTargetedEventID() end,
		on_ion_cannon_fired = function() return getIonCannonFiredEventID() end,
		target_ion_cannon = function(force, position, surface, player) return targetIonCannon(force, position, surface, player) end -- Player is optional
	}
)

function generateEvents()
	getIonCannonTargetedEventID()
	getIonCannonFiredEventID()
end

function getIonCannonTargetedEventID()
	if not _G.when_ion_cannon_targeted then
		_G.when_ion_cannon_targeted = script.generate_event_name()
	end
	return _G.when_ion_cannon_targeted
end

function getIonCannonFiredEventID()
	if not _G.when_ion_cannon_fired then
		_G.when_ion_cannon_fired = script.generate_event_name()
	end
	return when_ion_cannon_fired
end

this.initialize = function()
	fLog("initialize")
	-- on_init, on_configuration_changed, on_force_created
	generateEvents()
	if not global.forces_ion_cannon_table then
		global.forces_ion_cannon_table = {}
		global.forces_ion_cannon_table["player"] = {}
	else
		--print("OrbitalIonCannon:OnInit")
		-- MIGRATION: add 3rd column for "surface"
		for fn,f in pairs(global.forces_ion_cannon_table) do
			--print("Update cannon force ''"..fn.."'' "..serpent.line(f))
			for i,c in ipairs(f) do
				--if not c[3] then --TODO bad argument #2 of 3 to 'index' (string expected, got number) ???
				--  c[3] = "nauvis" end
				if #c==2 then
					--"Update cannon #"..tostring(i).." surface to 'nauvis'")
					table.insert(c, "nauvis")
				end
			end
		end
	end

	global.goToFull = global.goToFull or {}
	global.markers = global.markers or {}
	global.holding_targeter = global.holding_targeter or {}
	global.klaxonTick = global.klaxonTick or 0
	global.auto_tick = global.auto_tick or 0
	global.readyTick = {}
--	if remote.interfaces["silo_script"] then
--		local tracked_items = remote.call("silo_script", "get_tracked_items") --COMPATIBILITY 1.1 get_tracked_items removed
--		if not tracked_items["orbital-ion-cannon"] then
--			remote.call("silo_script", "add_tracked_item", "orbital-ion-cannon") --COMPATIBILITY 1.1 add_tracked_item removed
--		end
--	end
	if not global.permissions then Permissions.initialize() end
	for _, player in pairs(game.players) do
		global.readyTick[player.index] = 0
		global.forces_ion_cannon_table[player.force.name] = global.forces_ion_cannon_table[player.force.name] or {}
		if global.goToFull[player.index] == nil then
			global.goToFull[player.index] = true
		end
		if player.gui.top["ion-cannon-button"] then
			player.gui.top["ion-cannon-button"].destroy()
		end
		if player.gui.top["ion-cannon-stats"] then
			player.gui.top["ion-cannon-stats"].destroy()
		end
	end
	for i, force in pairs(game.forces) do
		force.reset_recipes()
		if global.forces_ion_cannon_table[force.name] and #global.forces_ion_cannon_table[force.name] > 0 then
			global.IonCannonLaunched = true
			script.on_nth_tick(60, process_60_ticks)
		end
	end
	global.forces_ion_cannon_table["Queue"] = global.forces_ion_cannon_table["Queue"] or {}
end

this.onLoad = function()
	fLog("onLoad")
	generateEvents()
	if global.IonCannonLaunched then
		script.on_nth_tick(60, process_60_ticks)
	end
end

script.on_event(defines.events.on_force_created, function(event)
	if not global.forces_ion_cannon_table then
		this.initialize()
	end
	global.forces_ion_cannon_table[event.force.name] = {}
end)

script.on_event(defines.events.on_forces_merging, function(event)
	fLog("on_forces_merging")
	global.forces_ion_cannon_table[event.source.name] = nil
	-- for i, player in pairs(game.players) do
		-- init_GUI(player)
	-- end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.player_index then
		--[[ why we should open the GUI always? KUX MODIFICATION
		local player = game.players[event.player_index]
		if global.IonCannonLaunched or player.cheat_mode or player.admin then
			open_GUI(player)
		end
	]]--
	end
end)

script.on_event("ion-cannon-hotkey", function(event)
	local player = game.players[event.player_index]
	if global.IonCannonLaunched or player.cheat_mode or player.admin then
		open_GUI(player)
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	fLog("on_player_created")
	init_GUI(game.players[event.player_index])
	global.readyTick[event.player_index] = 0
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
	local player = game.players[event.player_index]
	if isHolding({name = "ion-cannon-targeter", count = 1}, player) then
		if player.character then
			if not Permissions.hasPermission(player.index) then
				player.print({"ion-permission-denied"})
				playSoundForPlayer("unable-to-comply", player)
				if Version.baseVersionGreaterOrEqual1d1() then
					player.clear_cursor() --COMPATIBILITY 1.1
				else
					player.clean_cursor() --Factorio < 1.1
				end
			end
		end
		if (player.cheat_mode or (#global.forces_ion_cannon_table[player.force.name] > 0 and not isAllIonCannonOnCooldown(player))) and not global.holding_targeter[index] then
			playSoundForPlayer("select-target", player)
		end
	else
		global.holding_targeter[player.index] = false
	end
end)

function process_60_ticks(NthTickEvent)
	local current_tick = NthTickEvent.tick
	for i = #global.markers, 1, -1 do -- Loop over table backwards because some entries get removed within the loop
		local marker = global.markers[i]
		if marker[2] <= current_tick then
			if marker[1] and marker[1].valid then
				marker[1].destroy()
			end
			table.remove(global.markers, i)
		end
	end
	ReduceIonCannonCooldowns()
	for i, force in pairs(game.forces) do
		if global.forces_ion_cannon_table[force.name] and isIonCannonReady(force) then
			for i, player in pairs(force.connected_players) do
				if global.readyTick[player.index] < current_tick then
					global.readyTick[player.index] = current_tick + settings.get_player_settings(player)["ion-cannon-ready-ticks"].value
					playSoundForPlayer("ion-cannon-ready", player)
				end
			end
		end
	end
	for i, player in pairs(game.connected_players) do
		update_GUI(player)
	end
end

function ReduceIonCannonCooldowns()
	for _, force in pairs(game.forces) do
		if global.forces_ion_cannon_table[force.name] then
			for k, cooldown in pairs(global.forces_ion_cannon_table[force.name]) do
				if cooldown[1] > 0 then
					global.forces_ion_cannon_table[force.name][k][1] = global.forces_ion_cannon_table[force.name][k][1] - 1
				end
			end
		end
	end
end

function isAllIonCannonOnCooldown(player)
	for i, cooldown in pairs(global.forces_ion_cannon_table[player.force.name]) do
		if cooldown[2] == 1 then
			return false
		end
	end
	return true
end

function isIonCannonReady(force)
	local found = false
	for i, cooldown in pairs(global.forces_ion_cannon_table[force.name]) do
		if cooldown[1] == 0 and cooldown[2] == 0 then
			cooldown[2] = 1
			found = true
		end
	end
	return found
end

function playSoundForPlayer(sound, player)
	if settings.get_player_settings(player)["ion-cannon-play-voices"].value then
		local voice = settings.get_player_settings(player)["ion-cannon-voice-style"].value
		player.play_sound({path = sound .. "-" .. voice})
	end
end

function isHolding(stack, player)
	local holding = player.cursor_stack
	if holding and holding.valid_for_read and holding.name == stack.name and holding.count >= stack.count then
		return true
	end
	return false
end

function targetIonCannon(force, position, surface, player)
	local cannonNum = 0
	local targeterName = "Auto"

	for i, cooldown in pairs(global.forces_ion_cannon_table[force.name]) do
		if cooldown[2] == 1 and cooldown[3] == surface.name then
			cannonNum = i
			break
		end
	end

	if player then
		targeterName = player.name
		if player.cheat_mode == true then
			cannonNum = "Cheat"
			script.on_nth_tick(60, process_60_ticks)
		end
	end
	if cannonNum == 0 then
		if player then
			player.print({"unable-to-fire"})
			playSoundForPlayer("unable-to-comply", player)
		end
		return false
	else
		local current_tick = game.tick
		local TargetPosition = position
		TargetPosition.y = TargetPosition.y + 1
		local IonTarget = surface.create_entity({name = "ion-cannon-target", position = TargetPosition, force = game.forces.neutral})
		local marker = force.add_chart_tag(surface, {icon = {type = "item", name = "ion-cannon-targeter"}, text = "Ion cannon #" .. cannonNum .. " target location (" .. targeterName .. ")", position = TargetPosition})
		table.insert(global.markers, {marker, current_tick + settings.global["ion-cannon-chart-tag-duration"].value})
		local CrosshairsPosition = position
		CrosshairsPosition.y = CrosshairsPosition.y - 20
		surface.create_entity({name = "crosshairs", target = IonTarget, force = force, position = CrosshairsPosition, speed = 0})
		for i, player in pairs(game.connected_players) do
			if settings.get_player_settings(player)["ion-cannon-play-klaxon"].value and global.klaxonTick < current_tick then
				global.klaxonTick = current_tick + 60
				player.play_sound({path = "ion-cannon-klaxon"})
			end
		end
		if not player or not player.cheat_mode then
			global.forces_ion_cannon_table[force.name][cannonNum][1] = settings.global["ion-cannon-cooldown-seconds"].value
			global.forces_ion_cannon_table[force.name][cannonNum][2] = 0
		end
		if player then
			player.print({"targeting-ion-cannon" , cannonNum})
			for i, p in pairs(player.force.connected_players) do
				if settings.get_player_settings(p)["ion-cannon-custom-alerts"].value then
					p.add_custom_alert(IonTarget, {type = "item", name = "orbital-ion-cannon"}, {"ion-cannon-target-location", cannonNum, TargetPosition.x, TargetPosition.y, targeterName}, true)
				end
			end
			script.raise_event(_G.when_ion_cannon_targeted, {surface = surface, force = force, position = position, radius = settings.startup["ion-cannon-radius"].value, player_index = player.index,})		-- Passes event.surface, event.force, event.position, event.radius, and event.player_index
		else
			script.raise_event(_G.when_ion_cannon_targeted, {surface = surface, force = force, position = position, radius = settings.startup["ion-cannon-radius"].value})		-- Passes event.surface, event.force, event.position, and event.radius
		end
		return cannonNum
	end
end

--- Called when the rocket is launched.
-- rocket :: LuaEntity
-- rocket_silo :: LuaEntity (optional)
-- player_index :: uint (optional): The player that is riding the rocket, if any.
script.on_event(defines.events.on_rocket_launched, function(event)
	local force = event.rocket.force
	local surfaceName = event.rocket_silo.surface.name
	local suffix=" Orbit"
	if surfaceName == "Nauvis Orbit" then
		surfaceName = "nauvis"
	elseif #surfaceName > #suffix and string.sub(surfaceName, -#suffix) == suffix then
		local sn = string.sub(surfaceName, 1, #surfaceName-#suffix)
		--if game.surfaces[surfaceName] then surfaceName = sn end
		surfaceName = sn
	end
	if event.rocket.get_item_count("orbital-ion-cannon") > 0 then
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0, surfaceName})
		global.IonCannonLaunched = true
		script.on_nth_tick(60, process_60_ticks)
		for i, player in pairs(force.connected_players) do
			init_GUI(player)
			playSoundForPlayer("ion-cannon-charging", player)
		end
		if #global.forces_ion_cannon_table[force.name] == 1 then
			force.print({"congratulations-first"})
			force.print({"first-help"})
			force.print({"second-help"})
			force.print({"third-help"})
		else
			force.print({"congratulations-additional"})
			force.print({"ion-cannons-in-orbit" , #global.forces_ion_cannon_table[force.name]})
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local entity = event.created_entity
	if entity.name == "ion-cannon-targeter" then
		local player = game.players[event.player_index]
		player.cursor_stack.set_stack({name = "ion-cannon-targeter", count = 1})
		return entity.destroy()
	end
	if entity.name == "entity-ghost" then
		if entity.ghost_name == "ion-cannon-targeter" then
			return entity.destroy()
		end
	end
end)

script.on_event(defines.events.on_trigger_created_entity, function(event)
	local created_entity = event.entity
	if created_entity.name == "ion-cannon-explosion" then
		script.raise_event(when_ion_cannon_fired, {surface = created_entity.surface, position = created_entity.position, radius = settings.startup["ion-cannon-radius"].value})		-- Passes event.surface, event.position, and event.radius
		for i, force in pairs(game.forces) do
			force.chart(created_entity.surface, Position.expand_to_area(created_entity.position, 1))
		end
	end
end)

local c_on_pre_build = defines.events.on_pre_build --COMPATIBILITY 1.1 'on_put_item' renamed to 'on_pre_build'
if not c_on_pre_build then c_on_pre_build = defines.events.on_put_item end

script.on_event(c_on_pre_build, function(event)
	local current_tick = event.tick
	if global.tick and global.tick > current_tick then
		return
	end
	global.tick = current_tick + 10
	local player = game.players[event.player_index]
	if isHolding({name = "ion-cannon-targeter", count = 1}, player) and player.force.is_chunk_charted(player.surface, Chunk.from_position(event.position)) then
		targetIonCannon(player.force, event.position, player.surface, player)
		player.cursor_stack.clear()
		global.holding_targeter[event.player_index] = true
		player.cursor_stack.set_stack({name = "ion-cannon-targeter", count = 1})
	end
end)

ModGui.initEvents()

local allowed_items = {"ion-cannon-targeter"}

local function give_shortcut_item(player, prototype_name)
	if game.item_prototypes[prototype_name] then
		local cc = false
		if Version.baseVersionGreaterOrEqual1d1() then
			cc = player.clear_cursor() --COMPATIBILITY 1.1
		else
			cc = player.clean_cursor() --Factorio < 1.1
		end

		player.cursor_stack.set_stack({name = prototype_name})
	end
end

script.on_event(defines.events.on_lua_shortcut, function(event)
	local prototype_name = event.prototype_name
	local player = game.players[event.player_index]
	if game.shortcut_prototypes[prototype_name] then
		for _, item_name in pairs(allowed_items) do
			if item_name == prototype_name then
				give_shortcut_item(player, prototype_name)
			end
		end
	end
end)

script.on_init(this.initialize)
script.on_configuration_changed(this.initialize)
script.on_load(this.onLoad)
