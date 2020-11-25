function fillSpringWaterConfig(config)
	
	config["spring-water"] = {
		type="resource-liquid",
		minimum_amount=75000,
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness={min=75000, max=150000}, 
		size={min=2, max=4},
		
		multi_resource_chance=0.20,
		multi_resource={
			["crude-oil"] = 2,
		}
	}

end