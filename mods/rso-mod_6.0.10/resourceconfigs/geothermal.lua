function fillGeoTermalConfig(config)
	
	config["termal"] = {
		type="resource-liquid",
		minimum_amount=150000,
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness={min=150000, max=200000}, -- richness per resource spawn
		size={min=2, max=3},
		
		starting={richness=100000, size=2, probability=1},
	}
	
end