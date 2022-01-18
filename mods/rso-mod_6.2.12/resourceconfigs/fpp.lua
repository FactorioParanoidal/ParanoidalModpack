function fillFppConfig(config)
	
	config["gold-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 10,
	}
	
	config["silver-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=10, max=20},
		min_amount = 10,
		
		starting={richness=3000, size=10, probability=1},
	}
	
	config["titan-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=15, max=25},
		min_amount = 10,
	}

	config["cuprumferrit-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=15, max=25},
		min_amount = 10,
	}
	
	config["argentumferrit-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=10, max=20},
		min_amount = 10,
	}
	
	config["titaniumferrit-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=10, max=20},
		min_amount = 10,
	}

	config["sulphurcarbonite-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=15, max=25},
		min_amount = 10,
	}
	
	config["carfitium-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 10,
	}

	config["strachnite-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 10,
	}
end