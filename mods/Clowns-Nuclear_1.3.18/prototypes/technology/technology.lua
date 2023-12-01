data:extend(
{
	
	{
		type = "technology",
		name = "mixed-oxide-fuel",
		icon_size = 128,
		icon = "__Clowns-Nuclear__/graphics/technology/mixed-oxide.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "mixed-oxide"
			},
		},
		prerequisites = {"nuclear-power"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1}
			},
			time = 30,
			count = 100
		},
		order = "e-p-b-c"
	},
	{
		type = "technology",
		name = "thermonuclear-bomb",
		icon_size = 128,
		icon = "__Clowns-Nuclear__/graphics/technology/thermonuclear-bomb.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "thermonuclear-bomb"
			}
		},
		prerequisites = {"atomic-bomb"},
		unit =
		{
			count = 10000,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1}
			},
			time = 45
		},
		order = "e-a-b"
	},
}
)