function fillKpotConfig(config)
	
	config["titanium-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 25,
		
		starting={richness=5000, size=10, probability=1},
	}

	config["titanium-2-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 25,
		
		starting={richness=5000, size=10, probability=1},
	}
end