data:extend({

	{
		type = "recipe",
		name = "ye_trade_node",
		ingredients = {
			{ type = "item", name = "y-stargate", amount = 1 },
			{ type = "item", name = "y-bluegear", amount = 2 },
			{ type = "item", name = "iron-plate", amount = 4 },
		},
		results = {
			{ type = "item", name = "ye_trade_node", amount = 1 },
		},
		enabled = true,
		-- result_count = 8,
		order = "a2",
		subgroup = "yie_machinery2",
	},

	-- Solid Fuel Engine
	{
		type = "recipe",
		name = "y-sfe",
		ingredients = {
			{ type = "item", name = "y-basic-t1-mf", amount = 3 },
			{ type = "item", name = "y-bluegear", amount = 2 },
			{ type = "item", name = "iron-plate", amount = 4 },
		},
		results = { { type = "item", name = "y-sfe", amount = 1 } },
		enabled = true,
		-- result_count = 1,
		order = "engine",
		subgroup = "yie-engines",
	},
	-- Fluid Fuel Engine
	{
		type = "recipe",
		name = "y-ffe",
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 2 },
			{ type = "item", name = "y-bluegear", amount = 6 },
			{ type = "item", name = "steel-plate", amount = 4 },
		},
		results = { { type = "item", name = "y-ffe", amount = 1 } },
		enabled = true,
		-- result_count = 1,
		order = "engine",
		subgroup = "yie-engines",
	},
	-- Gas Fuel Engine
	{
		type = "recipe",
		name = "ye_gasmotor",
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 2 },
			{ type = "item", name = "yie_hard_metals", amount = 5 },
			{ type = "item", name = "y_structure_vessel", amount = 4 },
		},
		results = { { type = "item", name = "ye_gasmotor", amount = 1 } },
		enabled = true,
		-- result_count = 1,
		order = "engine",
		subgroup = "yie-engines",
	},

	-- waste condense
	{
		type = "recipe",
		name = "y-waste-condense",
		--category = "yrcat-eg4",
		enabled = true,
		energy_required = 1,
		ingredients = {
			{ type = "item", name = "y-pol-waste", amount = 150 },
		},
		results = {
			--{ type="item", name="solid-fuel", amount=3, },
			{ type = "item", name = "y-mixed-fuel", amount = 2 },
			{ type = "item", name = "y_greensign", amount = 1.0 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/waste1-icon.png",
		subgroup = "yie-processed",
		order = "a2",
	},
})
