--[[ Copyright (c) 2017 David-John Miller AKA Anoyomouse
 * Part of the Warehousing mod
 * ported to 2.0 by anoyomouse 2024
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
			{ type = "item", name = "steel-plate", amount = 150 },
			{ type = "item", name = "stone-brick", amount = 40 },
			{ type = "item", name = "iron-chest", amount = 40 },
		},
		energy_required = 30,
		results = {{type="item", name="warehouse-basic", amount = 1}},
	},
	{ -- Passive Provider Warehouse
		type = "recipe",
		name = "warehouse-passive-provider",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "warehouse-basic", amount = 1 },
			{ type = "item", name = "passive-provider-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 25 },
			{ type = "item", name = "concrete", amount = 40 },
		},
		energy_required = 5,
		results = {{type="item", name="warehouse-passive-provider", amount=1}},
	},
	{ -- Storage Warehouse
		type = "recipe",
		name = "warehouse-storage",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "warehouse-basic", amount = 1 },
			{ type = "item", name = "storage-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 25 },
			{ type = "item", name = "concrete", amount = 40 },
		},
		energy_required = 5,
		results = {{type="item", name="warehouse-storage", amount=1}},
	},
	{ -- Active Provider Warehouse
		type = "recipe",
		name = "warehouse-active-provider",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "warehouse-basic", amount = 1 },
			{ type = "item", name = "active-provider-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 25 },
			{ type = "item", name = "concrete", amount = 40 },
		},
		energy_required = 5,
		results = {{type="item", name="warehouse-active-provider", amount=1}},
	},
	{ -- Requester Warehouse
		type = "recipe",
		name = "warehouse-requester",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "warehouse-basic", amount = 1 },
			{ type = "item", name = "requester-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 25 },
			{ type = "item", name = "concrete", amount = 40 },
		},
		energy_required = 5,
		results = {{type="item", name="warehouse-requester", amount=1}},
	},
	{ -- Buffer Warehouse
		type = "recipe",
		name = "warehouse-buffer",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "warehouse-basic", amount = 1 },
			{ type = "item", name = "buffer-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 25 },
			{ type = "item", name = "concrete", amount = 40 },
		},
		energy_required = 5,
		results = {{type="item", name="warehouse-buffer", amount=1}},
	},
	{ -- Basic Storehouse
		type = "recipe",
		name = "storehouse-basic",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "steel-plate", amount = 40 },
			{ type = "item", name = "stone-brick", amount = 10 },
			{ type = "item", name = "iron-chest", amount = 10 },
		},
		energy_required = 30,
		results = {{type="item", name="storehouse-basic", amount=1}},
	},
	{ -- Passive Provider Storehouse
		type = "recipe",
		name = "storehouse-passive-provider",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "storehouse-basic", amount = 1 },
			{ type = "item", name = "passive-provider-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 10 },
			{ type = "item", name = "concrete", amount = 15 },
		},
		energy_required = 5,
		results = {{type="item", name="storehouse-passive-provider", amount=1}},
	},
	{ -- Storage Storehouse
		type = "recipe",
		name = "storehouse-storage",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "storehouse-basic", amount = 1 },
			{ type = "item", name = "storage-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 10 },
			{ type = "item", name = "concrete", amount = 15 },
		},
		energy_required = 5,
		results = {{type="item", name="storehouse-storage", amount=1}},
	},
	{ -- Active Provider Storehouse
		type = "recipe",
		name = "storehouse-active-provider",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "storehouse-basic", amount = 1 },
			{ type = "item", name = "active-provider-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 10 },
			{ type = "item", name = "concrete", amount = 15 },
		},
		energy_required = 5,
		results = {{type="item", name="storehouse-active-provider", amount=1}},
	},
	{ -- Requester Storehouse
		type = "recipe",
		name = "storehouse-requester",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "storehouse-basic", amount = 1 },
			{ type = "item", name = "requester-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 10 },
			{ type = "item", name = "concrete", amount = 15 },
		},
		energy_required = 5,
		results = {{type="item", name="storehouse-requester", amount=1}},
	},
	{ -- Buffer Storehouse
		type = "recipe",
		name = "storehouse-buffer",
		enabled = false,
		ingredients =
		{
			{ type = "item", name = "storehouse-basic", amount = 1 },
			{ type = "item", name = "buffer-chest", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 10 },
			{ type = "item", name = "concrete", amount = 15 },
		},
		energy_required = 5,
		results = {{type="item", name="storehouse-buffer", amount=1}},
	},
})
