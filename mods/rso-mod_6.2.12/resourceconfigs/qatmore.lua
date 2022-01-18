function fillQatmoreConfig(config)

	config["fluorite-ore"] = {
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount=300,
		
		multi_resource_chance=0.40,
		multi_resource={
			["stone"] = 3,
			['bauxite-ore'] = 3,
			["quartz"] = 2,
			["tungsten-ore"] = 2,
			["rutile-ore"] = 2,
		}
	}
end