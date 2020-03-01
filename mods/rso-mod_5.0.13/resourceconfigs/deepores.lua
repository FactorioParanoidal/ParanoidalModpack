function fillDeepOresConfig(config)
	
	config["deep-copper-ore"] = {
		type="resource-liquid",
		
		allotment=70,
		spawns_per_region={min=4, max=12},
		richness={min=250, max=1000},
		size={min=1, max=3},
		minimum_amount=500,
		
		starting={richness=1000, size=3, probability=1},
		
		multi_resource_chance=0.70,
		multi_resource={
			["copper-ore"] = 1,
		}
	}
	
	config["deep-iron-ore"] = {
		type="resource-liquid",
		
		allotment=70,
		spawns_per_region={min=4, max=12},
		richness={min=250, max=1000},
		size={min=1, max=3},
		minimum_amount=500,
		
		starting={richness=1000, size=3, probability=1},
		
		multi_resource_chance=0.70,
		multi_resource={
			["iron-ore"] = 1,
		}
	}
	
end