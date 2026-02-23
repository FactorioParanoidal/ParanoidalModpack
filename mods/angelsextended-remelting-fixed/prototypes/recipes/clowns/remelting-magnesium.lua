
data:extend({
	-- Magnesium Plate
	{
		type = "recipe",
		name = "molten-magnesium-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-alloys-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "clowns-plate-magnesium", amount = 4 } },
		results = { { type = "fluid", name = "clowns-liquid-molten-magnesium", amount = 35 } },

		icons = {
			{
				icon = "__Clowns-Processing__/graphics/icons/molten-magnesium.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 32,
		order = "i]",
	},
})
