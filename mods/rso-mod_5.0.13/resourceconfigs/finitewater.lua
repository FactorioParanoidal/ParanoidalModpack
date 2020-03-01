function fillFiniteWaterConfig(config)
	
	
	config["crude-water"] = {
		type="resource-liquid",
		minimum_amount=50000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=50000, max=100000}, -- richness per resource spawn
		size={min=6, max=15},
		
		starting={richness=150000, size=6, probability=1},
		useOreScaling = true
	}
	
end