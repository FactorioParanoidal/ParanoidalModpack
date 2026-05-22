local move_item = angelsmods.functions.move_item
local set_ingredients = bobmods.lib.recipe.set_ingredients

move_item("motor", "angels-basic-intermediate", "a[motor]-a")

set_ingredients("motor", {
	{ type = "item", name = "iron-plate", amount = 6 },
	{ type = "item", name = "iron-gear-wheel", amount = 4 },
})

move_item("electric-motor", "angels-basic-intermediate", "a[motor]-b")

set_ingredients("electric-motor", {
	{ type = "item", name = "motor", amount = 1 },
	{ type = "item", name = "copper-cable", amount = 4 },
})

set_ingredients("iron-gear-wheel", {
	{ type = "item", name = "iron-plate", amount = 3 },
})
set_ingredients("iron-stick", {
	{ type = "item", name = "iron-plate", amount = 5 },
})