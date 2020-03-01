function fillDp77SulfurConfig(config)
	
	config["sulfur-ore"] = {
		type = "resource-ore",
		allotment = 60,
		spawns_per_region = {min=1, max=1},
		richness = 5000,
		size = {min=15, max=20},
		
--		starting={richness=5000, size=10, probability=1}
	}

end