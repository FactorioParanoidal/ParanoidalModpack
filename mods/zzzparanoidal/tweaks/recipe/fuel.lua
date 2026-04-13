require("__zzzparanoidal__.paralib")
-- 5 solid fuel -> 4 coke pellets, 5*12MJ -> 4*15MJ
data.raw.recipe["bi-pellet-coke"].results[1].result_count = 4
data.raw.recipe["bi-pellet-coke"].energy_required = 4
-- 1MJ*16 pulp -> 20MJ*1 brick
data.raw.recipe["bi-wood-fuel-brick"].ingredients = 
    {{type = "item", name = "bi-woodpulp", amount=40}}

-- баланс электрички
if mods["BatteryElectricTrain"] then
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-2-empty", "battery", "bob-lithium-ion-battery")
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-3-empty", "battery", "bob-silver-zinc-battery")
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "battery", "bob-silver-zinc-battery")
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "effectivity-module-3", "speed-module-3")
	paralib.bobmods.lib.recipe.add_ingredient("bet-fuel-4-empty", { type = "item", name = "bob-advanced-processing-unit", amount = 3})
end
