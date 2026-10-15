local find_surrounding_factory = remote_api.find_surrounding_factory

local floor, ceil, max = math.floor, math.ceil, math.max

local type_map = {}

-- Not using metatables, for..... reasons
local c_unlocked = {}
local c_color = {}
local c_connect = {}
local c_recheck = {}
local c_direction = {}
local c_rotate = {}
local c_adjust = {}
local c_tick = {}
local c_destroy = {}
local connection_indicator_names = {}
factorissimo.connection_indicator_names = connection_indicator_names
local connectable_entity_types = {}

local function register_connection_type(ctype, class)
    for _, etype in pairs(class.entity_types) do
        type_map[etype] = ctype
        connectable_entity_types[#connectable_entity_types + 1] = etype
    end
    c_unlocked[ctype] = class.unlocked
    c_color[ctype] = class.color
    c_connect[ctype] = class.connect
    c_recheck[ctype] = class.recheck
    c_direction[ctype] = class.direction
    c_rotate[ctype] = class.rotate
    c_adjust[ctype] = class.adjust
    c_tick[ctype] = class.tick
    c_destroy[ctype] = class.destroy
    for _, name in pairs(class.indicator_settings) do
        connection_indicator_names["factory-connection-indicator-" .. ctype .. "-" .. name] = ctype
    end
end

local function is_connectable(entity)
    return type_map[entity.type] or type_map[entity.name]
end
factorissimo.is_connectable = is_connectable

-- Connection data structure --

local CONNECTION_UPDATE_RATE = 5
local CYCLIC_BUFFER_SIZE = 600
factorissimo.on_event(factorissimo.events.on_init(), function()
    storage.connections = storage.connections or {}
    storage.delayed_connection_checks = storage.delayed_connection_checks or {}
    for i = 0, CYCLIC_BUFFER_SIZE - 1 do
        storage.connections[i] = storage.connections[i] or {}
    end

    -- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/206
    for _, factory in pairs(storage.factories) do
        if factory.built then factorissimo.recheck_factory_connections(factory, nil, nil, true) end
    end
end)

--- Delays are kept on the update grid: a connection queued between the slots would never tick again.
local function normalize_delay(delay)
    delay = max(CONNECTION_UPDATE_RATE, ceil(delay / CONNECTION_UPDATE_RATE) * CONNECTION_UPDATE_RATE)
    if delay > CYCLIC_BUFFER_SIZE then delay = CYCLIC_BUFFER_SIZE end
    return delay
end

local function add_connection_to_queue(conn)
    local current_pos = (floor(game.tick / CONNECTION_UPDATE_RATE) + 1) * CONNECTION_UPDATE_RATE % CYCLIC_BUFFER_SIZE
    local slot = storage.connections[current_pos]
    slot[#slot + 1] = conn
end

-- Connection settings --

local function get_connection_settings(factory, cid, ctype)
    factory.connection_settings[cid] = factory.connection_settings[cid] or {}
    factory.connection_settings[cid][ctype] = factory.connection_settings[cid][ctype] or {}
    return factory.connection_settings[cid][ctype]
end
factorissimo.get_connection_settings = get_connection_settings

-- Connection indicators --

local function set_connection_indicator(factory, cid, ctype, setting, dir)
    local old_indicator = factory.connection_indicators[cid]
    if old_indicator and old_indicator.valid then old_indicator.destroy() end
    local cpos = factory.layout.connections[cid]
    local new_indicator = factory.inside_surface.create_entity {
        name = "factory-connection-indicator-" .. ctype .. "-" .. setting,
        force = factory.force,
        position = {x = factory.inside_x + cpos.inside_x + cpos.indicator_dx, y = factory.inside_y + cpos.inside_y + cpos.indicator_dy},
        create_build_effect_smoke = false,
        direction = dir,
        quality = factory.quality
    }
    new_indicator.destructible = false
    factory.connection_indicators[cid] = new_indicator
end

local function delete_connection_indicator(factory, cid, ctype)
    local old_indicator = factory.connection_indicators[cid]
    if old_indicator and old_indicator.valid then old_indicator.destroy() end
end

-- Connection changes --

local function register_connection(factory, cid, ctype, conn, settings)
    conn._id = cid
    conn._type = ctype
    conn._factory = factory
    conn._settings = settings
    conn._valid = true
    factory.connections[cid] = conn
    if conn.do_tick_update then add_connection_to_queue(conn) end
    local setting, dir = c_direction[ctype](conn)
    set_connection_indicator(factory, cid, ctype, setting, dir)
end

--- Only call this when factory.connections[cid] == nil!
--- `silent` suppresses the "research required" text during bulk rechecks.
local function init_connection(factory, cid, cpos, silent)
    if factory.inactive then return end
    local outside_surface, inside_surface = factory.outside_surface, factory.inside_surface
    if not (outside_surface and outside_surface.valid) then return end
    if not (inside_surface and inside_surface.valid) then return end
    local force = factory.force

    local outside_entities = outside_surface.find_entities_filtered {
        position = {cpos.outside_x + factory.outside_x, cpos.outside_y + factory.outside_y},
        force = force
    }
    if not outside_entities[1] then return end

    local inside_entities = inside_surface.find_entities_filtered {
        position = {cpos.inside_x + factory.inside_x, cpos.inside_y + factory.inside_y},
        force = force
    }
    if not inside_entities[1] then return end

    local warned = silent
    for _, outside_entity in pairs(outside_entities) do
        local ctype = type_map[outside_entity.type] or type_map[outside_entity.name]
        if ctype then
            for _, inside_entity in pairs(inside_entities) do
                if (type_map[inside_entity.type] or type_map[inside_entity.name]) == ctype then
                    if not c_unlocked[ctype](force) then
                        -- The connection type is not researched yet: no connection.
                        if not warned then
                            warned = true
                            factorissimo.create_flying_text {position = inside_entity.position, text = {"research-required"}}
                            factorissimo.create_flying_text {position = outside_entity.position, text = {"research-required"}}
                        end
                    else
                        local settings = get_connection_settings(factory, cid, ctype)
                        local new_connection = c_connect[ctype](factory, cid, cpos, outside_entity, inside_entity, settings)
                        if new_connection then
                            inside_surface.play_sound {path = "entity-close/assembling-machine-3", position = inside_entity.position}
                            outside_surface.play_sound {path = "entity-close/assembling-machine-3", position = outside_entity.position}
                            register_connection(factory, cid, ctype, new_connection, settings)
                            return
                        end
                    end
                end
            end
        end
    end
end
factorissimo.init_connection = init_connection

local function destroy_connection(conn)
    if conn and conn._valid then
        c_destroy[conn._type](conn)
        conn._valid = false                       -- _valid should be true iff conn._factory.connections[conn._id] == conn
        conn._factory.connections[conn._id] = nil -- Lua can handle this
        delete_connection_indicator(conn._factory, conn._id, conn._type)
    end
end
factorissimo.destroy_connection = destroy_connection

local function in_area(x, y, area)
    return x >= area.left_top.x and x <= area.right_bottom.x and y >= area.left_top.y and y <= area.right_bottom.y
end

local function recheck_factory_connections(factory, outside_area, inside_area, silent) -- Areas are optional
    if not factory.built then return end
    local outside_x, outside_y, inside_x, inside_y = factory.outside_x, factory.outside_y, factory.inside_x, factory.inside_y
    for cid, cpos in pairs(factory.layout.connections) do
        if (not outside_area or in_area(cpos.outside_x + outside_x, cpos.outside_y + outside_y, outside_area))
            and (not inside_area or in_area(cpos.inside_x + inside_x, cpos.inside_y + inside_y, inside_area)) then
            local conn = factory.connections[cid]
            if conn then
                if not c_recheck[conn._type](conn) then
                    destroy_connection(conn)
                    init_connection(factory, cid, cpos, silent)
                end
            else
                init_connection(factory, cid, cpos, silent)
            end
        end
    end
end
factorissimo.recheck_factory_connections = recheck_factory_connections

factorissimo.on_event({defines.events.on_research_finished, defines.events.on_research_reversed}, function(event)
    if not storage.factories then return end -- In case any mod or scenario script calls LuaForce.research_all_technologies() during its on_init
    local research = event.research
    if research.name:find("factory%-connection%-type%-") then
        local force_index = research.force.index
        for _, factory in pairs(storage.factories) do
            local force = factory.force
            if factory.built and force and force.valid and force.index == force_index then
                recheck_factory_connections(factory, nil, nil, true)
            end
        end
    end
end)

-- During deconstruction events of an entity that is part of a connection, the entity is still valid and built, so recheck_factory_connections would not destroy the connection involved.
-- Delaying the recheck causes these connections to be properly deconstructed immediately, instead of having to wait until the connection ticks again.
local function recheck_factory_connections_delayed(factory, outside_area, inside_area)
    local checks = storage.delayed_connection_checks
    checks[#checks + 1] = {
        factory = factory,
        outside_area = outside_area,
        inside_area = inside_area
    }
end

function factorissimo.disconnect_factory_connections(factory)
    for cid, conn in pairs(factory.connections or {}) do
        destroy_connection(conn)
    end
end

-- When a connection piece is placed or destroyed, check if can be connected to a factory building
local function recheck_nearby_connections(entity, delayed)
    local surface = entity.surface
    -- The entity's bounding box already respects its direction; expand it to whole tiles,
    -- plus a margin that reaches the factory buildings (their collision box ends 0.2 tiles inside the tile).
    local box = entity.bounding_box
    local left_top, right_bottom = box.left_top, box.right_bottom
    local area = {
        left_top = {x = floor(left_top.x) - 0.3, y = floor(left_top.y) - 0.3},
        right_bottom = {x = ceil(right_bottom.x) + 0.3, y = ceil(right_bottom.y) + 0.3}
    }

    local by_entity = storage.factories_by_entity
    for _, building in pairs(surface.find_entities_filtered {area = area, type = BUILDING_TYPE}) do
        local factory = by_entity[building.unit_number]
        if factory and factory.built then
            if delayed then
                recheck_factory_connections_delayed(factory, area, nil)
            else
                recheck_factory_connections(factory, area, nil)
            end
        end
    end

    local factory = find_surrounding_factory(surface, entity.position)
    if factory then
        if delayed then
            recheck_factory_connections_delayed(factory, nil, area)
        else
            recheck_factory_connections(factory, nil, area)
        end
    end
end

-- Entity types (and the circuit connector name) handled by connections, for event filters.
local function connection_entity_filters()
    return factorissimo.entity_filters(connectable_entity_types)
end

-- Connection effects --

factorissimo.on_nth_tick(CONNECTION_UPDATE_RATE, function(event)
    -- First let's run all them delayed connection checks
    local checks = storage.delayed_connection_checks
    if checks[1] then
        storage.delayed_connection_checks = {}
        for _, check in pairs(checks) do
            recheck_factory_connections(check.factory, check.outside_area, check.inside_area)
        end
    end

    local current_pos = event.tick % CYCLIC_BUFFER_SIZE
    local connections = storage.connections
    local current_slot = connections[current_pos]
    if not current_slot[1] then return end
    connections[current_pos] = {}
    for i = 1, #current_slot do
        local conn = current_slot[i]
        local delay = conn._valid and c_tick[conn._type](conn)
        if delay then
            -- Reinsert connection after delay
            local queue_pos = (current_pos + normalize_delay(delay)) % CYCLIC_BUFFER_SIZE
            local new_slot = connections[queue_pos]
            new_slot[#new_slot + 1] = conn
        elseif conn._valid then
            local factory = conn._factory
            destroy_connection(conn)
            if factory.layout then
                init_connection(factory, conn._id, factory.layout.connections[conn._id])
            end
        end
    end
end)

local function find_connection_of_indicator(factory, indicator)
    local unit_number = indicator.unit_number
    for cid, ind2 in pairs(factory.connection_indicators) do
        if ind2 and ind2.valid and ind2.unit_number == unit_number then
            return factory.connections[cid], cid
        end
    end
end

local function rotate(factory, indicator)
    local conn, cid = find_connection_of_indicator(factory, indicator)
    if not conn then return end
    local text, noop = c_rotate[conn._type](conn)
    factorissimo.create_flying_text {position = indicator.position, color = c_color[conn._type], text = text}
    if noop then return end
    local setting, dir = c_direction[conn._type](conn)
    set_connection_indicator(factory, cid, conn._type, setting, dir)
end

local function adjust(factory, indicator, positive)
    local conn, cid = find_connection_of_indicator(factory, indicator)
    if not conn then return end
    local text, noop = c_adjust[conn._type](conn, positive)
    factorissimo.create_flying_text {position = indicator.position, color = c_color[conn._type], text = text}
    if noop then return end
    local setting, dir = c_direction[conn._type](conn)
    set_connection_indicator(factory, cid, conn._type, setting, dir)
end

local function selected_indicator(event)
    local player = game.get_player(event.player_index)
    local entity = player and player.selected
    if not entity or not connection_indicator_names[entity.name] then return nil end
    local factory = find_surrounding_factory(entity.surface, entity.position)
    if not factory then return nil end
    return entity, factory
end

factorissimo.on_event("factory-rotate", function(event)
    local indicator, factory = selected_indicator(event)
    if indicator then rotate(factory, indicator) end
end)

factorissimo.on_event("factory-increase", function(event)
    local indicator, factory = selected_indicator(event)
    if indicator then adjust(factory, indicator, true) end
end)

factorissimo.on_event("factory-decrease", function(event)
    local indicator, factory = selected_indicator(event)
    if indicator then adjust(factory, indicator, false) end
end)

local beeps = {"Beep", "Boop", "Beep", "Boop", "Beeple"}
factorissimo.beep = function()
    local t = game.tick
    return beeps[t % 5 + 1], true
end

register_connection_type("belt", require("belt"))
register_connection_type("chest", require("chest"))
register_connection_type("fluid", require("fluid"))
register_connection_type("circuit", require("circuit"))
register_connection_type("heat", require("heat"))

local connection_filters = connection_entity_filters()

factorissimo.on_event(factorissimo.events.on_destroyed(), function(event)
    local entity = event.entity
    if entity.valid and is_connectable(entity) then
        recheck_nearby_connections(entity, true) -- Delay
    end
end, connection_filters)

factorissimo.on_event(factorissimo.events.on_built(), function(event)
    local entity = event.entity
    if not entity.valid or not is_connectable(entity) then return end

    if entity.name == "factory-circuit-connector" then
        entity.operable = false
    end

    recheck_nearby_connections(entity)
end, connection_filters)

factorissimo.on_event(defines.events.on_player_flipped_entity, function(event)
    local entity = event.entity
    if not connection_indicator_names[entity.name] then return end
    entity.mirroring = false
    local factory = find_surrounding_factory(entity.surface, entity.position)
    if factory then rotate(factory, entity) end
end)

factorissimo.on_event(defines.events.on_player_rotated_entity, function(event)
    local entity = event.entity
    if connection_indicator_names[entity.name] then
        entity.direction = event.previous_direction
    elseif is_connectable(entity) then
        recheck_nearby_connections(entity)
        if entity.valid and entity.type == "underground-belt" then
            local neighbour = entity.neighbours
            if neighbour then
                recheck_nearby_connections(neighbour)
            end
        end
    end
end)
