function fillBoboresConfig(config)
	
	-- BobOres
	-- up resources at start
	config.nauvis["stone"].allotment = 80
	config.nauvis["stone"].starting.richness = 20000
	config.nauvis["stone"].richness = 13000
  config.nauvis["iron-ore"].starting.richness = 40000
  config.nauvis["copper-ore"].starting.richness = 20000
  config.nauvis.coal.starting.richness = 12000
  config.nauvis.coal.starting.size = 25

  --Adjust crude oil
  config.nauvis["crude-oil"].minimum_amount = 600000
  config.nauvis["crude-oil"].richness.min = 1000000
  config.nauvis["crude-oil"].richness.max = 1800000
  config.nauvis["crude-oil"].size = {min = 6, max = 14}
	
	local function checkOre(name)
		local data = prototypes.entity[name]
		if data and data.autoplace_specification then
			return true
		end
		return false
	end
	
	if checkOre("bob-gold-ore") then
		config.nauvis["bob-gold-ore"] = {
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 250,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-silver-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-zinc-ore"] = 3,
				["bob-bauxite-ore"] = 3,
			}
		}
	end
	
	if checkOre("bob-silver-ore") then
		config.nauvis["bob-silver-ore"] = {
			type="resource-ore",
			
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=10, max=20},
			min_amount = 250,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-zinc-ore"] = 3,
				["bob-bauxite-ore"] = 3,
			}
		}
	end
		
	if checkOre("bob-lead-ore") then
		config.nauvis["bob-lead-ore"] = {
			type="resource-ore",
			
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=10, max=20},
			min_amount = 250,
			
			starting={richness=10000, size=18, probability=1},
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-zinc-ore"] = 3,
				["bob-bauxite-ore"] = 3,
			}
		}
	end
		
	if checkOre("bob-tin-ore") then
		config.nauvis["bob-tin-ore"] = {
			type="resource-ore",
			
			allotment=80,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=10, max=20},
			min_amount = 250,
			
			starting={richness=15000, size=15, probability=1},
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-zinc-ore"] = 3,
				["copper-ore"] = 2,
				["bob-bauxite-ore"] = 3,
			}
		}
	end
		
	if checkOre("bob-tungsten-ore") then
		config.nauvis["bob-tungsten-ore"] = {
			type="resource-ore",
			
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=20},
			min_amount = 200,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-zinc-ore"] = 3,
				["bob-bauxite-ore"] = 3,
				["bob-rutile-ore"] = 3,
			}
		}
	end	
		
	if checkOre("bob-zinc-ore") then
		config.nauvis["bob-zinc-ore"] = {
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 250,

			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-bauxite-ore"] = 3,
			}
		}
	end
		
	if checkOre("bob-bauxite-ore") then
		config.nauvis["bob-bauxite-ore"] = {
			type="resource-ore",
			
			allotment=70,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 200,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-zinc-ore"] = 3,
			}
		}
	end
		
	if checkOre("bob-rutile-ore") then
		config.nauvis["bob-rutile-ore"] = {
			type="resource-ore",
			
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=20},
			min_amount = 200,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-zinc-ore"] = 3,
				["bob-tungsten-ore"] = 3,
			}
		}
	end
		
	if checkOre("bob-quartz") then
		config.nauvis["bob-quartz"] = {
			type="resource-ore",
			
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 250,
			
			starting={richness=6000, size=15, probability=1},
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-zinc-ore"] = 3,
			}
		}
	end
	
	if checkOre("bob-cobalt-ore") then
		config.nauvis["bob-cobalt-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=15},
			min_amount = 250,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-quartz"] = 3,
			}
		}
	end
	
	if checkOre("bob-nickel-ore") then
		config.nauvis["bob-nickel-ore"] = {
			type="resource-ore",
			
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness=6000,
			size={min=10, max=20},
			min_amount = 200,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-tungsten-ore"] = 3,
				["bob-rutile-ore"] = 3,
				["bob-lead-ore"] = 3,
				["bob-quartz"] = 3,
			}
		}
		
	end
	
	if checkOre("bob-sulfur") then
		config.nauvis["bob-sulfur"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=8000,
			size={min=10, max=20},
			min_amount = 250,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-lead-ore"] = 3,
				["bob-tin-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-rutile-ore"] = 3,
			}
		}
	end
	
	if checkOre("bob-gem-ore") then
		config.nauvis["bob-gem-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=800,
			size={min=10, max=15},
			min_amount = 100,
			
			multi_resource_chance=0.20,
			multi_resource={
				["bob-silver-ore"] = 3,
				["bob-gold-ore"] = 3,
				["bob-tungsten-ore"] = 3,
				["bob-rutile-ore"] = 3,
			}
		}
	end
	
	if checkOre("bob-cobalt-ore") and checkOre("bob-nickel-ore") then
		config.nauvis["bob-cobalt-ore"].multi_resource["bob-nickel-ore"] = 3
		config.nauvis["bob-nickel-ore"].multi_resource["bob-cobalt-ore"] = 3
	end
	
	if checkOre("bob-gem-ore") and checkOre("bob-nickel-ore") then
		config.nauvis["bob-gem-ore"].multi_resource["bob-nickel-ore"] = 3
		config.nauvis["bob-nickel-ore"].multi_resource["bob-gem-ore"] = 3
	end
	
	if checkOre("bob-gem-ore") and checkOre("bob-cobalt-ore") then
		config.nauvis["bob-gem-ore"].multi_resource["bob-cobalt-ore"] = 3
		config.nauvis["bob-cobalt-ore"].multi_resource["bob-gem-ore"] = 3
	end
	
	if checkOre("bob-ground-water") then
		config.nauvis["bob-ground-water"] =
		{
			type="resource-liquid",
			minimum_amount=1200000,
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness={min=1200000, max=1200000}, -- richness per resource spawn
			size={min=8, max=14},
		}
    if settings.startup["bobmods-ores-startinggroundwater"].value == true then
			config.nauvis["bob-ground-water"].starting={richness=5000000, size=10, probability=1}
    end
	end



	if checkOre("bob-lithia-water") then
		config.nauvis["bob-lithia-water"] =
		{
			type="resource-liquid",
			minimum_amount=900000,
			allotment=50,
			spawns_per_region={min=1, max=1},
			richness={min=900000, max=900000}, -- richness per resource spawn
			size={min=6, max=12},
		}
	end

	if checkOre("bob-thorium-ore") then
		config.nauvis["bob-thorium-ore"] = {
			type="resource-ore",
			
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=4000,
			size={min=10, max=15},
			min_amount = 200,
		}
	end

--	if game.entity_prototypes["bob-ground-water"] and game.entity_prototypes["bob-lithia-water"] then
--		config.nauvis["bob-ground-water"].multi_resource_chance = 0.50
--		config.nauvis["bob-ground-water"].multi_resource = config["bob-ground-water"].multi_resource or {}
--		config.nauvis["bob-ground-water"].multi_resource["bob-lithia-water"] = 1
--		config.nauvis["bob-lithia-water"].multi_resource = config["bob-lithia-water"].multi_resource or {}
--		config.nauvis["bob-lithia-water"].multi_resource_chance = 0.50
--		config.nauvis["bob-lithia-water"].multi_resource["bob-ground-water"] = 1
--	end

end