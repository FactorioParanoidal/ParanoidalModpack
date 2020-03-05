data:extend(
{
	{
		type = "technology",
		name = "nuclear-fuel-1",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/nuclear-fuel.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "nuclear-fuel"
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
		name = "nuclear-fuel-2",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/nuclear-fuel.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "hypernuclear-fuel"
			},
		},
		prerequisites = {"nuclear-fuel-1"},
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
		name = "nuclear-fuel-3",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/nuclear-fuel.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "turbonuclear-fuel"
			},
		},
		prerequisites = {"nuclear-fuel-2"},
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
		name = "radiothermal-fuel-1",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/radiothermal-fuel.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "radiothermal-fuel"
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
		name = "radiothermal-fuel-2",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/radiothermal-fuel.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "superradiothermal-fuel"
			},
		},
		prerequisites = {"radiothermal-fuel-1"},
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
		name = "radiothermal-fuel-3",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/radiothermal-fuel.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "ultraradiothermal-fuel"
			},
		},
		prerequisites = {"radiothermal-fuel-2"},
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
}
)