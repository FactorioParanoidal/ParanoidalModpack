-- Valves copy the cost, unlock technology and subgroup of the pump
-- (zzzparanoidal then moves them to angels-fluid-control with their own cost).
local valves = require("config")

local function find_unlocking_technology()
    for _, technology in pairs(data.raw.technology) do
        for index, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == "pump" then return technology, index end
        end
    end
end

local technology, index = find_unlocking_technology()
local pump_recipe = data.raw.recipe["pump"]
local pump_item = data.raw.item["pump"]

for offset, valve in ipairs(valves) do
    if technology then
        table.insert(technology.effects, index + offset - 1, { type = "unlock-recipe", recipe = valve.name })
    end
    local recipe = data.raw.recipe[valve.name]
    recipe.enabled = technology == nil
    if pump_recipe then recipe.ingredients = table.deepcopy(pump_recipe.ingredients) end -- own copy, not shared
    if pump_item then data.raw.item[valve.name].subgroup = pump_item.subgroup end
end
