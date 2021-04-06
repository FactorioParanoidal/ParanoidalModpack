function fillExplosiveBitersEnemies(config)
	
	local enemyConfig = config["enemy-base"]
	
	enemyConfig.bases["explosive-biter-spawner"]={
		allotment = 30,
		allotment_distance_factor = 1.05,
		max_allotment_distance_factor = 2
	}
	
	if game.entity_prototypes["small-explosive-worm-turret"] then
		enemyConfig.sub_spawns["small-explosive-worm-turret"]={
			min_distance=2,
			allotment=200,
			allotment_distance_factor=0.8,
			clear_range = {2, 2},
		}
	end

	if game.entity_prototypes["medium-explosive-worm-turret"] then
		enemyConfig.sub_spawns["medium-explosive-worm-turret"]={
			min_distance=4,
			allotment=100,
			allotment_distance_factor=1.1,
			max_allotment_distance_factor = 4,
			clear_range = {2, 2},
		}
	end
	
	if game.entity_prototypes["big-explosive-worm-turret"] then
		enemyConfig.sub_spawns["big-explosive-worm-turret"]={
			min_distance=6,
			allotment=100,
			allotment_distance_factor=1.2,
			max_allotment_distance_factor = 6,
			clear_range = {2, 2},
		}
	end	
	
	if game.entity_prototypes["behemoth-explosive-worm-turret"] then
		enemyConfig.sub_spawns["behemoth-explosive-worm-turret"]={
			min_distance=8,
			allotment=100,
			allotment_distance_factor=1.3,
			max_allotment_distance_factor = 8,
			clear_range = {3, 3},
		}
	end	

	if game.entity_prototypes["leviathan-explosive-worm-turret"] then
		enemyConfig.sub_spawns["leviathan-explosive-worm-turret"]={
			min_distance=10,
			allotment=100,
			allotment_distance_factor=1.4,
			max_allotment_distance_factor = 8,
			clear_range = {3, 3},
		}
	end	

end