if not KaoExtended then
	KaoExtended = {}
end
if not KaoExtended.item then
	KaoExtended.item = {}
end
if not KaoExtended.recipe then
	KaoExtended.recipe = {}
end

data.raw["recipe"]["electronic-circuit"].enabled = false

if kaoextended.settingsoveride == true then
	data.raw["recipe"]["automation-science-pack"].ingredients = {
		{ type = "item", name = "iron-gear-wheel", amount = 3 },
		{ type = "item", name = "copper-plate", amount = 10 },
		{ type = "item", name = "sci-component-1", amount = 3 },
	}
	data.raw["recipe"]["logistic-science-pack"].enabled = false
	data.raw["recipe"]["logistic-science-pack"].ingredients = {
		{ type = "item", name = "inserter", amount = 2 },
		{ type = "item", name = "transport-belt", amount = 7 },
		{ type = "item", name = "sci-component-2", amount = 3 },
		{ type = "item", name = "bob-bronze-alloy", amount = 7 },
	}
	data.raw["recipe"]["chemical-science-pack"].ingredients = {
		{ type = "item", name = "advanced-circuit", amount = 1 },
		{ type = "item", name = "engine-unit", amount = 1 },
		{ type = "item", name = "electric-mining-drill", amount = 1 },
		{ type = "item", name = "steel-plate", amount = 7 },
		{ type = "item", name = "sci-component-3", amount = 3 },
	}
	data.raw["recipe"]["military-science-pack"].ingredients = {
		{ type = "item", name = "piercing-rounds-magazine", amount = 1 },
		{ type = "item", name = "grenade", amount = 1 },
		{ type = "item", name = "gun-turret", amount = 1 },
		{ type = "item", name = "sci-component-m", amount = 3 },
	}
	data.raw["recipe"]["bob-advanced-logistic-science-pack"].ingredients = {
		{ type = "item", name = "fast-inserter", amount = 1 },
		{ type = "item", name = "flying-robot-frame", amount = 1 },
		{ type = "item", name = "bob-brass-chest", amount = 1 },
		{ type = "item", name = "sci-component-l", amount = 3 },
	}
	data.raw["recipe"]["production-science-pack"].ingredients = {
		{ type = "item", name = "assembling-machine-1", amount = 1 },
		{ type = "item", name = "electric-furnace", amount = 1 },
		{ type = "item", name = "basic-structure-components", amount = 1 },
		{ type = "item", name = "sci-component-5", amount = 3 },
	}

	data.raw["recipe"]["utility-science-pack"].ingredients = {
		{ type = "item", name = "processing-unit", amount = 5 },
		{ type = "item", name = "express-transport-belt", amount = 10 },
		{ type = "item", name = "bob-lithium-ion-battery", amount = 10 },
		{ type = "item", name = "uranium-238", amount = 5 },
		{ type = "item", name = "sci-component-4", amount = 3 },
		{ type = "item", name = "bob-rubber", amount = 10 },
		{ type = "item", name = "advsci-component-4", amount = 3 },
	}
	data.raw["recipe"]["utility-science-pack"].energy_required = 28
	data.raw["recipe"]["utility-science-pack"].results[1].amount = 4

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
			results = {{ type = "item", name = "bob-science-pack-gold", amount = 1 }},
		},
	})

	KaoExtended.recipe.add_to_recipe("bob-oil-boiler", { type = "item", name = "oil-steam-boiler", amount = 2 })

	KaoExtended.recipe.add_to_recipe("bob-basic-circuit-board", { type = "item", name = "condensator", amount = 2 })

	KaoExtended.recipe.add_to_recipe("advanced-circuit", { type = "item", name = "standart-io", amount = 2 })
	KaoExtended.recipe.add_to_recipe("advanced-circuit", { type = "item", name = "condensator2", amount = 8 })

	KaoExtended.recipe.add_to_recipe("processing-unit", { type = "item", name = "advanced-io", amount = 2 })
	KaoExtended.recipe.add_to_recipe("processing-unit", { type = "item", name = "condensator", amount = 75 })
	KaoExtended.recipe.add_to_recipe("processing-unit", { type = "item", name = "condensator2", amount = 25 })
	KaoExtended.recipe.add_to_recipe("processing-unit", { type = "item", name = "condensator3", amount = 15 })

	KaoExtended.recipe.add_to_recipe(
		"bob-advanced-processing-unit",
		{ type = "item", name = "advanced-io", amount = 2 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-advanced-processing-unit",
		{ type = "item", name = "predictive-io", amount = 2 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-advanced-processing-unit",
		{ type = "item", name = "condensator", amount = 92 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-advanced-processing-unit",
		{ type = "item", name = "condensator2", amount = 40 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-advanced-processing-unit",
		{ type = "item", name = "condensator3", amount = 28 }
	)

	KaoExtended.recipe.add_to_recipe("bob-module-processor-board", { type = "item", name = "condensator", amount = 12 })

	KaoExtended.recipe.add_to_recipe(
		"bob-module-processor-board-2",
		{ type = "item", name = "condensator", amount = 8 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-module-processor-board-2",
		{ type = "item", name = "condensator2", amount = 10 }
	)

	KaoExtended.recipe.add_to_recipe(
		"bob-module-processor-board-3",
		{ type = "item", name = "condensator2", amount = 10 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-module-processor-board-3",
		{ type = "item", name = "condensator3", amount = 16 }
	)

	KaoExtended.recipe.add_to_recipe("bob-speed-processor", { type = "item", name = "condensator", amount = 8 })
	KaoExtended.recipe.add_to_recipe("bob-speed-processor-2", { type = "item", name = "condensator2", amount = 8 })
	KaoExtended.recipe.add_to_recipe("bob-speed-processor-3", { type = "item", name = "condensator3", amount = 8 })

	KaoExtended.recipe.add_to_recipe("bob-efficiency-processor", { type = "item", name = "condensator", amount = 8 })
	KaoExtended.recipe.add_to_recipe(
		"bob-efficiency-processor-2",
		{ type = "item", name = "condensator2", amount = 8 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-efficiency-processor-3",
		{ type = "item", name = "condensator3", amount = 8 }
	)

	KaoExtended.recipe.add_to_recipe("bob-productivity-processor", { type = "item", name = "condensator", amount = 8 })
	KaoExtended.recipe.add_to_recipe(
		"bob-productivity-processor-2",
		{ type = "item", name = "condensator2", amount = 8 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-productivity-processor-3",
		{ type = "item", name = "condensator3", amount = 8 }
	)

	KaoExtended.recipe.add_to_recipe("transport-belt", { type = "item", name = "bob-basic-transport-belt", amount = 2 })
else
	KaoExtended.recipe.add_to_recipe("automation-science-pack", { type = "item", name = "sci-component-1", amount = 3 })
	KaoExtended.recipe.add_to_recipe("logistic-science-pack", { type = "item", name = "sci-component-2", amount = 3 })
	KaoExtended.recipe.add_to_recipe("chemical-science-pack", { type = "item", name = "sci-component-3", amount = 3 })

	KaoExtended.recipe.add_to_recipe("military-science-pack", { type = "item", name = "sci-component-m", amount = 3 })
	KaoExtended.recipe.add_to_recipe("logistic-science-pack", { type = "item", name = "sci-component-l", amount = 3 })
	KaoExtended.recipe.add_to_recipe("production-science-pack", { type = "item", name = "sci-component-5", amount = 3 })
	KaoExtended.recipe.add_to_recipe("utility-science-pack", { type = "item", name = "sci-component-4", amount = 3 })
	KaoExtended.recipe.add_to_recipe("utility-science-pack", { type = "item", name = "advsci-component-4", amount = 3 })

	KaoExtended.recipe.add_to_recipe(
		"bob-module-processor-board",
		{ type = "item", name = "advsci-component-4", amount = 1 }
	)

	KaoExtended.recipe.add_to_recipe("bob-basic-circuit-board", { type = "item", name = "condensator", amount = 4 })
	KaoExtended.recipe.add_to_recipe(
		"bob-module-processor-board",
		{ type = "item", name = "advsci-component-4", amount = 1 }
	)

	KaoExtended.recipe.add_to_recipe("advanced-circuit", { type = "item", name = "standart-io", amount = 2 })
	KaoExtended.recipe.add_to_recipe("advanced-circuit", { type = "item", name = "condensator", amount = 25 })
	KaoExtended.recipe.add_to_recipe("advanced-circuit", { type = "item", name = "condensator2", amount = 5 })

	KaoExtended.recipe.add_to_recipe("processing-unit", { type = "item", name = "advanced-io", amount = 3 })
	KaoExtended.recipe.add_to_recipe("processing-unit", { type = "item", name = "condensator2", amount = 15 })
	KaoExtended.recipe.add_to_recipe("processing-unit", { type = "item", name = "condensator3", amount = 25 })

	KaoExtended.recipe.add_to_recipe(
		"bob-advanced-processing-unit",
		{ type = "item", name = "predictive-io", amount = 3 }
	)
	KaoExtended.recipe.add_to_recipe(
		"bob-advanced-processing-unit",
		{ type = "item", name = "condensator3", amount = 32 }
	)

	KaoExtended.recipe.add_to_recipe("bob-module-processor-board", { type = "item", name = "condensator", amount = 12 })
end
