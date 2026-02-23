bobmods.lib.tech.replace_science_pack("bob-electricity", "angels-science-pack-red", "angels-science-pack-grey")
bobmods.lib.tech.replace_science_pack("basic-automation", "angels-science-pack-red", "angels-science-pack-grey")
bobmods.lib.tech.replace_science_pack("basic-fluid-handling", "angels-science-pack-red", "angels-science-pack-grey")
bobmods.lib.tech.replace_science_pack("basic-automation", "datacore-processing-1", "datacore-basic")
bobmods.lib.tech.replace_science_pack("basic-fluid-handling", "datacore-logistic-1", "datacore-basic")
bobmods.lib.tech.replace_science_pack("steam-power", "angels-science-pack-red", "angels-science-pack-grey")
bobmods.lib.tech.replace_science_pack("steam-power", "datacore-energy-1", "datacore-basic")
bobmods.lib.tech.add_prerequisite("basic-automation","angels-components-mechanical-1")
angelsmods.functions.OV.global_replace_item("bob-brass-gear-wheel", "bob-brass-alloy")
angelsmods.functions.OV.global_replace_item("bob-steel-gear-wheel", "bob-steel-bearing")
angelsmods.functions.OV.global_replace_item("engine-unit", "motor-2")
angelsmods.functions.OV.global_replace_item("electric-engine-unit", "motor-4")
angelsmods.functions.OV.global_replace_item("battery", "bob-battery-2")
angelsmods.functions.OV.global_replace_item("lab", "angels-basic-lab-2")
angelsmods.functions.OV.global_replace_item("condensator", "circuit-transistor")
angelsmods.functions.OV.global_replace_item("condensator2", "circuit-microchip")
angelsmods.functions.OV.global_replace_item("condensator3", "circuit-transformer")
angelsmods.functions.OV.global_replace_item("bob-titanium-gear-wheel", "mechanical-parts")
angelsmods.functions.OV.global_replace_item("predictive-io", "bob-module-contact")
angelsmods.functions.OV.global_replace_item("intelligent-io", "bob-module-contact")
angelsmods.functions.OV.disable_recipe("condensator")
angelsmods.functions.OV.disable_recipe("condensator2")
angelsmods.functions.OV.disable_recipe("condensator3")
angelsmods.functions.OV.execute()
bobmods.lib.recipe.replace_ingredient("fast-belt", "angels-gear", "bob-steel-bearing")
bobmods.lib.recipe.replace_ingredient("fast-splitter", "angels-gear", "bob-steel-bearing")

--меняем рецепт у прототипа артилерии
bobmods.lib.recipe.clear_ingredients("artillery-turret-prototype")
bobmods.lib.recipe.add_ingredient("artillery-turret-prototype", { type = "item", name = "block-construction-2", amount = 10})
bobmods.lib.recipe.add_ingredient("artillery-turret-prototype", { type = "item", name = "block-mechanical-1", amount = 5})
bobmods.lib.recipe.add_ingredient("artillery-turret-prototype", { type = "item", name = "block-electronics-2", amount = 2})
bobmods.lib.recipe.add_ingredient("artillery-turret-prototype", { type = "item", name = "block-warfare-2", amount = 2})
bobmods.lib.recipe.add_ingredient("artillery-turret-prototype", { type = "item", name = "angels-concrete-brick", amount = 100})

--меняем рецепт у смешивателей металла
    bobmods.lib.recipe.clear_ingredients("alloy-mixer")
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "alloym-1", amount = 1})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t1-plate", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t0-circuit", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t1-pipe", amount = 4})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t1-gears", amount = 2})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t1-brick", amount = 2})

    bobmods.lib.recipe.clear_ingredients("alloy-mixer-2")
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "alloym-2", amount = 1})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t2-plate", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t2-circuit", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t2-pipe", amount = 4})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t2-gears", amount = 2})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t2-brick", amount = 2})

    bobmods.lib.recipe.clear_ingredients("alloy-mixer-3")
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "alloym-3", amount = 1})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t3-plate", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t3-circuit", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t3-pipe", amount = 4})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t3-gears", amount = 2})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t3-brick", amount = 2})

    bobmods.lib.recipe.clear_ingredients("alloy-mixer-4")
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "alloym-4", amount = 1})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t4-plate", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t4-circuit", amount = 3})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t4-pipe", amount = 4})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t4-gears", amount = 2})
    bobmods.lib.recipe.add_ingredient("alloy-mixer", { type = "item", name = "t4-brick", amount = 2})

--доработка атомных снарядов
data.raw.projectile["atomic-bomb-wave"].action[1].action_delivery.target_effects.damage.amount=5000
data.raw.projectile["atomic-bomb-wave"].action[1].action_delivery.target_effects.upper_distance_threshold=100
data.raw["artillery-projectile"]["artillery-projectile-nuclear"].action.action_delivery.target_effects[5].action.radius = 66
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[7].damage.amount = 666666
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[10].radius = 240
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[13].action.radius = 78
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[13].action.repeat_count = 4000
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[14].action.radius = 103
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[14].action.repeat_count = 4000
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[15].action.radius = 132
data.raw["artillery-projectile"]["artillery-projectile-thermonuclear"].action.action_delivery.target_effects[15].action.repeat_count = 4000
