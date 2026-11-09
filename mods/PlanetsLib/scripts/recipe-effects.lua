local recipe_effects = PlanetsLib.constants.recipe_effects
for recipe_name,effects in pairs(recipe_effects) do
    local recipe = prototypes.recipe[recipe_name]
    assert(recipe.on_crafted_event,"PlanetsLib(): Recipe with custom recipe effects had recipe.raise_on_crafted incorrectly disabled.")

    local function recipe_function(event)
        --local effects = recipe_effects[event.recipe]
        --local shared_roll = event.shared_roll
        local entity = event.entity
        if not storage.entity_info[entity.unit_number] then
                    storage.entity_info[entity.unit_number] = {
                        inventories = {
                            crafter_input = entity.get_inventory(defines.inventory.crafter_input),
                            crafter_output = entity.get_inventory(defines.inventory.crafter_output),
                            crafter_trash = entity.get_inventory(defines.inventory.crafter_trash)   
                        },
                        item_production_statistics = entity.force.get_item_production_statistics(entity.surface)
                    }
                end
        local entity_info = storage.entity_info[entity.unit_number]
        for _,ingredient in pairs(recipe_effects[event.recipe].returned_ingredients) do
            if (ingredient.no_probability) or
                (ingredient.shared_probability and event.shared_roll >= (ingredient.shared_probability.min or 0) and event.shared_roll <= (ingredient.shared_probability.max or 1)) or
                (ingredient.independent_probability and math.random() <= ingredient.independent_probability)
            then
                local net_return
                if event.bonus then
                    net_return = ingredient.amount_minus_ignored_by_productivity
                else
                    net_return = ingredient.amount
                end
                --local net_return = ingredient.amount - (event.bonus and ingredient.ignored_by_productivity or 0)
                local entity = event.entity
                if ingredient.batch_count then
                    if math.random() < ingredient.inverse_batch_count then --To improve performance, only insert returned ingredients randomly in batches.
                        entity_info.inventories.crafter_input.insert({name = ingredient.name,count = net_return*ingredient.batch_count, quality = event.recipe_quality}) --Insert returned items into crafter input
                    end
                else
                    if net_return > 0 then
                         entity_info.inventories.crafter_input.insert({name = ingredient.name,count = net_return, quality = event.recipe_quality}) --Insert returned items into crafter input
                    end
                   
                end
                
            else --Add to production stats if return not executed. In data, default production stats are overridden.
                local net_return
                if event.bonus then
                    net_return = ingredient.amount_minus_ignored_by_productivity
                else
                    net_return = ingredient.amount
                end
                --local net_return = ingredient.add_to_stats - (event.bonus and ingredient.ignored_by_productivity or 0)
                --game.print(net_return)
                if net_return > 0 then
                    local input_sample = entity_info.item_production_statistics.get_current_output_sample({name = ingredient.name,quality=event.recipe_quality})
                    local change = input_sample + net_return --Add net return not replaced to input_count
                    entity_info.item_production_statistics.set_current_output_sample({name = ingredient.name,quality=event.recipe_quality},math.max(change,0)) --Add returned ingredients to production statistics.
                    --TODO: Find way to make returned ingredients subtract from consumption statistics.
                end
                
            end
        end
    end
    script.on_event(recipe.on_crafted_event,recipe_function)
end 