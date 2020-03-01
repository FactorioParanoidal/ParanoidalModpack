function fillNapusConfig(config)
	config["remains"] = {
		type="resource-liquid",
		minimum_amount=250000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=250000, max=500000}, -- richness per resource spawn
		size={min=2, max=5},
	}
end