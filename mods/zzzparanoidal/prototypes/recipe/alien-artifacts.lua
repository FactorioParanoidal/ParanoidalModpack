-------------------------------------------------------------------------------------------------
-- создаем технологию для переработки шариков
data:extend({
	{
		type = "technology",
		name = "bob-alien-artifact",
		icon = "__reskins-bobs__/graphics/icons/enemies/artifacts/bob-alien-artifact.png",
		icon_size = 64,
		icon_mipmaps = 4,
		effects = {
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-red" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-orange" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-yellow" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-green" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-blue" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-purple" },

			{ type = "unlock-recipe", recipe = "bob-alien-artifact" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-red-from-small" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-orange-from-small" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-yellow-from-small" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-green-from-small" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-blue-from-small" },
			{ type = "unlock-recipe", recipe = "bob-alien-artifact-purple-from-small" },
		},
		prerequisites = { "angels-gardens" },
		unit = {
			count = 20,
			ingredients = { { "automation-science-pack", 1 } },
			time = 30,
		},
		order = "c-a",
	},
})
