data:extend(
{
	{
		type = "technology",
		name = "nuclear-fuel-reprocessing-2",
		icon = "__base__/graphics/technology/nuclear-fuel-reprocessing.png",
		icon_size = 256,
        icon_mipmaps = 4,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "advanced-nuclear-fuel-reprocessing"
			},
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
				recipe = "advanced-thorium-nuclear-fuel-reprocessing-b"
			},
			{
				type = "unlock-recipe",
				recipe = "thorium-nuclear-fuel-reprocessing"
			},
		},
		prerequisites = {"nuclear-fuel-reprocessing-2"}, --temp
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