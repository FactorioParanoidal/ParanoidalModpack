function fillBzleadConfig(config)

	config["lead-ore"] = {
		type="resource-ore",
		
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=14000,
		size={min=20, max=29},
		min_amount=300,

		starting={richness=5000, size=25, probability=1},
		
		multi_resource_chance=0.20,
		multi_resource={
			["iron-ore"] = 4,
			['copper-ore'] = 4,
			['lead-ore'] = 2,
			["coal"] = 4,
			["stone"] = 4,
		}
	}

end
