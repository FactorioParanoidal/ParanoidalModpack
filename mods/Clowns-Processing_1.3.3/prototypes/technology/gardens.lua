data:extend(
{
	{
		type = "technology",
		name = "garden-mutation",
		icon = "__angelsbioprocessing__/graphics/technology/seed-extractor-tech.png",
		icon_size = 128,
		order = "c",
		prerequisites =
		{
			"nuclear-power",
			"gardens"
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "temperate-garden-mutation"
			},
			{
				type = "unlock-recipe",
				recipe = "desert-garden-mutation"
			},
			{
				type = "unlock-recipe",
				recipe = "swamp-garden-mutation"
			},
		},
		unit =
		{
			count = 64,
			ingredients =
			{
				{"automation-science-pack", 4},
				{"logistic-science-pack", 4},
				{"chemical-science-pack", 4},
				{"utility-science-pack", 4},
				{"token-bio", 1}
			},
			time = 30
		},
	},
}
)