data:extend({
	{
		type = "technology",
		name = "flame_car",
		icons = {
			{
				icon = "__base__/graphics/technology/automobilism.png",
				icon_size = 256,
				icon_mipmaps = 4,
			},
			{
				icon = "__base__/graphics/technology/refined-flammables.png",
				icon_size = 256,
				icon_mipmaps = 4,
				scale = 0.5,
				shift = { -60, 50 },
			},
		},
		effects = { { type = "unlock-recipe", recipe = "flame_car" } },
		prerequisites = { "flamethrower", "automobilism" },
		unit = {
			count = 50,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
			time = 30,
		},
		order = "1",
	},
})
