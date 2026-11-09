if not mods["Krastorio2-spaced-out"] then return end
local table = require("lib.table")

local new_ingredients = {}
for _, ingredient in pairs(data.raw.recipe["promethium-science-pack"].ingredients) do
    if ingredient.name == "biter-egg" then
        ingredient.amount = ingredient.amount * 2
        table.insert(data.raw.recipe["kr-promethium-research-data"].ingredients, ingredient)
    else
        table.insert(new_ingredients, ingredient)
    end
end
data.raw.recipe["promethium-science-pack"].ingredients = new_ingredients

local qc = data.raw["assembling-machine"]["kr-quantum-computer"]
if qc then
    qc.effect_receiver = qc.effect_receiver or {}
    qc.effect_receiver.base_effect = qc.effect_receiver.base_effect or {}
    qc.effect_receiver.base_effect.quality = 0.5
end

data.raw["assembling-machine"]["kr-quantum-computer"].energy_usage = "50MW"

data.raw["assembling-machine"]["kr-advanced-chemical-plant"].crafting_categories =
    table.delete_if(data.raw["assembling-machine"]["kr-advanced-chemical-plant"].crafting_categories, "kr-fluid-filtration")

data.raw.recipe["hydraulic-science-pack-cooling"].results[1].quality_change = -1