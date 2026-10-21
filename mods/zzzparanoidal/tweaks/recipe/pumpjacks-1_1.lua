-- The missing 1.1 tier used titanium, processing units and two advanced frames.
local name = "paranoidal-pumpjack-4"
local recipe = data.raw.recipe[name]
local technology = data.raw.technology["paranoidal-pumpjacks-4"]
if not (recipe and technology) then return end

recipe.ingredients = {
    {type = "item", name = "bob-pumpjack-2", amount = 2},
    {type = "item", name = "bob-titanium-plate", amount = 20},
    {type = "item", name = "bob-titanium-gear-wheel", amount = 10},
    {type = "item", name = "processing-unit", amount = 5},
    {type = "item", name = "bob-titanium-pipe", amount = 10},
    {type = "item", name = "advanced-structure-components", amount = 2},
}
recipe.energy_required = 5
recipe.allow_productivity = false

-- Preserve the current top-tier price, substituting only its previous machine.
local top_recipe = data.raw.recipe["bob-pumpjack-3"]
if top_recipe then
    for _, ingredient in pairs(top_recipe.ingredients or {}) do
        if (ingredient.name or ingredient[1]) == "bob-pumpjack-2" then
            if ingredient.name then ingredient.name = name else ingredient[1] = name end
        end
    end
    top_recipe.localised_name = {"entity-name.paranoidal-pumpjack-5"}
end

for _, prerequisite in ipairs({"processing-unit", "bob-titanium-processing", "angels-metallurgy-3"}) do
    if data.raw.technology[prerequisite] then
        paralib.bobmods.lib.tech.add_prerequisite(technology.name, prerequisite)
    end
end
local top_technology = data.raw.technology["bob-pumpjacks-4"]
if top_technology then
    paralib.bobmods.lib.tech.add_prerequisite(top_technology.name, technology.name)
    top_technology.localised_name = {"technology-name.paranoidal-pumpjacks-5"}
end
