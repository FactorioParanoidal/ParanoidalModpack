function fillBukketConfig(config)

	config["rich-copper-ore"] =
	{
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=16000,
		size={min=15, max=25},
		min_amount=300,

		starting={richness=2000, size=10, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource={
			["quartz"] = 1,
			["calcopyrite"] = 3,
		}
	}
	
	config["rich-iron-ore"] =
	{
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=14000,
		size={min=15, max=25},
		min_amount = 250,
		
		starting={richness=2000, size=10, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource={
			["quartz"] = 1,
			["calcopyrite"] = 3,
		}
	}

	config["quartz"] =
	{
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=6000,
		size={min=10, max=20},
		min_amount = 150,
		
	}

	config["calcopyrite"] =
	{
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=24000,
		size={min=25, max=35},
		min_amount = 300,
	}
end