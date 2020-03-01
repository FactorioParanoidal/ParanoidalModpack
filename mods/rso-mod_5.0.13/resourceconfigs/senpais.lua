function fillSenpaisConfig(config)
	
	config["bavarium"] =
	{
		type="resource-ore",
		
		allotment=60,
		
		spawns_per_region={min=1, max=1},
		size={min=15, max=20},
		richness=13000,
		min_amount=250,
		
		starting={richness=7000, size=15, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource=
		{
			["iron-ore"] = 2,
			["coal"] = 2,
			["stone"] = 2,
		}
	}

	config["angel-ore"] =
	{
		type="resource-ore",

		allotment=40,
		
		spawns_per_region={min=1, max=1},
		size={min=4, max=8},
		richness=100,
		
		starting={richness=0.1, size=1, probability=1},
	}
		
	config["devil-ore"] =
	{
		type="resource-ore",
		
		allotment=40,
		
		spawns_per_region={min=1, max=1},
		size={min=4, max=8},
		richness=100,
		
		starting={richness=0.1, size=1, probability=1},
	} 

end