function fillIndustrialRevolutionConfig(config)
	
	config["iron-ore"].starting = nil
	
	config["tin-ore"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=100, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=14000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=15, max=25}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=300,
		
		starting={richness=8000, size=20, probability=1},
	}
	
	config["gold-ore"] = {
		type="resource-ore",
		
		allotment=50,
		spawns_per_region={min=1, max=1},
		richness=7000,
		size={min=10, max=15},
		min_amount=250,
	}
end