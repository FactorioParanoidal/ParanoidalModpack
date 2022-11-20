function fillBzcarbon(config)

	config["graphite"] = {
		type="resource-ore",
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=13000,
		size={min=15, max=25},
		min_amount=200,

		starting={richness=5000, size=15, probability=1},
	}

	config["diamond"] = {
		type="resource-ore",
		allotment=15,
		spawns_per_region={min=1, max=1},
		richness=14000,
		size={min=10, max=15},
		min_amount=500,
	}
end
