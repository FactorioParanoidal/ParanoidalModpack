local is_wire_surrogate = settings.startup["wire-shortcuts-is-retain-wire-crafting"].value

if data.raw["recipe"]["red-wire"] and data.raw["recipe"]["green-wire"] then
    data.raw["recipe"]["red-wire"].hidden = true
    data.raw["recipe"]["red-wire"].enabled = false
    data.raw["recipe"]["green-wire"].hidden = true
    data.raw["recipe"]["green-wire"].enabled = false
end

if data.raw["item"]["red-wire"] and data.raw["item"]["green-wire"] then
    data.raw["item"]["red-wire"].flags = {"only-in-cursor"}
    data.raw["item"]["green-wire"].flags = {"only-in-cursor"}
end

if data.raw["technology"]["circuit-network"] then
    local tech_effects = data.raw["technology"]["circuit-network"].effects
    for i = (#tech_effects), 1, -1 do
        if tech_effects[i].type == "unlock-recipe" then
            if tech_effects[i].recipe == "red-wire" or tech_effects[i].recipe == "green-wire" then
                if is_wire_surrogate then
                    tech_effects[i].recipe = "fake-" .. tech_effects[i].recipe
                else
                    table.remove(tech_effects, i)
                end
            end
        end
    end
end

function remove_or_replace_wire(ingredients)
    for i = (#ingredients), 1, -1 do
        if ingredients[i] then
            if ingredients[i][1] == "green-wire" or
                    ingredients[i][1] == "red-wire" then
                if is_wire_surrogate then
                    ingredients[i][1] = "fake-" .. ingredients[i][1]
                else
                    table.remove(ingredients, i)
                end
            elseif ingredients[i].name and (ingredients[i].name == "green-wire" or ingredients[i].name == "red-wire") then
                if is_wire_surrogate then
                    ingredients[i].name = "fake-" .. ingredients[i].name
                else
                    table.remove(ingredients, i)
                end
            end
        end
    end
end

for _, recipe in pairs(data.raw["recipe"]) do
    if recipe.ingredients then
        remove_or_replace_wire(recipe.ingredients)
    end
    if recipe.expensive and recipe.expensive.ingredients then
        remove_or_replace_wire(recipe.expensive.ingredients)
    end
    if recipe.normal and recipe.normal.ingredients then
        remove_or_replace_wire(recipe.normal.ingredients)
    end
end

if is_wire_surrogate then
    data.raw["item"]["fake-red-wire"].flags = {}
    data.raw["item"]["fake-green-wire"].flags = {}
    data.raw["recipe"]["fake-red-wire"].hidden = false
    data.raw["recipe"]["fake-green-wire"].hidden = false
    if data.raw["recipe"]["red-wire"] and data.raw["recipe"]["green-wire"] then
        data.raw["recipe"]["fake-red-wire"].ingredients = data.raw["recipe"]["red-wire"].ingredients
        data.raw["recipe"]["fake-green-wire"].ingredients = data.raw["recipe"]["green-wire"].ingredients
    end
end