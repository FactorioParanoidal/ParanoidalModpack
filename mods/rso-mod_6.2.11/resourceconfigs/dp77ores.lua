function fillDp77OresConfig(config)

    --Common:
	
	config["alluminium-ore"] = {
		type="resource-ore",
		
		allotment=110, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=20000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=20, max=30}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=500,
		starting={richness=8000, size=15, probability=1},
		
		multi_resource_chance=0.40, -- absolute value
		multi_resource={
			["iron-ore"] = 4,
			["lead-ore"] = 2,
			["tin-ore"] = 2,
			["copper-ore"] = 2,
			["randomite-ore"] = 3,
		}
	}

	config["germanium-ore"] = {
		type="resource-ore",
		
		allotment=100,
		spawns_per_region={min=1, max=1}, 
		richness=18000,
		
		size={min=20, max=30},
		min_amount=500,
		starting={richness=7000, size=23, probability=1},
		
		multi_resource_chance=0.40, 
		multi_resource={
			["lead-ore"] = 4,
			["tin-ore"] = 2,
			["copper-ore"] = 2,
			["alluminium-ore"] = 2,
			["randomite-ore"] = 3,
		}
	}
	
	config["lead-ore"] = {
		type="resource-ore",
		
		allotment=110, 
		spawns_per_region={min=1, max=1}, 
		richness=20000,  
		
		size={min=20, max=30},
		min_amount=500,
		starting={richness=8000, size=15, probability=1},
		
		multi_resource_chance=0.40, 
		multi_resource={
			["germanium-ore"] = 4,
			["alluminium-ore"] = 2,
			["tin-ore"] = 2,
			["copper-ore"] = 2,
			["randomite-ore"] = 3,
		}
	}

	config["quartz-ore"] = {
		type="resource-ore",
		
		allotment=110, 
		spawns_per_region={min=1, max=1}, 
		richness=18000,  
		
		size={min=20, max=30},
		min_amount=500,
		starting={richness=110000, size=15, probability=0.5},
		
		multi_resource_chance=0.35, 
		multi_resource={
			["diamond-ore"] = 3,
		}
	}
	
	config["randomite-ore"] = {
		type="resource-ore",
		
		allotment=110, 
		spawns_per_region={min=1, max=1}, 
		richness=22000,  
		
		size={min=20, max=30},
		min_amount=500,
		starting={richness=110000, size=15, probability=1},
	}
	
	config["silicon-ore"] = {
		type="resource-ore",
		
		allotment=110, 
		spawns_per_region={min=1, max=1}, 
		richness=20000,  
		
		size={min=20, max=30},
		min_amount=500,
		starting={richness=8000, size=15, probability=0.5},
		
		multi_resource_chance=0.40, 
		multi_resource={
			["iron-ore"] = 4,
			["randomite-ore"] = 3,
		}
	}
	
	config["tin-ore"] = {
		type="resource-ore",
		
		allotment=110, 
		spawns_per_region={min=1, max=1}, 
		richness=20000,  
		
		size={min=20, max=30},
		min_amount=500,
		starting={richness=8000, size=15, probability=1},
		
		multi_resource_chance=0.40, 
		multi_resource={
			["copper-ore"] = 4,
			["alluminium-ore"] = 2,
			["lead-ore"] = 2,
			["germanium-ore"] = 2,
			["randomite-ore"] = 3,
		}
	}
	

    --Rare:
	config["cadmium-ore"] = {
			type="resource-ore",
			
			allotment=90,
			spawns_per_region={min=1, max=1},
			richness=110000,
			size={min=10, max=20},
			min_amount = 500,
			
		}
	
	config["cinnabar-ore"] = {
		type="resource-ore",
		
		allotment=110, 
		spawns_per_region={min=1, max=1}, 
		richness=110000,  
		
		size={min=20, max=30},
		min_amount=250,
		starting={richness=8000, size=20, probability=1},
		
		multi_resource_chance=0.35, 
		multi_resource={
			["stone"] = 4,
			["coal"] = 2,
			["randomite-ore"] = 3,
		}
	}

	config["hafnium-ore"] = {
			type="resource-ore",
			
			allotment=90,
			spawns_per_region={min=1, max=1},
			richness=110000,
			size={min=10, max=20},
			min_amount = 500,
			
		}

	config["lithium-ore"] = {
			type="resource-ore",
			
			allotment=90,
			spawns_per_region={min=1, max=1},
			richness=110000,
			size={min=10, max=20},
			min_amount = 500,
			
		}

	config["osmium-ore"] = {
			type="resource-ore",
			
			allotment=90,
			spawns_per_region={min=1, max=1},
			richness=110000,
			size={min=10, max=20},
			min_amount = 500,
			starting={richness=8000, size=20, probability=1},
		
			
		}

	config["platinum-ore"] = {
			type="resource-ore",
			
			allotment=90,
			spawns_per_region={min=1, max=1},
			richness=110000,
			size={min=10, max=20},
			min_amount = 500,
			
		}

    --Epic:
	config["gold-ore"] = {
			type="resource-ore",
			
			allotment=70,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=10, max=20},
			min_amount = 300,
			
		}
	
	config["iridium-ore"] = {
		type="resource-ore",
		
		allotment=70, 
		spawns_per_region={min=1, max=1}, 
		richness=8000,  
		
		size={min=10, max=20},
		min_amount=500,
		starting={richness=8000, size=15, probability=0,5},
		
		multi_resource_chance=0.40, 
		multi_resource={
			["platinum-ore"] = 4,
		}
	}

	config["titanium-ore"] = {
			type="resource-ore",
			
			allotment=70,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 300,
		
		multi_resource_chance=0.40, 
		multi_resource={
			["titanium-ore"] = 4,
			["vibranium-ore"] = 3,
		}
			
	}

    --Legendary:
	config["diamond-ore"] = {
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=7, max=10},
			min_amount = 500,
		
		multi_resource_chance=0.35, 
		multi_resource={
			["quartz-ore"] = 4,
			["randomite-ore"] = 3,
		}
			
	}

	config["omega's-ametyst-ore"] = {
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=7, max=10},
			min_amount = 500,
			
		}

	config["vibranium-ore"] = {
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=7, max=10},
			min_amount = 500,
		
		multi_resource_chance=0.40, 
		multi_resource={
			["titanium-ore"] = 4,
			["randomite-ore"] = 3,
		}
			
	}
end
