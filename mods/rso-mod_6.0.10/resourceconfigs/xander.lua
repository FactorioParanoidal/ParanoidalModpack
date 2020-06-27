function fillXanderConfig(config)

--Base "coal" changes
config["coal"].allotment = 110
config["coal"].spawns_per_region = {min = 1, max = 2}
config["coal"].richness = 20000
config["coal"].size = {min = 15, max = 25}
config["coal"].min_amount = 100
config["coal"].starting = {richness = 60000, size = 35, probability = 1}
config["coal"].multi_resource_chance = 0.15
config["coal"].multi_resource =
{
	["uranium-ore"] = 1
}

--Base "copper-ore" changes
config["copper-ore"].allotment = 110
config["copper-ore"].spawns_per_region = {min = 1, max = 2}
config["copper-ore"].richness = 20000
config["copper-ore"].size = {min = 15, max = 25}
config["copper-ore"].min_amount = 100
config["copper-ore"].starting = {richness = 20000, size = 25, probability = 1}
config["copper-ore"].multi_resource_chance = 0.15
config["copper-ore"].multi_resource =
{
	["coal"] = 1
}

--Base "crude-oil" changes
config["crude-oil"].allotment = 100
config["crude-oil"].spawns_per_region = {min = 1, max = 2}
config["crude-oil"].richness = {min = 200000, max = 400000}
config["crude-oil"].size = {min = 5, max = 10}
config["crude-oil"].starting = {richness = 400000, size = 6, probability = 1}
config["crude-oil"].multi_resource_chance = 0.15
config["crude-oil"].multi_resource =
{
	["copper-ore"] = 1
}
--Evaporites
	config["evaporites"] =
	{
		type = "resource-ore",
		allotment = 90,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		starting = {richness = 5000, size = 30, probability = 1},
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["crude-oil"] = 1
		}
	}
--Igneous Sulfide Ore
	config["igneous-sulfide"] =
	{
		type = "resource-ore",
		allotment = 100,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["evaporites"] = 1
		}
	}
--Base "iron-ore" changes
config["iron-ore"].allotment = 130
config["iron-ore"].spawns_per_region = {min = 1, max = 2}
config["iron-ore"].richness = 20000
config["iron-ore"].size = {min = 15, max = 25}
config["iron-ore"].min_amount = 100
config["iron-ore"].starting = {richness = 30000, size = 25, probability = 1}
config["iron-ore"].multi_resource_chance = 0.15
config["iron-ore"].multi_resource =
{
	["igneous-sulfide"] = 1
}
--Laterite
	config["laterite"] =
	{
		type = "resource-ore",
		allotment = 120,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		starting = {richness = 40000, size = 25, probability = 1},
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["iron-ore"] = 1
		}
	}
--Magnetic Ore
	config["magnetic"] =
	{
		type = "resource-ore",
		allotment = 90,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["laterite"] = 1
		}
	}
--Massive Sulfide Ore
	config["massive-sulfide"] =
	{
		type = "resource-ore",
		allotment = 100,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		starting = {richness = 20000, size = 20, probability = 1},
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["magnetic"] = 1
		}
	}
--Natural Gas
	config["natural-gas"] =
	{
		type = "resource-liquid",
		minimum_amount = 120000,
		allotment = 100,
		spawns_per_region = {min = 1, max = 2},
		richness = {min = 200000, max = 400000},
		size = {min = 5, max = 10},
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["massive-sulfide"] = 1
		}
	}
--Phosphorite
	config["phosphorite"] =
	{
		type = "resource-ore",
		allotment = 80,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["natural-gas"] = 1
		}
	}
--Economic Sand
	config["sand-heavy"] =
	{
		type = "resource-ore",
		allotment = 100,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		starting = {richness = 20000, size = 25, probability = 1},
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["phosphorite"] = 1
		}
	}
--Skarn-Type Ore
	config["skarn"] =
	{
		type = "resource-ore",
		allotment = 100,
		spawns_per_region = {min = 1, max = 2},
		richness = 20000,
		size = {min = 15, max = 25},
		min_amount = 100,
		starting = {richness = 20000, size = 20, probability = 1},
		multi_resource_chance = 0.15,
		multi_resource =
		{
			["sand"] = 1
		}
	}
--Base "stone" changes
config["stone"].allotment = 110
config["stone"].spawns_per_region = {min = 1, max = 2}
config["stone"].richness = 20000
config["stone"].size = {min = 15, max = 25}
config["stone"].min_amount = 100
config["stone"].starting = {richness = 20000, size = 25, probability = 1}
config["stone"].multi_resource_chance = 0.15
config["stone"].multi_resource =
{
	["skarn"] = 1
}
--Base "uranium-ore" changes
config["uranium-ore"].allotment = 60
config["uranium-ore"].spawns_per_region = {min = 1, max = 1}
config["uranium-ore"].richness = 20000
config["uranium-ore"].size = {min = 15, max = 25}
config["uranium-ore"].min_amount = 100
config["uranium-ore"].multi_resource_chance = 0.15
config["uranium-ore"].multi_resource =
{
	["stone"] = 1
}
end