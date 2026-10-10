-- Согласованная интеграция: новые платиновые потребители и восстановление магния/углеродных пеллет.
-- Поздно, после OV.execute и восстановления модульной системы. Остальные рецептуры не меняются.
local technologies, recipes = data.raw.technology, data.raw.recipe
local function prerequisite(name, parent)
    local technology = assert(technologies[name], "Missing technology: " .. name)
    assert(technologies[parent], "Missing prerequisite: " .. parent)
    technology.prerequisites = technology.prerequisites or {}
    for _, value in ipairs(technology.prerequisites) do if value == parent then return end end
    technology.prerequisites[#technology.prerequisites + 1] = parent
end
local function unlock(name, recipe)
    local technology = assert(technologies[name], "Missing technology: " .. name)
    assert(recipes[recipe], "Missing recipe: " .. recipe)
    technology.effects = technology.effects or {}
    for _, effect in ipairs(technology.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe then return end
    end
    technology.effects[#technology.effects + 1] = { type = "unlock-recipe", recipe = recipe }
end
local consumers = {
    { "angels-ore-sorting-facility-5", "paranoidal-platinum-servo", 4, "angels-advanced-ore-refining-4", "paranoidal-platinum-servos" },
    { "angels-strand-casting-machine-4", "paranoidal-platinum-servo", 4, "angels-strand-casting-4", "paranoidal-platinum-servos" },
    { "angels-advanced-chemical-plant-2", "paranoidal-platinum-harness", 8, "angels-advanced-chemistry-4", "paranoidal-platinum-cabling" },
    { "angels-advanced-chemical-plant-3", "paranoidal-platinum-harness", 16, "angels-advanced-chemistry-5", "paranoidal-platinum-cabling" },
    { "satellite-communications", "paranoidal-platinum-harness", 8, "extremely-advanced-material-processing", "paranoidal-platinum-cabling" },
}
for _, row in ipairs(consumers) do
    local recipe = assert(recipes[row[1]], "Missing platinum consumer: " .. row[1])
    local found = false
    for _, ingredient in ipairs(recipe.ingredients) do
        if (ingredient.name or ingredient[1]) == row[2] then
            ingredient.amount = row[3]
            found = true
        end
    end
    if not found then recipe.ingredients[#recipe.ingredients + 1] = { type = "item", name = row[2], amount = row[3] } end
    prerequisite(row[4], row[5])
end
-- Clowns 2.0 скрывает литьё магния при выключенном plate-trigger, несмотря на оставшихся потребителей.
-- Возвращаем два последних шага Beta 8; действующая добыча и обработка руды/слитков сохраняются.
for _, name in ipairs({ "clowns-molten-magnesium-smelting", "clowns-plate-magnesium" }) do
    local recipe = assert(recipes[name], "Missing magnesium recipe: " .. name)
    recipe.hidden = false
    recipe.enabled = false
    recipe.localised_name = nil -- Удаляем служебное имя angels-void, имя берётся из результата.
    unlock("advanced-magnesium-smelting", name)
end
assert(data.raw.fluid["clowns-liquid-molten-magnesium"]).hidden = false
assert(data.raw.item["clowns-plate-magnesium"]).hidden = false
prerequisite("automation-8", "advanced-magnesium-smelting")
prerequisite("electronics-machine-5", "advanced-magnesium-smelting")
-- Normal Beta 8: 5 углерода -> 1 коксовая пеллета, 4 секунды, та же коксовая печь BI.
local pellet = assert(recipes["bi-pellet-coke-2"])
pellet.ingredients = { { type = "item", name = "angels-solid-carbon", amount = 5 } }
pellet.results = { { type = "item", name = "angels-pellet-coke", amount = 1 } }
pellet.energy_required = 4
pellet.enabled = false
unlock("bi-tech-coal-processing-2", "bi-pellet-coke-2")
-- Не переносим всю азотную ветку и не требуем позднюю химию для PMMA:
-- питательная пульпа из умеренного фермерства даёт ранний биологический ацетон.
prerequisite("plastic-pc", "angels-advanced-chemistry-5")
prerequisite("plastic-pmma", "angels-bio-nutrient-paste")
prerequisite("plastic-pmma", "angels-bio-temperate-farming-1")
prerequisite("modules", "angels-bio-temperate-farming-1")
