function fillCargoShipsConfig(config)
	local nauvisConfig = config.nauvis
	local aquiloConfig = config.aquilo
	
	nauvisConfig["offshore-oil"] =
	{
		type="resource-liquid",
		minimum_amount=450000,
		allotment=50,
		spawns_per_region={min=3, max=4},
		richness={min=450000, max=800000}, -- richness per resource spawn
		size={min=1, max=1},
	}

	aquiloConfig["offshore-oil"] =
	{
		type="resource-liquid",
		minimum_amount=300000,
		allotment=50,
		spawns_per_region={min=3, max=4},
		richness={min=300000, max=500000}, -- richness per resource spawn
		size={min=1, max=1},
	}	
end