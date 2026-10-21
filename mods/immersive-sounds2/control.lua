-- Paranoidal: item count of an inventory of the entity, 0 if it has none (a player in the remote view keeps the
-- character but has no inventory of it; vehicle ammo belongs to the vehicle, not to the player)
local function countIn(entity, index)
  local inventory = entity and entity.valid and entity.get_inventory(index)
  return inventory and inventory.get_item_count() or 0
end

function playSoundAtEntity(sound, entity)
  entity.surface.play_sound
  {
    path = sound,
    position = entity.position
  }
end


-- SWITCH WEAPON PRESS TRIGGERS

script.on_event("switch-gun-key", function(event)
	local player = game.players[event.player_index]
	if player.character and player.driving == false then
		if countIn(player.character, defines.inventory.character_ammo) >= 1 and countIn(player.character, defines.inventory.character_guns) >= 1 then
		playSoundAtEntity("select-smg", player.character)
		end
	end	
end)

script.on_event("switch-gun-key-tank", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "tank" and countIn(player.vehicle, defines.inventory.car_ammo) >= 1 then
		playSoundAtEntity("select-cannon", player.vehicle)
		end
	end
end)

script.on_event("switch-gun-key-car", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "car" and countIn(player.vehicle, defines.inventory.car_ammo) >= 1 then
		playSoundAtEntity("select-machine-gun", player.vehicle)
		end
	end
end)

script.on_event("switch-gun-key-spider", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "spidertron" and countIn(player.vehicle, defines.inventory.spider_ammo) >= 1 then
		playSoundAtEntity("select-machine-gun", player.vehicle)
		end
	end
end)

-- TANK KEY PRESS TRIGGERS

script.on_event("tank-moving-key-W", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "tank" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("tank-engine-loads", player.vehicle)
			end
		end
	end
end)

script.on_event("tank-moving-key-S", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "tank" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("tank-engine-loads-reverse", player.vehicle)
			end
		end
	end
end)

script.on_event("tank-moving-key-A", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "tank" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("tank-engine-loads-rotation", player.vehicle)
			end
		end
	end
end)

script.on_event("tank-moving-key-D", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "tank" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("tank-engine-loads-rotation", player.vehicle)
			end
		end
	end
end)


-- CAR KEY PRESS TRIGGERS

script.on_event("car-moving-key-W", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "car" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("car-engine-loads", player.vehicle)
			end
		end
	end
end)

script.on_event("car-moving-key-S", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "car" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("car-engine-loads-reverse", player.vehicle)
			end
		end
	end
end)

script.on_event("car-moving-key-A", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "car" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("car-steering", player.vehicle)
			end
		end
	end
end)

script.on_event("car-moving-key-D", function(event)
	local player = game.players[event.player_index]
	if player.vehicle then
		if player.vehicle.name == "car" then
			if player.vehicle.burner and player.vehicle.burner.currently_burning ~= nil then
			playSoundAtEntity("car-steering", player.vehicle)
			end
		end
	end
end)