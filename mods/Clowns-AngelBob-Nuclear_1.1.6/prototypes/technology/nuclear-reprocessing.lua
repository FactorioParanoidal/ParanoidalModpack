data:extend(
{
	{
		type = "technology",
		name = "nuclear-fuel-reprocessing",
		icon_size = 128,
		icon = "__base__/graphics/technology/nuclear-fuel-reprocessing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "nuclear-fuel-reprocessing"
			},
			--{
			--	type = "unlock-recipe",
			--	recipe = "thorium-nuclear-fuel-reprocessing"
			--},
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
			count = 1500
		},
		order = "e-p-b-c"
	},
	{
		type = "technology",
		name = "nuclear-fuel-reprocessing-2",
		icon_size = 128,
		icon = "__base__/graphics/technology/nuclear-fuel-reprocessing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "advanced-nuclear-fuel-reprocessing"
			},
			--{
			--	type = "unlock-recipe",
			--	recipe = "advanced-thorium-nuclear-fuel-reprocessing"
		  --},
		},
		prerequisites = {"nuclear-fuel-reprocessing"},
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
			count = 2000
		},
		order = "e-p-b-c"
	},

	{
		type = "technology",
		name = "thorium-nuclear-fuel-reprocessing",
		icon_size = 128,
		icon = "__Clowns-Nuclear__/graphics/technology/thorium-nuclear-fuel-reprocessing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "thorium-nuclear-fuel-reprocessing"
			},
		},
		prerequisites = {"thorium-nuclear-power"},
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
			count = 1500
		},
		order = "e-p-b-c"
	},
	{
		type = "technology",
		name = "thorium-nuclear-fuel-reprocessing-2",
		icon_size = 128,
		icon = "__Clowns-Nuclear__/graphics/technology/thorium-nuclear-fuel-reprocessing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "advanced-thorium-nuclear-fuel-reprocessing"
			},
			{
				type = "unlock-recipe",
				recipe = "advanced-thorium-nuclear-fuel-reprocessing|b"
			},
		},
		prerequisites = {"thorium-nuclear-fuel-reprocessing"},
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
			count = 2000
		},
		order = "e-p-b-c"
	}
}
)
