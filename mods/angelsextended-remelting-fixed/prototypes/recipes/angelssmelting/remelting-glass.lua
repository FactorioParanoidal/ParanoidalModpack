
data:extend({
	-- Glass Plate
	{
		type = "recipe",
		name = "molten-glass-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-glass-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "angels-plate-glass", amount = 4 } },
		results = { { type = "fluid", name = "angels-liquid-molten-glass", amount = 10 } },

		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-glass.png",
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
