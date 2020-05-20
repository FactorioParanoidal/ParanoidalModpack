function fillDarkstarConfig(config)
	
	config["gold-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=20000,
		size={min=10, max=15},
		min_amount = 450,
	}
	
	config["lead-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=30000,
		size={min=10, max=20},
		min_amount = 450,
	}

end