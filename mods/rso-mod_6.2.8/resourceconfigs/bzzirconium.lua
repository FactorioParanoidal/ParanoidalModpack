function fillBzzirconiumConfig(config)

	config["zircon"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=14000,
		size={min=15, max=30},
		min_amount=100,

		starting={richness=1000, size=15, probability=1},
	}

end
