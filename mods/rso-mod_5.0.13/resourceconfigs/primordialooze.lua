function fillPrimordialOozeConfig(config)
	config["primordial-ooze"] = {
		type="resource-liquid",
		minimum_amount=130000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=130000, max=200000}, -- richness per resource spawn
		size={min=2, max=5},
	}
end
