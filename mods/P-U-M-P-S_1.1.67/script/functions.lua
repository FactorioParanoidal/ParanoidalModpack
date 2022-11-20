---------------------
---- control.lua ----
---------------------

local PUMPS = {}

-- Place offshore pump
function PUMPS.make_offshore_pump(event)

	-- Boilers start with 10 water [checks for correct input fluid]
	if OSM.PUMPS.boiler_start_water then
		if event.created_entity.type == "boiler" then
			for _, fluidbox in pairs(event.created_entity.prototype.fluidbox_prototypes) do

				local filter = fluidbox.filter

				if filter and filter.name == "water" then
					event.created_entity.insert_fluid({name = "water", amount = 10})
					return
				end
			end
		end
	end

	-- Replace placeholder with actual entity
	if event.created_entity.type == "offshore-pump" then
		
		-- Prints unsupported offshore pumps on screen
		if not OSM.PUMPS.powered_pumps[event.created_entity.name] and OSM.PUMPS.power_enabled then
			event.created_entity.force.print({"", "[color=#ffa500][Offshore P.U.M.P.S.][/color] ", {"message.warning"}, ": ", "[color=#03dffc]"..'"'.. event.created_entity.name..'"'.."[/color]"})
			log("WARNING!!! Unsupported offshore pump detected: "..'"'..event.created_entity.name..'"')
		end

		if not OSM.PUMPS.powered_pumps[event.created_entity.name] then return end

		local placeholder = event.created_entity
		local powered_name = OSM.PUMPS.powered_pumps[placeholder.name].name
		local surface = placeholder.surface
		local position = placeholder.position
		local direction = placeholder.direction
		local force = placeholder.force

		-- Destroy placeholder
		placeholder.destroy()

		-- Place collision layer
		surface.create_entity
		{
			name = OSM.PUMPS.collision_layer,
			position = position,
			direction = direction,
			force = "neutral",
			fast_replace = true,
			spill = false,
			raise_built = false,
			create_build_effect_smoke = false
		}

		-- Place offshore pump
		surface.create_entity
		{
			name = powered_name,
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
	
	-- Prevent accidental placement of collision layer
	if event.created_entity.name == OSM.PUMPS.collision_layer then
		local collision_layer = event.created_entity or event.entity
		collision_layer.destroy()
		return
	end
end

-- Offshore pumps stay offshore
function PUMPS.offshore_means_offshore(event)

	local water_tile = false
	local ground_tile = true

	if not OSM.PUMPS.landfill_goes_boom then ground_tile = false end
	
	-- Determine if tile is ground-tile or water-tile (waiting for lua_group to be available in control stage)
	if string.find(event.tile.name, "water", 1, true) or string.find(event.tile.name, "safefill", 1, true) then
		water_tile = true
		ground_tile = false
	end

	if not ground_tile and not water_tile then return end

	local mods = game.active_mods
	local player = game.connected_players[event.player_index]
	local tile_prototype = game.tile_prototypes[event.tile.name]
	local surface = game.surfaces[event.surface_index]
	local area =
	{
		left_top = {event.tiles[1].position.x-4, event.tiles[1].position.y-4},
		right_bottom = {event.tiles[#event.tiles].position.x+4, event.tiles[#event.tiles].position.y+4}
	}

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
	for _, pump in pairs(OSM.PUMPS.powered_pumps) do
		
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
function PUMPS.replace_vanilla_item(event)

	if OSM.PUMPS.debug_mode then return end

	local player = game.connected_players[event.player_index]
	
	if player and player.valid then

		local item_count = player.get_item_count("offshore-pump")

		if item_count > 0 then
			player.remove_item({name="offshore-pump", count=item_count})
			player.insert{name="offshore-pump-1", count=item_count}
		end
	end
end

-- Remove collision layer
function PUMPS.remove_collision_layer(event)

	if not OSM.PUMPS.powered_pumps[event.entity.name.."-placeholder"] then return end
	if event.entity.name ~= OSM.PUMPS.powered_pumps[event.entity.name.."-placeholder"].name then return end

	local pump_surface = event.entity.surface
	local pump_position = event.entity.position

	local collision_layer = pump_surface.find_entity(OSM.PUMPS.collision_layer, event.entity.position)
	
	if collision_layer then
		collision_layer.destroy()
	end
end

return PUMPS