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
				recipe = "clowns-osmium-ore-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-osmium-processed-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-osmium-pellet-smelting"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-casting-powder-osmium"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-plate-osmium"
			},
			{
				type = "unlock-recipe",
				recipe = "clowns-osmium-rounds-magazine"
			},
		},
		prerequisites = {"angels-powder-metallurgy-4", "angels-ore-processing-3", "angels-sodium-processing-2", "angels-rocket-booster-2", "military-3"},
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
			count = 100
		},
		order = "e"
	},
}
)