
script.on_event(defines.events.on_sector_scanned, function (event)
--Called when the radar finishes scanning a sector. Can be filtered for the radar using LuaSectorScannedEventFilters

--Contains
--radar :: LuaEntity: The radar that did the scanning.
--chunk_position :: ChunkPosition: The chunk scanned.
--area :: BoundingBox: Area of the scanned chunk.
	
	local entity = event.radar
--	game.print ('scanned ' .. entity.name)
	if (entity.name == "ore-radar") then
		local force = entity.force
		local surface = entity.surface
		
		local areas = global.areas[surface.name] or nil
		if areas then
--			game.print ('areas: '.. #areas)
			local i = math.random (#areas)
--			game.print ('i: '.. i)
			local area = global.areas[surface.name][i]
			
			if (surface.count_entities_filtered{area = area, type = 'resource', limit=1} == 0) then
				table.remove(global.areas, i)
				return
			end
			
			force.chart(surface, {area.left_top,{x = area.right_bottom.x-1, y = area.right_bottom.y-1}})
		end
	end
end)



script.on_event(defines.events.on_chunk_generated, function(event)
	local surface = event.surface
	
	local area = event.area
	-- count_entities_filtered{area=…, position=…, name=…, type=…, ghost_name=…, ghost_type=…, force=…, limit=…, invert=…}
	if (surface.count_entities_filtered{area = area, type = 'resource', limit=1} > 0) then
		if not global.areas[surface.name] then
			global.areas[surface.name] = {}
		end
		table.insert (global.areas[surface.name], area)
--		game.print ('added chunk ' .. #global.areas[surface.name])
	else
		
	end
end)

script.on_init(function ()
	global.areas = {}
		
end)