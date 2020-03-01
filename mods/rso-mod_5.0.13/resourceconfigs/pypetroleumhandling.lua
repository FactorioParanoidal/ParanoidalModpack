function fillPyPetroleumHandlingConfig(config)


	config["oil-sand"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30},
		min_amount=250,
		starting={richness=8000, size=25, probability=0.2}
	}

	config["natural-gas"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}


	config["oil-mk01"] = {
		type="resource-liquid",
		minimum_amount=40000,
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness={min=200000, max=300000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true,

		starting={richness=250000, size=2, probability=1}
	}

	config["oil-mk02"] = {
		type="resource-liquid",
		minimum_amount=40000,
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness={min=300000, max=450000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true
	}

	config["oil-mk03"] = {
		type="resource-liquid",
		minimum_amount=40000,
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness={min=450000, max=600000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true
	}

	config["oil-mk04"] = {
		type="resource-liquid",
		minimum_amount=40000,
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness={min=600000, max=800000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true
	}

	config["sulfur-patch"] = {
		type="resource-liquid",
		minimum_amount=50000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=50000, max=85000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true
	}

	config["tar-patch"] = {
		type="resource-liquid",
		minimum_amount=40000,
		allotment=60,
		spawns_per_region={min=1, max=2},
		richness={min=100000, max=200000}, -- richness per resource spawn
		size={min=2, max=5},
		useOreScaling = true,

		starting={richness=75000, size=2, probability=0.2}
	}

end
