function fillTiberiumConfig(config)
	
	config["tiberium-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=15},
		min_amount = 250,
		
--		starting={richness=4000, size=10, probability=1},
	}

end