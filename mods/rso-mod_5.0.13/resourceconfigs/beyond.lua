function fillBeyondConfig(config)
   
    config["lithium-brine"] = 
	{
        type="resource-liquid",
        minimum_amount=5000,
        allotment=50,
        spawns_per_region={min=1, max=2},
        richness={min=5000, max=15000}, -- richness per resource spawn
        size={min=1, max=3},
       
        starting={richness=12000, size=2, probability=1},
    }
   
    config["silicon-ore"] = 
	{
        type="resource-ore",
       
        allotment=50,
        spawns_per_region={min=1, max=1},
        richness=8000,
        size={min=10, max=20},
        min_amount = 250,
       
        starting={richness=2000, size=15, probability=1},
    }

end