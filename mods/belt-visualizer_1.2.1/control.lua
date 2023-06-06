local const = require("constants")
local straight = const.straight
local curved = const.curved
local arc_radius = const.arc_radius
local underground = const.underground
local dash = const.dash
local splitter = const.splitter
local loader = const.loader
local loader_1x1 = const.loader_1x1
local linked_belt = const.linked_belt

local e = defines.events

local connectables = {
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true,
    ["loader"] = true,
    ["loader-1x1"] = true,
    ["linked-belt"] = true,
}

local lane_cycle = {
    {true, true},
    {[1] = true},
    {[2] = true},
}

local side_cycle = {
    both = {"left", "right"},
    left = {"left"},
    right = {"right"},
}

local function setup_globals()
    global.data = {}
    global.in_progress = {}
    global.refresh = {}
    global.hover = global.hover or {}
end

script.on_init(function()
    setup_globals()
end)

script.on_configuration_changed(function(_)
    rendering.clear("belt-visualizer")
    setup_globals()
end)

local function clear(index)
    global.in_progress[index] = nil
    global.refresh[index] = nil
    local data = global.data[index]
    if not data then return end
    data.checked = {}
    for id in pairs(data.ids) do
        if rendering.is_valid(id) then
            rendering.destroy(id)
        end
    end
end

local function remove_player(event)
    local index = event.player_index
    clear(index)
    global.data[index] = nil
    global.hover[index] = nil
end

script.on_event(e.on_player_left_game, remove_player)
script.on_event(e.on_player_removed, remove_player)

local function empty_check(type)
    return type == "splitter" and {left = {{{}, {}}, {{}, {}}}, right = {{{}, {}}, {{}, {}}}} or {{}, {}}
end

local function check_entity(data, unit_number, lane, path, sides)
    local checked = data.checked[unit_number]
    if sides then
        for _, side in pairs(sides) do
            checked[side][path][lane][path] = true
        end
    else
        checked[lane][path] = true
    end
end

local function highlight(event)
    local index = event.player_index
    clear(index)
    local player = game.get_player(index) ---@cast player -nil
    local selected = player.selected
    if not selected then return end
    local ghost = event.input_name ~= nil and event.input_name == "bv-highlight-ghost"
    local type = selected.type
    if type == "entity-ghost" then
        if ghost then
            type = selected.ghost_type
        else return end
    end
    if not connectables[type] then return end
    local data = global.data[index] or {}
    global.data[index] = data
    local unit_number = selected.unit_number --[[@as number]]
    local filter = not player.is_cursor_empty() and player.cursor_stack.valid_for_read and player.cursor_stack.name
    if data.ghost == ghost and data.filter == filter and data.origin.valid and data.origin.unit_number == unit_number then
        data.cycle = data.cycle % 3 + 1
    else
        data.cycle = 1
    end
    data.index = index
    data.ghost = ghost
    data.filter = filter
    data.origin = selected
    data.next_entities = {}
    data.drawn_offsets = {}
    data.drawn_arcs = {}
    data.checked = {}
    data.checked[unit_number] = empty_check(type)
    local lanes = lane_cycle[data.cycle]
    for path = 1, 2 do
        data.next_entities[path] = {entity = selected, lanes = lanes, path = path}
        local sides = type == "splitter" and side_cycle.both
        for lane in pairs(lanes) do
            check_entity(data, unit_number, lane, path, sides)
        end
    end
    data.ids = {}
    global.in_progress[index] = true
end

local function refresh(data)
    clear(data.index)
    local entity = data.origin
    if not entity.valid then return end
    data.next_entities = {}
    for i = 1, 2 do
        data.next_entities[i] = {entity = entity, lanes = lane_cycle[data.cycle], path = i}
    end
    data.drawn_offsets = {}
    data.drawn_arcs = {}
    data.checked = {}
    data.checked[entity.unit_number] = empty_check(entity.type)
    data.ids = {}
    global.in_progress[data.index] = true
end

script.on_event("bv-highlight-belt", highlight)
-- script.on_event("bv-highlight-ghost", highlight)

script.on_event(e.on_selected_entity_changed, function(event)
    if not global.hover[event.player_index] then return end
    highlight(event)
end)

local function toggle_hover(event)
    local index = event.player_index
    clear(index)
    local player = game.get_player(index) ---@cast player -nil
    global.hover[index] = not global.hover[index]
    player.set_shortcut_toggled("bv-toggle-hover", global.hover[index])
end

script.on_event("bv-toggle-hover", toggle_hover)
script.on_event(e.on_lua_shortcut, function(event)
    if event.prototype_name ~= "bv-toggle-hover" then return end
    toggle_hover(event)
end)

local function highlightable(data, entity)
    local checked = data.checked
    if checked[entity.unit_number] then return true end
    for _, input in pairs(entity.belt_neighbours.inputs) do
        if checked[input.unit_number] then return true end
    end
    for _, output in pairs(entity.belt_neighbours.outputs) do
        if checked[output.unit_number] then return true end
    end
    if entity.type == "underground-belt" then
        local neighbours = entity.neighbours
        if neighbours and checked[neighbours.unit_number] then return true end
    elseif entity.type == "linked-belt" then
        local neighbours = entity.linked_belt_neighbours
        if neighbours and checked[neighbours.unit_number] then return true end
    end
    return false
end

local function on_entity_modified(event)
    local entity = event.entity or event.created_entity or event.destination
    for _, data in pairs(global.data) do
        if highlightable(data, entity) then
            if not global.refresh[data.index] then
                global.refresh[data.index] = event.tick + 60
            end
        end
    end
end

local filter = {{filter = "transport-belt-connectable"}}

script.on_event(e.on_built_entity, on_entity_modified, filter)
script.on_event(e.on_robot_built_entity, on_entity_modified, filter)
script.on_event(e.on_entity_cloned, on_entity_modified, filter)
script.on_event(e.script_raised_built, on_entity_modified, filter)
script.on_event(e.script_raised_revive, on_entity_modified, filter)
script.on_event(e.on_player_mined_entity, on_entity_modified, filter)
script.on_event(e.on_robot_mined_entity, on_entity_modified, filter)
script.on_event(e.script_raised_destroy, on_entity_modified, filter)
script.on_event(e.on_entity_died, on_entity_modified, filter)

script.on_event(e.on_player_rotated_entity, function(event)
    if not connectables[event.entity.type] then return end
    on_entity_modified(event)
    local entity = event.entity
    local neighbours = entity.type == "underground-belt" and entity.neighbours or entity.type == "linked-belt" and entity.linked_belt_neighbour
    if neighbours then on_entity_modified{entity = neighbours, tick = event.tick} end
end)

local function draw_line(data, entity, from_offset, to_offset)
    local drawn = data.drawn_offsets[entity.unit_number]
    if not drawn then
        drawn = {}
        data.drawn_offsets[entity.unit_number] = drawn
    end
    if drawn[from_offset] and drawn[to_offset] then return end
    drawn[from_offset] = true
    drawn[to_offset] = true
    data.ids[rendering.draw_line{
        color = const.color,
        width = const.width,
        from = entity,
        to = entity,
        from_offset = from_offset,
        to_offset = to_offset,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

local function draw_dash(data, entity, from_offset, to_offset)
    data.ids[rendering.draw_line{
        color = const.color,
        width = const.width,
        from = entity,
        to = entity.neighbours,
        from_offset = from_offset,
        to_offset = to_offset,
        dash_length = const.dash_length,
        gap_length = const.gap_length,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

local function draw_arc(data, entity, lane, clockwise)
    local drawn = data.drawn_arcs[entity.unit_number]
    if not drawn then
        drawn = {}
        data.drawn_arcs[entity.unit_number] = drawn
    end
    if drawn[lane] then return end
    drawn[lane] = true
    local offset = ((clockwise and 2 or 0) + entity.direction) % 8
    lane = clockwise and lane % 2 + 1 or lane
    local radii = arc_radius[lane]
    data.ids[rendering.draw_arc{
        color = const.color,
        min_radius = radii.min,
        max_radius = radii.max,
        start_angle = math.rad(offset * 45) --[[@as float]],
        angle = math.rad(90) --[[@as float]],
        target = entity,
        target_offset = curved[offset],
        surface = entity.surface,
        players = {data.index},
    }] = true
end

local function draw_circle(data, entity, offset)
    data.ids[rendering.draw_circle{
        color = const.color,
        radius = const.radius,
        filled = true,
        target = entity,
        target_offset = offset,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

local function draw_rectangle(data, entity, offsets)
    data.ids[rendering.draw_rectangle{
        color = const.color,
        filled = true,
        left_top = entity,
        left_top_offset = offsets.left_top,
        right_bottom = entity,
        right_bottom_offset = offsets.right_bottom,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

local function is_clockwise(entity, output)
    return (output.direction - entity.direction) % 8 == 2
end

local function get_belt_type(entity)
    return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

local function get_splitter_sides(entity, belt)
    local direction = entity.direction
    local position = entity.position
    local belt_position = belt.position
    local axis = direction % 4 == 0 and "x" or "y"
    if position[axis] == belt_position[axis] then return side_cycle.both end
    return (position[axis] > belt_position[axis]) ~= (direction >= 4) and side_cycle.left or side_cycle.right
end

local function get_filter_side(data, entity)
    if not data.filter then return end
    local splitter_filter = entity.splitter_filter
    if not splitter_filter then return end
    local output_priority = entity.splitter_output_priority
    if output_priority == "none" then return end
    return (output_priority == "left") == (data.filter == splitter_filter.name) and "left" or "right"
end

local function get_input_lanes(data, entity, input, side)
    local check = data.checked[input.unit_number]
    if not check then return {} end
    local lanes = {}
    local sides = get_splitter_sides(input, entity)
    side = sides[2] and side or sides[1]
    local lane_check = get_belt_type(input) == "splitter" and check[side][1] or check
    for lane, paths in pairs(lane_check) do
        if paths[1] then
            lanes[lane] = true
        end
    end
    return lanes
end

local default_output = {"output", "output"}
local function get_next_lanes(data, entity, lanes, output)
    if not output or entity.direction == output.direction then return lanes, default_output end
    if not data.ghost and output.type == "entity-ghost" then return lanes, default_output end
    local clockwise = is_clockwise(entity, output)
    local next_lanes = {}
    local offsets = {}
    if get_belt_type(output) == "underground-belt" then
        for lane in pairs(lanes) do
            local type = output.belt_to_ground_type == "input"
            if (clockwise == type) == (lane == 1) then
                next_lanes[clockwise and 2 or 1] = true
                offsets[lane] = "sideload"
            else
                offsets[lane] = "output"
            end
        end
    else
        if #output.belt_neighbours.inputs ~= 1 then
            for lane in pairs(lanes) do
                next_lanes[clockwise and 2 or 1] = true
                offsets[lane] = "sideload"
            end
        else
            return lanes, default_output
        end
    end
    return next_lanes, offsets
end

local function get_prev_lanes(entity, lanes, input)
    if entity.direction == input.direction then return lanes end
    local clockwise = is_clockwise(input, entity)
    for lane in pairs(lanes) do
        if clockwise == (lane == 2) then
            if get_belt_type(entity) == "underground-belt" then
                local type = entity.belt_to_ground_type == "input"
                return lane_cycle[clockwise == type and 2 or 3]
            else
                return lane_cycle[1]
            end
        end
    end
end

local function add_to_queue(data, old_entity, lanes, entity, path)
    if not entity then return end
    local type = entity.type
    if type == "entity-ghost" then
        if data.ghost then
            type = entity.ghost_type
        else return end
    end
    local is_splitter = type == "splitter"
    local sides
    if is_splitter then
        sides = {}
        if path == 2 then
            local filter_side = get_filter_side(data, entity)
            if filter_side then
                for _, side in pairs(get_splitter_sides(entity, old_entity)) do
                    if filter_side == side then
                        sides[#sides+1] = side
                    end
                end
                if not next(sides) then return end
            end
        end
        if not next(sides) then
            sides = side_cycle.both
        end
    end
    local unit_number = entity.unit_number
    local checked = data.checked
    local new_lanes = {}
    for lane in pairs(lanes) do
        local check
        if checked[unit_number] then
            if is_splitter then
                for _, side in pairs(sides) do
                    check = checked[unit_number][side][path%2+1][lane][path] or check
                end
            else
                check = checked[unit_number][lane][path] or check
            end
        else
            checked[unit_number] = empty_check(type)
        end
        if not check then
            new_lanes[lane] = true
            check_entity(data, unit_number, lane, path, sides)
        end
    end
    if next(new_lanes) then
        local next_entities = data.next_entities
        local i = #next_entities + 1
        next_entities[i] = {entity = entity, lanes = new_lanes, path = path}
    end
end

local highlight_entity = {
    ["transport-belt"] = function(data, entity, lanes, path)
        local direction = entity.direction
        local belt_neighbours = entity.belt_neighbours
        local inputs = belt_neighbours.inputs
        local output = belt_neighbours.outputs[1]
        local is_curved = (#inputs == 1) and (direction ~= inputs[1].direction)
        local next_lanes, lane_offsets = get_next_lanes(data, entity, lanes, output)
        for lane in pairs(lanes) do
            local offsets = straight[lane][direction]
            local lane_offset = lane_offsets[lane]
            if not is_curved then
                draw_line(data, entity, offsets.input, offsets[lane_offset])
            else
                draw_arc(data, entity, lane, is_clockwise(inputs[1], entity))
                if lane_offset == "sideload" then
                    draw_line(data, entity, offsets.output, offsets[lane_offset])
                end
            end
        end
        if path == 1 then
            add_to_queue(data, entity, next_lanes, output, 1)
        else
            for _, input in pairs(inputs) do
                local prev_lanes = is_curved and lanes or get_prev_lanes(entity, lanes, input)
                if prev_lanes then add_to_queue(data, entity, prev_lanes, input, 2) end
            end
        end
    end,
    ["underground-belt"] = function(data, entity, lanes, path)
        local direction = entity.direction
        local belt_neighbours = entity.belt_neighbours
        local output = belt_neighbours.outputs[1]
        local type = entity.belt_to_ground_type
        local is_input = type == "input"
        local next_lanes, lane_offsets = get_next_lanes(data, entity, lanes, output)
        for lane in pairs(lanes) do
            local lane_offset = is_input and "input" or lane_offsets[lane]
            draw_line(data, entity, underground[lane][direction][type], straight[lane][direction][lane_offset])
        end
        local forward = path == 1
        if forward then
            add_to_queue(data, entity, next_lanes, output, 1)
        else
            for _, input in pairs(belt_neighbours.inputs) do
                local prev_lanes = get_prev_lanes(entity, lanes, input)
                if prev_lanes then add_to_queue(data, entity, prev_lanes, input, 2) end
            end
        end
        if forward == is_input and entity.neighbours then
            local check = data.checked[entity.unit_number]
            local neighbour_check = data.checked[entity.neighbours.unit_number]
            for lane in pairs(lanes) do
                if not (neighbour_check and neighbour_check[lane].dash) then
                    local offsets = dash[lane][direction]
                    draw_dash(data, is_input and entity or entity.neighbours, offsets.input, offsets.output)
                end
                check[lane].dash = true
            end
            add_to_queue(data, entity, lanes, entity.neighbours, path)
        end
    end,
    ["splitter"] = function(data, entity, lanes, path)
        local direction = entity.direction
        local belt_neighbours = entity.belt_neighbours
        local forward = path == 1
        local belts = {}
        for _, belt in pairs(belt_neighbours[forward and "outputs" or "inputs"]) do
            for _, side in pairs(get_splitter_sides(entity, belt)) do
                if forward or get_belt_type(belt) ~= "splitter" or get_filter_side(data, belt) ~= side then
                    belts[side] = belt
                end
            end
        end
        local filter_side = get_filter_side(data, entity)
        local queued = nil
        for _, side in pairs(forward and side_cycle[filter_side] or side_cycle.both) do
            local next_lanes, lane_offsets = get_next_lanes(data, entity, lanes, belts[side])
            for lane in pairs(lanes) do
                local offsets = splitter[lane][direction]
                local side_offsets = offsets[side]
                local lane_offset = forward and lane_offsets[lane] or "input"
                draw_line(data, entity, side_offsets.middle, side_offsets[lane_offset])
                draw_line(data, entity, offsets.left.line, offsets.right.line)
            end
            if queued ~= belts[side] then
                add_to_queue(data, entity, next_lanes, belts[side], path)
                queued = belts[side]
            end
        end
        for _, belt in pairs(belt_neighbours[forward and "inputs" or "outputs"]) do
            local belt_check = data.checked[belt.unit_number]
            if belt_check then
                local sides = not forward and side_cycle[filter_side] or get_splitter_sides(entity, belt)
                for _, side in pairs(sides) do
                    local _, lane_offsets = get_next_lanes(data, entity, lanes, belt)
                    local checked_lanes = forward and get_input_lanes(data, entity, belt, side) or lanes
                    for lane in pairs(checked_lanes) do
                        local belt_path
                        if get_belt_type(belt) == "splitter" then
                            local output_side = sides[2] and side or (side == "left" and "right" or "left")
                            belt_path = belt_check[output_side][path][lane][path]
                        else
                            belt_path = belt_check[lane][path]
                        end
                        if belt_path then
                            local side_offsets = splitter[lane][direction][side]
                            local lane_offset = forward and "input" or lane_offsets[lane]
                            draw_line(data, entity, side_offsets.middle, side_offsets[lane_offset])
                        end
                    end
                end
            end
        end
    end,
    ["linked-belt"] = function(data, entity, lanes, path)
        local direction = entity.direction
        local belt_neighbours = entity.belt_neighbours
        local output = belt_neighbours.outputs[1]
        local linked_belt_neighbour = entity.linked_belt_neighbour
        local is_input = entity.linked_belt_type == "input"
        local forward = path == 1
        local next_lanes, lane_offsets = get_next_lanes(data, entity, lanes, output)
        for lane in pairs(lanes) do
            local offsets = linked_belt[lane][direction]
            local middle = offsets.middle
            local lane_offset = is_input and "input" or lane_offsets[lane]
            draw_line(data, entity, middle, offsets[lane_offset])
            draw_circle(data, entity, middle)
        end
        add_to_queue(data, entity, next_lanes, forward and output or belt_neighbours.inputs[1], path)
        if is_input == forward then
            add_to_queue(data, entity, lanes, linked_belt_neighbour, path)
        end
    end,
}
local function highlight_loader(loader_const)
    return function(data, entity, lanes, path)
        local direction = entity.direction
        local belt_neighbours = entity.belt_neighbours
        local output = belt_neighbours.outputs[1]
        local next_lanes, lane_offsets = get_next_lanes(data, entity, lanes, output)
        for lane in pairs(lanes) do
            local offsets = loader_const[lane][direction]
            local lane_offset = lane_offsets[lane]
            draw_line(data, entity, offsets.input, offsets[lane_offset])
            draw_rectangle(data, entity, loader_const.rectangle[lane][direction][entity.loader_type])
        end
        add_to_queue(data, entity, next_lanes, path == 1 and output or belt_neighbours.inputs[1], path)
    end
end
highlight_entity["loader"] = highlight_loader(loader)
highlight_entity["loader-1x1"] = highlight_loader(loader_1x1)

script.on_event(e.on_tick, function(event)
    for index, tick in pairs(global.refresh) do
        if tick == event.tick then
            refresh(global.data[index])
            global.refresh[index] = nil
        end
    end
    local length = table_size(global.in_progress)
    for index in pairs(global.in_progress) do
        local data = global.data[index]
        local c = 0
        while c < settings.global["highlight-maximum"].value / length do
            local i, next_data = next(data.next_entities)
            if not i then break end
            local entity = next_data.entity
            if entity.valid then
                highlight_entity[get_belt_type(entity)](data, next_data.entity, next_data.lanes, next_data.path)
                c = c + 1
            end
            table.remove(data.next_entities, i) -- optimize to insert last element in hole?
        end
        if not next(data.next_entities) then global.in_progress[data.index] = nil end
    end
end)