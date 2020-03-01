function fillPortalResearchConfig(config)
	
	config["factorium-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=5000,
		size={min=10, max=15},
		min_amount = 50,
		
		starting={richness=1500, size=8, probability=1},
	}
end