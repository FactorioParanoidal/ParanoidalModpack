
PlanetsLib.constants.recipe_effects = {
    --["recipe-name"] = {returned_ingredients = {{type = "item", name = "wood", amount = 1, shared_probability = {min = 0,max = 0.9]}, ignored_by_productivity = 1}}
}

for _,recipe in pairs(data.raw.recipe) do
    if recipe.PlanetsLib_recipe_effects then
        local effects = recipe.PlanetsLib_recipe_effects
        if effects then
            
            PlanetsLib.constants.recipe_effects[recipe.name] = effects
            if effects.returned_ingredients then
                for _,returned_ingredient in pairs(effects.returned_ingredients) do
                    if returned_ingredient.type == "fluid" then
                        error("RecipePrototype::PlanetsLib_recipe_effects: Returning fluids are not currently supported with PlanetsLib_recipe_effects.returned_ingredients")
                    end
                    for _,ingredient in pairs(recipe.ingredients) do
                        if ingredient.name == returned_ingredient.name then
                            returned_ingredient.add_to_stats = ingredient.amount-(ingredient.ignored_by_stats or 0) --Amount to add to production statistics when ingredient not returned
                            ingredient.ignored_by_stats = ingredient.amount
                            returned_ingredient.amount_minus_ignored_by_productivity = returned_ingredient.amount - (returned_ingredient.ignored_by_productivity or 0)
                        end
                    end
                    if returned_ingredient.batch_count then
                        returned_ingredient.inverse_batch_count = 1/returned_ingredient.batch_count
                    end
                    if not (returned_ingredient.shared_probability or returned_ingredient.independent_probability) then
                        returned_ingredient.no_probability = true
                    end

                    if not recipe.custom_tooltip_fields then
                        recipe.custom_tooltip_fields = {}
                    end
                    
                    local probability
                    if returned_ingredient.independent_probability then
                        probability = tostring(returned_ingredient.independent_probability)
                    elseif returned_ingredient.shared_probability then
                        probability = tostring((returned_ingredient.shared_probability.max - returned_ingredient.shared_probability.min) * 100)
                    end

                    local amount_string = tostring(returned_ingredient.amount)
                    table.insert(recipe.custom_tooltip_fields,
                    {
                        name = {"tooltip.returned-ingredients",{recipe.localised_name or ("item-name."..returned_ingredient.name)}},
                        value = probability and {"tooltip-value.returned-ingredients-probability", probability, amount_string}
                                or {"tooltip-value.returned-ingredients", amount_string},
                    }
                            
                    
                    )
                end
            end
        end
        if not recipe.raise_on_crafted then
            recipe.raise_on_crafted = true
        end
        
    end
end
