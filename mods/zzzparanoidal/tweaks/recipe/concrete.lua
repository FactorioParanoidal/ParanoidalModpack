require("__zzzparanoidal__.paralib")
--убираем рецепт бетона из бетона
paralib.bobmods.lib.recipe.hide("angels-concrete")

-- from KaoExtended
paralib.bobmods.lib.recipe.remove_ingredient("angels-concrete", "concrete")
paralib.bobmods.lib.recipe.add_new_ingredient("angels-concrete", { type = "item", name = "concrete", amount = 10 })

