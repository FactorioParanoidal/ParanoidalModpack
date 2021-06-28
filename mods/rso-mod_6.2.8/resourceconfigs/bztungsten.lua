function fillBztungstenConfig(config)

	config["tungsten-ore"] = {
		type="resource-ore",
		
		allotment=70,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=15, max=29},
		min_amount=300,

		starting={richness=1000, size=10, probability=1},
	}

end
