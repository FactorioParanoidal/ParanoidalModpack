function fillHydraulicPumpjacksConfig(config)

	config["deep-crude-oil"] = {
		type="resource-liquid",
		minimum_amount=150000,
		allotment=60,
		spawns_per_region={min=1, max=2},
		richness={min=40000, max=200000}, -- richness per resource spawn
		size={min=2, max=5},
	}
end