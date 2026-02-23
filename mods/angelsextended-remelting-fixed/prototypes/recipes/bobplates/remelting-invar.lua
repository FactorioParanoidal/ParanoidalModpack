
data:extend({
	-- Invar Plate
	{
		type = "recipe",
		name = "molten-invar-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-alloys-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "bob-invar-alloy", amount = 4 } },
		results = { { type = "fluid", name = "angels-liquid-molten-invar", amount = 35 } },

		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-invar.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "e]",
	},

	-- Molten Invar
	{
		type = "recipe",
		name = "molten-invar-alloy-mixing-1",
		category = "molten-alloy-mixing",
		subgroup = "aragas-invar-alloy-mixing",
		enabled = false,
		energy_required = 4,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-molten-steel", amount = 240 },
			{ type = "fluid", name = "angels-liquid-molten-nickel", amount = 120 },
		},
		results = { { type = "fluid", name = "angels-liquid-molten-invar", amount = 360 } },
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-invar.png",
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
