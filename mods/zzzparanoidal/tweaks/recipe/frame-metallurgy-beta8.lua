-- Beta 8 (KaoExtended + zzzparanoidal), after Angels overrides/OV.execute.
-- Keep the expensive bootstrap route in Bob's mixing furnaces, not blast furnaces.
for _, name in ipairs({
    "bronze-alloy-x", "bob-brass-alloy-x", "bob-invar-alloy-x", "bob-cobalt-steel-alloy-x",
}) do
    local recipe = data.raw.recipe[name]
    if recipe then recipe.category = "bob-mixing-furnace" end
end

-- Beta 8 frames were machine-only. A dedicated category avoids changing other
-- recipes or the character; retain the current machines' ingredient limits.
local category = "paranoidal-structure-crafting"
data:extend({{ type = "recipe-category", name = category }})
for _, machine in pairs(data.raw["assembling-machine"]) do
    local categories = machine.crafting_categories or {}
    local crafting, present = false, false
    for _, name in ipairs(categories) do
        if name == "crafting" then crafting = true end
        if name == category then present = true end
    end
    if crafting and not present then table.insert(categories, category) end
end
for _, name in ipairs({"basic", "intermediate", "advanced"}) do
    local recipe = data.raw.recipe[name .. "-structure-components"]
    if recipe then recipe.category = category end
end

-- The tier-III bootstrap used ordinary concrete, not the new Angels bricks.
for _, name in ipairs({
    "angels-blast-furnace-3", "angels-induction-furnace-3",
    "angels-casting-machine-3", "angels-chemical-furnace-2",
}) do
    local recipe = data.raw.recipe[name]
    if recipe then
        for _, ingredient in ipairs(recipe.ingredients or {}) do
            if ingredient.name == "angels-concrete-brick" then ingredient.name = "concrete" end
        end
    end
end
