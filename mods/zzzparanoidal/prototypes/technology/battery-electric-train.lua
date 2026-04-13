data:extend({
	{
		type = "technology",
		name = "hiend_train",
		icon = "__zzzparanoidal__/graphics/train/hiend/ht-trains-tech.png",
		icon_size = 128,
		icon_mipmaps = 1,
		effects = {
			{ type = "unlock-recipe", recipe = "hiend_loco" },
			{ type = "unlock-recipe", recipe = "hiend_wagon" },
			{ type = "unlock-recipe", recipe = "hiend_fluid_wagon" },
			{ type = "unlock-recipe", recipe = "super_charger" },
		},
		prerequisites = { "bet-fuel-4", "bob-fluid-handling-4", "bob-speed-module-4" },
		unit = {
			count = 1000,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "bob-advanced-logistic-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 30,
		},
		order = "4",
	},
})
