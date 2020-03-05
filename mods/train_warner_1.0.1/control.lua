-- Settings per user, containing the keys: active, radius and range
settings = {}
-- Players, who currently hear a horn playing
playingSounds = {}
-- Lenght of the sound file in ticks
soundLength = 138

function loadSettings(player)
	settings[player.index] = {
		active=player.mod_settings["train_warner_warn_active"].value,
		range=player.mod_settings["train_warner_warn_range"].value,
		radius=player.mod_settings["train_warner_warn_radius"].value
	}
end

function isTrainInRange(player --[[LuaPlayer]], radius --[[int]])
	local playerPosition = player.position
	local playerSurface = player.surface
	local trains = playerSurface.get_trains()

	if table_size(trains) > 0 then
		local playerPosition = player.position
		local playerPosX = playerPosition["x"]
		local playerPosY = playerPosition["y"]
		local trainLocation
		for index, singleTrain in pairs(trains) do
			if (singleTrain.speed < 0) then
				trainLocation = singleTrain.locomotives["back_movers"][1].position
			else
				trainLocation = singleTrain.locomotives["front_movers"][1].position
			end
			local trainPosX = trainLocation["x"]
			local trainPosY = trainLocation["y"]
			local distance = math.sqrt((playerPosX - trainPosX) ^ 2 + (playerPosY - trainPosY) ^ 2)
			if (distance < settings[player.index].radius) then
				return true
			end
		end
	end

	return false
end

function playerNearRails(player)
	local things = player.surface.find_entities_filtered{position=player.position, radius=settings[player.index].range, name={"curved-rail", "straight-rail"}}
		
	return table_size(things) > 0
end

function playHornForPlayer(player)
	if (playingSounds[player.index] == nil) then
		player.play_sound{path="train-warner-sound", position=player.position}
		playingSounds[player.index] = 0
	end
end

function round(number, decimals)
	return tonumber(string.format("%." .. decimals .. "f", number))
end

function tickHandler(event)
	if game and event.tick ~= 0 then
		for index, player in pairs(game.players) do
			if settings[index] == nil then
				loadSettings(player)
			end
			if settings[index].active and playerNearRails(player) and isTrainInRange(player, settings[index].radius) then
				playHornForPlayer(player)
			end
			if playingSounds[index] ~= nil then
				if playingSounds[index] >= soundLength then
					playingSounds[index] = nil
				else
					playingSounds[index] = playingSounds[index] + 5
				end
			end
		end
	end
end

script.on_event(
	defines.events.on_runtime_mod_setting_changed,
	function(event)
		if event.player_index ~= nil and (event.setting == "train_warner_warn_active" or event.setting == "train_warner_warn_range" or event.setting == "train_warner_warn_radius") then
			loadSettings(game.players[event.player_index])
		end
	end
)

script.on_nth_tick(1, tickHandler)
