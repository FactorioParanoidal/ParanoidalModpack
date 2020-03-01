function fillDrugLabConfig(config)
	config["manganese-ore-dl"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=30000,
		size={min=20, max=30},
		min_amount=300,
	}
	
	config["fracking-sludge-dl"] = {
		type="resource-liquid",
		minimum_amount=440000,
		allotment=80,
		spawns_per_region={min=1, max=2},
		richness={min=440000, max=800000},
		size={min=2, max=5},
	}
	
	config["tarsands-dl"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=90000,
		size={min=20, max=30},
		min_amount=300,
	}
		
end