function fillPicksBaseConfig(config)
   
    config.nauvis["pi-lithium-ore"] = 
	{
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=6000,
		size={min=10, max=15},
		min_amount=300,
	}

end