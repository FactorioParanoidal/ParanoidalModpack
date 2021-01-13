function fillMobileFactoryConfig(config)
	config["DimensionalOre"] = {
		type="resource-ore",
		
		allotment=80,
		
		spawns_per_region={min=1, max=1},
		size={min=15, max=25},
		richness=13000,
		min_amount=300,

		starting={richness=6000, size=20, probability=1},
	}

	config["DimensionalFluid"] = {
		type="resource-liquid",
		minimum_amount=240000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=240000, max=400000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=400000, size=2, probability=1},
	}
end