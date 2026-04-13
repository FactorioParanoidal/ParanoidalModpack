-- from KaoExtended
data:extend({
	{
		type = "recipe",
		name = "bob-science-pack-gold",
		enabled = false,
		energy_required = 30,
		ingredients = {
			{ type = "item", name = "automation-science-pack", amount = 1 },
			{ type = "item", name = "logistic-science-pack", amount = 1 },
			{ type = "item", name = "chemical-science-pack", amount = 1 },
			{ type = "item", name = "military-science-pack", amount = 1 },
			{ type = "item", name = "sci-component-o", amount = 3 },
		},
		results = { { type = "item", name = "bob-science-pack-gold", amount = 1 } },
	},
})
