--создаем рецепт для стекла из дробленого кронтиниума
data:extend({
	{
		type = "recipe",
		name = "glass-from-ore4",
		localised_name = { "item-name.bob-glass" },
		category = "smelting",
		group = "angels-casting",
		subgroup = "angels-glass-casting",
		order = "az",
		always_show_products = true,
		icons = {
			{
				icon = "__reskins-library__/graphics/icons/shared/items/glass.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__angelsrefininggraphics__/graphics/icons/angels-ore4/angels-ore4-crushed.png",
				icon_size = 32,
				icon_mipmaps = 1,
				scale = 0.4375,
				shift = { -10, -10 },
			},
		},
		energy_required = 20,
		ingredients = { { type = "item", name = "angels-ore4-crushed", amount = 7 } },
		results = {
			{ type = "item", name = "bob-glass", amount = 4 },
			{ name = "angels-slag", type = "item", amount = 1 },
		},
	},
	{
		type = "recipe",
		name = "quartz-glass",
		localised_name = { "item-name.bob-glass" },
		category = "smelting",
		group = "angels-casting",
		subgroup = "angels-glass-casting",
		order = "ay",
		always_show_products = true,
		icons = {
			{
				icon = "__reskins-library__/graphics/icons/shared/items/glass.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__bobores__/graphics/icons/quartz.png",
				icon_size = 32,
				icon_mipmaps = 1,
				scale = 0.4375,
				shift = { -10, -10 },
			},
		},
		energy_required = 4,
		ingredients = { { type = "item", name = "bob-quartz", amount = 4 } },
		results = {
			{ type = "item", name = "bob-glass", amount = 3 },
		},
	}
})

