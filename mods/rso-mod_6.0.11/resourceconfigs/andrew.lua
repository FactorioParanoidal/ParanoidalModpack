function fillAndrewConfig(config)
   
	config["aluminium-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=8, max=15},
		min_amount = 300,
		
        starting={richness=5000, size=8, probability=1},
	}
   
    config["clay"] = 
	{
        type="resource-ore",
       
        allotment=50,
        spawns_per_region={min=1, max=1},
        richness=8000,
        size={min=8, max=15},
        min_amount = 250,
       
        starting={richness=2000, size=8, probability=1},
    }
   
	config["gold-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=8, max=12},
		min_amount = 250,
		
        starting={richness=1000, size=8, probability=1},
	}

	config["a-natural-gas"] = {
		type="resource-liquid",
		minimum_amount=10000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=10000, max=30000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=20000, size=2, probability=1},
	}
end

