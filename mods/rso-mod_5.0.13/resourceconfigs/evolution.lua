function fillEvolutionConfig(config)
	
	config["alien-artifacts"] =
	{
		type = "resource-ore",
		allotment = 40,
		spawns_per_region = {min=1, max=1},
		richness = 4000,
		size = {min=15, max=20},
		min_size = 50,
		
		starting={richness=1000, size=15, probability=1},
	
		multi_resource_chance=0.30, -- absolute value
		multi_resource={
			["iron-ore"] = 2, -- ["resource_name"] = allotment
			["coal"] = 4,
			["stone"] = 4,
		}
	}
	
	if config["iron-ore"] and config["iron-ore"].multi_resource then
		config["iron-ore"].multi_resource["alien-artifacts"] = 2
	end
	if config["coal"] and config["coal"].multi_resource then
		config["coal"].multi_resource["alien-artifacts"] = 3
	end
	if config["stone"] and config["stone"].multi_resource then
		config["stone"].multi_resource["alien-artifacts"] = 3
	end
	
end