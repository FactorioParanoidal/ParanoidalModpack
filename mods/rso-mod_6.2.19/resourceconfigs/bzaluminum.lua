function fillBzaluminumConfig(config)

	config["aluminum-ore"] = {
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=20, max=30},
		min_amount=300,

		starting={richness=6000, size=25, probability=1},
	}
end
