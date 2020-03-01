function fillEngineersConfig(config)
	
	if not game.active_mods["Engineersvsenvironmentalist"] then
		return
	end
	
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
			["silver-ore"] = 3,
			["tin-ore"] = 3,
			["tungsten-ore"] = 3,
			["zinc-ore"] = 3,
			["bauxite-ore"] = 3,
		}
	}
	config["silver-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=12000,
		size={min=10, max=20},
		min_amount = 150,
		
		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["tungsten-ore"] = 3,
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
			["silver-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["tungsten-ore"] = 3,
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
			["silver-ore"] = 3,
			["gold-ore"] = 3,
			["tungsten-ore"] = 3,
			["zinc-ore"] = 3,
			["copper-ore"] = 2,
			["bauxite-ore"] = 3,
		}
	}
	
	config["tungsten-ore"] = {
		type="resource-ore",
		
		allotment=30,
		spawns_per_region={min=1, max=1},
		richness=10000,
		size={min=10, max=20},
		min_amount = 200,
		
		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["silver-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["zinc-ore"] = 3,
			["bauxite-ore"] = 3,
			["rutile-ore"] = 3,
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
			["silver-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["tungsten-ore"] = 3,
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
			["silver-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["zinc-ore"] = 3,
		}
	}
	
	config["rutile-ore"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 200,
		
		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["silver-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["zinc-ore"] = 3,
			["tungsten-ore"] = 3,
		}
	}
	
	config["quartz"] = {
		type="resource-ore",
		
		allotment=40,
		spawns_per_region={min=1, max=1},
		richness=8000,
		size={min=10, max=20},
		min_amount = 250,
		
		starting={richness=2000, size=15, probability=1},
		
		multi_resource_chance=0.30,
		multi_resource={
			["lead-ore"] = 3,
			["silver-ore"] = 3,
			["gold-ore"] = 3,
			["tin-ore"] = 3,
			["zinc-ore"] = 3,
		}
	}
	
	-- check if Nickel, Cobalt, Sulfur or GemOre is added by bobs ores
	if game.entity_prototypes["cobalt-ore"] then
		config["cobalt-ore"] = {
			type="resource-ore",
			
			allotment=30,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=15},
			min_amount = 150,
			
			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["tungsten-ore"] = 3,
				["gold-ore"] = 3,
				["quartz"] = 3,
			}
		}
	end
	
	if game.entity_prototypes["nickel-ore"] then
		config["nickel-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 200,
			
			starting={richness=2000, size=10, probability=1},
			
			multi_resource_chance=0.30,
			multi_resource={
				["tungsten-ore"] = 3,
				["rutile-ore"] = 3,
				["lead-ore"] = 3,
				["quartz"] = 3,
			}
		}
		
	end
	
	if game.entity_prototypes["sulfur"] then
		config["sulfur"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=15},
			min_amount = 250,
			
			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["tin-ore"] = 3,
				["tungsten-ore"] = 3,
				["rutile-ore"] = 3,
			}
		}
	end
	
	if game.entity_prototypes["gem-ore"] then
		config["gem-ore"] = {
			type="resource-ore",
			
			allotment=30,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=15},
			min_amount = 250,
			
			multi_resource_chance=0.30,
			multi_resource={
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tungsten-ore"] = 3,
				["rutile-ore"] = 3,
			}
		}
	end
	
	if game.entity_prototypes["cobalt-ore"] and game.entity_prototypes["nickel-ore"] then
		config["cobalt-ore"].multi_resource["nickel-ore"] = 3
		config["nickel-ore"].multi_resource["cobalt-ore"] = 3
	end
	
	if game.entity_prototypes["gem-ore"] and game.entity_prototypes["nickel-ore"] then
		config["gem-ore"].multi_resource["nickel-ore"] = 3
		config["nickel-ore"].multi_resource["gem-ore"] = 3
	end
	
	if game.entity_prototypes["gem-ore"] and game.entity_prototypes["cobalt-ore"] then
		config["gem-ore"].multi_resource["cobalt-ore"] = 3
		config["cobalt-ore"].multi_resource["gem-ore"] = 3
	end

	config["chalcopyrite-ore"] = {
		type="resource-ore",
		
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=90000,
		size={min=20, max=25},
		min_amount=500,

		starting={richness=45000, size=20, probability=1},
		
	}

	config["copper-ore"].starting = nil
	config["copper-ore"].allotment = 60
	
	config["hematite"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=80, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=25000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=15, max=25}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=300,
		
		-- resource provided at starting location
		-- probability: 1 = 100% chance to be in starting area
		--              0 = resource is not in starting area
		starting={richness=15000, size=20, probability=1},
		
	}

	config["lignite-ore"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=80, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=250000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=20, max=30}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=1000,
		
		-- resource provided at starting location
		-- probability: 1 = 100% chance to be in starting area
		--              0 = resource is not in starting area
		starting={richness=150000, size=30, probability=1},
	}
	
	config["salpeter"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=50, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=15000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=10, max=20}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=250,
		
	}
	
	config["cryolite"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=50, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=10000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=10, max=20}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=250,
		
	}
	
	config["magma"] = {
		type="resource-ore",
		
		-- general spawn params
		allotment=60, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=15000000,        -- resource_ore has only one richness value - resource-liquid has min/max
		
		size={min=5, max=10}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=25000,
		
		-- resource provided at starting location
		-- probability: 1 = 100% chance to be in starting area
		--              0 = resource is not in starting area
		starting={richness=5000000, size=5, probability=1},
	}
	
	config["coal"] = {
		type="resource-ore",
		
		allotment=80,
		
		spawns_per_region={min=1, max=1},
		size={min=20, max=30},
		richness=300000,
		min_amount=500,

		starting={richness=200000, size=30, probability=1},
	}
end