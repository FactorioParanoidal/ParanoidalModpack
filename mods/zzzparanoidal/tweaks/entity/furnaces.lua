require("__zzzparanoidal__.paralib")
-- подкрутка печек чтобы использовать рецепт со шлаком
data.raw["furnace"]["stone-furnace"].result_inventory_size = 2
data.raw["furnace"]["steel-furnace"].result_inventory_size = 2
data.raw["furnace"]["electric-furnace"].result_inventory_size = 2
data.raw["furnace"]["bob-electric-furnace-2"].result_inventory_size = 2
data.raw["furnace"]["bob-electric-furnace-3"].result_inventory_size = 2

--Исправление загрязнения для отстойника и факельной стойки
data.raw["furnace"]["angels-clarifier"].energy_source.emissions_per_minute = { pollution = 75 }
data.raw["furnace"]["angels-flare-stack"].energy_source.emissions_per_minute = { pollution = 75 }

-- Иконки и графика зарядников BET 1–3 — tweaks/entity/battery-electric-train-chargers.lua (data-updates).

-- super_charger стоит как "4" сразу за bet-charger-3 (order "b"); низкоприоритетные — после него
for _, name in ipairs({ "bet-charger-tertiary-1", "bet-charger-tertiary-2", "bet-charger-tertiary-3" }) do
	if data.raw.item[name] then
		data.raw.item[name].order = "c"
	end
end

