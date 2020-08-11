function fillTinyOverhaulConfig(config)
	
	config["bauxite"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 250,
	}
		
	config["quartz"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 300,
	}
	
	config["lithium-brine"] =
	{
		type="resource-liquid",
		minimum_amount=60000,
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness={min=150000, max=450000}, -- richness per resource spawn
		size={min=3, max=6},
	}

end