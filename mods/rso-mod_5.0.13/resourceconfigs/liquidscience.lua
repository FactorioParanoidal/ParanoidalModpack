function fillLiquidScienceConfig(config)

	config["sand-ore"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=10, max=20},
		min_amount=300,
    
		starting={richness=5000, size=15, probability=1}
	}
end