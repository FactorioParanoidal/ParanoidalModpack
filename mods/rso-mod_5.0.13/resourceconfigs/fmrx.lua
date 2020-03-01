function fillFmrxConfig(config)
	
	config["raw_veridium"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=60, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=10000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=10, max=20}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=20,
		
		-- resource provided at starting location
		-- probability: 1 = 100% chance to be in starting area
		--              0 = resource is not in starting area
		starting={richness=3000, size=10, probability=1},
	}
end