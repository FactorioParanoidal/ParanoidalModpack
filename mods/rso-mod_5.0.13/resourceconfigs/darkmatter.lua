function fillDarkMatterConfig(config)
	
	config["tenemut"] = {
		type="resource-ore",
		
		allotment=40,
		
		spawns_per_region={min=1, max=1},
		size={min=5, max=8},
		richness=13500,
		
		starting={richness=8000, size=7, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource={
			["iron-ore"] = 2,
			["coal"] = 2,
			["stone"] = 2,
		}
	}
	
	config["iron-ore"].multi_resource["tenemut"] = 2
	config["coal"].multi_resource["tenemut"] = 2
	config["stone"].multi_resource["tenemut"] = 2
	
end