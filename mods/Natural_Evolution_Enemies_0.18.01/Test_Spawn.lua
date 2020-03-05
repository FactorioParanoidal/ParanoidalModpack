----- Just used for Testing


	function Test_Spawn()

		local surface = game.surfaces['nauvis']
	--[[
		for i = 1, 20 do
		
		--surface.create_entity({name="ne-spawner-red", position={-15, 0}, force = game.forces.player})	
		
		surface.create_entity({name="ne-biter-breeder-" .. i, position={-5 - i, 10}, force = game.forces.player})
		surface.create_entity({name="ne-biter-fire-" .. i, position={-5 - i, 5}, force = game.forces.player})
	    surface.create_entity({name="ne-biter-fast-" .. i, position={-5 - i, 0}, force = game.forces.player})
		--fast.health = fast.health *.95
		surface.create_entity({name="ne-biter-wallbreaker-" .. i, position={-5 - i, -5}, force = game.forces.player})
		surface.create_entity({name="ne-biter-tank-" .. i, position={-5 - i, -10}, force = game.forces.player})

		surface.create_entity({name="ne-spitter-breeder-" .. i, position={5 + i, 10}, force = game.forces.player})	
		surface.create_entity({name="ne-spitter-fire-" .. i, position={5 + i, 5}, force = game.forces.player})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, 0}, force = game.forces.player})
		surface.create_entity({name="ne-spitter-webshooter-" .. i, position={5 + i, -5}, force = game.forces.player})
		surface.create_entity({name="ne-spitter-mine-" .. i, position={5 + i, -10}, force = game.forces.player})	

		--surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={15 + i, 0}, force = game.forces.enemy})		
		
		--surface.create_entity({name="ne-spitter-fire-" .. i, position={-20 + i, 15}, force = game.forces.player})
		--surface.create_entity({name="ne-spitter-fire-" .. i, position={-5 + i, 15}, force = game.forces.enemy})
		
		--surface.create_entity({name="small-worm-turret", position={-30, -35}, force = game.forces.enemy})	
		--surface.create_entity({name="medium-worm-turret", position={-30, -30}, force = game.forces.enemy})	
		--surface.create_entity({name="big-worm-turret", position={-30, -15}, force = game.forces.enemy})	
		--surface.create_entity({name="behemoth-worm-turret", position={-30, -25}, force = game.forces.enemy})	
		

		--surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, -5}, force = game.forces.enemy})
	
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, -4}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, -3}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, -2}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, -1}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, 0}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, 1}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, 2}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, 3}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, 4}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={5 + i, 5}, force = game.forces.enemy})
		
end
]]
		--local megalodon = surface.create_entity({name="ne-biter-megalodon", position={-15, -15}, force = game.forces.enemy})	
		--megalodon.health = 1000
		--megalodon.resistances = {{type = "physical", percent = 2}}

	--[[
	--surface.create_entity({name="ne-biter-breeder-" .. i, position={-15 - i, 10}, force = game.forces.enemy})
		--surface.create_entity({name="ne-biter-fire-" .. i, position={-15 - i, 5}, force = game.forces.enemy})
		--surface.create_entity({name="ne-biter-fast-" .. i, position={-15 - i, 0}, force = game.forces.enemy})
		--surface.create_entity({name="ne-biter-wallbreaker-" .. i, position={-15 - i, -5}, force = game.forces.enemy})
		--surface.create_entity({name="ne-biter-tank-" .. i, position={-15 - i, -10}, force = game.forces.enemy})

		--surface.create_entity({name="ne-spitter-breeder-" .. i, position={15 + i, 10}, force = game.forces.enemy})	
		--surface.create_entity({name="ne-spitter-fire-" .. i, position={15 + i, 5}, force = game.forces.enemy})
		surface.create_entity({name="ne-spitter-ulaunch-" .. i, position={15 + i, 0}, force = game.forces.enemy})
		--surface.create_entity({name="ne-spitter-webshooter-" .. i, position={15 + i, -5}, force = game.forces.enemy})
		--surface.create_entity({name="ne-spitter-mine-" .. i, position={15 + i, -10}, force = game.forces.enemy})
	
		--surface.create_entity({name="ne-spitter-mine-" .. i, position={-5 + i, -5}, force = game.forces.enemy})	
		--	surface.create_entity({name="medium-spitter-Mk2", position={50 + i, -25}, force = game.forces.enemy})	
		]]
		
		
		--surface.create_entity({name="ne-spawner-red", position={-15, 0}, force = game.forces.enemy})	
		--surface.create_entity({name="ne-spawner-red", position={-5, 5}, force = game.forces.enemy})	
		--surface.create_entity({name="ne-spawner-yellow", position={15, 0}, force = game.forces.player})	
		
	--	surface.create_entity({name="ne-spitter-mine-1", position={-20, 0}, force = game.forces.enemy})
		--surface.create_entity({name="ne-spitter-mine-10", position={20, 0}, force = game.forces.player})
		
		

		--local megalodon = surface.create_entity({name="ne-biter-megalodon", position={-15, -15}, force = game.forces.player})	
		--megalodon.health = 100
		
		
		--surface.create_entity({name="ne-spawner-blue", position={15, 15}, force = game.forces.enemy})	
		--[[
		surface.create_entity({name="ne-spawner-red", position={15, 25}, force = game.forces.player})	
		surface.create_entity({name="ne-spawner-green", position={15, 35}, force = game.forces.player})	
		surface.create_entity({name="ne-spawner-yellow", position={15, 45}, force = game.forces.player})	
		surface.create_entity({name="ne-spawner-pink", position={15, 55}, force = game.forces.player})	
		]]
		
		--surface.create_entity({name="ne-spitter-mine-10", position={-20, -20}, force = game.forces.enemy})	
	--	surface.create_entity({name="medium-spitter-Mk2", position={-50, -20}, force = game.forces.enemy})
		--surface.create_entity({name="medium-worm-turret", position={-30, -30}, force = game.forces.enemy})	
		--surface.create_entity({name="big-worm-turret", position={-15, -15}, force = game.forces.enemy})	
		--surface.create_entity({name="ne-biter-fire-10", position={-50, 15}, force = game.forces.enemy})
		--surface.create_entity({name="ne-biter-fire-40", position={-40, 15}, force = game.forces.enemy})
		--surface.create_entity({name="ne-biter-fire-60", position={-30, 15}, force = game.forces.enemy})
		
		script.on_event(defines.events.on_player_created, function(event)
		
			local iteminsert = game.players[event.player_index].insert

			iteminsert{name="submachine-gun", count=1}	
			--iteminsert{name="steel-axe", count=1}	
			iteminsert{name="uranium-rounds-magazine", count=200}		
			iteminsert{name="small-alien-artifact", count=500}		
			iteminsert{name="alien-artifact", count=500}		
			iteminsert{name="coal", count=500}		
			iteminsert{name="iron-ore", count=500}	
			iteminsert{name="stone-furnace", count=20}		
			iteminsert{name="power-armor-mk2", count=1}		
			--iteminsert{name="rocket-silo", count=4}		
		
		end)
		
		surface.always_day = true
		--game.speed = .05
		
	end

