require "util"

global.spawns = {}

function ui(player)
	if player.gui.top.spawn == nil then
		player.gui.top.add{name = "spawn", type = "button", caption = "Set Spawn", style="spc_fentus_button"}
	end
	if (settings.global["random-spawn"].value) then
		if player.gui.top.random == nil then
			player.gui.top.add{name = "random", type = "button", caption = "Rand.spawn", description = "this will kill you!", style="spc_fentus_button"}
		end
	else --we are suposed to not have random spawn
		if player.gui.top.random ~= nil then --but we have it
			player.gui.top.random.destroy()
		end
	end
	if (settings.global["unstuck-button"].value) then
		if player.gui.top.unstuck == nil then
			player.gui.top.add{name = "unstuck", type = "button", caption = "I'm stuck", description = "this will find non-stuck place close to you", style="spc_fentus_button"}
		end
	else
		if player.gui.top.unstuck ~= nil then
			player.gui.top.unstuck.destroy()
		end
	end
end

function ui_all()
	for playerIndex, player in pairs(game.players) do
		ui(player)
	end
end

script.on_configuration_changed(function(_)
    ui_all()
end)

function safe_location( obj_name,surf,position )
	local close_lookup = 3;
	local pos = surf.find_non_colliding_position(obj_name, position, close_lookup , 0.1, true); --first - small radius and high accuracy
	if (pos==nil) then
		local lookup_radius = 1000;
		pos = surf.find_non_colliding_position(obj_name, position, lookup_radius, 1); --later big radius and less accuracy.
	end
	return pos;
end

function safe_location_for_player(player)
    if (player.character == nil) then
        player.print("you don't control any character")
		return nil
	end
    local position = player.character.position
    local surf = player.character.surface
	return safe_location( player.character.name,surf,position )
end

function set_spawn(player,pos)
end

function on_gui_click( event )
    local player = game.players[event.player_index]
	if event.element.name == "unstuck" then
        local pos = safe_location_for_player(player)
        if (pos==nil) then
        	player.print("could not unstuck character")
        	return
        end
		player.teleport(pos)
	end
	if event.element.name == "random" then

		if (global.spawns[player.name]~=nil) then
			local nextChangeTick = global.spawns[player.name].changeTick+settings.global["respawn-timer"].value*60
			if (nextChangeTick>game.tick) then
				player.print("can't change spawn yet! (try again after : " .. string.format("%.1f", (nextChangeTick-game.tick)/60) .. " seconds" )
				return
			end
		end

		-- added changeTick and surface
		local p_x = player.position.x;
		local p_y = player.position.y;

		global.spawns[player.name] = {player = player.name, x = math.random(p_x-4000,p_x+4000) , y = math.random(p_y-4000,p_y+4000) , lock = true, tries = 0, changeTick = game.tick, surface = player.surface}

		game.print("Setting " .. player.name .. "'s spawn point to random location.")
		if (player.character ~= nil) then
			player.character.die()
		end
	end
	if event.element.name == "spawn" then

		-- in orginal mod "table.insert(...)" caused another entry for buton click... Now there should be only one antry per each player clicking button. 
		if (global.spawns[player.name]~=nil) then
			local nextChangeTick = global.spawns[player.name].changeTick+settings.global["respawn-timer"].value*60
			if (nextChangeTick>game.tick) then
				player.print("can't change spawn yet! (try again after : " .. string.format("%.1f", (nextChangeTick-game.tick)/60) .. " seconds" )
				return
			end
		end
		-- added changeTick and surface
		global.spawns[player.name] = {player = player.name, x = player.position.x, y = player.position.y, lock = true, tries = 0, changeTick = game.tick, surface = player.surface}
		game.print("Setting " .. player.name .. "'s spawn point.")
	end
end

function on_respawned(event)
    local player = game.players[event.player_index]
	for _, spawn in pairs(global.spawns) do
		if spawn.player == player.name then
			player.teleport({x=spawn.x, y=spawn.y}, spawn.surface)
		end
	end
end

function on_mod_settings_changed(event)
	ui_all()
end

function player_joined(event)
    local player = game.players[event.player_index]
	ui(player)
end

script.on_event(defines.events.on_player_joined_game, player_joined)

script.on_event(defines.events.on_player_respawned, on_respawned)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)

script.on_event(defines.events.on_runtime_mod_setting_changed, on_mod_settings_changed)
