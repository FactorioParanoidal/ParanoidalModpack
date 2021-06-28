function fillNulliusConfig(config)

	config["nullius-sandstone"] = {
		type="resource-ore",
		
		allotment=95,
		spawns_per_region={min=1, max=1},
		richness=18000,
		
		size={min=18, max=27},
		min_amount=300,
		
		starting={richness=7000, size=22, probability=1},
		
		multi_resource_chance=0.20,
		multi_resource={
			["iron-ore"] = 3,
			["nullius-sandstone"] = 2,
			["nullius-bauxite"] = 4,
			["nullius-limestone"] = 5,
		}
	}
	
	config["nullius-bauxite"] = {
		type="resource-ore",
		
		allotment=90,
		spawns_per_region={min=1, max=1},
		richness=16000,
		size={min=16, max=25},
		min_amount=300,

		starting={richness=6000, size=20, probability=1},
		
		multi_resource_chance=0.25,
		multi_resource={
			["iron-ore"] = 5,
			["nullius-sandstone"] = 4,
			["nullius-bauxite"] = 2,
			["nullius-limestone"] = 3,
		}
	}

	config["nullius-limestone"] = {
		type="resource-ore",

		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=14, max=22},
		min_amount=300,

		multi_resource_chance=0.15,
		multi_resource={
			["iron-ore"] = 4,
			["nullius-sandstone"] = 5,
			["nullius-bauxite"] = 3,
			["nullius-limestone"] = 2,
		}
	}
	
	config["nullius-fumarole"] = {
		type="resource-liquid",
		minimum_amount=320000,
		allotment=90,
		spawns_per_region={min=1, max=1},
		richness={min=320000, max=480000}, -- richness per resource spawn
		size={min=3, max=8},
		multi_resource_chance=0.2,
		multi_resource={
			["iron-ore"] = 4,
			["nullius-fumarole"] = 2,
		}
	}

	if config["iron-ore"] then
		config["iron-ore"].multi_resource = {
			["iron-ore"] = 2,
			["nullius-sandstone"] = 3,
			["nullius-bauxite"] = 5,
			["nullius-limestone"] = 4,
			["nullius-fumarole"] = 1,
		}
	end
end