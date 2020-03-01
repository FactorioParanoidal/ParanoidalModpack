function fillSulfurConfig(config)
	
	config["sulfur"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=15, max=25},
		min_amount=100,

		starting={richness=6000, size=15, probability=1},
		
		multi_resource_chance=0.20,
		multi_resource={
			["iron-ore"] = 4,
			['copper-ore'] = 2,
			["coal"] = 4,
			["stone"] = 4,
		}
	}

end