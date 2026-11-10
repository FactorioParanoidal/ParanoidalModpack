local Fluid = {}

Fluid.color = {r = 167 / 255, g = 229 / 255, b = 255 / 255}
Fluid.entity_types = {"pipe", "pipe-to-ground", "pump", "storage-tank", "infinity-pipe", "offshore-pump", "elevated-pipe"}
Fluid.unlocked = function(force) return force.technologies["factory-connection-type-fluid"].researched end

local function create_linked_connections(factory, cpos, settings, other)
    local inside_surface = factory.inside_surface
    local outside_surface = other and other.factory.inside_surface or factory.outside_surface

    local inside_position = {factory.inside_x + cpos.inside_x + cpos.indicator_dx, factory.inside_y + cpos.inside_y + cpos.indicator_dy}
    local outside_position = other and {
        other.factory.inside_x + other.cpos.inside_x + other.cpos.indicator_dx,
        other.factory.inside_y + other.cpos.inside_y + other.cpos.indicator_dy
    } or {factory.outside_x + cpos.outside_x - cpos.indicator_dx, factory.outside_y + cpos.outside_y - cpos.indicator_dy}

    local inside_flow_direction, outside_flow_direction = "input", "output"
    if settings.input_mode then
        inside_flow_direction, outside_flow_direction = outside_flow_direction, inside_flow_direction
    end

    local inside_connector = inside_surface.create_entity {
        name = "factory-inside-pump-" .. inside_flow_direction,
        position = inside_position,
        direction = cpos.direction_in,
        quality = factory.quality,
    }
    if not inside_connector then return end
    inside_connector.destructible = false
    inside_connector.operable = false
    inside_connector.rotatable = false

    local outside_connector = outside_surface.create_entity {
        name = (other and "factory-inside-pump-" or "factory-outside-pump-") .. outside_flow_direction,
        position = outside_position,
        direction = other and other.cpos.direction_in or cpos.direction_out,
        quality = factory.quality,
    }
    if not outside_connector then
        inside_connector.destroy()
        return
    end
    outside_connector.destructible = false
    outside_connector.operable = false
    outside_connector.rotatable = false

    -- Factorio 2.1: LuaEntity::fluidbox was removed, linked connections are made on the entity
    inside_connector.add_fluid_box_linked_connection(0, outside_connector, 0)

    return inside_connector, outside_connector
end

Fluid.connect = function(factory, cid, cpos, outside_entity, inside_entity, settings, other)
    if inside_entity == outside_entity then return nil end

    local inside_connector, outside_connector = create_linked_connections(factory, cpos, settings, other)
    if not inside_connector then return end

    return {
        inside = inside_entity,
        outside = outside_entity,
        inside_connector = inside_connector,
        outside_connector = outside_connector,
        do_tick_update = false
    }
end

Fluid.recheck = function(conn)
    return conn.inside_connector.valid and conn.outside_connector.valid and conn.inside.valid and conn.outside.valid
end

Fluid.indicator_settings = {"d0"}

Fluid.direction = function(conn)
    if conn._settings.input_mode then
        return "d0", conn._factory.layout.connections[conn._id].direction_in
    else
        return "d0", conn._factory.layout.connections[conn._id].direction_out
    end
end

local function pump_contents(pump)
    local contents = {}
    if pump and pump.valid then
        for i = 1, pump.fluids_count do contents[i] = pump.get_fluid(i) end
    end
    return contents
end

local function restore_contents(pump, contents)
    for i, fluid in pairs(contents) do pump.set_fluid(i, fluid) end
end

Fluid.rotate = function(conn, reversed)
    local inside_contents = pump_contents(conn.inside_connector)
    local outside_contents = pump_contents(conn.outside_connector)
    conn._settings.input_mode = not conn._settings.input_mode

    if conn.inside_connector and conn.inside_connector.valid then
        conn.inside_connector.destroy()
    end
    if conn.outside_connector and conn.outside_connector.valid then
        conn.outside_connector.destroy()
    end

    local cpos = conn._factory.layout.connections[conn._id]
    local other = conn._other_factory and {
        factory = conn._other_factory,
        cpos = conn._other_factory.layout.connections[conn._other_id]
    }
    conn.inside_connector, conn.outside_connector = create_linked_connections(conn._factory, cpos, conn._settings, other)
    if not conn.inside_connector then
        conn._settings.input_mode = not conn._settings.input_mode
        conn.inside_connector, conn.outside_connector = create_linked_connections(conn._factory, cpos, conn._settings, other)
        if not conn.inside_connector then
            factorissimo.destroy_connection(conn)
            return factorissimo.beep()
        end
        restore_contents(conn.inside_connector, inside_contents)
        restore_contents(conn.outside_connector, outside_contents)
        return factorissimo.beep()
    end
    restore_contents(conn.inside_connector, inside_contents)
    restore_contents(conn.outside_connector, outside_contents)

    local input = not not conn._settings.input_mode
    if reversed then input = not input end
    if input then
        return {"factory-connection-text.input-mode"}
    else
        return {"factory-connection-text.output-mode"}
    end
end

Fluid.adjust = factorissimo.beep

Fluid.destroy = function(conn)
    if conn.outside_connector and conn.outside_connector.valid then conn.outside_connector.destroy() end
    if conn.inside_connector and conn.inside_connector.valid then conn.inside_connector.destroy() end
end

Fluid.tick = function() end

return Fluid
