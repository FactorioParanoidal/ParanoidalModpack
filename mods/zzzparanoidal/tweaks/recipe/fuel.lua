require("__zzzparanoidal__.paralib")
-- Общие твёрдые топлива задаёт поздний tweaks.custom.energy-port после flowfix.

-- баланс электрички
if mods["BatteryElectricTrain"] then
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-2-empty", "battery", "bob-battery-2")
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-3-empty", "battery", "bob-battery-3")
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "battery", "bob-battery-3")
	paralib.bobmods.lib.recipe.replace_ingredient("bet-fuel-4-empty", "efficiency-module-3", "speed-module-3")
	paralib.bobmods.lib.recipe.add_ingredient("bet-fuel-4-empty", { type = "item", name = "bob-advanced-processing-unit", amount = 3})
end
