function fill5dimConfig(config)
	
	config["gold-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=15, max=20},
		min_amount = 150,
		
		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["tin-ore"] = 3,
			["zinc-ore"] = 3,
			["bauxite-ore"] = 3,
		}
	}
	
	config["lead-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 300,
		
		starting={richness=4000, size=15, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource={
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["zinc-ore"] = 3,
			["bauxite-ore"] = 3,
		}
	}
	
	config["tin-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=15000,
		size={min=15, max=25},
		min_amount = 300,
		
		starting={richness=4000, size=15, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["gold-ore"] = 3,
			["zinc-ore"] = 3,
			["copper-ore"] = 2,
			["bauxite-ore"] = 3,
		}
	}
	
	config["zinc-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=7000,
		size={min=10, max=20},
		min_amount = 250,

		starting={richness=1000, size=10, probability=1},

		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["bauxite-ore"] = 3,
		}
	}
	
	config["bauxite-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 200,
		
		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["zinc-ore"] = 3,
		}
	}
	
end