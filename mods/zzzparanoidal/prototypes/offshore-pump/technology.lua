data:extend({
	{
		type = "technology",
		name = "offshore-mk2-pump",
		icon_size = 256,
		icon_mipmaps = 4,
		icon = "__zzzparanoidal__/graphics/technology/offshore-pump-2.png",
		prerequisites = { "advanced-circuit", "bob-fluid-handling-2" },
		effects = { { type = "unlock-recipe", recipe = "offshore-mk2-pump" } },
		unit = {
			count = 50,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
			},
			time = 30,
		},
		order = "d-a-a",
	},
	{
		type = "technology",
		name = "offshore-mk3-pump",
		icon_size = 256,
		icon_mipmaps = 4,
		icon = "__zzzparanoidal__/graphics/technology/offshore-pump-3.png",
		prerequisites = { "offshore-mk2-pump", "advanced-circuit", "angels-titanium-smelting-1", "bob-fluid-handling-2" },
		effects = { { type = "unlock-recipe", recipe = "offshore-mk3-pump" } },
		unit = {
			count = 75,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
			},
			time = 30,
		},
		order = "d-a-a",
	},
	{
		type = "technology",
		name = "offshore-mk4-pump",
		icon_size = 256,
		icon_mipmaps = 4,
		icon = "__zzzparanoidal__/graphics/technology/offshore-pump-4.png",
		prerequisites = { "offshore-mk3-pump", "processing-unit", "bob-advanced-processing-unit" },
		effects = { { type = "unlock-recipe", recipe = "offshore-mk4-pump" } },
		unit = {
			count = 75,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
			time = 30,
		},
		order = "d-a-a",
	},
})
