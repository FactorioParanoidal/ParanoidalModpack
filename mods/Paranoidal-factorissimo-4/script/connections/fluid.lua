local Fluid = {}

Fluid.color = {r = 167 / 255, g = 229 / 255, b = 255 / 255}
Fluid.entity_types = {"pipe", "pipe-to-ground", "pump", "storage-tank", "infinity-pipe", "offshore-pump", "elevated-pipe"}
Fluid.unlocked = function(force) return force.technologies["factory-connection-type-fluid"].researched end

local inside_terminal = "factory-fluid-terminal-inside"
local outside_terminal = "factory-fluid-terminal-outside"
Fluid.terminal_names = {[inside_terminal] = true, [outside_terminal] = true}

local function pump_name(input_mode, inside, paired)
    if inside then return input_mode and "factory-inside-pump-output" or "factory-inside-pump-input" end
    local prefix = paired and "factory-inside-pump-" or "factory-outside-pump-"
    return prefix .. (input_mode and "input" or "output")
end

local function create_connector(surface, args)
    local entity = surface.create_entity(args)
    if not entity then return end
    entity.destructible = false
    entity.operable = false
    entity.rotatable = false
    return entity
end

local function is_linked(a, b)
    local peer, id = a.get_fluid_box_linked_connection(0)
    return peer == b and id == 0
end

local function link(a, b)
    a.add_fluid_box_linked_connection(0, b, 0)
    return is_linked(a, b)
end

local function create_linked_connections(factory, cpos, settings, other)
    local inside_surface = factory.inside_surface
    local outside_surface = other and other.factory.inside_surface or factory.outside_surface

    local inside_position = {factory.inside_x + cpos.inside_x + cpos.indicator_dx, factory.inside_y + cpos.inside_y + cpos.indicator_dy}
    local outside_position = other and {
        other.factory.inside_x + other.cpos.inside_x + other.cpos.indicator_dx,
        other.factory.inside_y + other.cpos.inside_y + other.cpos.indicator_dy
    } or {factory.outside_x + cpos.outside_x - cpos.indicator_dx, factory.outside_y + cpos.outside_y - cpos.indicator_dy}

    local inside_connector = create_connector(inside_surface, {
        name = pump_name(settings.input_mode, true),
        position = inside_position,
        direction = cpos.direction_in,
        quality = factory.quality,
    })
    if not inside_connector then return end

    -- Keep the terminal on the same wall even when flow reverses. Only the owner's pump changes.
    local outside_connector = create_connector(outside_surface, {
        name = other and inside_terminal or outside_terminal,
        position = outside_position,
        direction = other and other.cpos.direction_in or cpos.direction_out,
        quality = factory.quality,
    })
    if outside_connector and link(inside_connector, outside_connector) then
        return inside_connector, outside_connector
    end
    if outside_connector then outside_connector.destroy() end
    inside_connector.destroy()
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
    local inside, outside = conn.inside_connector, conn.outside_connector
    return inside and inside.valid and outside and outside.valid and conn.inside.valid and conn.outside.valid
end

Fluid.indicator_settings = {"d0"}

Fluid.direction = function(conn)
    if conn._settings.input_mode then
        return "d0", conn._factory.layout.connections[conn._id].direction_in
    else
        return "d0", conn._factory.layout.connections[conn._id].direction_out
    end
end

local function prepare_pump(old, name)
    if old.name == name then return old end
    local new = create_connector(old.surface, {
        name = name, position = old.position, direction = old.direction, force = old.force, quality = old.quality,
    })
    if not new then return end
    for i = 1, old.fluids_count do
        local fluid = old.get_fluid(i)
        if fluid and math.abs(new.set_fluid(i, fluid) - fluid.amount) > 0.0001 then
            new.destroy()
            return
        end
    end
    return new
end

local function destroy_replaced(entity, keep)
    if entity and entity ~= keep then entity.destroy() end
end

function Fluid.set_direction(conn, input_mode)
    if not Fluid.recheck(conn) then return false end
    local inside, outside = conn.inside_connector, conn.outside_connector
    local new_inside = prepare_pump(inside, pump_name(input_mode, true))
    if not new_inside then return false end
    -- Existing two-pump ports retain their architecture. Never disturb the passive segment on rotation.
    local new_outside = outside
    if not Fluid.terminal_names[outside.name] then
        new_outside = prepare_pump(outside, pump_name(input_mode, false, conn._other_factory))
    end
    local old_linked = is_linked(inside, outside)
    if not (new_outside and ((new_inside == inside and new_outside == outside and old_linked) or link(new_inside, new_outside))) then
        destroy_replaced(new_inside, inside)
        destroy_replaced(new_outside, outside)
        if old_linked and not is_linked(inside, outside) then link(inside, outside) end
        return false
    end
    destroy_replaced(inside, new_inside)
    destroy_replaced(outside, new_outside)
    conn.inside_connector, conn.outside_connector = new_inside, new_outside
    conn._settings.input_mode = input_mode
    return true
end

Fluid.rotate = function(conn, reversed)
    local input = not conn._settings.input_mode
    if not Fluid.set_direction(conn, input) then return {"factory-connection-text.fluid-direction-failed"}, true end
    if reversed then input = not input end
    if input then
        return {"factory-connection-text.input-mode"}
    else
        return {"factory-connection-text.output-mode"}
    end
end

Fluid.adjust = function()
    return {"factory-connection-text.fluid-rate-fixed"}, true
end

Fluid.destroy = function(conn)
    if conn.outside_connector and conn.outside_connector.valid then conn.outside_connector.destroy() end
    if conn.inside_connector and conn.inside_connector.valid then conn.inside_connector.destroy() end
end

Fluid.tick = function() end

return Fluid
