
data:extend({
	-- Steel Plate
	{
		type = "recipe",
		name = "molten-steel-remelting",
		category = "angels-induction-smelting",
		subgroup = "angels-steel-casting",
		enabled = false,
		energy_required = 6,
		ingredients = { { type = "item", name = "angels-plate-steel", amount = 4 } },
		results = { { type = "fluid", name = "angels-liquid-molten-steel", amount = 15 } },

		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-steel.png",
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

	-- Molten Steel
	{
		type = "recipe",
		name = "molten-steel-alloy-mixing",
		category = "molten-alloy-mixing",
		subgroup = "aragas-steel-alloy-mixing",
		enabled = false,
		energy_required = 4,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-molten-iron", amount = 240 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 60 },
		},
		results = { { type = "fluid", name = "angels-liquid-molten-steel", amount = 60 } },
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-steel.png",
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
	{
		type = "recipe",
		name = "molten-steel-alloy-mixing-2",
		category = "molten-alloy-mixing",
		subgroup = "aragas-steel-alloy-mixing",
		enabled = false,
		energy_required = 4,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-molten-iron", amount = 480 },
			{ type = "fluid", name = "angels-liquid-molten-silicon", amount = 120 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 120 },
		},
		results = { { type = "fluid", name = "angels-liquid-molten-steel", amount = 240 } },
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-steel.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "ab",
	},
	{
		type = "recipe",
		name = "molten-steel-alloy-mixing-3",
		category = "molten-alloy-mixing",
		subgroup = "aragas-steel-alloy-mixing",
		enabled = false,
		energy_required = 4,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-molten-iron", amount = 480 },
			{ type = "fluid", name = "angels-liquid-molten-manganese", amount = 120 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 120 },
		},
		results = { { type = "fluid", name = "angels-liquid-molten-steel", amount = 240 } },
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-steel.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "ac",
	},
	{
		type = "recipe",
		name = "molten-steel-alloy-mixing-4",
		category = "molten-alloy-mixing",
		subgroup = "aragas-steel-alloy-mixing",
		enabled = false,
		energy_required = 4,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-molten-iron", amount = 240 },
			{ type = "fluid", name = "angels-liquid-molten-chrome", amount = 120 },
			{ type = "fluid", name = "angels-gas-oxygen", amount = 60 },
			{ type = "item", name = "angels-powder-tungsten", amount = 12 },
		},
		results = { { type = "fluid", name = "angels-liquid-molten-steel", amount = 440 } },
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/molten-steel.png",
			},
			{
				icon = "__angelsextended-remelting-fixed__/graphics/icons/remelting.png",
				tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
				scale = 0.32,
				shift = { -12, -12 },
			},
		},
		icon_size = 64,
		order = "ad",
	},
})
