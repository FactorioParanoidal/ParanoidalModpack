function fillBzgasConfig(config)
	config["gas"] = {
		type="resource-liquid",
		minimum_amount=220000,
		
		allotment=65,
		spawns_per_region={min=1, max=2},
		richness={min=220000, max=380000},
		size={min=2, max=7},

		starting={richness=380000, size=4, probability=1},
	}
end
