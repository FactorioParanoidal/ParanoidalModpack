data:extend(
{
	{
		type = "technology",
		name = "thorium-nuclear-power",
		icon_size = 128,
		icon = "__Clowns-Nuclear__/graphics/technology/thorium-nuclear-power.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "thorium-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "thorium-fuel-cell"
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
			count = 200
		},
		order = "e-p-b-c"
	},
}
)