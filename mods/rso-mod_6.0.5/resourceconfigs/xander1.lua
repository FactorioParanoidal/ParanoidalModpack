function fillXander1Config(config)

--Apatite
	config["apatite"] =
	{
		type = "resource-ore",
		allotment = 80,
		spawns_per_region = {min = 1, max = 1},
		richness = 10000,
		size = {min = 15, max = 25},
		min_amount = 250,
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["bauxite"] = 5,
			["sulfidic-ore"] = 2
		}
	}
--Bauxite
	config["bauxite"] =
	{
		type = "resource-ore",
		allotment = 150,
		spawns_per_region = {min = 1, max = 2},
		richness = 15000,
		size = {min = 15, max = 25},
		min_amount = 250,
		starting = {richness = 40000, size = 25, probability = 1},
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["garnierite"] = 5,
			["apatite"] = 2
		}
	}
--Base "coal" changes
config["coal"].allotment = 120
config["coal"].spawns_per_region = {min = 1, max = 2}
config["coal"].richness = 15000
config["coal"].size = {min = 15, max = 25}
config["coal"].starting = {richness = 60000, size = 35, probability = 1}
config["coal"].multi_resource_chance = 0.2
config["coal"].multi_resource =
{
	["natural-gas"] = 5,
	["bauxite"] = 2
}

--Base "copper-ore" changes
config["copper-ore"].allotment = 120
config["copper-ore"].spawns_per_region = {min = 1, max = 2}
config["copper-ore"].richness = 15000
config["copper-ore"].size = {min = 15, max = 25}
config["copper-ore"].starting = {richness = 20000, size = 25, probability = 1}
config["copper-ore"].multi_resource_chance = 0.2
config["copper-ore"].multi_resource =
{
	["sulfidic-ore"] = 5,
	["coal"] = 2
}

--Base "crude-oil" changes
config["crude-oil"].allotment = 110
config["crude-oil"].spawns_per_region = {min = 1, max = 1}
config["crude-oil"].richness = {min = 240000, max = 500000}
config["crude-oil"].size = {min = 5, max = 10}
config["crude-oil"].starting = {richness = 400000, size = 6, probability = 1}
config["crude-oil"].multi_resource_chance = 0.2
config["crude-oil"].multi_resource =
{
	["coal"] = 5,
	["copper-ore"] = 2
}

--Garnierite
	config["garnierite"] =
	{
		type = "resource-ore",
		allotment = 80,
		spawns_per_region = {min = 1, max = 1},
		richness = 10000,
		size = {min = 15, max = 25},
		min_amount = 250,
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["apatite"] = 5,
			["crude-oil"] = 2
		}
	}
--Granitic Ore
	config["granitic"] =
	{
		type = "resource-ore",
		allotment = 90,
		spawns_per_region = {min = 1, max = 1},
		richness = 10000,
		size = {min = 15, max = 25},
		min_amount = 250,
		starting = {richness = 20000, size = 20, probability = 1},
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["heavy-sand"] = 5,
			["garnierite"] = 2
		}
	}
--Heavy Mineral Sand
	config["heavy-sand"] =
	{
		type = "resource-ore",
		allotment = 50,
		spawns_per_region = {min = 1, max = 1},
		richness = 10000,
		size = {min = 15, max = 25},
		min_amount = 250,
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["uranium-ore"] = 5,
			["granitic"] = 2
		}
	}
--Base "iron-ore" changes
config["iron-ore"].allotment = 100
config["iron-ore"].spawns_per_region = {min = 1, max = 2}
config["iron-ore"].richness = 15000
config["iron-ore"].size = {min = 15, max = 25}
config["iron-ore"].starting = {richness = 30000, size = 25, probability = 1}
config["iron-ore"].multi_resource_chance = 0.2
config["iron-ore"].multi_resource =
{
	["stone"] = 5,
	["heavy-sand"] = 2
}

--Lead Ore
	config["lead-ore"] =
	{
		type = "resource-ore",
		allotment = 70,
		spawns_per_region = {min = 1, max = 1},
		richness = 10000,
		size = {min = 15, max = 25},
		min_amount = 250,
		starting = {richness = 20000, size = 20, probability = 1},
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["copper-ore"] = 5,
			["iron-ore"] = 2
		}
	}
--Mineral Water
	config["mineral-water"] =
	{
		type = "resource-liquid",
		minimum_amount = 120000,
		allotment = 100,
		spawns_per_region = {min = 1, max = 2},
		richness = {min = 300000, max = 500000},
		size = {min = 5, max = 10},
		starting = {richness = 400000, size = 8, probability = 1},
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["iron-ore"] = 5,
			["lead-ore"] = 2
		}
	}
--Natural Gas
	config["natural-gas"] =
	{
		type = "resource-liquid",
		minimum_amount = 120000,
		allotment = 60,
		spawns_per_region = {min = 1, max = 1},
		richness = {min = 300000, max = 400000},
		size = {min = 5, max = 10},
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["crude-oil"] = 5,
			["mineral-water"] = 2
		}
	}
--Base "uranium-ore" changes
config["uranium-ore"].allotment = 50
config["uranium-ore"].spawns_per_region = {min = 1, max = 1}
config["uranium-ore"].richness = 10000
config["uranium-ore"].size = {min = 10, max = 20}
config["uranium-ore"].multi_resource =
{
	["granitic"] = 5,
	["natural-gas"] = 2
}

--Base "stone" changes
config["stone"].allotment = 150
config["stone"].spawns_per_region = {min = 1, max = 2}
config["stone"].richness = 15000
config["stone"].size = {min = 15, max = 25}
config["stone"].starting = {richness = 20000, size = 25, probability = 1}
config["stone"].multi_resource_chance = 0.2
config["stone"].multi_resource =
{
	["mineral-water"] = 5,
	["uranium-ore"] = 2
}

--Sulfidic Ore
	config["sulfidic-ore"] =
	{
		type = "resource-ore",
		allotment = 150,
		spawns_per_region = {min = 1, max = 2},
		richness = 15000,
		size = {min = 15, max = 25},
		min_amount = 250,
		multi_resource_chance = 0.2,
		multi_resource =
		{
			["lead-ore"] = 5,
			["stone"] = 2
		}
	}

end