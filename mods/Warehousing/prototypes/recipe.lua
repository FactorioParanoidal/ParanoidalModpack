--[[ Copyright (c) 2017 David-John Miller AKA Anoyomouse
 * Part of the Warehousing mod
 *
 * See License.txt in the project directory for license information.
--]]
data:extend({
	{ -- Basic Warehouse
		type = "recipe",
		name = "warehouse-basic",
		enabled = false,
		ingredients =
		{
			{ "steel-plate", 200 },
			{ "stone-brick", 40 },
			{ "iron-stick", 85 },
		},
		energy_required = 30,
		result = "warehouse-basic",
	},
	{ -- Passive Provider Warehouse
		type = "recipe",
		name = "warehouse-passive-provider",
		enabled = false,
		ingredients =
		{
			{ "warehouse-basic", 1 },
			{ "logistic-chest-passive-provider", 1 },
			{ "steel-plate", 10 },
			{ "iron-stick", 15 },
		},
		energy_required = 5,
		result = "warehouse-passive-provider",
	},
	{ -- Storage Warehouse
		type = "recipe",
		name = "warehouse-storage",
		enabled = false,
		ingredients =
		{
			{ "warehouse-basic", 1 },
			{ "logistic-chest-storage", 1 },
			{ "steel-plate", 10 },
			{ "iron-stick", 15 },
		},
		energy_required = 5,
		result = "warehouse-storage",
	},
	{ -- Active Provider Warehouse
		type = "recipe",
		name = "warehouse-active-provider",
		enabled = false,
		ingredients =
		{
			{ "warehouse-basic", 1 },
			{ "logistic-chest-active-provider", 1 },
			{ "steel-plate", 10 },
			{ "iron-stick", 15 },
		},
		energy_required = 5,
		result = "warehouse-active-provider",
	},
	{ -- Requester Warehouse
		type = "recipe",
		name = "warehouse-requester",
		enabled = false,
		ingredients =
		{
			{ "warehouse-basic", 1 },
			{ "logistic-chest-requester", 1 },
			{ "steel-plate", 10 },
			{ "iron-stick", 15 },
		},
		energy_required = 5,
		result = "warehouse-requester",
	},
	{ -- Buffer Warehouse
		type = "recipe",
		name = "warehouse-buffer",
		enabled = false,
		ingredients =
		{
			{ "warehouse-basic", 1 },
			{ "logistic-chest-buffer", 1 },
			{ "steel-plate", 10 },
			{ "iron-stick", 15 },
		},
		energy_required = 5,
		result = "warehouse-buffer",
	},
	{ -- Basic Storehouse
		type = "recipe",
		name = "storehouse-basic",
		enabled = false,
		ingredients =
		{
			{ "steel-plate", 50 },
			{ "stone-brick", 10 },
			{ "iron-stick", 16 },
		},
		energy_required = 30,
		result = "storehouse-basic",
	},
	{ -- Passive Provider Storehouse
		type = "recipe",
		name = "storehouse-passive-provider",
		enabled = false,
		ingredients =
		{
			{ "storehouse-basic", 1 },
			{ "logistic-chest-passive-provider", 1 },
			{ "iron-stick", 4 },
		},
		energy_required = 5,
		result = "storehouse-passive-provider",
	},
	{ -- Storage Storehouse
		type = "recipe",
		name = "storehouse-storage",
		enabled = false,
		ingredients =
		{
			{ "storehouse-basic", 1 },
			{ "logistic-chest-storage", 1 },
			{ "iron-stick", 4 },
		},
		energy_required = 5,
		result = "storehouse-storage",
	},
	{ -- Active Provider Storehouse
		type = "recipe",
		name = "storehouse-active-provider",
		enabled = false,
		ingredients =
		{
			{ "storehouse-basic", 1 },
			{ "logistic-chest-active-provider", 1 },
			{ "iron-stick", 4 },
		},
		energy_required = 5,
		result = "storehouse-active-provider",
	},
	{ -- Requester Storehouse
		type = "recipe",
		name = "storehouse-requester",
		enabled = false,
		ingredients =
		{
			{ "storehouse-basic", 1 },
			{ "logistic-chest-requester", 1 },
			{ "iron-stick", 4 },
		},
		energy_required = 5,
		result = "storehouse-requester",
	},
	{ -- Buffer Storehouse
		type = "recipe",
		name = "storehouse-buffer",
		enabled = false,
		ingredients =
		{
			{ "storehouse-basic", 1 },
			{ "logistic-chest-buffer", 1 },
			{ "iron-stick", 4 },
		},
		energy_required = 5,
		result = "storehouse-buffer",
	},
})
