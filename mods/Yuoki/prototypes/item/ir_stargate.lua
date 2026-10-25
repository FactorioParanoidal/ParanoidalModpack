data:extend({
	-- stargate trade recipes

	-- fame trade for fuel-cell
	{
		type = "recipe",
		name = "y-fuel-cell-c",
		order = "w1",
		energy_required = 2.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-fame", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-fuel-cell-c", amount = 1 },
		},
		main_product = "y-fuel-cell-c",
		group = "yuoki-energy",
		subgroup = "y-fuel",
		category = "yuoki-stargate",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/fuel_cell_c.png",
	},

	-- fuel-cell-c
	{
		type = "item",
		name = "y-fuel-cell-c",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/fuel_cell_c.png",
		subgroup = "y-fuel",
		fuel_category = "chemical",
		fuel_value = "10GJ",
		stack_size = 500,
	},

	-- fame recipe
	{
		type = "recipe",
		name = "y-fame",
		order = "x1",
		energy_required = 1800.0,
		enabled = true,
		ingredients = {},
		results = {
			{ type = "item", name = "y-fame", amount = 1 },
		},
		main_product = "y-fame",
		subgroup = "y-stargate-4",
		category = "yuoki-fame",
	},

	{
		type = "recipe",
		name = "y_fame_tech",
		order = "x2",
		energy_required = 900.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_rwtechsign", amount = 25 },
		},
		results = {
			{ type = "item", name = "y-fame", amount = 1 },
		},
		main_product = "y-fame",
		subgroup = "y-stargate-4",
		category = "yuoki-fame",
	},

	-- fame
	{
		type = "item",
		name = "y-fame",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/fame-icon.png",
		subgroup = "y-stargate-f",
		stack_size = 10000,
	},

	-- stargate recipe
	{
		type = "recipe",
		name = "y-stargate",
		energy_required = 5.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-accumulator-crystal-m", amount = 1 },
			{ type = "item", name = "y-alien-infuser", amount = 1 },
			{ type = "item", name = "y-crystal2", amount = 150 },
			{ type = "item", name = "y-chip-2", amount = 8 },
			{ type = "item", name = "y-fame", amount = 10 },
		},
		results = {
			{ type = "item", name = "y-stargate", amount = 1 },
		},
		main_product = "y-stargate",
		group = "yuoki-energy",
		subgroup = "y_ultimate_products",
		order = "2",
	},

	-- stargate itself
	{
		type = "item",
		name = "y-stargate",
		place_result = "y-stargate",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/laika-gate-icon.png",
		group = "yuoki-energy",
		subgroup = "y_ultimate_products",
		stack_size = 3,
	},

	-- 40-Users recipe
	{
		type = "recipe",
		name = "y-fame-gen",
		energy_required = 5.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-alien-infuser", amount = 1 },
			{ type = "item", name = "y-ups-flywheel-b", amount = 1 },
			{ type = "item", name = "y-unicomp-a2", amount = 100 },
		},
		results = {
			{ type = "item", name = "y-fame-gen", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 10 },
		},
		main_product = "y-fame-gen",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/thanks-icon.png",
		group = "yuoki-energy",
		subgroup = "y_ultimate_products",
		order = "1",
	},

	-- 40-Users
	{
		type = "item",
		name = "y-fame-gen",
		place_result = "y-fame-gen",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/thanks-icon.png",
		group = "yuoki-energy",
		subgroup = "y_ultimate_products",
		stack_size = 6,
	},
})
