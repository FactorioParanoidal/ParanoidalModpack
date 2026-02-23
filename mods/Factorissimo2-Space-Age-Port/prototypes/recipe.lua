local easy_recipes = settings.startup["Factorissimo2-easy-recipes"].value

local multiplier = easy_recipes and 1 or 10

data:extend({

	-- Factory buildings
	{
		type = "recipe",
		name = "factory-1",
		enabled = false,
		energy_required = 30,
		ingredients = {{type="item", name="stone", amount=50 * multiplier}, {type="item", name="iron-plate", amount=50 * multiplier}, {type="item", name="copper-plate", amount=10 * multiplier}},
		results = {{type="item", name="factory-1", amount=1}},
		auto_recycle = false
	},

	{
		type = "recipe",
		name = "factory-2",
		enabled = false,
		energy_required = 46,
		ingredients = {{type="item", name="stone-brick", amount=100 * multiplier}, {type="item", name="steel-plate", amount=25 * multiplier}, {type="item", name="big-electric-pole", amount=5 * multiplier}},
		results = {{type="item", name="factory-2", amount=1}},
		auto_recycle = false
	},

	{
		type = "recipe",
		name = "factory-3",
		enabled = false,
		energy_required = 60,
		ingredients = {{type="item", name="concrete", amount=500 * multiplier}, {type="item", name="steel-plate", amount=200 * multiplier}, {type="item", name="substation", amount=10 * multiplier}},
		results = {{type="item", name="factory-3", amount=1}},
		auto_recycle = false
	},

	-- Utilities
	{
		type = "recipe",
		name = "factory-circuit-input",
		enabled = false,
		energy_required = 1,
		ingredients = {{type="item", name="copper-cable", amount=5 * multiplier}, {type="item", name="electronic-circuit", amount=2 * multiplier}},
		results = {{type="item", name="factory-circuit-input", amount=1}},
		auto_recycle = false
	},
	{
		type = "recipe",
		name = "factory-circuit-output",
		enabled = false,
		energy_required = 1,
		ingredients = {{type="item", name="electronic-circuit", amount=2 * multiplier}, {type="item", name="copper-cable", amount=5 * multiplier}},
		results = {{type="item", name="factory-circuit-output", amount=1}},
		auto_recycle = false
	},
	{
		type = "recipe",
		name = "factory-input-pipe",
		enabled = false,
		energy_required = 1,
		ingredients = {{type="item", name="pipe", amount=5 * multiplier}},
		results = {{type="item", name="factory-input-pipe", amount=1}},
		auto_recycle = false
	},
	{
		type = "recipe",
		name = "factory-output-pipe",
		enabled = false,
		energy_required = 1,
		ingredients = {{type="item", name="pipe", amount=5 * multiplier}},
		results = {{type="item", name="factory-output-pipe", amount=1}},
		auto_recycle = false
	},
	{
		type = "recipe",
		name = "factory-requester-chest",
		enabled = false,
		energy_required = 10,
		ingredients = {{type="item", name="requester-chest", amount=5 * multiplier}},
		results = {{type="item", name="factory-requester-chest", amount=1}},
		auto_recycle = false
	},
});
