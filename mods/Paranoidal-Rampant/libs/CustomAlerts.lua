if (customAlertsG) then
    return customAlertsG
end
local customAlerts = {}

-- Ordinary squads still record detection, but never emit a custom alert.
function customAlerts.isSquadDetected(surface, entity)
    local planet = surface.planet
    local location = planet and planet.name
    local position = entity.position
    local chunk = {x = math.floor(position.x / 32), y = math.floor(position.y / 32)}
    for _, force in pairs(game.forces) do
        if (not location or force.is_space_location_unlocked(location)) and #force.connected_players > 0
            and force.is_chunk_visible(surface, chunk) then
            return true
        end
    end
    return false
end

function customAlerts.showAlert(surface, entity, alertName, message)
	if alertName == "squadDetected-warning-rampant" then return customAlerts.isSquadDetected(surface, entity) end
	local planet = surface.planet
	local position = entity.position
	local chunkPosition = {x = math.floor(position.x / 32), y = math.floor(position.y / 32)}

	local result = false
	for _, force in pairs(game.forces) do
		if not planet or force.is_space_location_unlocked(planet.name) then
			local visible
			for _, player in pairs(force.connected_players) do
				if visible == nil then visible = force.is_chunk_visible(surface, chunkPosition) end
				if visible then
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