--нерфим плавку дробленки в печах
--сапфирит
bobmods.lib.recipe.set_energy_required("iron-plate", 20)
bobmods.lib.recipe.set_ingredient("iron-plate", { type = "item", name = "angels-ore1-crushed", amount = 7})
bobmods.lib.recipe.set_result("iron-plate", { type = "item", name = "iron-plate", amount = 4 })
bobmods.lib.recipe.add_result("iron-plate", { type = "item", name = "angels-slag", amount = 1})
--стиратит
bobmods.lib.recipe.set_energy_required("copper-plate", 20)
bobmods.lib.recipe.set_ingredient("copper-plate", { type = "item", name = "angels-ore3-crushed", amount = 7})
bobmods.lib.recipe.set_result("copper-plate", { type = "item", name = "copper-plate", amount = 4 })
bobmods.lib.recipe.add_result("copper-plate", { type = "item", name = "angels-slag", amount = 1})
--рубит
bobmods.lib.recipe.set_energy_required("angels-ore5-crushed-smelting", 20)
bobmods.lib.recipe.set_ingredient("angels-ore5-crushed-smelting", { type = "item", name = "angels-ore5-crushed", amount = 7})
bobmods.lib.recipe.set_result("angels-ore5-crushed-smelting", { type = "item", name = "bob-lead-plate", amount = 4 })
bobmods.lib.recipe.add_result("angels-ore5-crushed-smelting", { type = "item", name = "angels-slag", amount = 1})
--бобмониум
bobmods.lib.recipe.set_energy_required("angels-ore6-crushed-smelting", 20)
bobmods.lib.recipe.set_ingredient("angels-ore6-crushed-smelting", { type = "item", name = "angels-ore6-crushed", amount = 7})
bobmods.lib.recipe.set_result("angels-ore6-crushed-smelting", { type = "item", name = "bob-tin-plate", amount = 4 })
bobmods.lib.recipe.add_result("angels-ore6-crushed-smelting", { type = "item", name = "angels-slag", amount = 1})

