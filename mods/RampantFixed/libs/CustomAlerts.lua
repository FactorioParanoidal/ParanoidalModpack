if (customAlertsG) then
    return customAlertsG
end
local customAlerts = {}

function customAlerts.showAlert(surface, entity, alertName, message)
	local planet = surface.planet
	local chunkX = math.floor(entity.position.x / 32)
	local chunkY = math.floor(entity.position.y / 32)

	local result = false
	for _, force in pairs(game.forces) do
		if not planet or force.is_space_location_unlocked(planet.name) then	
			for _, player in pairs(force.connected_players) do
				if force.is_chunk_visible(surface, {x = chunkX, y = chunkY}) then
					local player_settings = settings.get_player_settings(player)
					if player_settings["rampantFixed--showSquadAlert"].value then 
						player.add_custom_alert(
						  entity,
						  {
							type = "virtual",
							name = alertName
						  },
						  message or "",
						  true
						)
					end
					result = true					 
				end
			end
		end	
	end
	return result
end

customAlertsG = customAlerts
return customAlerts