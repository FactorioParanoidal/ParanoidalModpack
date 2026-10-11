-- Колба PCPRedux не используется после финальных правок рецептов науки.
if not mods["PCPRedux"] then return end

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
