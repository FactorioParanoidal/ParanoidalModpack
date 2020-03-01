function fillNaturalGasConfig(config)
	
	config["natural-gas"] = {
		type="resource-liquid",
		minimum_amount=150e6,
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness={min=125e6, max=175e6}, 
		size={min=2, max=4},
		
		starting={richness=200e6, size=2, probability=0.4},
	}

end