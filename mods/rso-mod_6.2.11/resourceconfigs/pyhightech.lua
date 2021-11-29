function fillPyHighTechConfig(config)
	
	
	config["molybdenum-ore"] = { -- warning - it exists also in pyfusion
		type="resource-ore",
		
		allotment=70,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount=250,
	}
	
	config["phosphate-rock"] = {
		type="resource-liquid",
		minimum_amount=40000,
		allotment=50,
		spawns_per_region={min=1, max=2},
		richness={min=65000, max=150000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true,
		
		starting={richness=75000, size=2, probability=1}
	}
	
	config["rare-earth-bolide"] = {
		type="resource-liquid",
		minimum_amount=40000,
		allotment=50,
		spawns_per_region={min=1, max=2},
		richness={min=50000, max=100000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true,

		starting={richness=85000, size=2, probability=1}
}
end