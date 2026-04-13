function fillBobEnemies(config)
	
	local nauvisConfig = config.nauvis	
	local enemyConfig = nauvisConfig["enemy-base"]
	
	enemyConfig.bases["bob-biter-spawner"]={
		allotment = 30,
		allotment_distance_factor = 1.05,
		max_allotment_distance_factor = 2
	}
	enemyConfig.bases["bob-spitter-spawner"]={
		allotment = 30,
		allotment_distance_factor = 1.05,
		max_allotment_distance_factor = 2
	}
	
	if prototypes.entity["bob-super-spawner"] then
		enemyConfig.bases["bob-super-spawner"]={
			allotment = 10,
			allotment_distance_factor = 1.1,
			max_allotment_distance_factor = 10
		}
	end

	enemyConfig.sub_spawns["bob-big-explosive-worm-turret"]={
		min_distance=6,
		allotment=100,
		allotment_distance_factor=1.2,
		max_allotment_distance_factor = 4,
		clear_range = {2, 2},
	}
	enemyConfig.sub_spawns["bob-big-fire-worm-turret"]={
		min_distance=6,
		allotment=100,
		allotment_distance_factor=1.2,
		max_allotment_distance_factor = 4,
		clear_range = {2, 2},
	}
	enemyConfig.sub_spawns["bob-big-poison-worm-turret"]={
		min_distance=6,
		allotment=100,
		allotment_distance_factor=1.2,
		max_allotment_distance_factor = 4,
		clear_range = {2, 2},
	}
	enemyConfig.sub_spawns["bob-big-piercing-worm-turret"]={
		min_distance=6,
		allotment=100,
		allotment_distance_factor=1.2,
		max_allotment_distance_factor = 4,
		clear_range = {2, 2},
	}
	enemyConfig.sub_spawns["bob-big-electric-worm-turret"]={
		min_distance=6,
		allotment=100,
		allotment_distance_factor=1.2,
		max_allotment_distance_factor = 4,
		clear_range = {2, 2},
	}
	enemyConfig.sub_spawns["bob-giant-worm-turret"]={
		min_distance=8,
		allotment=80,
		allotment_distance_factor=1.3,
		max_allotment_distance_factor = 8,
		clear_range = {4, 4},
	}
	enemyConfig.sub_spawns["bob-titan-worm-turret"]={
		min_distance=10,
		allotment=80,
		allotment_distance_factor=1.3,
		max_allotment_distance_factor = 8,
		clear_range = {4, 4},
	}
	enemyConfig.sub_spawns["behemoth-worm-turret"]={
		min_distance=12,
		allotment=80,
		allotment_distance_factor=1.3,
		max_allotment_distance_factor = 8,
		clear_range = {4, 4},
	}
	enemyConfig.sub_spawns["bob-leviathan-worm-turret"]={
		min_distance=14,
		allotment=80,
		allotment_distance_factor=1.3,
		max_allotment_distance_factor = 8,
		clear_range = {4, 4},
	}	
end