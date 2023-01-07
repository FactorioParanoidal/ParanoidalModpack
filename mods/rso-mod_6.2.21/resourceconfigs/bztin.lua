function fillBztinConfig(config)

	config["tin-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=15, max=25},
		min_amount=300,

		starting={richness=4000, size=15, probability=1},
	}
end
