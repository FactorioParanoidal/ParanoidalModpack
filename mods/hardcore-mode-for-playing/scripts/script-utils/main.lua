all_available_entity_items = {}
function handle_researched_technology(researched_technology)
    local recipe_names = _table.map(
        _table.filter(researched_technology.effects, function(effect) return effect.type == "unlock-recipe" end),
        function(effect) return effect.recipe end)
    local recipe_prototypes = _table.filter(game.recipe_prototypes,
        function(recipe) return _table.contains(recipe_names, recipe.name) end)
    _table.each(recipe_prototypes, function(recipe_prototype)
        _table.each(_table.filter(recipe_prototype.products,
                function(product)
                    local product_name = product.name or product[1]
                    return product.type == "item"
                        and game.item_prototypes[product_name] --and game.item_prototypes[product_name].place_result
                end),
            function(product)
                local product_name = product.name or product[1]
                _table.insert_all_if_not_exists(all_available_entity_items,
                    { game.item_prototypes[product_name].place_result, product_name })
            end
        )
    end)
    if game.active_mods["factorissimo-2"] or game.active_mods["factorissimo-2-notnotmelon"] then
        table.insert(all_available_entity_items, "factory-1-raw")
    end
    table.insert(all_available_entity_items, "gun-turret")
    -- разрешаем самому себе передвигаться
    table.insert(all_available_entity_items, "character")
end

function disable_player_entity_on_all_surfaces(force)
    _table.each(game.surfaces, function(surface)
        local surface_entities = surface.find_entities_filtered { force = force }
        _table.each(surface_entities, function(entity)
            if not _table.contains(all_available_entity_items, entity.name) then
                --    log('deactivated entity.name ' .. entity.name)
                disable_entity(entity)
            end
        end)
    end)
end

function disable_entity(entity)
    entity.active = false
    --[[    local control_behavior = entity.get_or_create_control_behavior()
    if not control_behavior then return end
    local control_behavior_type = control_behavior.type
    if control_behavior_type == defines.control_behavior.type.train_stop or control_behavior_type == defines.control_behavior.type.transport_belt
        or control_behavior_type == defines.control_behavior.type.generic_on_off then
        control_behavior.circuit_condition = { condition = {} }
    end
    if control_behavior_type == defines.control_behavior.type.train_stop or control_behavior_type == defines.control_behavior.type.transport_belt then
        control_behavior.enable_disable = true
    end
    if control_behavior_type == defines.control_behavior.type.mining_drill then
        control_behavior.circuit_enable_disable = true
    end]]
end

function enable_player_entity_on_all_surfaces(force)
    _table.each(game.surfaces, function(surface)
        local surface_entities = surface.find_entities_filtered { force = force }
        _table.each(surface_entities, function(entity)
            if _table.contains(all_available_entity_items, entity.name) then
                --log('activated entity.name ' .. entity.name)
                enable_entity(entity)
            end
        end)
    end)
end

function enable_entity(entity)
    entity.active = true
    --[[local control_behavior = entity.get_or_create_control_behavior()
    if not control_behavior then return end
    local control_behavior_type = control_behavior.type
    if control_behavior_type == defines.control_behavior.type.train_stop or control_behavior_type == defines.control_behavior.type.transport_belt
        or control_behavior_type == defines.control_behavior.type.generic_on_off then
        control_behavior.circuit_condition = { condition = {} }
    end
    if control_behavior_type == defines.control_behavior.type.train_stop or control_behavior_type == defines.control_behavior.type.transport_belt then
        control_behavior.enable_disable = true
    end
    if control_behavior_type == defines.control_behavior.type.mining_drill then
        control_behavior.circuit_enable_disable = true
    end]]
end
