function fillPyCoalConfig194(config)

	config["borax"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=80, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=25000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=20, max=30}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=250,
		
		-- resource provided at starting location
		-- probability: 1 = 100% chance to be in starting area
		--              0 = resource is not in starting area
	}
	
	config["niobium"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=60, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=25000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=20, max=30}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=300,
	}
	
end