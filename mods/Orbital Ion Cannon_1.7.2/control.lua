require "util"
-- require("__stdlib__/stdlib/core")
local Chunk = require("__stdlib__/stdlib/area/chunk")
local Position = require("__stdlib__/stdlib/area/position")
require "autotargeter"

script.on_init(function() On_Init() end)
script.on_configuration_changed(function() On_Init() end)
script.on_load(function() On_Load() end)

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
	if not when_ion_cannon_targeted then
		when_ion_cannon_targeted = script.generate_event_name()
	end
	return when_ion_cannon_targeted
end

function getIonCannonFiredEventID()
	if not when_ion_cannon_fired then
		when_ion_cannon_fired = script.generate_event_name()
	end
	return when_ion_cannon_fired
end

function On_Init()
	generateEvents()
	if not global.forces_ion_cannon_table then
		global.forces_ion_cannon_table = {}
		global.forces_ion_cannon_table["player"] = {}
	end
	global.goToFull = global.goToFull or {}
	global.markers = global.markers or {}
	global.holding_targeter = global.holding_targeter or {}
	global.klaxonTick = global.klaxonTick or 0
	global.auto_tick = global.auto_tick or 0
	global.readyTick = {}
	if remote.interfaces["silo_script"] then
		local tracked_items = remote.call("silo_script", "get_tracked_items")
		if not tracked_items["orbital-ion-cannon"] then
			remote.call("silo_script", "add_tracked_item", "orbital-ion-cannon")
		end
	end
	if not global.permissions then
		global.permissions = {}
		global.permissions[-2] = settings.global["ion-cannon-auto-targeting"].value
		global.permissions[-1] = false
		global.permissions[0] = false
	end
	for i, player in pairs(game.players) do
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
		global.permissions[player.index] = player.admin
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

function On_Load()
	generateEvents()
	if global.IonCannonLaunched then
		script.on_nth_tick(60, process_60_ticks)
	end
end

script.on_event(defines.events.on_force_created, function(event)
	if not global.forces_ion_cannon_table then
		On_Init()
	end
	global.forces_ion_cannon_table[event.force.name] = {}
end)

script.on_event(defines.events.on_forces_merging, function(event)
	global.forces_ion_cannon_table[event.source.name] = nil
	-- for i, player in pairs(game.players) do
		-- init_GUI(player)
	-- end
end)

function init_GUI(player)
	if #global.forces_ion_cannon_table[player.force.name] == 0 and not player.cheat_mode then
		local frame = player.gui.left["ion-cannon-stats"]
		if frame then
			frame.destroy()
		end
		if player.gui.top["ion-cannon-button"] then
			player.gui.top["ion-cannon-button"].destroy()
		end
		return
	end
	if not player.gui.top["ion-cannon-button"] then
		player.gui.top.add{type = "button", name = "ion-cannon-button", style = "ion-cannon-button-style"}
	end
end

function open_GUI(player)
	local frame = player.gui.left["ion-cannon-stats"]
	local force = player.force
	local forceName = force.name
	local player_index = player.index
	if frame and global.goToFull[player_index] then
		frame.destroy()
	else
		if global.goToFull[player_index] and #global.forces_ion_cannon_table[forceName] < 40 then
			global.goToFull[player_index] = false
			if frame then
				frame.destroy()
			end
			frame = player.gui.left.add{type = "frame", name = "ion-cannon-stats", direction = "vertical"}
			frame.add{type = "label", caption = {"ion-cannon-details-full"}}
			frame.add{type = "table", column_count = 2, name = "ion-cannon-table"}
			for i = 1, #global.forces_ion_cannon_table[forceName] do
				frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannon-num", i}}
				if global.forces_ion_cannon_table[forceName][i][2] == 1 then
					frame["ion-cannon-table"].add{type = "label", caption = {"ready"}}
				else
					frame["ion-cannon-table"].add{type = "label", caption = {"cooldown", global.forces_ion_cannon_table[forceName][i][1]}}
				end
			end
		else
			global.goToFull[player_index] = true
			if frame then
				frame.destroy()
			end
			frame = player.gui.left.add{type = "frame", name = "ion-cannon-stats", direction = "vertical"}
			frame.add{type = "label", caption = {"ion-cannon-details-compact"}}
			if player.admin then
				frame.add{type = "table", column_count = 2, name = "ion-cannon-admin-panel-header"}
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-admin-panel-show"}}
				frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = global.permissions[-1], name = "show"}
				-- frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-menu-show"}}
				if global.permissions[-2] == nil then global.permissions[-2] = settings.global["ion-cannon-auto-targeting"].value end
				-- frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = global.permissions[-2], name = "cheats"}
				if frame["ion-cannon-admin-panel-header"]["show"].state then
					frame.add{type = "table", column_count = 2, name = "ion-cannon-admin-panel-table"}
					frame["ion-cannon-admin-panel-table"].add{type = "label", caption = {"player-names"}}
					frame["ion-cannon-admin-panel-table"].add{type = "label", caption = {"allowed"}}
					frame["ion-cannon-admin-panel-table"].add{type = "label", caption = {"toggle-all"}}
					frame["ion-cannon-admin-panel-table"].add{type = "checkbox", state = global.permissions[0], name = "0"}
					for i, player in pairs(game.players) do
						frame["ion-cannon-admin-panel-table"].add{type = "label", caption = player.name}
						frame["ion-cannon-admin-panel-table"].add{type = "checkbox", state = global.permissions[player.index], name = player.index .. ""}
					end
				end
				-- if frame["ion-cannon-admin-panel-header"]["cheats"].state then
				if settings.global["ion-cannon-cheat-menu"].value then
					frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-one"}}
					frame["ion-cannon-admin-panel-header"].add{type = "button", name = "add-ion-cannon", style = "ion-cannon-button-style"}
					frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-cheat-five"}}
					frame["ion-cannon-admin-panel-header"].add{type = "button", name = "add-five-ion-cannon", style = "ion-cannon-button-style"}
					frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"ion-cannon-remove-one"}}
					frame["ion-cannon-admin-panel-header"].add{type = "button", name = "remove-ion-cannon", style = "ion-cannon-remove-button-style"}
				end
				frame["ion-cannon-admin-panel-header"].add{type = "label", caption = {"mod-setting-name.ion-cannon-auto-targeting"}}
				frame["ion-cannon-admin-panel-header"].add{type = "checkbox", state = global.permissions[-2], name = "ion-cannon-auto-target-enabled"}
			end
			frame.add{type = "table", column_count = 1, name = "ion-cannon-table"}
			frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-in-orbit", #global.forces_ion_cannon_table[forceName]}}
			frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-ready", countIonCannonsReady(force)}}
			if countIonCannonsReady(force) < #global.forces_ion_cannon_table[forceName] then
				frame["ion-cannon-table"].add{type = "label", caption = {"time-until-next-ready", timeUntilNextReady(force)}}
			end
		end
	end
end

function update_GUI(player)
	init_GUI(player)
	local frame = player.gui.left["ion-cannon-stats"]
	if frame then
		local force = player.force
		local forceName = force.name
		local player_index = player.index
		if frame["ion-cannon-table"] and not global.goToFull[player_index] then
			frame["ion-cannon-table"].destroy()
			frame.add{type = "table", column_count = 2, name = "ion-cannon-table"}
			for i = 1, #global.forces_ion_cannon_table[forceName] do
				frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannon-num", i}}
				if global.forces_ion_cannon_table[forceName][i][2] == 1 then
					frame["ion-cannon-table"].add{type = "label", caption = {"ready"}}
				else
					frame["ion-cannon-table"].add{type = "label", caption = {"cooldown", global.forces_ion_cannon_table[forceName][i][1]}}
				end
			end
		end
		if frame["ion-cannon-table"] and global.goToFull[player_index] then
			frame["ion-cannon-table"].destroy()
			frame.add{type = "table", column_count = 1, name = "ion-cannon-table"}
			frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-in-orbit", #global.forces_ion_cannon_table[forceName]}}
			frame["ion-cannon-table"].add{type = "label", caption = {"ion-cannons-ready", countIonCannonsReady(force)}}
			if countIonCannonsReady(force) < #global.forces_ion_cannon_table[forceName] then
				frame["ion-cannon-table"].add{type = "label", caption = {"time-until-next-ready", timeUntilNextReady(force)}}
			end
		end
	end
end

function countIonCannonsReady(force)
	local ionCannonsReady = 0
	if global.forces_ion_cannon_table[force.name] then
		for i, cooldown in pairs(global.forces_ion_cannon_table[force.name]) do
			if cooldown[2] == 1 then
				ionCannonsReady = ionCannonsReady + 1
			end
		end
	end
	return ionCannonsReady
end

function timeUntilNextReady(force)
	local shortestCooldown = settings.global["ion-cannon-cooldown-seconds"].value
	for i, cooldown in pairs(global.forces_ion_cannon_table[force.name]) do
		if cooldown[1] < shortestCooldown and cooldown[2] == 0 then
			shortestCooldown = cooldown[1]
		end
	end
	return shortestCooldown
end

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.element.player_index]
	local force = player.force
	local name = event.element.name
	if name == "ion-cannon-button" then
		open_GUI(player)
		return
	elseif name == "add-ion-cannon" then
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
		global.IonCannonLaunched = true
		script.on_nth_tick(60, process_60_ticks)
		for i, player in pairs(force.connected_players) do
			init_GUI(player)
			playSoundForPlayer("ion-cannon-charging", player)
		end
		force.print({"ion-cannons-in-orbit" , #global.forces_ion_cannon_table[force.name]})
		return
	elseif name == "add-five-ion-cannon" then
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
		global.IonCannonLaunched = true
		script.on_nth_tick(60, process_60_ticks)
		for i, player in pairs(force.connected_players) do
			init_GUI(player)
			playSoundForPlayer("ion-cannon-charging", player)
		end
		force.print({"ion-cannons-in-orbit" , #global.forces_ion_cannon_table[force.name]})
		return
	elseif name == "remove-ion-cannon" then
		if #global.forces_ion_cannon_table[force.name] > 0 then
			table.remove(global.forces_ion_cannon_table[force.name])
			for i, player in pairs(force.connected_players) do
				update_GUI(player)
			end
			force.print({"ion-cannon-removed"})
		else
			player.print({"no-ion-cannons"})
		end
		return
	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	local player = game.players[event.player_index]
	if global.IonCannonLaunched or player.cheat_mode or player.admin then
		open_GUI(player)
	end
end)

script.on_event("ion-cannon-hotkey", function(event)
	local player = game.players[event.player_index]
	if global.IonCannonLaunched or player.cheat_mode or player.admin then
		open_GUI(player)
	end
end)

script.on_event(defines.events.on_player_created, function(event)
	init_GUI(game.players[event.player_index])
	global.readyTick[event.player_index] = 0
	local player = game.players[event.player_index]
	if not global.permissions then
		global.permissions = {}
		global.permissions[0] = false
		global.permissions[event.player_index] = player.admin
	else
		global.permissions[event.player_index] = player.admin or global.permissions[0]
	end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
	if not global.permissions then
		global.permissions = {}
		global.permissions[0] = false
		for i, p in pairs(game.players) do
			global.permissions[p.index] = player.admin
		end
	end
	local index = event.player_index
	local player = game.players[index]
	if isHolding({name = "ion-cannon-targeter", count = 1}, player) then
		if player.character then
			if not global.permissions[index] then
				player.print({"ion-permission-denied"})
				playSoundForPlayer("unable-to-comply", player)
				return player.cursor_stack.clear()
			end
		end
		if (player.cheat_mode or (#global.forces_ion_cannon_table[player.force.name] > 0 and not isAllIonCannonOnCooldown(player))) and not global.holding_targeter[index] then
			playSoundForPlayer("select-target", player)
		end
	else
		global.holding_targeter[index] = false
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
	for i, force in pairs(game.forces) do
		local name = force.name
		if global.forces_ion_cannon_table[name] then
			for i, cooldown in pairs(global.forces_ion_cannon_table[name]) do
				if cooldown[1] > 0 then
					global.forces_ion_cannon_table[name][i][1] = global.forces_ion_cannon_table[name][i][1] - 1
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
		if cooldown[2] == 1 then
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
			script.raise_event(when_ion_cannon_targeted, {surface = surface, force = force, position = position, radius = settings.startup["ion-cannon-radius"].value, player_index = player.index,})		-- Passes event.surface, event.force, event.position, event.radius, and event.player_index
		else
			script.raise_event(when_ion_cannon_targeted, {surface = surface, force = force, position = position, radius = settings.startup["ion-cannon-radius"].value})		-- Passes event.surface, event.force, event.position, and event.radius
		end
		return cannonNum
	end
end

script.on_event(defines.events.on_rocket_launched, function(event)
	local force = event.rocket.force
	if event.rocket.get_item_count("orbital-ion-cannon") > 0 then
		table.insert(global.forces_ion_cannon_table[force.name], {settings.global["ion-cannon-cooldown-seconds"].value, 0})
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

script.on_event(defines.events.on_put_item, function(event)
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

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
	local checkbox = event.element
	if checkbox.name == "show" then
		global.goToFull[event.player_index] = false
		global.permissions[-1] = checkbox.state
		open_GUI(game.players[event.player_index])
	elseif checkbox.name == "ion-cannon-auto-target-enabled" then
		global.goToFull[event.player_index] = false
		global.permissions[-2] = checkbox.state
		open_GUI(game.players[event.player_index])
	else
		local index = tonumber(checkbox.name)
		if checkbox.parent.name == "ion-cannon-admin-panel-table" then
			global.permissions[index] = checkbox.state
			if index == 0 then
				for i = 1, #game.players do
					global.permissions[i] = global.permissions[0]
				end
				global.goToFull[event.player_index] = false
				open_GUI(game.players[event.player_index])
			end
		end
	end
end)
