data:extend(
	{
		{
			type = "technology",
			name = "thorium-ore-processing",
			icon_size = 128,
			icon = "__Clowns-AngelBob-Nuclear__/graphics/technology/thorium-processing.png",
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "clowns-thorium-purification"
				},
				{
					type = "unlock-recipe",
					recipe = "thorium-crystallisation"
				},
				{
					type = "unlock-recipe",
					recipe = "clowns-thorium-ore-processing"
				},
				{
					type = "unlock-recipe",
					recipe = "thorium-processing"
				},
			},
			prerequisites = {
				"advanced-uranium-processing-2",
				"mixed-oxide-fuel",
				"angels-ore-electro-whinning-cell"
			},
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack",    1 },
				},
				time = 30,
				count = 100
			},
			order = "e-p-b-c"
		}
	}
)
