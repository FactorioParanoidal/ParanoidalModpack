data:extend({
	{ -- Basic Warehouse
		type = "recipe",
		name = "warehouse-basic",
		enabled = false,
		ingredients = {
			{ type = "item", name = "storehouse-basic", amount = 2}, --added drd
			{ type = "item", name = "steel-plate", amount = 200},
			{ type = "item", name = "stone-brick", amount = 40},
			{ type = "item", name = "iron-stick", amount = 85},
		},
		energy_required = 30,
		results = { { type = "item", name = "warehouse-basic", amount = 1 } },
	},
	{ -- Passive Provider Warehouse
		type = "recipe",
		name = "angels-warehouse-passive-provider",
		enabled = false,
		ingredients = {
			{ type = "item", name = "warehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-passive-provider", amount = 1},
			{ type = "item", name = "steel-plate", amount = 10},
			{ type = "item", name = "iron-stick", amount = 15},
		},
		energy_required = 5,
		results = { { type = "item", name = "angels-warehouse-passive-provider", amount = 1 } },
	},
	{ -- Storage Warehouse
		type = "recipe",
		name = "angels-warehouse-storage",
		enabled = false,
		ingredients = {
			{ type = "item", name = "warehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-storage", amount = 1},
			{ type = "item", name = "steel-plate", amount = 10},
			{ type = "item", name = "iron-stick", amount = 15},
		},
		energy_required = 5,
		results = { { type = "item", name = "angels-warehouse-storage", amount = 1 } },
	},
	{ -- Active Provider Warehouse
		type = "recipe",
		name = "angels-warehouse-active-provider",
		enabled = false,
		ingredients = {
			{ type = "item", name = "warehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-active-provider", amount = 1},
			{ type = "item", name = "steel-plate", amount = 10},
			{ type = "item", name = "iron-stick", amount = 15},
		},
		energy_required = 5,
		results = { { type = "item", name = "angels-warehouse-active-provider", amount = 1 } },
	},
	{ -- Requester Warehouse
		type = "recipe",
		name = "angels-warehouse-requester",
		enabled = false,
		ingredients = {
			{ type = "item", name = "warehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-requester", amount = 1},
			{ type = "item", name = "steel-plate", amount = 10},
			{ type = "item", name = "iron-stick", amount = 15},
		},
		energy_required = 5,
		results = { { type = "item", name = "angels-warehouse-requester", amount = 1 } },
	},
	{ -- Buffer Warehouse
		type = "recipe",
		name = "angels-warehouse-buffer",
		enabled = false,
		ingredients = {
			{ type = "item", name = "warehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-buffer", amount = 1},
			{ type = "item", name = "steel-plate", amount = 10},
			{ type = "item", name = "iron-stick", amount = 15},
		},
		energy_required = 5,
		results = { { type = "item", name = "angels-warehouse-buffer", amount = 1 } },
	},
	{ -- Basic Storehouse
		type = "recipe",
		name = "storehouse-basic",
		enabled = false,
		ingredients = {
			{ type = "item", name = "steel-chest", amount = 10}, --drd
			{ type = "item", name = "steel-plate", amount = 50},
			{ type = "item", name = "stone-brick", amount = 10},
			{ type = "item", name = "iron-stick", amount = 16},
		},
		energy_required = 30,
		results = { { type = "item", name = "storehouse-basic", amount = 1 } },
	},
	{ -- Passive Provider Storehouse
		type = "recipe",
		name = "storehouse-passive-provider",
		enabled = false,
		ingredients = {
			{ type = "item", name = "storehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-passive-provider", amount = 1},
			{ type = "item", name = "iron-stick", amount = 16}, --drd
		},
		energy_required = 5,
		results = { { type = "item", name = "storehouse-passive-provider", amount = 1 } },
	},
	{ -- Storage Storehouse
		type = "recipe",
		name = "storehouse-storage",
		enabled = false,
		ingredients = {
			{ type = "item", name = "storehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-storage", amount = 1},
			{ type = "item", name = "iron-stick", amount = 16}, --drd
		},
		energy_required = 5,
		results = { { type = "item", name = "storehouse-storage", amount = 1 } },
	},
	{ -- Active Provider Storehouse
		type = "recipe",
		name = "storehouse-active-provider",
		enabled = false,
		ingredients = {
			{ type = "item", name = "storehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-active-provider", amount = 1},
			{ type = "item", name = "iron-stick", amount = 16}, --drd
		},
		energy_required = 5,
		results = { { type = "item", name = "storehouse-active-provider", amount = 1 } },
	},
	{ -- Requester Storehouse
		type = "recipe",
		name = "storehouse-requester",
		enabled = false,
		ingredients = {
			{ type = "item", name = "storehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-requester", amount = 1},
			{ type = "item", name = "iron-stick", amount = 16}, --drd
		},
		energy_required = 5,
		results = { { type = "item", name = "storehouse-requester", amount = 1 } },
	},
	{ -- Buffer Storehouse
		type = "recipe",
		name = "storehouse-buffer",
		enabled = false,
		ingredients = {
			{ type = "item", name = "storehouse-basic", amount = 1},
			{ type = "item", name = "angels-logistic-chest-buffer", amount = 1},
			{ type = "item", name = "iron-stick", amount = 16}, --drd
		},
		energy_required = 5,
		results = { { type = "item", name = "storehouse-buffer", amount = 1 } },
	},
})
