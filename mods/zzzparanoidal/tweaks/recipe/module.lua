require("paralib")

paralib.bobmods.lib.recipe.set_ingredients("bob-module-contact", {
	{ type = "item", name = "bob-silver-plate", amount = 1 },
	{ type = "item", name = "bob-gold-plate", amount = 1 },
})
paralib.bobmods.lib.recipe.set_results(
	"bob-module-contact",
	{ { type = "item", name = "bob-module-contact", amount = 2 } }
)


