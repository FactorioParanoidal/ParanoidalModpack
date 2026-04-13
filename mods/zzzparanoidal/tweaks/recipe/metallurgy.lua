require("__zzzparanoidal__.paralib")

-- from KaoExtended
paralib.bobmods.lib.recipe.remove_ingredient("bob-brass-alloy", "copper-plate")
paralib.bobmods.lib.recipe.remove_ingredient("bob-brass-alloy", "bob-zinc-plate")
paralib.bobmods.lib.recipe.add_ingredient("bob-brass-alloy", { type = "item", name = "bob-bronze-alloy", amount = 2 })
paralib.bobmods.lib.recipe.add_ingredient("bob-brass-alloy", { type = "item", name = "bob-zinc-plate", amount = 8 })

paralib.bobmods.lib.recipe.remove_ingredient("bob-invar-alloy", "iron-plate")
paralib.bobmods.lib.recipe.add_ingredient("bob-invar-alloy", { type = "item", name = "bob-lead-plate", amount = 3 })

paralib.bobmods.lib.recipe.hide("bob-zinc-plate")
paralib.bobmods.lib.recipe.hide("bob-nickel-plate")

paralib.bobmods.lib.recipe.hide("bob-invar-alloy")
paralib.bobmods.lib.recipe.hide("bob-brass-alloy")

--нерфим плавку дробленки в печах
--сапфирит
paralib.bobmods.lib.recipe.set_energy_required("iron-plate", 20)
paralib.bobmods.lib.recipe.set_ingredient("iron-plate", { type = "item", name = "angels-ore1-crushed", amount = 7})
paralib.bobmods.lib.recipe.set_result("iron-plate", { type = "item", name = "iron-plate", amount = 4 })
paralib.bobmods.lib.recipe.add_result("iron-plate", { type = "item", name = "angels-slag", amount = 1})
--стиратит
paralib.bobmods.lib.recipe.set_energy_required("copper-plate", 20)
paralib.bobmods.lib.recipe.set_ingredient("copper-plate", { type = "item", name = "angels-ore3-crushed", amount = 7})
paralib.bobmods.lib.recipe.set_result("copper-plate", { type = "item", name = "copper-plate", amount = 4 })
paralib.bobmods.lib.recipe.add_result("copper-plate", { type = "item", name = "angels-slag", amount = 1})
--рубит (переноємо в data-final-fixes.lua після OV.execute)
-- paralib: bob-lead-plate → пряме присвоєння після OV.execute
--бобмониум (переносимо в data-final-fixes.lua)
-- paralib: bob-tin-plate → пряме присвоєння після OV.execute

--бафаем скорость первой сортировки
paralib.bobmods.lib.recipe.set_energy_required("angels-ore1-crushed-processing", 2)
paralib.bobmods.lib.recipe.set_ingredient("angels-ore1-crushed-processing", { type = "item", name = "angels-ore1-crushed", amount = 20})
paralib.bobmods.lib.recipe.set_result("angels-ore1-crushed-processing", { name = "angels-slag", type = "item", amount = 5 })
paralib.bobmods.lib.recipe.set_result("angels-ore1-crushed-processing", { name = "iron-ore", type = "item", amount = 10 })
paralib.bobmods.lib.recipe.set_result("angels-ore1-crushed-processing", { name = "copper-ore", type = "item", amount = 5 })

paralib.bobmods.lib.recipe.set_energy_required("angels-ore2-crushed-processing", 2)
paralib.bobmods.lib.recipe.set_ingredient("angels-ore2-crushed-processing", { type = "item", name = "angels-ore2-crushed", amount = 20})
paralib.bobmods.lib.recipe.set_result("angels-ore2-crushed-processing", { name = "angels-slag", type = "item", amount = 5 })
paralib.bobmods.lib.recipe.set_result("angels-ore2-crushed-processing", { name = "iron-ore", type = "item", amount = 10 })
paralib.bobmods.lib.recipe.set_result("angels-ore2-crushed-processing", { name = "copper-ore", type = "item", amount = 5 })

paralib.bobmods.lib.recipe.set_energy_required("angels-ore3-crushed-processing", 2)
paralib.bobmods.lib.recipe.set_ingredient("angels-ore3-crushed-processing", { type = "item", name = "angels-ore3-crushed", amount = 20})
paralib.bobmods.lib.recipe.set_result("angels-ore3-crushed-processing", { name = "angels-slag", type = "item", amount = 5 })
paralib.bobmods.lib.recipe.set_result("angels-ore3-crushed-processing", { name = "copper-ore", type = "item", amount = 10 })
paralib.bobmods.lib.recipe.set_result("angels-ore3-crushed-processing", { name = "iron-ore", type = "item", amount = 5 })

paralib.bobmods.lib.recipe.set_energy_required("angels-ore4-crushed-processing", 2)
paralib.bobmods.lib.recipe.set_ingredient("angels-ore4-crushed-processing", { type = "item", name = "angels-ore4-crushed", amount = 20})
paralib.bobmods.lib.recipe.set_result("angels-ore4-crushed-processing", { name = "angels-slag", type = "item", amount = 5 })
paralib.bobmods.lib.recipe.set_result("angels-ore4-crushed-processing", { name = "copper-ore", type = "item", amount = 10 })
paralib.bobmods.lib.recipe.set_result("angels-ore4-crushed-processing", { name = "iron-ore", type = "item", amount = 5 })

paralib.bobmods.lib.recipe.set_energy_required("angels-ore5-crushed-processing", 2)
paralib.bobmods.lib.recipe.set_ingredient("angels-ore5-crushed-processing", { type = "item", name = "angels-ore5-crushed", amount = 20})
paralib.bobmods.lib.recipe.set_result("angels-ore5-crushed-processing", { name = "angels-slag", type = "item", amount = 5 })
paralib.bobmods.lib.recipe.set_result("angels-ore5-crushed-processing", { name = "bob-lead-ore", type = "item", amount = 10 })
paralib.bobmods.lib.recipe.set_result("angels-ore5-crushed-processing", { name = "bob-nickel-ore", type = "item", amount = 5 })

paralib.bobmods.lib.recipe.set_energy_required("angels-ore6-crushed-processing", 2)
paralib.bobmods.lib.recipe.set_ingredient("angels-ore6-crushed-processing", { type = "item", name = "angels-ore6-crushed", amount = 20})
paralib.bobmods.lib.recipe.set_result("angels-ore6-crushed-processing", { name = "angels-slag", type = "item", amount = 5 })
paralib.bobmods.lib.recipe.set_result("angels-ore6-crushed-processing", { name = "bob-tin-ore", type = "item", amount = 10 })
paralib.bobmods.lib.recipe.set_result("angels-ore6-crushed-processing", { name = "bob-quartz", type = "item", amount = 5 })
-------------------------------------------------------------------------------------------------
--баф скорости дробления шлака
paralib.bobmods.lib.recipe.set_energy_required("angels-stone-crushed", 2)
paralib.bobmods.lib.recipe.set_ingredient("angels-stone-crushed", { type = "item", name = "angels-slag", amount = 5})
paralib.bobmods.lib.recipe.set_result("angels-stone-crushed", { type = "item", name = "angels-stone-crushed", amount = 10})

