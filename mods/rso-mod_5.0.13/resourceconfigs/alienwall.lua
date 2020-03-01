function fillAlienWallConfig(config)
	
	config["alien-biomass"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=5000,
		size={min=10, max=15},
		min_amount = 50,
		
		starting={richness=3000, size=10, probability=1},
	}
end