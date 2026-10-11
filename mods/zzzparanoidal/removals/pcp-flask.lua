-- Колба PCPRedux не используется после финальных правок рецептов науки.
if not mods["PCPRedux"] then return end

-- Quality строит переработку в data-updates, до финальных правок науки.
-- Переработка не потребитель колбы: убираем колбу из её выходов, пустую делаем самопереработкой.
data.raw.recipe["flask-recycling"] = nil
for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == "recycling" and recipe.results then
        for index = #recipe.results, 1, -1 do
            local entry = recipe.results[index]
            if (entry.name or entry[1]) == "flask" then table.remove(recipe.results, index) end
        end
        local input = recipe.ingredients and recipe.ingredients[1]
        if #recipe.results == 0 and input then
            recipe.results = { { type = "item", name = input.name or input[1], amount = 1, probability = 0.25, ignored_by_stats = 1 } }
        end
    end
end

for name, recipe in pairs(data.raw.recipe) do
    if name ~= "flask" then
        for _, list in ipairs({ recipe.ingredients or {}, recipe.results or {} }) do
            for _, entry in pairs(list) do
                assert((entry.name or entry[1]) ~= "flask", "PCP flask still used by recipe: " .. name)
            end
        end
    end
end
for name, technology in pairs(data.raw.technology) do
    if name ~= "flask" then
        for _, prerequisite in pairs(technology.prerequisites or {}) do
            assert(prerequisite ~= "flask", "PCP flask technology still required by: " .. name)
        end
        for index = #(technology.effects or {}), 1, -1 do
            local effect = technology.effects[index]
            if effect.type == "unlock-recipe" and effect.recipe == "flask" then
                table.remove(technology.effects, index)
            end
        end
    end
end

data.raw.recipe["flask"] = nil
data.raw.technology["flask"] = nil
data.raw.item["flask"] = nil
