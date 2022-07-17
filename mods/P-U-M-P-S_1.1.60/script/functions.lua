---------------------
---- control.lua ----
---------------------

local script = {}

-- Places offshore pump
function script.make_offshore_pump(event)
	
	local offshore_pumps_array =
	{
		["offshore-pump-0-placeholder"] = "offshore-pump-0",
		["offshore-pump-1-placeholder"] = "offshore-pump-1",
		["offshore-pump-2-placeholder"] = "offshore-pump-2",
		["offshore-pump-3-placeholder"] = "offshore-pump-3",
		["offshore-pump-4-placeholder"] = "offshore-pump-4",
		["seafloor-pump-placeholder"] = "seafloor-pump",
		["ground-water-pump-placeholder"] = "ground-water-pump"
	}

	-- Boilers start with 10 water [checks for correct input fluid]
	if boiler_start_water then
		if event.created_entity.type == "boiler" then
			for _, fluidbox in pairs(event.created_entity.prototype.fluidbox_prototypes) do

				local filter = fluidbox.filter
				local production_type = fluidbox.production_type

				if filter and filter.name == "water" then
					event.created_entity.insert_fluid({name = "water", amount = 10})
				end
			end
		end
	end

	-- Replace placeholder with actual entity
	if event.created_entity.type == "offshore-pump" then
		local pump = event.created_entity or event.entity
		local name = offshore_pumps_array[pump.name]
		local surface = pump.surface
		local position = pump.position
		local direction = pump.direction
		local force = pump.force

		if not name then return end

		pump.destroy()
		surface.create_entity
		{
			name = name,
			position = position,
			direction = direction,
			force = force,
			fast_replace = true,
			spill = false,
			raise_built = true,
			create_build_effect_smoke = false
		}
	end
end

-- Landfill destroys offshore pumps
function script.offshore_means_offshore(event)

	if not settings.startup["osm-pumps-landfill-goes-boom"].value then return end
	if not game.tile_prototypes[event.tile.name].collision_mask_with_flags == "ground-tile" then return end
	
	local offshore_pumps =
	{
		"offshore-pump-0",
		"offshore-pump-1",
		"offshore-pump-2",
		"offshore-pump-3",
		"offshore-pump-4",
		"seafloor-pump",
	}

	local player = game.connected_players[event.player_index]
	local tile_prototype = game.tile_prototypes[event.tile.name]
	local surface = game.surfaces[event.surface_index]
	local area =
	{
		left_top = {event.tiles[1].position.x-4, event.tiles[1].position.y-4},
		right_bottom = {event.tiles[#event.tiles].position.x+4, event.tiles[#event.tiles].position.y+4}
	}
	
	local function make_remnants(pump)
		
		surface.create_entity
		{
			name = "offshore-pump-remnants",
			position = pump.position,
			direction = pump.direction,
			force = pump.force,
			fast_replace = true,
			spill = false,
			raise_built = false,
			create_build_effect_smoke = false
		}
	end
	
	local filtered_pumps = {}
	
	-- Get pumps in range
	for _, offshore_pump in pairs(offshore_pumps) do
		for _, pump in pairs(surface.find_entities_filtered{area=area, name=offshore_pump}) do
			for _, tile in pairs(event.tiles) do

				-- North
				if pump and pump.direction == 0 then
					if (pump.position.x == tile.position.x+0.5) or (pump.position.x == tile.position.x-0.5) or (pump.position.x == tile.position.x+1.5) then
						if (pump.position.y == tile.position.y+0.5) or (pump.position.y == tile.position.y+1.5) or (pump.position.y == tile.position.y+2.5)  then
							make_remnants(pump)
							table.insert(filtered_pumps, pump)
						end
					end
				
				-- East
				elseif pump and pump.direction == 2 then
					if (pump.position.x == tile.position.x-0.5) or (pump.position.x == tile.position.x-1.5) or (pump.position.x == tile.position.x-2.5) then
						if (pump.position.y == tile.position.y+0.5) or (pump.position.y == tile.position.y-0.5) or (pump.position.y == tile.position.y+1.5) then
							make_remnants(pump)
							table.insert(filtered_pumps, pump)
						end
					end

				-- South
				elseif pump and pump.direction == 4 then
					if (pump.position.x == tile.position.x+0.5) or (pump.position.x == tile.position.x-0.5) or (pump.position.x == tile.position.x+1.5) then
						if (pump.position.y == tile.position.y-0.5) or (pump.position.y == tile.position.y-1.5) or (pump.position.y == tile.position.y-2.5)  then
							make_remnants(pump)
							table.insert(filtered_pumps, pump)
						end
					end

				-- West
				elseif pump and pump.direction == 6 then
					if (pump.position.x == tile.position.x+1.5) or (pump.position.x == tile.position.x+2.5) or (pump.position.x == tile.position.x+3.5) then
						if (pump.position.y == tile.position.y+0.5) or (pump.position.y == tile.position.y-0.5) or (pump.position.y == tile.position.y+1.5) then
							make_remnants(pump)
							table.insert(filtered_pumps, pump)
						end
					end
				end
			end
		end
	end
	
	-- Destroy pumps
	for _, pump in pairs(filtered_pumps) do
		pump.destroy()
	end
	
	-- Offshore pump goes boom
	if player and player.valid and player.character and player.character.valid then
		player.play_sound({path = "osm-pump-boom", position=player.character.position, volume_modifier = 0.5})
	end
end

-- Replace vanilla offshore pump in inventory with my equivalent
function script.replace_vanilla_item(event)

	if OSM.debug_mode then return end

	local player = game.connected_players[event.player_index]
	
	if player and player.valid then

		local item_count = player.get_item_count("offshore-pump")

		if item_count > 0 then
			player.remove_item({name="offshore-pump", count=item_count})
			player.insert{name="offshore-pump-1", count=item_count}
		end
	end
end

return script