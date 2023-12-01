function fillDytechConfig(config)
	
	-- dytech is the only mod which is listed in the dependencies (info.json)
	-- so it is safe to use remote.interfaces (some resources are shared with bobs ores - so it's unsafe to check for those -> better use remote.interfaces)
	if remote.interfaces["DyTech-Core"] then
		config["stone"].allotment = 80
		config["stone"].richness = 20000
		config["stone"].starting.richness = 8000
	end
	
	if remote.interfaces["DyTech-Core"] then
		-- exotic ores
		config["gold-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=15, max=20},
			min_amount = 150,
			
			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["silver-ore"] = 3,
				["tin-ore"] = 3,
				["tungsten-ore"] = 3,
				["zinc-ore"] = 3,
				["gems"] = 2
			}
		}
		config["silver-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=10, max=20},
			min_amount = 150,
			
			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["tungsten-ore"] = 3,
				["zinc-ore"] = 3,
				["cobalt-ore"] = 2,
			}
		}
		
		config["lead-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=10, max=20},
			min_amount = 300,
			
			starting={richness=3000, size=15, probability=1},
			
			multi_resource_chance=0.30,
			multi_resource={
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["tungsten-ore"] = 3,
				["zinc-ore"] = 3,
				["gems"] = 2
			}
		}
		
		config["bauxite-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=10000,
			size={min=10, max=20},
			min_amount = 300,
			
			starting={richness=3000, size=15, probability=1},
			
			multi_resource_chance=0.30,
			multi_resource={
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["tungsten-ore"] = 3,
				["zinc-ore"] = 3,
				["gems"] = 2
			}
		}
		
		config["tin-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=12000,
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
			}
		}
		
		config["zinc-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=20},
			min_amount = 250,

			starting={richness=2000, size=15, probability=1},

			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["tungsten-ore"] = 3,
				["gems"] = 2
			}
		}
		
		
		config["tungsten-ore"] = {
			type="resource-ore",
			
			allotment=30,
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
				["cobalt-ore"] = 1
			}
		}
		
		config["gems"] = {
			type="resource-ore",
			
			allotment=30,
			spawns_per_region={min=1, max=1},
			richness=2000,
			size={min=15, max=20},
			min_amount = 30,
			
			multi_resource_chance=0.30,
			multi_resource={
				["stone"] = 1,
				["lead-ore"] = 3,
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["tungsten-ore"] = 3,
				["zinc-ore"] = 3
			}
		}
		
		config["chromite-ore"] = {
			type="resource-ore",
			
			allotment=30,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=15},
			min_amount = 100,
			
			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["zinc-ore"] = 3,
				["cobalt-ore"] = 3,
			}
		}
		
		config["cobalt-ore"] = {
			type="resource-ore",
			
			allotment=30,
			spawns_per_region={min=1, max=1},
			richness=2000,
			size={min=10, max=15},
			min_amount = 150,
			
			
			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["zinc-ore"] = 3,
				["ardite-ore"] = 3,
			}
		}
		
		config["rutile-ore"] = {
			type="resource-ore",
			
			allotment=30,
			spawns_per_region={min=1, max=1},
			richness=2000,
			size={min=10, max=15},
			min_amount = 150,
			
			
			multi_resource_chance=0.30,
			multi_resource={
				["lead-ore"] = 3,
				["silver-ore"] = 3,
				["gold-ore"] = 3,
				["tin-ore"] = 3,
				["zinc-ore"] = 3,
				["ardite-ore"] = 3,
			}
		}
	end
	
	-- lava is added by DyTech-Machine
	if remote.interfaces["DyTech-Machine"] then
		config["lava-600"] = {
			type="resource-liquid",
			minimum_amount=125000,
			
			allotment=25,
			spawns_per_region={min=1, max=1},
			richness={min=150000, max=400000}, -- total richness of site
			size={min=2, max=3}, -- richness divided by this number
			
			absolute_probability=0.01,
			
			starting={richness=150000, size=1, probability=0.4},
			multi_resource_chance=0.3,
			multi_resource={
				["lava-2800"] = 1,
				["lava-1400"] = 2,
				["lava-600"] = 4
			}
		}
	end
	
end
