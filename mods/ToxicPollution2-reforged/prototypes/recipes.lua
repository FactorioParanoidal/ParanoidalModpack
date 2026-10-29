local C = require("shared.config")

local function item(name, amount)
	return { type = "item", name = name, amount = amount }
end

data:extend({
	-- Unchanged from toxicPollution2: available from the start.
	{
		type = "recipe",
		name = C.RESPIRATOR,
		enabled = true,
		ingredients = { item("iron-plate", 4), item("wood", 4), item("coal", 2) },
		results = { item(C.RESPIRATOR, 1) },
	},
	{
		type = "recipe",
		name = C.GAS_MASK,
		enabled = false,
		energy_required = 5,
		ingredients = { item(C.RESPIRATOR, 1), item("steel-plate", 4), item("iron-plate", 2), item("coal", 10) },
		results = { item(C.GAS_MASK, 1) },
	},
	{
		type = "recipe",
		name = C.FILTER_MODULE,
		enabled = false,
		energy_required = 10,
		ingredients = { item(C.GAS_MASK, 1), item("electronic-circuit", 10), item("iron-gear-wheel", 5), item("steel-plate", 5) },
		results = { item(C.FILTER_MODULE, 1) },
	},
	{
		type = "recipe",
		name = C.CLOSED_MODULE,
		enabled = false,
		energy_required = 20,
		ingredients = { item(C.FILTER_MODULE, 2), item("advanced-circuit", 10), item("plastic-bar", 20), item("battery", 5) },
		results = { item(C.CLOSED_MODULE, 1) },
	},
})
