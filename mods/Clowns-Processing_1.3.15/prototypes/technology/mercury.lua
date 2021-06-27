data:extend(
{
	{
		type = "technology",
		name = "mercury-processing-1",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/mercury-tech.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "thermal-filtering-mercury"
			},
		},
		prerequisites = {"thermal-water-extraction", "angels-advanced-chemistry-3"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 30,
			count = 50
		},
		order = "e"
	},
	{
		type = "technology",
		name = "mercury-processing-2",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/mercury-tech.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "dimethylmercury-synthesis"
			},
			{
				type = "unlock-recipe",
				recipe = "neurotoxin-capsule"
			},
		},
		prerequisites = {"mercury-processing-1", "military-4"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"utility-science-pack", 1},
			},
			time = 30,
			count = 50
		},
		order = "e"
	},
	
}
)