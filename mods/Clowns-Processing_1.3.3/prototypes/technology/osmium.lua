data:extend(
{
	{
		type = "technology",
		name = "advanced-osmium-smelting",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/smelting-osmium.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "osmium-ore-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "osmium-processed-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "osmium-pellet-smelting"
			},
			{
				type = "unlock-recipe",
				recipe = "casting-powder-osmium"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-plate-osmium"
			},
		},
		prerequisites = {"powder-metallurgy-1", "ore-processing-2"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"utility-science-pack", 1}
			},
			time = 30,
			count = 100
		},
		order = "e"
	},
}
)