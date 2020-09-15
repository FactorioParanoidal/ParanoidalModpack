require "prototypes.functions"

--Ontick has a few jobs, but fundamentally, they are all graphics update related.
script.on_event(defines.events.on_tick, function(event)
	if event.tick % 60 == 0 then
		--As we iterate through global.needsGFXUpdate we want to remove any elements that are done being updated (most shields fill and stay filled). We store any elements that need a further update in this list.
		local tmp_list = {}
		
		--log("debug: ontick running")
		for turretID, state in pairs(global.needsGFXUpdate) do
			if state and global.turrets[turretID][TURRET_ENTITY] and global.turrets[turretID][TURRET_ENTITY].valid then
				updateShieldGraphics(global.turrets[turretID], false, state)
				if global.turrets[turretID][ELECTRIC_GRID_INTERFACE].energy ~= global.turrets[turretID][ELECTRIC_GRID_INTERFACE].electric_buffer_size then
					tmp_list[turretID] = state
				end
			end
		end
		global.needsGFXUpdate = tmp_list
	end
end)