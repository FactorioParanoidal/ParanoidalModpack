function fillAnonyModsConfig(config)

	-- boost vanilla resources to make sure they are still quite frequent
	if config["iron-ore"] then
		config["iron-ore"].allotment = 200
	end
	if config["copper-ore"] then
		config["copper-ore"].allotment = 200
	end
	if config["coal"] then
		config["coal"].allotment = 160
	end
	if config["stone"] then
		config["stone"].allotment = 120
	end
	if config["crude-oil"] then
		config["crude-oil"].allotment = 140
	end

	config["aluminum-ore"] =
	{
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=15, max=20},
		min_amount = 300,

		starting={richness=8000, size=10, probability=1},
	}
	
	config["cobalt-ore"] = 
	{
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=15},
		min_amount = 250,
	}

	config["gold-ore"] = 
	{
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=15},
		min_amount = 250,
	}

	config["lead-ore"] =
	{
		type="resource-ore",
		
		allotment=85,
		spawns_per_region={min=1, max=1},
		richness=22000,
		size={min=15, max=20},
		min_amount = 550,
		
		starting={richness=10000, size=12, probability=1},
	}

	config["limestone-ore"] =
	{
		type="resource-ore",
		
		allotment=90,
		spawns_per_region={min=1, max=1},
		richness=24000,
		size={min=15, max=20},
		min_amount = 300,
		
		starting={richness=13000, size=14, probability=1},
	}

	config["mercury-ore"] =
	{
		type="resource-ore",
		
		allotment=85,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=15, max=20},
		min_amount = 250,
		
		starting={richness=6000, size=8, probability=1},
	}
	
	config["nickel-ore"] =
	{
		type="resource-ore",
		
		allotment=75,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=10, max=15},
		min_amount = 300,
		
		starting={richness=8000, size=11, probability=1},
	}

	config["phosphorus-ore"] =
	{
		type="resource-ore",
		
		allotment=75,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=15},
		min_amount = 250,
		
		starting={richness=5000, size=11, probability=1},
	}

	config["quartz-ore"] =
	{
		type="resource-ore",
		
		allotment=90,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=15, max=25},
		min_amount = 300,
		
		starting={richness=9000, size=15, probability=1},
	}

	config["silver-ore"] =
	{
		type="resource-ore",
		
		allotment=45,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=8, max=15},
		min_amount = 200,
	}

	config["sulfur-ore"] =
	{
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=15},
		min_amount = 250,
	}

	config["tin-ore"] =
	{
		type="resource-ore",
		
		allotment=90,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=15, max=20},
		min_amount = 250,
		
		starting={richness=6000, size=10, probability=1},
	}

	config["titanium-ore"] =
	{
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=8, max=12},
		min_amount = 250,
	}

	config["tungsten-ore"] =
	{
		type="resource-ore",
		
		allotment=65,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=15},
		min_amount = 250,
	}
	
	config["zinc-ore"] =
	{
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=10, max=15},
		min_amount = 250,
	}
	
	config["natural-gas"] =
	{
		type="resource-liquid",
		minimum_amount=6000,
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness={min=20000, max=40000},
		size={min=2, max=4},
	}

	config["thermal-water"] =
	{
		type="resource-liquid",
		minimum_amount=6000,
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness={min=20000, max=40000},
		size={min=2, max=4},
	}

	config["sedimentary-ore"] =
	{
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=15, max=20},
		min_amount = 300,

		starting={richness=12000, size=15, probability=1},
	}

	config["metamorphic-ore"] =
	{
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=15, max=20},
		min_amount = 300,

		starting={richness=12000, size=15, probability=1},
	}

	config["igneous-ore"] =
	{
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=15, max=20},
		min_amount = 300,

		starting={richness=12000, size=15, probability=1},
	}

end