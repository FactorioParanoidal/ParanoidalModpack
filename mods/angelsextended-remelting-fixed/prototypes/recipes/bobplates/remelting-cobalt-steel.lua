
data:extend({
	-- Cobalt Steel Plate
	{
		type = "recipe",
		name = "molten-cobalt-steel-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-alloys-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "bob-cobalt-steel-alloy", amount = 4 } },
		results = { { type = "fluid", name = "angels-liquid-molten-cobalt-steel", amount = 35 } },

		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-cobalt-steel.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "f]",
	},

	-- Molten Cobalt Steel
	{
		type = "recipe",
		name = "molten-cobalt-steel-alloy-mixing-1",
		category = "molten-alloy-mixing",
		subgroup = "aragas-cobalt-steel-alloy-mixing",
		enabled = false,
		energy_required = 4,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-molten-steel", amount = 240 },
			{ type = "fluid", name = "angels-liquid-molten-cobalt", amount = 120 },
		},
		results = { { type = "fluid", name = "angels-liquid-molten-cobalt-steel", amount = 360 } },
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-cobalt-steel.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "aa",
	},
})
