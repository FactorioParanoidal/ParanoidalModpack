data:extend(
{
	
	{
		type = "technology",
		name = "centrifuging-1",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/advanced-centrifuging.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "centrifuge-mk2"
			},
			
		},
		prerequisites = {"nuclear-power"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1}
			},
			time = 30,
			count = 300
		},
		order = "f"
	},
	{
		type = "technology",
		name = "centrifuging-2",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/advanced-centrifuging.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "centrifuge-mk3"
			},
		},
		prerequisites = {"centrifuging-1"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1}
			},
			time = 30,
			count = 500
		},
		order = "f"
	},
}
)