---------------------
---- control.lua ----
---------------------

local script = {}

-- Place offshore pump
function script.make_offshore_pump(event)

	-- Boilers start with 10 water [checks for correct input fluid]
	if OSM.boiler_start_water then
		if event.created_entity.type == "boiler" then
			for _, fluidbox in pairs(event.created_entity.prototype.fluidbox_prototypes) do

				local filter = fluidbox.filter
				local production_type = fluidbox.production_type

				if filter and filter.name == "water" then
					event.created_entity.insert_fluid({name = "water", amount = 10})
				end
			end
			return
		end
	end

	-- Replace placeholder with actual entity
	if event.created_entity.type == "offshore-pump" then
		local pump = event.created_entity or event.entity
		local name = OSM.powered_pumps[pump.name].name
		local surface = pump.surface
		local position = pump.position
		local direction = pump.direction
		local force = pump.force

		if not name then return end

		pump.destroy()
		surface.create_entity
		{
			name = OSM.collision_layer,
			position = position,
			direction = direction,
			force = "neutral",
			fast_replace = true,
			spill = false,
			raise_built = false,
			create_build_effect_smoke = false
		}
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
		return
	end
	
	-- Prevents placement of collision layer
	if event.created_entity.name == OSM.collision_layer then
		local collision_layer = event.created_entity or event.entity
		collision_layer.destroy()
		return
	end
end

-- Landfill destroys offshore pumps
function script.offshore_means_offshore(event)

	local water_tile = false
	local ground_tile = true
	
	if not OSM.landfill_goes_boom then ground_tile = false end

	local mods = game.active_mods
	local player = game.connected_players[event.player_index]
	local tile_prototype = game.tile_prototypes[event.tile.name]
	local surface = game.surfaces[event.surface_index]
	local area =
	{
		left_top = {event.tiles[1].position.x-4, event.tiles[1].position.y-4},
		right_bottom = {event.tiles[#event.tiles].position.x+4, event.tiles[#event.tiles].position.y+4}
	}

	-- Determine if tile is ground-tile or water-tile (waiting for lua_group to be available in control stage)
	if string.find(event.tile.name, "water", 1, true) or string.find(event.tile.name, "safefill", 1, true) then
		water_tile = true
		ground_tile = false
	end

	local pumps = {}
	
	local function index_pump(pump, event)
		for _, tile in pairs(event.tiles) do

			-- Landfill destroys offshore pump
			if pump and ground_tile then
				
				-- North
				if pump.direction == 0 then
					if (pump.position.x == tile.position.x+0.5) or (pump.position.x == tile.position.x-0.5) or (pump.position.x == tile.position.x+1.5) then
						if (pump.position.y == tile.position.y+0.5) or (pump.position.y == tile.position.y+1.5) or (pump.position.y == tile.position.y+2.5)  then
							local i = string.gsub(tostring(pump.position.x)..tostring(pump.position.y), "%.", "-" )
							pumps[i] = pump
						end
					end
				
				-- East
				elseif pump.direction == 2 then
					if (pump.position.x == tile.position.x-0.5) or (pump.position.x == tile.position.x-1.5) or (pump.position.x == tile.position.x-2.5) then
						if (pump.position.y == tile.position.y+0.5) or (pump.position.y == tile.position.y-0.5) or (pump.position.y == tile.position.y+1.5) then
							local i = string.gsub(tostring(pump.position.x)..tostring(pump.position.y), "%.", "-" )
							pumps[i] = pump
						end
					end

				-- South
				elseif pump.direction == 4 then
					if (pump.position.x == tile.position.x+0.5) or (pump.position.x == tile.position.x-0.5) or (pump.position.x == tile.position.x+1.5) then
						if (pump.position.y == tile.position.y-0.5) or (pump.position.y == tile.position.y-1.5) or (pump.position.y == tile.position.y-2.5)  then
							local i = string.gsub(tostring(pump.position.x)..tostring(pump.position.y), "%.", "-" )
							pumps[i] = pump
						end
					end

				-- West
				elseif pump.direction == 6 then
					if (pump.position.x == tile.position.x+1.5) or (pump.position.x == tile.position.x+2.5) or (pump.position.x == tile.position.x+3.5) then
						if (pump.position.y == tile.position.y+0.5) or (pump.position.y == tile.position.y-0.5) or (pump.position.y == tile.position.y+1.5) then
							local i = string.gsub(tostring(pump.position.x)..tostring(pump.position.y), "%.", "-" )
							pumps[i] = pump
						end
					end
				end
			
			-- Simulates water-tile collision mask
			elseif pump and water_tile then
				
				-- All directions
				if pump.position.x == tile.position.x+0.5 then
					if pump.position.y == tile.position.y+0.5 then
						local i = string.gsub(tostring(pump.position.x)..tostring(pump.position.y), "%.", "-" )
						pumps[i] = pump
					end
				end
			end
		end
	end
	
	-- Get pumps in range
	for _, pump in pairs(OSM.powered_pumps) do
		
		if pump.is_offshore then

			-- Get entity
			for _, pump in pairs(surface.find_entities_filtered{area=area, name=pump.name}) do
				index_pump(pump, event)
			end
			
			-- Get ghost
			for _, pump in pairs(surface.find_entities_filtered{area=area, ghost_name=pump.name}) do
				index_pump(pump, event)
			end
		end
	end
		
	-- Destroy pumps and ghosts in range
	for _, pump in pairs(pumps) do

		local name = pump.name
		local surface = pump.surface
		local position = pump.position
		local direction = pump.direction
		local force = pump.force

		if ground_tile then
			
			if pump.health then
				pump.damage(pump.health, pump.force)
			else
				pump.destroy()
			end
			
			for _, ghost in pairs(surface.find_entities_filtered{position=position, ghost_name=name}) do
				if ghost then ghost.destroy() end
			end
		
		elseif water_tile then

			if not string.find(event.tile.name, "safefill", 1, true) then -- Enables compatibility with "Safe Waterfill"
				pump.destroy()
			end
			
			for _, ghost in pairs(surface.find_entities_filtered{position=position, ghost_name=name}) do
				if ghost then ghost.destroy() end
			end
		end
	end
end

-- Replace vanilla offshore pump in inventory
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