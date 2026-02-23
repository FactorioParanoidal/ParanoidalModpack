
data:extend({
	-- Zinc Plate
	{
		type = "recipe",
		name = "molten-zinc-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-zinc-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "angels-plate-zinc", amount = 4 } },
		results = { { type = "fluid", name = "angels-liquid-molten-zinc", amount = 15 } },

		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-zinc.png",
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
