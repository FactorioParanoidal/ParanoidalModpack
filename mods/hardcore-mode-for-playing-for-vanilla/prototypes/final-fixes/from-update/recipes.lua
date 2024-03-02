data:extend({
	{
		type = "recipe",
		name = "satellite-raw-fish",
		icon = "__base__/graphics/icons/fish.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "intermediate-product",
		order = "m[satelite-raw-fish]",
		normal = {
			ingredients = { { type = "item", name = "satellite", amount = 1 } },
			result = "raw-fish",
			result_count = 100,
		},
		expensive = {
			ingredients = { { type = "item", name = "satellite", amount = 1 } },
			result = "raw-fish",
			result_count = 50,
		},
	},
})
