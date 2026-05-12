local Belt = {}

Belt.color = {r = 0, g = 183 / 255, b = 0}
Belt.entity_types = {"transport-belt", "underground-belt", "loader", "loader-1x1", "linked-belt", "splitter", "lane-splitter", "inserter"}
Belt.unlocked = function(force) return true end

Belt.indicator_settings = {"d0"}

local opposite = {
    [defines.direction.north] = defines.direction.south,
    [defines.direction.south] = defines.direction.north,
    [defines.direction.east] = defines.direction.west,
    [defines.direction.west] = defines.direction.east,
}

local function get_belt_type(entity)
    if entity.type == "loader" or entity.type == "loader-1x1" then
        return entity.loader_type
    elseif entity.type == "linked-belt" then
        return entity.linked_belt_type
    elseif entity.type == "underground-belt" then
        return entity.belt_to_ground_type
    end
end

local belt_prototypes_which_do_not_care_about_direction = {
    ["transport-belt"] = true,
    ["splitter"] = true,
    ["lane-splitter"] = true,
    ["inserter"] = true,
}

local function get_entity_direction(entity)
    local direction = entity.direction
    if entity.type == "inserter" then
        direction = (direction + 8) % 16
    end
    return direction
end

local function get_conn_facing(outside_entity, inside_entity, direction_out, direction_in)
    local outside_entity_type, inside_entity_type = outside_entity.type, inside_entity.type
    local outside_dir, inside_dir = get_entity_direction(outside_entity), get_entity_direction(inside_entity)

    if not belt_prototypes_which_do_not_care_about_direction[outside_entity_type] then
        if get_belt_type(outside_entity) == "input" then
            if direction_out ~= outside_dir then return nil end
        else
            if direction_in ~= outside_dir then return nil end
        end
    end

    if not belt_prototypes_which_do_not_care_about_direction[inside_entity_type] then
        if get_belt_type(inside_entity) == "input" then
            if direction_in ~= inside_dir then return nil end
        else
            if direction_out ~= inside_dir then return nil end
        end
    end

    return (outside_dir == inside_dir) and outside_dir or nil
end

Belt.connect = function(factory, cid, cpos, outside_entity, inside_entity)
    local conn_facing = get_conn_facing(outside_entity, inside_entity, cpos.direction_out, cpos.direction_in)
    if not (conn_facing == cpos.direction_in or conn_facing == cpos.direction_out) then return end

    if inside_entity.type == "inserter" and outside_entity.type == "inserter" then return end
    local inside_link_name, outside_link_name
    if inside_entity.type == "inserter" then
        if inside_entity.name:find("long") then return end
        inside_link_name = "factory-linked-" .. outside_entity.name
    else
        inside_link_name = "factory-linked-" .. inside_entity.name
    end
    if outside_entity.type == "inserter" then
        if outside_entity.name:find("long") then return end
        outside_link_name = "factory-linked-" .. inside_entity.name
    else
        outside_link_name = "factory-linked-" .. outside_entity.name
    end

    if not prototypes.entity[inside_link_name] or not prototypes.entity[outside_link_name] then return end

    local outside_link_position = {factory.outside_x + cpos.outside_x - cpos.indicator_dx, factory.outside_y + cpos.outside_y - cpos.indicator_dy}
    local outside_link = outside_entity.surface.create_entity {
        name = outside_link_name,
        position = outside_link_position,
        create_build_effect_smoke = false,
        raise_built = false,
    } or outside_entity.surface.find_entity(outside_link_name, outside_link_position)
    if not outside_link then return end
    outside_link.destructible = false
    outside_link.force = outside_entity.force_index

    local inside_link = inside_entity.surface.create_entity {
        name = inside_link_name,
        position = {factory.inside_x + cpos.inside_x + cpos.indicator_dx, factory.inside_y + cpos.inside_y + cpos.indicator_dy},
        create_build_effect_smoke = false,
        raise_built = false,
        force = inside_entity.force
    }
    if not inside_link then return end
    inside_link.destructible = false

    local connection
    if conn_facing == cpos.direction_in then
        connection = {
            from = outside_entity,
            to = inside_entity,
            from_link = outside_link,
            to_link = inside_link,
            facing = cpos.direction_in,
            spill_location = inside_entity.position,
            do_tick_update = false
        }
    else
        connection = {
            from = inside_entity,
            to = outside_entity,
            from_link = inside_link,
            to_link = outside_link,
            facing = cpos.direction_out,
            spill_location = inside_entity.position,
            do_tick_update = false
        }
    end

    connection.from_link.linked_belt_type = "input"
    connection.to_link.linked_belt_type = "output"
    connection.to_link.connect_linked_belts(connection.from_link)
    connection.to_link.direction = get_entity_direction(connection.from)
    connection.from_link.direction = get_entity_direction(connection.from)

    return connection
end

Belt.recheck = function(conn)
    return conn.from.valid and conn.to.valid and conn.to_link.valid and conn.from_link.valid and
        conn.facing == get_conn_facing(conn.from, conn.to, opposite[conn.facing], conn.facing)
end

Belt.direction = function(conn)
    return "d0", conn.facing
end

Belt.rotate = factorissimo.beep

Belt.adjust = factorissimo.beep

local function spill_link_items(belt, link, surface, position)
    for _, i in pairs {1, 2} do
        local line = link.get_transport_line(i)
        for j = 1, math.min(256, #line) do
            local stack = line[j]
            if stack and stack.valid_for_read then
                surface.spill_item_stack {
                    position = position,
                    stack = stack,
                    enable_looted = true,
                    force = link.force_index,
                    allow_belts = false,
                    use_start_position_on_failure = true
                }
            end
        end
    end
end

Belt.destroy = function(conn)
    local surface = conn._factory.inside_surface
    local position = conn.spill_location

    if conn.from_link.valid then
        spill_link_items(conn.from, conn.from_link, surface, position)
        conn.from_link.destroy()
    end
    if conn.to_link.valid then
        spill_link_items(conn.to, conn.to_link, surface, position)
        conn.to_link.destroy()
    end
end

return Belt
