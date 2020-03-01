function fillRoadworksConfig(config)

	config["RW_limestone"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=13000,
		size={min=10, max=20},
		min_amount = 100,
		
		starting={richness=2000, size=10, probability=0.9},
		
		multi_resource_chance=0.30,
		multi_resource={
			["coal"] = 2,
			["stone"] = 4,
			["crude-oil"] = 2,
		}
	}
	
	if config["stone"] and config["stone"].multi_resource then
		config["stone"].multi_resource["RW_limestone"] = 3
	end
	if config["iron-ore"] and config["iron-ore"].multi_resource then
		config["iron-ore"].multi_resource["RW_limestone"] = 3
	end
	if config["copper-ore"] and config["copper-ore"].multi_resource then
		config["copper-ore"].multi_resource["RW_limestone"] = 3
	end
	if config["coal"] and config["coal"].multi_resource then
		config["coal"].multi_resource["RW_limestone"] = 2
	end
end