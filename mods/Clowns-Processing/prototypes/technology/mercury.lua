if mods["angelsbioprocessing"] then
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
				recipe = "neurotoxin-capsule"
			},
			{
				type = "unlock-recipe",
				recipe = "methylmercury-algae"
			},
			{
				type = "unlock-recipe",
				recipe = "algae-violet"
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
				recipe = "thermal-filtering-mercury"
			},
			{
				type = "unlock-recipe",
				recipe = "dimethylmercury-synthesis"
			}, 
		},
		prerequisites = {"mercury-processing-1", "military-3"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
			},
			time = 30,
			count = 50
		},
		order = "e"
	},
	
}
)
end