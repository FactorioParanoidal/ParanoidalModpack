function fillPyPetroleumHandlingConfig194(config)


	config["oil-sand"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30},
		min_amount=250,
	}

	config["sulfur-patch"] = {
		type="resource-liquid",
		minimum_amount=50000,
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness={min=80000, max=160000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true
	}

	config["bitumen-seep"] = {
		type="resource-liquid",
		minimum_amount=1000,
		allotment=60,
		spawns_per_region={min=1, max=3},
		richness={min=1000, max=2500}, -- richness per resource spawn
		size={min=1, max=2},
		useOreScaling = false,
	}

end
