function fillHomeworldConfig(config)
	config["sand-source"] = {
		type="resource-ore",
		
		autoplace_name = "sand",
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=11000,
		size={min=10, max=20},
		min_amount=250,

		starting={richness=4000, size=15, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource={
			["coal"] = 4,
			["crude-oil"] = 2,
			["iron-ore"] = 3,
			['copper-ore'] = 3,
		}
	}
end