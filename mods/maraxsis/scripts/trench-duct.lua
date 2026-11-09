local function opposite_direction(dir)
    return (dir + 8) % 16
end

maraxsis.on_event(maraxsis.events.on_init(), function()
    storage.trench_ducts = {}
end)

maraxsis.on_event(maraxsis.events.on_built(), function(event)
    local surface_duct = event.entity
    if not surface_duct or not surface_duct.valid then return end
    if surface_duct.name ~= "maraxsis-trench-duct" then return end

    if surface_duct.surface.name ~= maraxsis_constants.MARAXSIS_SURFACE_NAME then
        maraxsis.cancel_creation(surface_duct, event.player_index, {"maraxsis.invalid-trench-duct-placement"})
        return
    end

    local trench_planet = game.planets[maraxsis_constants.TRENCH_SURFACE_NAME]
    local trench = trench_planet.create_surface()

    local trench_duct = trench.create_entity {
        name = "maraxsis-trench-duct-lower",
        position = surface_duct.position,
        force = surface_duct.force_index,
        direction = opposite_direction(surface_duct.direction)
    }

    surface_duct.add_fluid_box_linked_connection(0, trench_duct, 0)

    local trench_duct_data = {
        surface_duct = surface_duct,
        trench_duct = trench_duct,
        surface_duct_unit_number = surface_duct.unit_number,
        trench_duct_unit_number = trench_duct.unit_number
    }

    storage.trench_ducts[surface_duct.unit_number] = trench_duct_data
    storage.trench_ducts[trench_duct.unit_number] = trench_duct_data
end)

local function get_trench_duct_data(entity)
    if not entity or not entity.valid then return end
    local name = entity.name
    if name ~= "maraxsis-trench-duct" and name ~= "maraxsis-trench-duct-lower" then return end
    return storage.trench_ducts[entity.unit_number]
end

maraxsis.on_event(maraxsis.events.on_destroyed(), function(event)
    local entity = event.entity
    local trench_duct_data = get_trench_duct_data(entity)
    if not trench_duct_data then return end

    local surface_duct = trench_duct_data.surface_duct
    local trench_duct = trench_duct_data.trench_duct
    if surface_duct ~= entity then surface_duct.destroy() end
    if trench_duct ~= entity then trench_duct.destroy() end

    storage.trench_ducts[trench_duct_data.surface_duct_unit_number] = nil
    storage.trench_ducts[trench_duct_data.trench_duct_unit_number] = nil
end)

maraxsis.on_event(defines.events.on_player_rotated_entity, function(event)
    local entity = event.entity
    local trench_duct_data = get_trench_duct_data(entity)
    if not trench_duct_data then return end

    local surface_duct = trench_duct_data.surface_duct
    local trench_duct = trench_duct_data.trench_duct

    if not surface_duct.valid or not trench_duct.valid then return end

    if surface_duct == entity then
        trench_duct.direction = opposite_direction(entity.direction)
    else
        surface_duct.direction = opposite_direction(entity.direction)
    end
end)
