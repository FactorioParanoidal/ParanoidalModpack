local Circuit = {}

Circuit.color = {r = 255 / 255, g = 61 / 255, b = 61 / 255}
Circuit.entity_types = {"factory-circuit-connector"}
Circuit.unlocked = function(force) return force.technologies["factory-connection-type-circuit"].researched end

local function connect_two_poles_with_circuit_wires(pole_1, pole_2)
    for _, connector_type in pairs {
        defines.wire_connector_id.circuit_red,
        defines.wire_connector_id.circuit_green,
    } do
        local connector_1 = pole_1.get_wire_connector(connector_type, true)
        local connector_2 = pole_2.get_wire_connector(connector_type, true)
        connector_1.connect_to(connector_2, false, defines.wire_origin.script)
    end
end

Circuit.connect = function(factory, cid, cpos, outside_entity, inside_entity)
    if outside_entity.name ~= "factory-circuit-connector" or inside_entity.name ~= "factory-circuit-connector" then return nil end

    local inside_middleman = inside_entity.surface.create_entity {
        name = "factory-circuit-connector-invisible",
        position = inside_entity.position,
        force = inside_entity.force,
    }
    inside_middleman.destructible = false
    inside_middleman.operable = false
    connect_two_poles_with_circuit_wires(inside_entity, inside_middleman)

    local outside_middleman = outside_entity.surface.create_entity {
        name = "factory-circuit-connector-invisible",
        position = outside_entity.position,
        force = outside_entity.force,
    }
    outside_middleman.destructible = false
    outside_middleman.operable = false
    connect_two_poles_with_circuit_wires(outside_entity, outside_middleman)

    connect_two_poles_with_circuit_wires(inside_middleman, outside_middleman)

    return {
        inside_entity = inside_entity,
        inside_middleman = inside_middleman,
        outside_entity = outside_entity,
        outside_middleman = outside_middleman,
        do_tick_update = false,
    }
end

-- return true if the two poles are connected to each other
Circuit.recheck = function(conn)
    local pole_1 = conn.inside_entity
    local pole_2 = conn.outside_entity

    if not pole_1 or not pole_2 then return false end
    if not pole_1.valid or not pole_2.valid then return false end

    local wire_counter = 0
    for _, connector_type in pairs {
        defines.wire_connector_id.circuit_red,
        defines.wire_connector_id.circuit_green,
    } do
        local connector_1 = pole_1.get_wire_connector(connector_type, true)
        local connector_2 = pole_2.get_wire_connector(connector_type, true)
        if connector_1.network_id == connector_2.network_id then wire_counter = wire_counter + 1 end
    end
    return wire_counter == 2
end

Circuit.indicator_settings = {"b0"}

Circuit.direction = function(conn)
    return "b0", defines.direction.north
end

Circuit.rotate = factorissimo.beep

Circuit.adjust = factorissimo.beep

Circuit.destroy = function(conn)
    if conn.inside_middleman and conn.inside_middleman.valid then conn.inside_middleman.destroy() end
    if conn.outside_middleman and conn.outside_middleman.valid then conn.outside_middleman.destroy() end
end

return Circuit
