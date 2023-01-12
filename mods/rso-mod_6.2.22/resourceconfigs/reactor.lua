function fillReactorConfig(config)
	
	config["Nature-Gas"] =
	{
		type="resource-liquid",
		minimum_amount=1000,
		allotment=40,
		spawns_per_region={min=1, max=2},
		richness={min=15000, max=30000}, 
		size={min=2, max=4},
		
		starting={richness=20000, size=2, probability=0.3},
	}
	
	config["nuclear-ores"] =
	{
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=4000,
		size={min=10, max=16},
		min_amount = 150,
		
		starting={richness=5000, size=12, probability=1},
	}
	

end