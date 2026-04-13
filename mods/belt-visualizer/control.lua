local const = require("scripts/constants")
local utils = require("scripts/utils")
local highlight_entity = require("scripts/highlight")
local get_belt_type = utils.get_belt_type
local connectables = const.connectables
local lane_cycle = const.lane_cycle
local side_cycle = const.side_cycle
local e = defines.events

local function setup_globals()
    storage.data = {}
    storage.in_progress = {}
    storage.refresh = {}
    storage.belt_lines = {}
    storage.clear = storage.clear or {}
    storage.hover = storage.hover or {}
    -- global.colors = const.generate_colors()
end

script.on_init(function()
    setup_globals()
end)

script.on_configuration_changed(function(data)
    rendering.clear("belt-visualizer")
    setup_globals()
end)

local function clear(index)
    storage.in_progress[index] = nil
    storage.refresh[index] = nil
    local data = storage.data[index]
    if not data then return end
    data.checked = nil
    data.belt_line = nil
    if data.render then
        storage.clear[data.render] = true
    end
    data.render = nil
end

local function remove_player(event)
    local index = event.player_index
    clear(index)
    storage.data[index] = nil
    storage.belt_lines[index] = nil
    storage.hover[index] = nil
end

script.on_event(e.on_player_left_game, remove_player)
script.on_event(e.on_player_removed, remove_player)

local function highlight(event)
    local index = event.player_index
    clear(index)
    local player = game.get_player(index) --[[@as LuaPlayer]]
    local selected = player.selected
    if not selected then
        if storage.hover[index] == "disabled" then
            storage.hover[index] = "on"
        end
        return
    end
    local ghost = event.input_name ~= "bv-highlight-belt" or selected.type == "entity-ghost"
    local type = selected.type
    if type == "entity-ghost" then
        if ghost then
            type = selected.ghost_type
        else return end
    end
    if not connectables[type] then return end
    local data = storage.data[index] or {}
    storage.data[index] = data
    local unit_number = selected.unit_number --[[@as number]]
    local filter = utils.get_cursor_name(player)
    local repeat_origin = data.origin and data.origin.valid and data.origin.unit_number == unit_number
    if data.filter == filter and repeat_origin then
        data.cycle = data.cycle % 3 + 1
    else
        data.cycle = 1
    end
    data.index = index
    data.ghost = ghost
    data.filter = filter
    data.origin = selected
    data.drawn_offsets = {}
    data.drawn_arcs = {}
    data.checked = {[unit_number] = utils.empty_check(type)}
    data.belt_line = {}
    data.head = selected
    data.tail = selected
    data.next_entities = {}
    data.next_index = 1
    data.next_len = 2
    local lanes = lane_cycle[data.cycle]
    for path = 1, 2 do
        data.next_entities[path] = {entity = selected, lanes = lanes, path = path}
        local sides = type == "splitter" and side_cycle.both
        for lane in pairs(lanes) do
            utils.check_entity(data, unit_number, lane, path, sides)
        end
    end
    data.render = {}
    data.container_passthrough = settings.get_player_settings(player)["bv-container-passthrough"].value
    storage.in_progress[index] = true
end

local function refresh(data)
    clear(data.index)
    local entity = data.origin
    if not entity.valid then return end
    data.next_entities = {}
    data.next_index = 1
    data.next_len = 2
    for i = 1, 2 do
        data.next_entities[i] = {entity = entity, lanes = lane_cycle[data.cycle], path = i}
    end
    data.drawn_offsets = {}
    data.drawn_arcs = {}
    data.checked = {[entity.unit_number] = utils.empty_check(entity.type)}
    data.belt_line = {}
    data.head = entity
    data.tail = entity
    data.render = {}
    storage.in_progress[data.index] = true
end

local function keybind(event)
    local index = event.player_index
    if storage.hover[index] == "on" then
        storage.hover[index] = "disabled"
    else
        highlight(event)
    end
end

script.on_event("bv-highlight-belt", keybind)
script.on_event("bv-highlight-ghost", keybind)

script.on_event(e.on_selected_entity_changed, function(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local data = storage.data[event.player_index]
    local selected = player.selected --[[@as LuaEntity]]
    local is_connectable = selected and connectables[get_belt_type(selected)]
    local belt_line = data and data.belt_line
    if is_connectable and belt_line and belt_line[selected.unit_number] then
        data.origin = player.selected
        return
    end
    if storage.hover[event.player_index] ~= "on" then return end
    highlight(event)
end)

local function toggle_hover(event)
    local index = event.player_index
    local player = game.get_player(index) --[[@as LuaPlayer]]
    local toggle = not player.is_shortcut_toggled("bv-toggle-hover")
    storage.hover[index] = toggle and "on" or "off"
    player.set_shortcut_toggled("bv-toggle-hover", toggle)
end

script.on_event("bv-toggle-hover", toggle_hover)
script.on_event(e.on_lua_shortcut, function(event)
    if event.prototype_name ~= "bv-toggle-hover" then return end
    toggle_hover(event)
end)

local function highlightable(data, entity)
    local checked = data.checked
    if not checked then return false end
    if checked[entity.unit_number] then return true end
    for _, input in pairs(entity.belt_neighbours.inputs) do
        if checked[input.unit_number] then return true end
    end
    for _, output in pairs(entity.belt_neighbours.outputs) do
        if checked[output.unit_number] then return true end
    end
    if entity.type == "underground-belt" then
        local neighbour = entity.neighbours
        if neighbour and checked[neighbour.unit_number] then return true end
    elseif entity.type == "linked-belt" then
        local neighbour = entity.linked_belt_neighbour
        if neighbour and checked[neighbour.unit_number] then return true end
    end
    return false
end

local function on_entity_modified(event)
    local entity = event.entity or event.destination
    for _, data in pairs(storage.data) do
        if highlightable(data, entity) then
            if not storage.refresh[data.index] then
                storage.refresh[data.index] = event.tick + 60
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

---@param t table
---@param case any
local function switch(t, case, ...)
    local fun = t[case]
    if fun then
        return fun(...)
    end
end

---@type table<string, fun(entity: LuaEntity): LuaEntity?>
local next_switch = {
    ["transport-belt"] = function(entity)
        return entity.belt_neighbours.outputs[1]
    end,
    ["underground-belt"] = function(entity)
        if entity.belt_to_ground_type == "input" then
            return entity.neighbours
        else
            return entity.belt_neighbours.outputs[1]
        end
    end,
    ["linked-belt"] = function(entity)
        if entity.linked_belt_type == "input" then
            return entity.linked_belt_neighbour
        else
            return entity.belt_neighbours.outputs[1]
        end
    end,
}

---@type table<string, fun(entity: LuaEntity): LuaEntity?>
local previous_switch = {
    ["transport-belt"] = function(entity)
        return entity.belt_neighbours.inputs[1]
    end,
    ["underground-belt"] = function(entity)
        if entity.belt_to_ground_type == "output" then
            return entity.neighbours
        else
            return entity.belt_neighbours.inputs[1]
        end
    end,
    ["linked-belt"] = function(entity)
        if entity.linked_belt_type == "output" then
            return entity.linked_belt_neighbour
        else
            return entity.belt_neighbours.inputs[1]
        end
    end,
}

local function walk_belt(belt, belt_switch, belt_line, max_highlights, ghost, include)
    local c = 0
    while c < max_highlights do
        if not belt then return end
        if belt.type == "entity-ghost" and not ghost then return end
        local belt_type = get_belt_type(belt)
        if belt_type == "splitter" then return end
        if include then
            belt_line[belt.unit_number] = true
        end
        local limit = 1
        if (belt_type == "underground-belt" and belt.belt_to_ground_type == "output")
        or (belt_type == "linked-belt" and belt.linked_belt_type == "output") then
            limit = 0
        end
        if #belt.belt_neighbours.inputs > limit then return end
        belt_line[belt.unit_number] = true
        belt = switch(belt_switch, belt_type, belt)
        c = c + 1
    end
    return belt
end

local function cache_belt_line(data, max_highlights)
    local head, tail = data.head, data.tail
    local belt_line = data.belt_line
    local ghost = data.ghost
    if head and head.valid then
        head = switch(next_switch, get_belt_type(head), head)
        data.head = walk_belt(head, next_switch, belt_line, max_highlights, ghost)
    end
    if tail and tail.valid then
        data.tail = walk_belt(tail, previous_switch, belt_line, max_highlights, ghost, true)
    end
end

script.on_event(e.on_tick, function(event)
    for index, tick in pairs(storage.refresh) do
        if tick == event.tick then
            refresh(storage.data[index])
        end
    end
    local player_count = table_size(storage.in_progress)
    local highlight_maximum = settings.global["bv-highlight-maximum"].value
    local max_highlights = highlight_maximum * 8 / table_size(storage.clear)
    for renders in pairs(storage.clear) do
        local c = 0
        for id, render in pairs(renders) do
            if render.valid then
                render.destroy()
            end
            renders[id] = nil
            c = c + 1
            if c > max_highlights then break end
        end
        if not next(renders) then storage.clear[renders] = nil end
    end
    max_highlights = highlight_maximum / player_count
    for index in pairs(storage.in_progress) do
        local data = storage.data[index]
        cache_belt_line(data, max_highlights)
        local c = 0
        while c < max_highlights do
            local next_index = data.next_index
            local next_data = data.next_entities[next_index]
            if not next_data then break end
            local entity = next_data.entity
            if entity.valid then
                highlight_entity[get_belt_type(entity)](data, next_data.entity, next_data.lanes, next_data.path)
                c = c + 1
            end
            data.next_entities[next_index] = nil
            data.next_index = next_index + 1
        end
        if not data.next_entities[data.next_index] then storage.in_progress[data.index] = nil end
    end
end)