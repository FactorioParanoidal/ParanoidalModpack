-- Формы для gear-wheel casting (1.1 ASE ironworks):
-- ASE-sand-die — расходный (sand) die для expendable casting
-- ASE-metal-die — металлический die для advanced casting (multi-use)
-- ASE-spent-metal-die — отработанный metal-die, чистится через ASE-metal-die-wash

data:extend({
	{
		type = "item",
		name = "ASE-sand-die",
		icons = {
			{ icon = "__angelssmeltinggraphics__/graphics/icons/expendable-mold.png", icon_size = 32 },
			{ icon = "__angelssmeltinggraphics__/graphics/icons/expendable-mold.png", icon_size = 32, tint = { 0.91, 0.89, 0.79, 0.5 } },
		},
		icon_size = 32,
		subgroup = "angels-mold-casting",
		order = "a-ASE",
		stack_size = 200,
	},
	{
		type = "item",
		name = "ASE-metal-die",
		icons = {
			{ icon = "__angelssmeltinggraphics__/graphics/icons/non-expendable-mold.png", icon_size = 32 },
			{ icon = "__angelssmeltinggraphics__/graphics/icons/non-expendable-mold.png", icon_size = 32, tint = { 0.91, 0.89, 0.79, 0.5 } },
		},
		icon_size = 32,
		subgroup = "angels-mold-casting",
		order = "b-ASE",
		stack_size = 200,
	},
	{
		type = "item",
		name = "ASE-spent-metal-die",
		icons = {
			{ icon = "__angelssmeltinggraphics__/graphics/icons/spent-non-expendable-mold.png", icon_size = 32 },
			{ icon = "__angelssmeltinggraphics__/graphics/icons/spent-non-expendable-mold.png", icon_size = 32, tint = { 0.91, 0.89, 0.79, 0.5 } },
			{ icon = "__angelsrefininggraphics__/graphics/icons/slag.png", icon_size = 32, scale = 0.6 },
		},
		icon_size = 32,
		subgroup = "angels-mold-casting",
		order = "c-ASE",
		stack_size = 200,
	},
})
