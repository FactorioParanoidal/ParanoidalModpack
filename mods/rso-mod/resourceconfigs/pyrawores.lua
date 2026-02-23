function fillPyRawOresConfig(config)
	local nauvisConfig = config.nauvis
	
	
	nauvisConfig["ore-aluminium"] = {
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
		starting={richness=8000, size=25, probability=1}
	}
	
	nauvisConfig["ore-chromium"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=2000, size=10, probability=1}
	}
	
	nauvisConfig["ore-lead"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=1}
	}
	
	nauvisConfig["ore-nickel"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=0}
	}
	
	nauvisConfig["ore-quartz"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=1}
	}
	
	nauvisConfig["raw-coal"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=1}
	}
	
	nauvisConfig["ore-tin"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=1}
	}
	
	nauvisConfig["ore-titanium"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=1}
	}
	
	nauvisConfig["ore-zinc"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=0}
	}

	nauvisConfig["ore-nexelit"] = {
		type="resource-ore",
		allotment=80,
		spawns_per_region={min=1, max=1},
		richness=25000,
		size={min=20, max=30}, 
		min_amount=250,
		starting={richness=8000, size=25, probability=1}
	}
	
	-- BIG ROCKS
	nauvisConfig["aluminium-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["chromium-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["coal-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["copper-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["iron-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["lead-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["nexelit-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["nickel-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["phosphate-rock-02"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["quartz-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["salt-rock"] = {
		type="resource-liquid",
		minimum_amount=100000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=200000, max=400000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true,
		
		starting={richness=150000, size=1, probability=1}
	}
	
	nauvisConfig["tin-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["titanium-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["uranium-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["zinc-rock"] = {
		type="resource-liquid",
		minimum_amount=500000,
		allotment=60,
		spawns_per_region={min=1, max=1},
		richness={min=3000000, max=5000000}, -- richness per resource spawn
		size={min=1, max=1},
		useOreScaling = true
	}
	
	nauvisConfig["coal"] = {
		type="empty"
	}
	
end
