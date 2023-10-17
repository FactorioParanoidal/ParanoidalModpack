local const = require("scripts/constants")
local utils = require("scripts/utils")
local draw = require("scripts/rendering")
local get_belt_type = utils.get_belt_type
local empty_check = utils.empty_check
local check_entity = utils.check_entity
local lane_cycle = const.lane_cycle
local side_cycle = const.side_cycle
local straight = const.straight
local underground = const.underground
local dash = const.dash
local splitter = const.splitter
local loader = const.loader
local loader_1x1 = const.loader_1x1
local linked_belt = const.linked_belt

local function is_clockwise(entity, output)
    return (output.direction - entity.direction) % 8 == 2
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

local function get_input_paths(check, lanes)
    for lane, paths in pairs(check) do
        if paths[1] then
            lanes[lane] = true
        end
    end
end

local function get_input_lanes(data, entity, input)
    local check = data.checked[input.unit_number]
    local lanes = {}
    if get_belt_type(input) == "splitter" then
        for _, side_check in pairs(check) do
            get_input_paths(side_check, lanes)
        end
    else
        get_input_paths(check, lanes)
    end
    return lanes
end

local default_output = {"output", "output"}
local function get_output_lanes(data, entity, lanes, output)
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

local function add_to_queue(data, entity, lanes, path, old_entity)
    if not entity then return end
    local belt_type = entity.type
    if belt_type == "entity-ghost" then
        if data.ghost then
            belt_type = entity.ghost_type
        else return end
    end
    local is_splitter = belt_type == "splitter"
    local sides
    if is_splitter then
        local const_sides = get_splitter_sides(entity, old_entity)
        sides = {}
        for side in pairs(const_sides) do
            sides[side] = true
        end
        if path == 2 then
            local filter_side = get_filter_side(data, entity)
            if filter_side then
                for side in pairs(const_sides) do
                    if filter_side ~= side then
                        sides[side] = nil
                    end
                end
                if not next(sides) then return end
            end
        end
    end
    local unit_number = entity.unit_number
    local checked = data.checked
    local new_lanes = {}
    for lane in pairs(lanes) do
        local check
        if checked[unit_number] then
            if is_splitter then
                for side in pairs(sides) do
                    check = checked[unit_number][side][lane][path]
                end
            else
                check = checked[unit_number][lane][path]
            end
        else
            checked[unit_number] = empty_check(belt_type)
        end
        if not check then
            new_lanes[lane] = true
            check_entity(data, unit_number, lane, path, sides)
        end
    end
    if next(new_lanes) then
        local next_entities = data.next_entities
        local next_len = data.next_len + 1
        data.next_len = next_len
        next_entities[next_len] = {entity = entity, lanes = new_lanes, path = path}
    end
end

local highlight_entity = {}

highlight_entity["transport-belt"] = function(data, entity, lanes, path)
    local direction = entity.direction
    local belt_neighbours = entity.belt_neighbours
    local inputs = belt_neighbours.inputs
    local output = belt_neighbours.outputs[1]
    local is_curved = (#inputs == 1) and (direction ~= inputs[1].direction)
    local next_lanes, lane_offsets = get_output_lanes(data, entity, lanes, output)
    for lane in pairs(lanes) do
        local offsets = straight[lane][direction]
        local lane_offset = lane_offsets[lane]
        if not is_curved then
            draw.line(data, entity, offsets.input, offsets[lane_offset])
        else
            draw.arc(data, entity, lane, is_clockwise(inputs[1], entity))
            if lane_offset == "sideload" then
                draw.line(data, entity, offsets.output, offsets[lane_offset])
            end
        end
    end
    if path == 1 then
        add_to_queue(data, output, next_lanes, 1, entity)
    else
        for _, input in pairs(inputs) do
            local prev_lanes = is_curved and lanes or get_prev_lanes(entity, lanes, input)
            if prev_lanes then add_to_queue(data, input, prev_lanes, 2, entity) end
        end
    end
end

highlight_entity["underground-belt"] = function(data, entity, lanes, path)
    local direction = entity.direction
    local belt_neighbours = entity.belt_neighbours
    local output = belt_neighbours.outputs[1]
    local type = entity.belt_to_ground_type
    local is_input = type == "input"
    local next_lanes, lane_offsets = get_output_lanes(data, entity, lanes, output)
    for lane in pairs(lanes) do
        local lane_offset = is_input and "input" or lane_offsets[lane]
        draw.line(data, entity, underground[lane][direction][type], straight[lane][direction][lane_offset])
    end
    local forward = path == 1
    if forward then
        add_to_queue(data, output, next_lanes, path, entity)
    else
        for _, input in pairs(belt_neighbours.inputs) do
            local prev_lanes = get_prev_lanes(entity, lanes, input)
            if prev_lanes then add_to_queue(data, input, prev_lanes, path, entity) end
        end
    end
    local neighbour = entity.neighbours
    if forward == is_input and neighbour then
        local check = data.checked[entity.unit_number]
        local neighbour_check = data.checked[neighbour.unit_number]
        for lane in pairs(lanes) do
            if not (neighbour_check and neighbour_check[lane].dash) then
                local offsets = dash[lane][direction]
                draw.dash(data, is_input and entity or neighbour, offsets.input, offsets.output)
            end
            check[lane].dash = true
        end
        add_to_queue(data, neighbour, lanes, path, entity)
    end
end

highlight_entity["splitter"] = function(data, entity, lanes, path)
    local direction = entity.direction
    local belt_neighbours = entity.belt_neighbours
    local forward = path == 1
    local belts = {}
    for _, belt in pairs(belt_neighbours[forward and "outputs" or "inputs"]) do
        for side in pairs(get_splitter_sides(entity, belt)) do
            if forward or get_belt_type(belt) ~= "splitter" or get_filter_side(data, belt) ~= side then
                belts[side] = belt
            end
        end
    end
    local queued
    local filter_side = get_filter_side(data, entity)
    for side in pairs(forward and side_cycle[filter_side] or side_cycle.both) do
        local next_lanes, lane_offsets = get_output_lanes(data, entity, lanes, belts[side])
        for lane in pairs(lanes) do
            local offsets = splitter[lane][direction]
            local side_offsets = offsets[side]
            local lane_offset = forward and lane_offsets[lane] or "input"
            draw.line(data, entity, side_offsets.middle, side_offsets[lane_offset])
            draw.line(data, entity, offsets.left.line, offsets.right.line)
        end
        if queued ~= belts[side] then
            add_to_queue(data, belts[side], next_lanes, path, entity)
            queued = belts[side]
        end
    end
    for _, belt in pairs(belt_neighbours[forward and "inputs" or "outputs"]) do
        local belt_check = data.checked[belt.unit_number]
        if belt_check then
            local checked_lanes = forward and get_input_lanes(data, entity, belt) or lanes
            local _, lane_offsets = get_output_lanes(data, entity, lanes, belt)
            local sides = not forward and side_cycle[filter_side] or get_splitter_sides(entity, belt)
            for side in pairs(sides) do
                for lane in pairs(checked_lanes) do
                    local belt_path
                    if get_belt_type(belt) == "splitter" then
                        belt_path = belt_check.left[lane][path] or belt_check.right[lane][path]
                    else
                        belt_path = belt_check[lane][path]
                    end
                    if belt_path then
                        local side_offsets = splitter[lane][direction][side]
                        local lane_offset = forward and "input" or lane_offsets[lane]
                        draw.line(data, entity, side_offsets.middle, side_offsets[lane_offset])
                    end
                end
            end
        end
    end
end

highlight_entity["linked-belt"] = function(data, entity, lanes, path)
    local direction = entity.direction
    local belt_neighbours = entity.belt_neighbours
    local output = belt_neighbours.outputs[1]
    local linked_belt_neighbour = entity.linked_belt_neighbour
    local is_input = entity.linked_belt_type == "input"
    local forward = path == 1
    local next_lanes, lane_offsets = get_output_lanes(data, entity, lanes, output)
    for lane in pairs(lanes) do
        local offsets = linked_belt[lane][direction]
        local middle = offsets.middle
        local lane_offset = is_input and "input" or lane_offsets[lane]
        draw.line(data, entity, middle, offsets[lane_offset])
        draw.circle(data, entity, middle)
    end
    add_to_queue(data, forward and output or belt_neighbours.inputs[1], next_lanes, path, entity)
    if is_input == forward then
        add_to_queue(data, linked_belt_neighbour, lanes, path, entity)
    end
end

---@return fun(data: table, entity: LuaEntity, lanes: table, path: 1|2)
local function highlight_loader(loader_const)
    return function(data, entity, lanes, path)
        local direction = entity.direction
        local belt_neighbours = entity.belt_neighbours
        local output = belt_neighbours.outputs[1]
        local loader_type = entity.loader_type
        local next_lanes, lane_offsets = get_output_lanes(data, entity, lanes, output)
        for lane in pairs(lanes) do
            local offsets = loader_const[lane][direction]
            local lane_offset = lane_offsets[lane]
            draw.line(data, entity, offsets.input, offsets[lane_offset])
            draw.rectangle(data, entity, loader_const.rectangle[lane][direction][loader_type])
        end
        local forward = path == 1
        local new_entity = forward and output or belt_neighbours.inputs[1]
        add_to_queue(data, new_entity, next_lanes, path, entity)
        if entity.type == "entity-ghost" then return end -- TODO: ACTUALLY FIX
        if data.container_passthrough and forward == (loader_type == "input") then
            local container = entity.loader_container
            if container and (container.type == "container" or container.type == "logistic-container" or container.type == "infinity-container") then
                local box = container.prototype.collision_box
                local lt, rb = box.left_top, box.right_bottom
                local pos = container.position
                local loaders = container.surface.find_entities_filtered{
                    area = {{pos.x + lt.x - 1, pos.y + lt.y - 1}, {pos.x + rb.x + 1, pos.y + rb.y + 1}},
                    type = {"loader", "loader-1x1"},
                }
                for _, loader in pairs(loaders) do
                    local loader_container = loader.loader_container
                    if loader ~= entity and loader_container and loader_container == container and loader_type ~= loader.loader_type then
                        add_to_queue(data, loader, lane_cycle[1], path, entity)
                    end
                end
            end
        end
    end
end

highlight_entity["loader"] = highlight_loader(loader)
highlight_entity["loader-1x1"] = highlight_loader(loader_1x1)

return highlight_entity