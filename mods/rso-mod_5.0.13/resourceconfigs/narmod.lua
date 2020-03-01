function fillNARModConfig(config)
	
	config["brine-pool"] = {
		type="resource-liquid",
		minimum_amount=5000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=5000, max=15000}, -- richness per resource spawn
		size={min=1, max=3},
		
		starting={richness=7000, size=2, probability=1},
		
		multi_resource_chance=0.20,
		multi_resource={
			["coal"] = 4,
		}
	}
	
end