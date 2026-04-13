require("paralib")

paralib.bobmods.lib.recipe.set_ingredients("bob-module-contact", {
	{ type = "item", name = "bob-silver-plate", amount = 1 },
	{ type = "item", name = "bob-gold-plate", amount = 1 },
})
paralib.bobmods.lib.recipe.set_results(
	"bob-module-contact",
	{ { type = "item", name = "bob-module-contact", amount = 2 } }
)

-- from KaoExtended
paralib.bobmods.lib.recipe.add_new_ingredient("angels-bio-yield-module", {type = "item", name = "bob-alien-artifact", amount = 5})
paralib.bobmods.lib.recipe.add_new_ingredient("angels-bio-yield-module-2", {type = "item", name = "bob-alien-artifact", amount = 10})
paralib.bobmods.lib.recipe.add_new_ingredient("angels-bio-yield-module-3", {type = "item", name = "bob-alien-artifact", amount = 20})


