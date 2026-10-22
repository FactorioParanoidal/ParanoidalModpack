local function checkOre(name)
	local data = prototypes.entity[name]
	if data and data.autoplace_specification then
		return true
	end
	return false
end

local function fillAngelsOresConfig(config)
	if checkOre("angels-ore1") then
		config.nauvis["angels-ore1"] =
		{
			type="resource-ore",

			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=15000,
			size={min=20, max=25},
			min_amount = 150,

			multi_resource_chance=0.30,
			multi_resource={
				["angels-ore2"] = 3,
			}
		}

		if settings.startup["angels-starting-resource-ore1"].value then
			config.nauvis["angels-ore1"].starting={richness=12000, size=20, probability=1}
		end
	end

	if checkOre("angels-ore2") then
		config.nauvis["angels-ore2"] =
		{
			type="resource-ore",

			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=15, max=20},
			min_amount = 150,

			multi_resource_chance=0.30,
			multi_resource={
				["angels-ore3"] = 3,
			}
		}

		if settings.startup["angels-starting-resource-ore2"].value then
			config.nauvis["angels-ore2"].starting={richness=10000, size=15, probability=1}
		end
	end
	
	if checkOre("angels-ore3") then
		config.nauvis["angels-ore3"] =
		{
			type="resource-ore",

			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=15000,
			size={min=20, max=25},
			min_amount = 150,

			multi_resource_chance=0.30,
			multi_resource={
				["angels-ore4"] = 3,
			}
		}

		if settings.startup["angels-starting-resource-ore3"].value then
			config.nauvis["angels-ore3"].starting={richness=12000, size=20, probability=1}
		end
	end

	if checkOre("angels-ore4") then
		config.nauvis["angels-ore4"] =
		{
			type="resource-ore",

			allotment=60,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=15, max=20},
			min_amount = 150,

			multi_resource_chance=0.30,
			multi_resource={
				["angels-ore5"] = 3,
			}
		}

		if settings.startup["angels-starting-resource-ore4"].value then
			config.nauvis["angels-ore4"].starting={richness=10000, size=15, probability=1}
		end
	end
	
	if checkOre("angels-fissure") then
		config.nauvis["angels-fissure"] =
		{
			type="resource-liquid",
			minimum_amount=100000,
			allotment=40,
			spawns_per_region={min=1, max=1},
			richness={min=75000, max=200000}, -- richness per resource spawn
			size={min=1, max=3},
		}
	end
	
	if checkOre("angels-ore5") then
		config.nauvis["angels-ore5"] =
		{
			type="resource-ore",

			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=15, max=20},
			min_amount = 150,

			multi_resource_chance=0.30,
			multi_resource={
				["angels-ore6"] = 3,
			}
		}

		if settings.startup["angels-starting-resource-ore5"].value then
		config.nauvis["angels-ore5"].starting={richness=8000, size=20, probability=1}
		end
	end
	
	if checkOre("angels-ore6") then
		config.nauvis["angels-ore6"] = 
		{
			type="resource-ore",

			allotment=40,
			spawns_per_region={min=1, max=1},
			richness=12000,
			size={min=15, max=20},
			min_amount = 150,

			multi_resource_chance=0.30,
			multi_resource={
				["angels-ore1"] = 3,
			}
		}

		if settings.startup["angels-starting-resource-ore6"].value then
		config.nauvis["angels-ore6"].starting={richness=8000, size=20, probability=1}
		end
	end

	if script.active_mods["angelspetrochem"] then
		config.nauvis["angels-natural-gas"] =
		{
			type="resource-liquid",
			minimum_amount=4000, -- reduced from 10k
			allotment=60,
			spawns_per_region={min=1, max=1},
			richness={min=4000, max=12000}, -- richness per resource spawn --reduced from 10k and 30k
			size={min=2, max=3},

			starting={richness=4000, size=1, probability=1}, --reduced from 20k to 4k for spawn are to bring it inline with the oil spawn, reduced size from 2 to 1, now about 1-2x that of the oil spawn

			multi_resource_chance=0.20,
			multi_resource={
				["crude-oil"] = 4,
			}
		}

		config.nauvis["crude-oil"].allotment=60
		config.nauvis["crude-oil"].spawns_per_region={min=1, max=1}
		config.nauvis["crude-oil"].size={min=2, max=6} --increased max from 4 to 6

	end

	-- RSO Reforged: weight of a resource near the start (near) and far from it (far), see
	-- distance_near/distance_far in config.lua. Ores of the starting area are found more often
	-- close to it, the others further away.
	local distance_weights = {
		["angels-ore1"] = {near = 1.2, far = 0.85},
		["angels-ore3"] = {near = 1.2, far = 0.85},
		["angels-ore2"] = {near = 0.8, far = 1.3},
		["angels-ore4"] = {near = 0.8, far = 1.3},
		["angels-fissure"] = {near = 0.5, far = 1.6},
		["coal"] = {near = 1.1, far = 0.9},
	}
	for name, weight in pairs(distance_weights) do
		if config.nauvis[name] then
			config.nauvis[name].distance_weight = weight
		end
	end
end

return fillAngelsOresConfig
