function nuclear_category(input,output)
    local newCategory = {}
    local function multiply_ingredients(newRecipe, oldRecipe, multiplier)
        if newRecipe.ingredients[1].amount then
            newRecipe.ingredients[1].amount = oldRecipe.ingredients[1].amount*multiplier
        elseif newRecipe.ingredients[1][2] then
            newRecipe.ingredients[1][2] = oldRecipe.ingredients[1][2]*multiplier
        end
        return newRecipe
    end
    local function multiply_results(newRecipe, oldRecipe, multiplier)
        if oldRecipe.results then
            if oldRecipe.results[1].amount then
                newRecipe.results[1].amount = oldRecipe.results[1].amount*multiplier
            elseif oldRecipe.results[1][2] then
                newRecipe.results[1][2] = oldRecipe.results[1][2]*multiplier
            end
            newRecipe.result_count = multiplier
        elseif oldRecipe.result_count then
            newRecipe.result_count = oldRecipe.result_count*multiplier
        else
            newRecipe.result_count = multiplier
        end
        return newRecipe
    end
    for recipeName,_ in pairs(data.raw["recipe"]) do
        local oldRecipe = table.deepcopy(data.raw.recipe[recipeName])
       if oldRecipe.category == "smelting" and oldRecipe.normal then
            local newRecipe = oldRecipe
            newRecipe.category = "nuclear-smelting"
            newRecipe.name = "nuclear-smelting-"..oldRecipe.name
            newRecipe.type = "recipe"
            newRecipe.normal = multiply_ingredients(newRecipe.normal, oldRecipe.normal, input)
            newRecipe.normal.enabled = false
            newRecipe.normal.energy_required = oldRecipe.normal.energy_required*input
            newRecipe.normal = multiply_results(newRecipe.normal, oldRecipe.normal, output)
            newRecipe.expensive = multiply_ingredients(newRecipe.expensive, oldRecipe.expensive, input)
            newRecipe.expensive.enabled = false
            newRecipe.expensive.energy_required = oldRecipe.expensive.energy_required*input
            newRecipe.expensive = multiply_results(newRecipe.expensive, oldRecipe.expensive, output)
            log(serpent.block(newRecipe))
            data:extend({newRecipe})
            table.insert(data.raw.technology["ober-nuclear-processing"].effects,{type="unlock-recipe",recipe = newRecipe.name})
        end
        if oldRecipe.category == "smelting" then
            local newRecipe = oldRecipe
            newRecipe.category = "nuclear-smelting"
            newRecipe.name = "nuclear-smelting-"..oldRecipe.name
            newRecipe = multiply_ingredients(newRecipe, oldRecipe, input)
            newRecipe.enabled = false
            newRecipe.energy_required = oldRecipe.energy_required*input
            newRecipe = multiply_results(newRecipe, oldRecipe, output)
            log(serpent.block(newRecipe))
            data:extend({newRecipe})
            table.insert(data.raw.technology["ober-nuclear-processing"].effects,{type="unlock-recipe",recipe = newRecipe.name})
        end
    end
end
nuclear_category(4,5)