function fillDyWorldConfig(config)
	
	-- exotic ores
	config["gold-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=15, max=20},
		min_amount = 150,
	}
	config["silver-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=20},
		min_amount = 150,
	}
	
	config["lead-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=20},
		min_amount = 300,
		
		starting={richness=3000, size=15, probability=1},
	}
	
	config["titanium-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=20},
		min_amount = 300,
		
		starting={richness=3000, size=15, probability=1},
	}
	
	config["tin-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=15, max=25},
		min_amount = 300,
		
		starting={richness=4000, size=15, probability=1},
	}
	
	config["nickel-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=15, max=25},
		min_amount = 300,
		
		starting={richness=4000, size=10, probability=1},
	}	
	
	config["tungsten-ore"] = {
		type="resource-ore",
		
		allotment=30,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 200,
	}
	
	config["cobalt-ore"] = {
		type="resource-ore",
		
		allotment=30,
		spawns_per_region={min=1, max=1},
		richness=3000,
		size={min=10, max=15},
		min_amount = 150,
	}
	
	config["arditium-ore"] = {
		type="resource-ore",
		
		allotment=30,
		spawns_per_region={min=1, max=1},
		richness=3000,
		size={min=10, max=15},
		min_amount = 150,
	}

	config["neutronium-ore"] = {
		type="resource-ore",
		
		allotment=30,
		spawns_per_region={min=1, max=1},
		richness=3000,
		size={min=10, max=15},
		min_amount = 150,
	}	
end