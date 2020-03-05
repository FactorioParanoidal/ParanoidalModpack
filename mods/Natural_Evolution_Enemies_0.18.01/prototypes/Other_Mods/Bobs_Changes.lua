if mods["bobenemies"] then

	local function call_radius(w_name,radius)
		if data.raw.turret[w_name] then
			data.raw.turret[w_name].call_for_help_radius = radius
		end
	end



	local function pollution_attack(u_name,amount)
		if data.raw.unit[u_name] then
			data.raw.unit[u_name].pollution_to_join_attack = amount
		end
	end

		   

	if data.raw["unit-spawner"]["bob-biter-spawner"] then

		-- Bob's Biter Spawner Adjustments
		data.raw["unit-spawner"]["bob-biter-spawner"].max_count_of_owned_units = 13 + (2 * NE_Enemies.Settings.NE_Difficulty)
		data.raw["unit-spawner"]["bob-biter-spawner"].max_friends_around_to_spawn = 20 + (2 * NE_Enemies.Settings.NE_Difficulty)
		data.raw["unit-spawner"]["bob-biter-spawner"].spawning_cooldown = {(200+100/NE_Enemies.Settings.NE_Difficulty), (100+50/NE_Enemies.Settings.NE_Difficulty)}
		data.raw["unit-spawner"]["bob-biter-spawner"].max_health = 500 + (500 * NE_Enemies.Settings.NE_Difficulty)
		data.raw["unit-spawner"]["bob-biter-spawner"].resistances = Resistances.Spawner
		data.raw["unit-spawner"]["bob-biter-spawner"].spawning_radius = 25
		data.raw["unit-spawner"]["bob-biter-spawner"].spawning_spacing = 2
		data.raw["unit-spawner"]["bob-biter-spawner"].healing_per_tick = 0.01 + (0.002 * NE_Enemies.Settings.NE_Difficulty) -- 0.02
		data.raw["unit-spawner"]["bob-biter-spawner"].pollution_absorption_absolute = 15
		data.raw["unit-spawner"]["bob-biter-spawner"].pollution_absorption_proportional = 0.005


		--- Bob's Biter Units
		pollution_attack("bob-big-piercing-biter", 2000)
		pollution_attack("bob-huge-acid-biter", 4000)
		pollution_attack("bob-huge-explosive-biter", 4000)
		pollution_attack("bob-giant-poison-biter", 6000)
		pollution_attack("bob-giant-fire-biter", 6000)
		pollution_attack("bob-titan-biter", 8000)
		pollution_attack("bob-behemoth-biter", 10000)
		pollution_attack("bob-leviathan-biter", 15000)
		
	end	  


	if data.raw["unit-spawner"]["bob-spitter-spawner"] then


			-- Bob's Spitter Spawner Adjustments
		data.raw["unit-spawner"]["bob-spitter-spawner"].max_count_of_owned_units = 8 + (2 * NE_Enemies.Settings.NE_Difficulty)
		data.raw["unit-spawner"]["bob-spitter-spawner"].max_friends_around_to_spawn = 13 + (2 * NE_Enemies.Settings.NE_Difficulty)
		data.raw["unit-spawner"]["bob-spitter-spawner"].spawning_cooldown = {(300+100/NE_Enemies.Settings.NE_Difficulty), (100+80/NE_Enemies.Settings.NE_Difficulty)}
		data.raw["unit-spawner"]["bob-spitter-spawner"].max_health = 1000 + (500 * NE_Enemies.Settings.NE_Difficulty)
		data.raw["unit-spawner"]["bob-spitter-spawner"].resistances = Resistances.Spawner
		data.raw["unit-spawner"]["bob-spitter-spawner"].spawning_radius = 20
		data.raw["unit-spawner"]["bob-spitter-spawner"].spawning_spacing = 2
		data.raw["unit-spawner"]["bob-spitter-spawner"].healing_per_tick = 0.01 + (0.002 * NE_Enemies.Settings.NE_Difficulty) -- 0.02
		data.raw["unit-spawner"]["bob-spitter-spawner"].pollution_absorption_absolute = 15
		data.raw["unit-spawner"]["bob-spitter-spawner"].pollution_absorption_proportional = 0.005

		--- Bob's Spitter Units
		pollution_attack("bob-big-electric-spitter", 1500)
		pollution_attack("bob-huge-explosive-spitter", 2500)
		pollution_attack("bob-huge-acid-spitter", 2300)
		pollution_attack("bob-giant-fire-spitter", 4500)
		pollution_attack("bob-giant-poison-spitter", 5500)
		pollution_attack("bob-titan-spitter", 6500)
		pollution_attack("bob-behemoth-spitter", 7500)
		pollution_attack("bob-leviathan-spitter", 8500)
		
	end	


			
	--- Bob's Worms
	 call_radius("bob-big-explosive-worm-turret", 120)
	 call_radius("bob-big-fire-worm-turret", 120)
	 call_radius("bob-big-poison-worm-turret", 120)
	 call_radius("bob-big-piercing-worm-turret", 120)
	 call_radius("bob-big-electric-worm-turret", 120)
	 call_radius("bob-giant-worm-turret", 200)


end




