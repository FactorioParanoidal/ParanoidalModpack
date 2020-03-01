function fillDyWorldConfig(config)
	
	config["copper-ore"] = nil
	config["iron-ore"] = nil
	config["coal"] = nil
	config["stone"] = nil
	config["uranium-ore"] = nil
	
	
	config["chalcopyrite"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=16000,
		size={min=15, max=30},
		min_amount = 10,

		starting={richness=8000, size=15, probability=1},
	}
	
	config["hematite"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=15, max=30},
		min_amount = 10,

		starting={richness=10000, size=20, probability=1},
	}
	
	config["galena"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 10,
	}
	
	config["prolycotherium"] = {
		type="resource-ore",
		
		allotment=70,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=25},
		min_amount = 10,
	}

	config["carbolycite"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=15, max=30},
		min_amount = 10,

		starting={richness=10000, size=20, probability=1},
	}
	
	config["bauxite"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 10,
		
		starting={richness=6000, size=12, probability=1},
	}
	
	config["radicium"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 10,
	}	
	
	config["dyworld-methane"] = {
		type="resource-liquid",
		minimum_amount=24000,
		allotment=60,
		spawns_per_region={min=1, max=2},
		richness={min=24000, max=40000}, -- richness per resource spawn
		size={min=2, max=5},
	}

end