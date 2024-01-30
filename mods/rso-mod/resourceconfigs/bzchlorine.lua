function fillBzchlorineConfig(config)

	config["salt"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=15, max=25},
		min_amount=300,

		starting={richness=2000, size=13, probability=1},
	}
end
