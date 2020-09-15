function fillZombiesExtendedConfig(config)
	
	config["gold-ore"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=80, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=15000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=20, max=30}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=300,
		
		-- resource provided at starting location
		-- probability: 1 = 100% chance to be in starting area
		--              0 = resource is not in starting area
		starting={richness=5000, size=20, probability=1},
	}
	
	config["vibranium-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=6000,
		size={min=10, max=15},
		min_amount=300,
	}
end