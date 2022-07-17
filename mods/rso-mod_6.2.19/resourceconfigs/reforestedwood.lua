function fillReforestedWoodConfig(config)
	
	config["reforested-wood"] = {
		type="resource-ore",
		
		allotment=70,
		
		spawns_per_region={min=1, max=1},
		size={min=10, max=20},
		richness=8000,
		min_amount=50,

		starting={richness=4000, size=10, probability=1},
	}
end