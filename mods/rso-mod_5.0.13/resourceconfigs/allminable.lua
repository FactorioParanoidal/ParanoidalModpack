function fillAllMinableConfig(config)
	
	
	config["crude-water"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
	}
		
	
	config["crude-steam"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
	}
	
	
	config["crude-heavy-oil"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
	}
	
	config["crude-light-oil"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
	}
	
	config["crude-petroleum-gas"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
		
	}
	
	config["crude-lubricant"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
		
	}
	
	config["crude-sulfuric-acid"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
		
	}
	
	
	--- patchs
	config["iron-plate"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["sulfur"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}
	
	config["copper-plate"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["steel-plate"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["plastic-bar"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}

	config["battery"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}

	config["explosives"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}

	config["copper-cable"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["iron-stick"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["iron-gear-wheel"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["electronic-circuit"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["advanced-circuit"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}

	config["processing-unit"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}

	config["engine-unit"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}

	config["electric-engine-unit"] = {
	type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=100,
		size={min=8, max=12},
		min_amount = 250,
	}
end