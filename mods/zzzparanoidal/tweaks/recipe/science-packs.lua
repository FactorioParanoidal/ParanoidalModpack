require("paralib")

paralib.bobmods.lib.recipe.set_ingredients("automation-science-pack", {
	{ type = "item", name = "iron-gear-wheel", amount = 3 },
	{ type = "item", name = "copper-plate", amount = 10 },
	{ type = "item", name = "sci-component-1", amount = 3 },
})
paralib.bobmods.lib.recipe.enabled("logistic-science-pack", false)
paralib.bobmods.lib.recipe.set_ingredients("logistic-science-pack", {
	{ type = "item", name = "inserter", amount = 2 },
	{ type = "item", name = "transport-belt", amount = 7 },
	{ type = "item", name = "sci-component-2", amount = 3 },
	{ type = "item", name = "bob-bronze-alloy", amount = 7 },
})
paralib.bobmods.lib.recipe.set_ingredients("chemical-science-pack", {
	{ type = "item", name = "advanced-circuit", amount = 1 },
	{ type = "item", name = "engine-unit", amount = 1 },
	{ type = "item", name = "electric-mining-drill", amount = 1 },
	{ type = "item", name = "steel-plate", amount = 7 },
	{ type = "item", name = "sci-component-3", amount = 3 },
})
paralib.bobmods.lib.recipe.set_ingredients("military-science-pack", {
	{ type = "item", name = "piercing-rounds-magazine", amount = 1 },
	{ type = "item", name = "grenade", amount = 1 },
	{ type = "item", name = "gun-turret", amount = 1 },
	{ type = "item", name = "sci-component-m", amount = 3 },
})
paralib.bobmods.lib.recipe.set_ingredients("bob-advanced-logistic-science-pack", {
	{ type = "item", name = "fast-inserter", amount = 1 },
	{ type = "item", name = "flying-robot-frame", amount = 1 },
	{ type = "item", name = "bob-brass-chest", amount = 1 },
	{ type = "item", name = "sci-component-l", amount = 3 },
})
paralib.bobmods.lib.recipe.set_ingredients("production-science-pack", {
	{ type = "item", name = "assembling-machine-1", amount = 1 },
	{ type = "item", name = "electric-furnace", amount = 1 },
	{ type = "item", name = "basic-structure-components", amount = 1 },
	{ type = "item", name = "sci-component-5", amount = 3 },
})

paralib.bobmods.lib.recipe.set_ingredients("utility-science-pack", {
	{ type = "item", name = "processing-unit", amount = 5 },
	{ type = "item", name = "express-transport-belt", amount = 10 },
	{ type = "item", name = "bob-lithium-ion-battery", amount = 10 },
	{ type = "item", name = "uranium-238", amount = 5 },
	{ type = "item", name = "sci-component-4", amount = 3 },
	{ type = "item", name = "bob-rubber", amount = 10 },
	{ type = "item", name = "advsci-component-4", amount = 3 },
})
data.raw["recipe"]["utility-science-pack"].energy_required = 28
data.raw["recipe"]["utility-science-pack"].results[1].amount = 4

paralib.bobmods.lib.recipe.add_ingredient("bob-oil-boiler", { type = "item", name = "oil-steam-boiler", amount = 2 })

paralib.bobmods.lib.recipe.add_ingredient(
	"bob-basic-circuit-board",
	{ type = "item", name = "condensator", amount = 2 }
)

paralib.bobmods.lib.recipe.add_ingredient("advanced-circuit", { type = "item", name = "standart-io", amount = 2 })
paralib.bobmods.lib.recipe.add_ingredient("advanced-circuit", { type = "item", name = "condensator2", amount = 8 })

paralib.bobmods.lib.recipe.add_ingredient("processing-unit", { type = "item", name = "advanced-io", amount = 2 })
paralib.bobmods.lib.recipe.add_ingredient("processing-unit", { type = "item", name = "condensator", amount = 75 })
paralib.bobmods.lib.recipe.add_ingredient("processing-unit", { type = "item", name = "condensator2", amount = 25 })
paralib.bobmods.lib.recipe.add_ingredient("processing-unit", { type = "item", name = "condensator3", amount = 15 })

paralib.bobmods.lib.recipe.add_ingredient(
	"bob-advanced-processing-unit",
	{ type = "item", name = "advanced-io", amount = 2 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-advanced-processing-unit",
	{ type = "item", name = "predictive-io", amount = 2 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-advanced-processing-unit",
	{ type = "item", name = "condensator", amount = 92 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-advanced-processing-unit",
	{ type = "item", name = "condensator2", amount = 40 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-advanced-processing-unit",
	{ type = "item", name = "condensator3", amount = 28 }
)

paralib.bobmods.lib.recipe.add_ingredient(
	"bob-module-processor-board",
	{ type = "item", name = "condensator", amount = 12 }
)

paralib.bobmods.lib.recipe.add_ingredient(
	"bob-module-processor-board-2",
	{ type = "item", name = "condensator", amount = 8 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-module-processor-board-2",
	{ type = "item", name = "condensator2", amount = 10 }
)

paralib.bobmods.lib.recipe.add_ingredient(
	"bob-module-processor-board-3",
	{ type = "item", name = "condensator2", amount = 10 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-module-processor-board-3",
	{ type = "item", name = "condensator3", amount = 16 }
)

paralib.bobmods.lib.recipe.add_ingredient("bob-speed-processor", { type = "item", name = "condensator", amount = 8 })
paralib.bobmods.lib.recipe.add_ingredient("bob-speed-processor-2", { type = "item", name = "condensator2", amount = 8 })
paralib.bobmods.lib.recipe.add_ingredient("bob-speed-processor-3", { type = "item", name = "condensator3", amount = 8 })

paralib.bobmods.lib.recipe.add_ingredient(
	"bob-efficiency-processor",
	{ type = "item", name = "condensator", amount = 8 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-efficiency-processor-2",
	{ type = "item", name = "condensator2", amount = 8 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-efficiency-processor-3",
	{ type = "item", name = "condensator3", amount = 8 }
)

paralib.bobmods.lib.recipe.add_ingredient(
	"bob-productivity-processor",
	{ type = "item", name = "condensator", amount = 8 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-productivity-processor-2",
	{ type = "item", name = "condensator2", amount = 8 }
)
paralib.bobmods.lib.recipe.add_ingredient(
	"bob-productivity-processor-3",
	{ type = "item", name = "condensator3", amount = 8 }
)

paralib.bobmods.lib.recipe.add_ingredient(
	"transport-belt",
	{ type = "item", name = "bob-basic-transport-belt", amount = 2 }
)
