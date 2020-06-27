function fillFoodIndustriesConfig(config)
	
	config["pure-water"] =
	{
		type="resource-liquid",
		minimum_amount=1000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=30000, max=70000}, -- richness per resource spawn
		size={min=1, max=4},
		
		starting={richness=40000, size=1, probability=1},
	}
end