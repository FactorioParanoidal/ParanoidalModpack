function fillBioIndustriesConfig(config)
	
	config["bi-ground-water"] = {
		type="resource-liquid",
		minimum_amount=1000,
		allotment=100,
		spawns_per_region={min=2, max=4},
		richness={min=100000, max=300000}, -- richness per resource spawn
		size={min=2, max=5},
		
		starting={richness=300000, size=6, probability=1},
	}
end