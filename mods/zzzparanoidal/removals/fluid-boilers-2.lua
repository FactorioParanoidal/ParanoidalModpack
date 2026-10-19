-- The user chose the five Beta 8 KS boilers instead of Bob's fluid boilers.
-- Delete only this family and its conversion recipes, after all Bob/Angels overrides.
-- Existing saves are intentionally unsupported; no migration or replacement on surfaces.
local items, recipes, technologies = {}, {}, {}
for tier = 1, 4 do
    local name = "bob-oil-boiler" .. (tier == 1 and "" or "-" .. tier)
    items[name], recipes[name] = true, true
    -- Quality creates these in data-updates, before this family is retired.
    -- Remove only the retired items' recycling recipes; keep the consumer guard.
    recipes[name .. "-recycling"] = true
    technologies["bob-oil-boiler-" .. tier] = true
    recipes["bob-boiler-" .. (tier + 1) .. "-from-oil-boiler" .. (tier == 1 and "" or "-" .. tier)] = true
    if tier > 1 then
        recipes[name .. "-from-boiler-" .. (tier + 1)] = true
    end
end

-- Do not silently erase unrelated content if a future upstream update adds a consumer.
for name, recipe in pairs(data.raw.recipe) do
    if not recipes[name] then
        for _, list in ipairs({recipe.ingredients or {}, recipe.results or {}}) do
            for _, ingredient in pairs(list) do
                assert(not items[ingredient.name or ingredient[1]], "Removed fluid boiler still used by recipe: " .. name)
            end
        end
    end
end
for name, technology in pairs(data.raw.technology) do
    if not technologies[name] then
        for _, prerequisite in pairs(technology.prerequisites or {}) do
            assert(not technologies[prerequisite], "Removed fluid boiler technology still required by: " .. name)
        end
        for index = #(technology.effects or {}), 1, -1 do
            local effect = technology.effects[index]
            if effect.type == "unlock-recipe" and recipes[effect.recipe] then
                table.remove(technology.effects, index)
            end
        end
    end
end
for name in pairs(recipes) do data.raw.recipe[name] = nil end
for name in pairs(technologies) do data.raw.technology[name] = nil end
for name in pairs(items) do
    data.raw.item[name] = nil
    data.raw.boiler[name] = nil
end
