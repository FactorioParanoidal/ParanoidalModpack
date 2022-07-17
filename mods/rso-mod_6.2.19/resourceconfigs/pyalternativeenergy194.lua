function fillPyAlternativeEnergyConfig194(config)
	config["ree"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30},
		min_amount=250,
	}
	
	config["antimonium"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30},
		min_amount=250,
	}
	
	config["geothermal-crack"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness={min=2000000, max=4000000}, -- richness per resource spawn
		size={min=2, max=4},
		useOreScaling = true,
	}
end