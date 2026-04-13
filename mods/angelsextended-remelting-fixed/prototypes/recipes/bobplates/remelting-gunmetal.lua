
data:extend({
	-- Gunmetal Plate
	{
		type = "recipe",
		name = "molten-gunmetal-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-alloys-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "bob-gunmetal-alloy", amount = 4 } },
		results = { { type = "fluid", name = "angels-liquid-molten-gunmetal", amount = 35 } },

		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-gunmetal.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "d]",
	},

	-- Molten Gunmetal
	{
		type = "recipe",
		name = "molten-gunmetal-alloy-mixing-1",
		category = "molten-alloy-mixing",
		subgroup = "aragas-gunmetal-alloy-mixing",
		enabled = false,
		energy_required = 4,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-molten-copper", amount = 180 },
			{ type = "fluid", name = "angels-liquid-molten-zinc", amount = 120 },
			{ type = "fluid", name = "angels-liquid-molten-tin", amount = 60 },
		},
		results = { { type = "fluid", name = "angels-liquid-molten-gunmetal", amount = 360 } },
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-gunmetal.png",
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
