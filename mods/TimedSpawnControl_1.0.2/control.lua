require "util"

global.spawns = {{name = 'player', x = 0, y = 0, lock = true}}

function ui()
	for playerIndex, player in pairs(game.players) do
		if player.gui.top.spawn == nil then
			player.gui.top.add{name = "spawn", type = "button", caption = "Set Spawn", style="spc_fentus_button"}
		end
    end
	for playerIndex, player in pairs(game.players) do
		if player.gui.top.random == nil then
			player.gui.top.add{name = "random", type = "button", caption = "Random spawn (Kill me!/I'm stuck)", description = "this will kill you!", style="spc_fentus_button"}
		end
    end
end

script.on_configuration_changed(function(_)
    ui()
end)

function handle_event(defines,eventou)
	if eventou.name == defines.on_player_joined_game then
		ui()
	end
	
	-- on_gui_click
	if eventou.name == defines.on_gui_click then
		if eventou.element.name == "random" then
            local player = game.players[eventou.player_index]

            -- I don't think timing out random spawn is necessary.
			--if (global.spawns[player.name]~=nil) then
			--	local nextChangeTick = global.spawns[player.name].changeTick+(10*60)
			--	if (nextChangeTick>game.tick) then
			--		game.print("can't change spawn yet! (try again after : " .. string.format("%.1f", (nextChangeTick-game.tick)/60) .. " seconds" )
			--		return
			--	end
			--end

			-- added changeTick and surface
			local p_x = player.position.x;
			local p_y = player.position.y;
			global.spawns[player.name] = {player = player.name, x = math.random(p_x-4000,p_x+4000), y = math.random(p_y-4000,p_y+4000), lock = true, tries = 0, changeTick = game.tick, surface = player.surface}
			game.print("Setting " .. player.name .. "'s spawn point to random location.")
			if (player.character ~= nil) then
				player.character.die()
			end
		end
		if eventou.element.name == "spawn" then
            local player = game.players[eventou.player_index]

			-- in orginal mod "table.insert(...)" caused another entry for buton click... Now there should be only one antry per each player clicking button. 
			if (global.spawns[player.name]~=nil) then
				local nextChangeTick = global.spawns[player.name].changeTick+settings.global["respawn-timer"].value*60
				if (nextChangeTick>game.tick) then
					game.print("can't change spawn yet! (try again after : " .. string.format("%.1f", (nextChangeTick-game.tick)/60) .. " seconds" )
					return
				end
			end
			-- added changeTick and surface
			global.spawns[player.name] = {player = player.name, x = player.position.x, y = player.position.y, lock = true, tries = 0, changeTick = game.tick, surface = player.surface}
			game.print("Setting " .. player.name .. "'s spawn point.")
		end
	end
	
	if eventou.name == defines.on_player_respawned then
        -- Get Current Player
        local player = game.players[eventou.player_index]
		
		for _, spawn in pairs(global.spawns) do
			if spawn.player == player.name then
				player.teleport({spawn.x, spawn.y}, spawn.surface)
			end
		end
	end
end

script.on_event(defines.events, function(event)
	handle_event(defines.events,event)
end)
