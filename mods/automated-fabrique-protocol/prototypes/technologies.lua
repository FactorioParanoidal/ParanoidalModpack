local ATTP_PREREQUISITES = {
	"circuit-network",
	"fluid-handling",
	"fluid-wagon",
	"gate",
	"fast-inserter",
	"railway",
	"rail-signals",
	"electric-mining",
	"bi-tech-wooden-pole-1",
}
local ATTP_2_PREREUISITES =
	{ ATTP_1_TECHNOLOGY_NAME, "logistics-2", "logistic-science-pack", "automation-2", "gun-turret" }
local ATTP_3_PREREQUISITES =
	{ ATTP_2_TECHNOLOGY_NAME, "warehouse-research", "utility-science-pack", "logistics-3", "automation-3" }
local ATTP_4_PREREQUISITES = { ATTP_3_TECHNOLOGY_NAME, "utility-science-pack", "production-science-pack" }
data:extend({
	{
		type = "technology",
		name = ATTP_1_TECHNOLOGY_NAME,
		icon = "__base__/graphics/technology/circuit-network.png",
		icon_size = 256,
		icon_mipmaps = 4,
		prerequisites = ATTP_PREREQUISITES,
		unit = {
			count = 500,
			ingredients = { { "automation-science-pack", 1 } },
			time = 120,
		},
	},
	{
		type = "technology",
		name = ATTP_2_TECHNOLOGY_NAME,
		icon = "__base__/graphics/technology/circuit-network.png",
		icon_size = 256,
		icon_mipmaps = 4,
		prerequisites = ATTP_2_PREREUISITES,
		unit = {
			count = 150,
			ingredients = {
				{ "automation-science-pack", 3 },
				{ "logistic-science-pack", 1 },
			},
			time = 120,
		},
	},
	{
		type = "technology",
		name = ATTP_3_TECHNOLOGY_NAME,
		icon = "__base__/graphics/technology/circuit-network.png",
		icon_size = 256,
		icon_mipmaps = 4,
		prerequisites = ATTP_3_PREREQUISITES,
		unit = {
			count = 150,
			ingredients = {
				{ "automation-science-pack", 5 },
				{ "logistic-science-pack", 2 },
				{ "utility-science-pack", 1 },
			},
			time = 120,
		},
	},
	{
		type = "technology",
		name = ATTP_4_TECHNOLOGY_NAME,
		icon = "__base__/graphics/technology/circuit-network.png",
		icon_size = 256,
		icon_mipmaps = 4,
		prerequisites = ATTP_4_PREREQUISITES,
		unit = {
			count = 200,
			ingredients = {
				{ "automation-science-pack", 10 },
				{ "logistic-science-pack", 6 },
				{ "utility-science-pack", 3 },
				{ "production-science-pack", 1 },
			},
			time = 120,
		},
	},
})

--[[attp technologies
	TreeRecipeUtil.add_prerequisites_to_technologyWithoutMode(technologies[ATTP_1_TECHNOLOGY_NAME], {
		"factory-architecture-t1",
		"factory-connection-type-chest",
		"factory-connection-type-fluid",
		"factory-connection-type-circuit",
		"factory-interior-upgrade-lights",
		"factory-interior-upgrade-display",
	})
	TreeRecipeUtil.add_prerequisites_to_technology(technologies[ATTP_2_TECHNOLOGY_NAME], { "factory-architecture-t2" })
	TreeRecipeUtil.add_prerequisites_to_technology(technologies[ATTP_3_TECHNOLOGY_NAME], { "factory-recursion-t1" })
	TreeRecipeUtil.add_prerequisites_to_technology(technologies[ATTP_4_TECHNOLOGY_NAME], { "factory-recursion-t2" })]]
