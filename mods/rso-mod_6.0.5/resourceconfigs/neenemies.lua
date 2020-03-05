function fillNEConfig(config)
	
	local enemyConfig = config["enemy-base"]

	if settings.startup["NE_Blue_Spawners"].value then
		enemyConfig.bases["ne-spawner-blue"]={
			allotment = 30,
			allotment_distance_factor = 1.05,
			max_allotment_distance_factor = 2
		}
	end
	if settings.startup["NE_Red_Spawners"].value then
		enemyConfig.bases["ne-spawner-red"]={
			allotment = 30,
			allotment_distance_factor = 1.05,
			max_allotment_distance_factor = 2
		}
	end
	if settings.startup["NE_Green_Spawners"].value then
		enemyConfig.bases["ne-spawner-green"]={
			allotment = 30,
			allotment_distance_factor = 1.05,
			max_allotment_distance_factor = 2
		}
	end
	if settings.startup["NE_Yellow_Spawners"].value then
		enemyConfig.bases["ne-spawner-yellow"]={
			allotment = 30,
			allotment_distance_factor = 1.05,
			max_allotment_distance_factor = 2
		}
	end
	if settings.startup["NE_Pink_Spawners"].value then
		enemyConfig.bases["ne-spawner-pink"]={
			allotment = 30,
			allotment_distance_factor = 1.05,
			max_allotment_distance_factor = 2
		}
	end
	if settings.startup["NE_Remove_Vanilla_Spawners"].value then
		enemyConfig.bases["biter-spawner"] = nil
		enemyConfig.bases["spitter-spawner"] = nil
	end
end