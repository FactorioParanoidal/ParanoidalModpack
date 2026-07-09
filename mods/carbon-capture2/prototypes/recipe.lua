-- 2.0-порт рецептов CW. Миграции: result→results, short-form→long-form,
-- enabled/hidden строки→bool; ремап Bob's-сплавов (bob-*) и Angels-флюидов (angels-*).
local ICON = "__carbon-capture2__/graphics/icons/"

data:extend({
	{
		type = "recipe-category",
		name = "CW-air-filter",
	},

	-- ── машины MK1-6 (постройка, Bob's-интермедиаты) ──
	{
		type = "recipe", name = "CW-air-filter-machine-1",
		icon = ICON .. "air-filter-machine-1.png", icon_size = 64,
		category = "crafting", energy_required = 5, enabled = false,
		ingredients = {
			{ type = "item", name = "assembling-machine-2", amount = 1 },
			{ type = "item", name = "electronic-circuit", amount = 5 },
			{ type = "item", name = "steel-plate", amount = 10 },
			{ type = "item", name = "bob-steel-pipe", amount = 10 },
		},
		results = { { type = "item", name = "CW-air-filter-machine-1", amount = 1 } },
	},
	{
		type = "recipe", name = "CW-air-filter-machine-2",
		icon = ICON .. "air-filter-machine-2.png", icon_size = 64,
		category = "crafting", energy_required = 10, enabled = false,
		ingredients = {
			{ type = "item", name = "CW-air-filter-machine-1", amount = 2 },
			{ type = "item", name = "advanced-circuit", amount = 10 },
			{ type = "item", name = "bob-invar-alloy", amount = 10 },
		},
		results = { { type = "item", name = "CW-air-filter-machine-2", amount = 1 } },
	},
	{
		type = "recipe", name = "CW-air-filter-machine-3",
		icon = ICON .. "air-filter-machine-3.png", icon_size = 64,
		category = "crafting", energy_required = 10, enabled = false,
		ingredients = {
			{ type = "item", name = "CW-air-filter-machine-2", amount = 2 },
			{ type = "item", name = "advanced-circuit", amount = 25 },
			{ type = "item", name = "engine-unit", amount = 10 },
			{ type = "item", name = "bob-aluminium-plate", amount = 10 },
		},
		results = { { type = "item", name = "CW-air-filter-machine-3", amount = 1 } },
	},
	{
		type = "recipe", name = "CW-air-filter-machine-4",
		icon = ICON .. "air-filter-machine-4.png", icon_size = 64,
		category = "crafting", energy_required = 10, enabled = false,
		ingredients = {
			{ type = "item", name = "CW-air-filter-machine-3", amount = 2 },
			{ type = "item", name = "processing-unit", amount = 10 },
			{ type = "item", name = "bob-titanium-plate", amount = 25 },
		},
		results = { { type = "item", name = "CW-air-filter-machine-4", amount = 1 } },
	},
	{
		type = "recipe", name = "CW-air-filter-machine-5",
		icon = ICON .. "air-filter-machine-5.png", icon_size = 64,
		category = "crafting", energy_required = 10, enabled = false,
		ingredients = {
			{ type = "item", name = "CW-air-filter-machine-4", amount = 2 },
			{ type = "item", name = "processing-unit", amount = 50 },
			{ type = "item", name = "electric-engine-unit", amount = 10 },
			{ type = "item", name = "bob-nitinol-alloy", amount = 20 },
		},
		results = { { type = "item", name = "CW-air-filter-machine-5", amount = 1 } },
	},
	{
		type = "recipe", name = "CW-air-filter-machine-6",
		icon = ICON .. "air-filter-machine-6.png", icon_size = 64,
		category = "crafting", energy_required = 15, enabled = false,
		ingredients = {
			{ type = "item", name = "CW-air-filter-machine-5", amount = 2 },
			{ type = "item", name = "processing-unit", amount = 200 },
			{ type = "item", name = "bob-copper-tungsten-alloy", amount = 50 },
			{ type = "item", name = "electric-engine-unit", amount = 25 },
		},
		results = { { type = "item", name = "CW-air-filter-machine-6", amount = 1 } },
	},

	-- ── фильтры ──
	{
		type = "recipe", name = "CW-empty-air-filter",
		icon = ICON .. "empty-air-filter.png", icon_size = 64,
		category = "crafting", energy_required = 2, enabled = false,
		ingredients = { { type = "item", name = "steel-plate", amount = 5 } },
		results = { { type = "item", name = "CW-empty-air-filter", amount = 1 } },
	},
	{
		type = "recipe", name = "CW-air-filter",
		icon = ICON .. "air-filter.png", icon_size = 64,
		category = "crafting", energy_required = 3, enabled = false,
		ingredients = {
			{ type = "item", name = "coal", amount = 10 },
			{ type = "item", name = "CW-empty-air-filter", amount = 1 },
		},
		results = { { type = "item", name = "CW-air-filter", amount = 1 } },
	},
	{
		type = "recipe", name = "CW-filter-air",
		icon = ICON .. "filter-air.png", icon_size = 64,
		category = "CW-air-filter", energy_required = 100, enabled = true, hidden = true,
		ingredients = { { type = "item", name = "CW-air-filter", amount = 1 } },
		results = { { type = "item", name = "CW-used-air-filter", amount = 1 } },
	},

	-- ── регенерация фильтров (1-2 крафт, 3-4 химзавод) ──
	{
		type = "recipe", name = "CW-air-filter-cleaning-1",
		icon = ICON .. "air-filter-cleaning.png", icon_size = 32,
		category = "crafting", energy_required = 5, enabled = false,
		main_product = "CW-air-filter",
		ingredients = {
			{ type = "item", name = "CW-used-air-filter", amount = 1 },
			{ type = "item", name = "coal", amount = 5 },
		},
		results = { { type = "item", name = "CW-air-filter", amount = 1, probability = 0.9 } },
	},
	{
		type = "recipe", name = "CW-air-filter-cleaning-2",
		icon = ICON .. "air-filter-cleaning-2.png", icon_size = 32,
		category = "crafting", energy_required = 20, enabled = false,
		main_product = "CW-air-filter",
		ingredients = {
			{ type = "item", name = "CW-used-air-filter", amount = 5 },
			{ type = "item", name = "coal", amount = 20 },
		},
		results = { { type = "item", name = "CW-air-filter", amount = 5, probability = 0.95 } },
	},
	{
		type = "recipe", name = "CW-air-filter-cleaning-3",
		icon = ICON .. "air-filter-cleaning-3.png", icon_size = 32,
		category = "chemistry", energy_required = 15, enabled = false,
		main_product = "CW-air-filter",
		ingredients = {
			{ type = "item", name = "CW-used-air-filter", amount = 5 },
			{ type = "fluid", name = "angels-water-purified", amount = 100 },
		},
		results = {
			{ type = "item", name = "CW-air-filter", amount = 5, probability = 0.98 },
			{ type = "fluid", name = "angels-water-yellow-waste", amount = 80 },
		},
	},
	{
		type = "recipe", name = "CW-air-filter-cleaning-4",
		icon = ICON .. "air-filter-cleaning-4.png", icon_size = 32,
		category = "chemistry", energy_required = 12, enabled = false,
		main_product = "CW-air-filter",
		ingredients = {
			{ type = "item", name = "CW-used-air-filter", amount = 5 },
			{ type = "fluid", name = "steam", amount = 150 },
		},
		results = {
			{ type = "item", name = "CW-air-filter", amount = 5, probability = 0.99 },
			{ type = "fluid", name = "angels-water-yellow-waste", amount = 80 },
			{ type = "fluid", name = "angels-thermal-water", amount = 20 },
		},
	},
})
