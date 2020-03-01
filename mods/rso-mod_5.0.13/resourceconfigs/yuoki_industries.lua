function fillYuokiConfig(config)
	
	config["y-res1"] = {
		type="resource-ore",
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=9000,
		size={min=14, max=20},
		min_size=150,
		
		starting={richness=2000, size=15, probability=1},
	}
	
	config["y-res2"] = {
		type="resource-ore",
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=14, max=20},
		min_size=150,
		
		starting={richness=2000, size=15, probability=1},
	}
end