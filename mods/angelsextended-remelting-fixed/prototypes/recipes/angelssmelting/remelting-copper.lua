
data:extend({
	-- Copper Plate
	{
		type = "recipe",
		name = "molten-copper-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-copper-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "copper-plate", amount = 4 } },
		results = { { type = "fluid", name = "angels-liquid-molten-copper", amount = 15 } },

		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-copper.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "a]",
	},
})
