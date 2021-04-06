function fillColdBitersEnemies(config)
	
	local enemyConfig = config["enemy-base"]
	
	enemyConfig.bases["cb-cold-spawner"]={
		allotment = 30,
		allotment_distance_factor = 1.05,
		max_allotment_distance_factor = 2
	}
	
	if game.entity_prototypes["small-cold-worm-turret"] then
		enemyConfig.sub_spawns["small-cold-worm-turret"]={
			min_distance=2,
			allotment=200,
			allotment_distance_factor=0.8,
			clear_range = {2, 2},
		}
	end

	if game.entity_prototypes["medium-cold-worm-turret"] then
		enemyConfig.sub_spawns["medium-cold-worm-turret"]={
			min_distance=4,
			allotment=100,
			allotment_distance_factor=1.1,
			max_allotment_distance_factor = 4,
			clear_range = {2, 2},
		}
	end
	
	if game.entity_prototypes["big-cold-worm-turret"] then
		enemyConfig.sub_spawns["big-cold-worm-turret"]={
			min_distance=6,
			allotment=100,
			allotment_distance_factor=1.2,
			max_allotment_distance_factor = 6,
			clear_range = {2, 2},
		}
	end	
	
	if game.entity_prototypes["behemoth-cold-worm-turret"] then
		enemyConfig.sub_spawns["behemoth-cold-worm-turret"]={
			min_distance=8,
			allotment=100,
			allotment_distance_factor=1.3,
			max_allotment_distance_factor = 8,
			clear_range = {3, 3},
		}
	end	

	if game.entity_prototypes["leviathan-cold-worm-turret"] then
		enemyConfig.sub_spawns["leviathan-cold-worm-turret"]={
			min_distance=10,
			allotment=100,
			allotment_distance_factor=1.4,
			max_allotment_distance_factor = 8,
			clear_range = {3, 3},
		}
	end	

end