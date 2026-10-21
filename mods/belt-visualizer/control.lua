local const = require("scripts/constants")
local utils = require("scripts/utils")
local highlight_entity = require("scripts/highlight")
local get_belt_type = utils.get_belt_type
local connectables = const.connectables
local lane_cycle = const.lane_cycle
local side_cycle = const.side_cycle
local e = defines.events

-- A modification near a highlight refreshes it after REFRESH_DELAY ticks of quiet,
-- but never later than REFRESH_MAX_DELAY ticks after the first modification
local REFRESH_DELAY = 60
local REFRESH_MAX_DELAY = 300

local connectable_types = {}
for belt_type in pairs(connectables) do
    connectable_types[#connectable_types + 1] = belt_type
end

---@type integer?
local highlight_maximum -- cached runtime-global setting, read lazily

local function get_highlight_maximum()
    if not highlight_maximum then
        highlight_maximum = settings.global["bv-highlight-maximum"].value --[[@as integer]]
    end
    return highlight_maximum
end

local function setup_globals()
    storage.data = {}
    storage.in_progress = {}
    storage.refresh = {}
    storage.belt_lines = {}
    storage.clear = storage.clear or {}
    storage.hover = storage.hover or {}
    -- global.colors = const.generate_colors()
end

---------------------------------------------------------------------------------------------------
-- on_tick is registered only while there is work to do

local on_tick
local tick_registered = false

local function has_work()
    return next(storage.in_progress or {}) ~= nil
        or next(storage.clear or {}) ~= nil
        or next(storage.refresh or {}) ~= nil
end

local function set_tick_handler(active)
    if active == tick_registered then return end
    tick_registered = active
    script.on_event(e.on_tick, active and on_tick or nil)
end

local function activate()
    set_tick_handler(true)
end

local function update_tick_handler()
    set_tick_handler(has_work())
end

---------------------------------------------------------------------------------------------------
-- Belt line caching (the straight part of the belt around the origin without merges)

---@return LuaEntity?
local function step_belt(belt, belt_type, belt_neighbours, forward)
    if belt_type == "underground-belt" then
        if (belt.belt_to_ground_type == "input") == forward then return belt.neighbours end
    elseif belt_type == "linked-belt" then
        if (belt.linked_belt_type == "input") == forward then return belt.linked_belt_neighbour end
    elseif belt_type ~= "transport-belt" then
        return nil
    end
    local list = forward and belt_neighbours.outputs or belt_neighbours.inputs
    return list[1]
end

---@return LuaEntity?
local function next_belt(entity, belt_type)
    if belt_type ~= "transport-belt" and belt_type ~= "underground-belt" and belt_type ~= "linked-belt" then return end
    return step_belt(entity, belt_type, entity.belt_neighbours, true)
end

local function walk_belt(belt, forward, belt_line, max_steps, ghost, include)
    for _ = 1, max_steps do
        if not (belt and belt.valid) then return end
        local unit_number = belt.unit_number --[[@as number]]
        -- already visited: closed loop or the other walk got here first
        if belt_line[unit_number] then return end
        local belt_type = belt.type
        if belt_type == "entity-ghost" then
            if not ghost then return end
            belt_type = belt.ghost_type
        end
        if belt_type == "splitter" then return end
        if include then
            belt_line[unit_number] = true
        end
        local belt_neighbours = belt.belt_neighbours
        local limit = 1
        if (belt_type == "underground-belt" and belt.belt_to_ground_type == "output")
        or (belt_type == "linked-belt" and belt.linked_belt_type == "output") then
            limit = 0
        end
        if #belt_neighbours.inputs > limit then return end
        belt_line[unit_number] = true
        belt = step_belt(belt, belt_type, belt_neighbours, forward)
    end
    return belt
end

local function cache_belt_line(data, max_steps)
    local belt_line = data.belt_line
    local ghost = data.ghost
    if data.head then
        data.head = walk_belt(data.head, true, belt_line, max_steps, ghost)
    end
    if data.tail then
        data.tail = walk_belt(data.tail, false, belt_line, max_steps, ghost, true)
    end
end

---------------------------------------------------------------------------------------------------
-- Highlight lifecycle

local function clear(index)
    storage.in_progress[index] = nil
    storage.refresh[index] = nil
    local data = storage.data[index]
    if not data then return end
    data.checked = nil
    data.belt_line = nil
    data.refresh_deadline = nil
    data.head = nil
    data.tail = nil
    data.next_entities = nil
    data.drawn_offsets = nil
    data.drawn_arcs = nil
    data.drawn_shapes = nil
    data.passthrough = nil
    local render = data.render
    if render and next(render) then
        storage.clear[render] = true
        activate()
    end
    data.render = nil
    data.render_n = nil
end

-- Frees traversal-only state once the whole network has been drawn
local function finish(data)
    storage.in_progress[data.index] = nil
    data.next_entities = nil
    data.head = nil
    data.tail = nil
    data.drawn_offsets = nil
    data.drawn_arcs = nil
    data.drawn_shapes = nil
    data.passthrough = nil
end

---@param data table
---@param entity LuaEntity
---@param belt_type string
local function start(data, entity, belt_type)
    local index = data.index
    local unit_number = entity.unit_number --[[@as number]]
    local lanes = lane_cycle[data.cycle]
    local sides = belt_type == "splitter" and side_cycle.both or nil
    data.checked = {[unit_number] = utils.empty_check(belt_type)}
    data.next_entities = {}
    for path = 1, 2 do
        data.next_entities[path] = {entity = entity, lanes = lanes, path = path}
        for lane in pairs(lanes) do
            utils.check_entity(data, unit_number, lane, path, sides)
        end
    end
    data.next_index = 1
    data.next_len = 2
    data.drawn_offsets = {}
    data.drawn_arcs = {}
    data.drawn_shapes = {}
    data.passthrough = {{}, {}}
    data.belt_line = {}
    data.head = next_belt(entity, belt_type)
    data.tail = entity
    data.render = {}
    data.render_n = 0
    data.players = {index}
    local player = game.get_player(index)
    data.container_passthrough = player and settings.get_player_settings(player)["bv-container-passthrough"].value
    storage.in_progress[index] = true
    activate()
end

local function refresh(data)
    clear(data.index)
    local entity = data.origin
    if not (entity and entity.valid) then return end
    local belt_type = get_belt_type(entity)
    if not connectables[belt_type] then return end
    if belt_type ~= entity.type and not data.ghost then return end
    if not lane_cycle[data.cycle] then return end -- the highlight was switched off by the cycle
    start(data, entity, belt_type)
end

script.on_init(function()
    setup_globals()
end)

script.on_load(function()
    update_tick_handler()
end)

script.on_configuration_changed(function(data)
    rendering.clear("belt-visualizer")
    setup_globals()
    update_tick_handler()
end)

script.on_event(e.on_runtime_mod_setting_changed, function(event)
    if event.setting == "bv-highlight-maximum" then
        highlight_maximum = nil
    end
end)

local function remove_player(event)
    local index = event.player_index
    clear(index)
    storage.data[index] = nil
    storage.belt_lines[index] = nil
    storage.hover[index] = nil
end

-- The shortcut toggle state survives leaving the game, so the hover state is kept too
script.on_event(e.on_player_left_game, function(event)
    clear(event.player_index)
end)
script.on_event(e.on_player_removed, remove_player)

-- cycle_lanes: a key press on the same belt steps through both lanes -> left -> right -> off;
-- hovering (cycle_lanes = nil) always starts from both lanes.
local function highlight(event, cycle_lanes)
    local index = event.player_index
    clear(index)
    local player = game.get_player(index) --[[@as LuaPlayer]]
    local selected = player.selected
    if not selected then return end
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
    if cycle_lanes and data.filter == filter and repeat_origin and data.cycle then
        -- one step past the lane modes is "off"
        data.cycle = data.cycle % (#lane_cycle + 1) + 1
    else
        data.cycle = 1
    end
    data.index = index
    data.ghost = ghost
    data.filter = filter
    data.origin = selected
    if not lane_cycle[data.cycle] then return end -- off: the highlight is already cleared
    start(data, selected, type)
end

-- Paranoidal: the key cycles the lanes in hover mode too instead of freezing the highlight.
-- "disabled" (the old frozen hover state kept in storage) goes back to hover mode.
local function keybind(event)
    local index = event.player_index
    if storage.hover[index] == "disabled" then
        storage.hover[index] = "on"
    end
    highlight(event, true)
end

script.on_event("bv-highlight-belt", keybind)
script.on_event("bv-highlight-ghost", keybind)

script.on_event(e.on_selected_entity_changed, function(event)
    local index = event.player_index
    local data = storage.data[index]
    local hover = storage.hover[index] == "on"
    local belt_line = data and data.belt_line
    if not (hover or belt_line) then return end
    local player = game.get_player(index) --[[@as LuaPlayer]]
    local selected = player.selected
    if selected and belt_line and belt_line[selected.unit_number] and connectables[get_belt_type(selected)] then
        data.origin = selected
        return
    end
    if not hover then return end
    highlight(event)
end)

local function toggle_hover(event)
    local index = event.player_index
    local player = game.get_player(index) --[[@as LuaPlayer]]
    local toggle = not player.is_shortcut_toggled("bv-toggle-hover")
    storage.hover[index] = toggle and "on" or "off"
    player.set_shortcut_toggled("bv-toggle-hover", toggle)
    -- switching hover mode off removes the highlight it left behind
    if not toggle then clear(index) end
end

script.on_event("bv-toggle-hover", toggle_hover)
script.on_event(e.on_lua_shortcut, function(event)
    if event.prototype_name ~= "bv-toggle-hover" then return end
    toggle_hover(event)
end)

---------------------------------------------------------------------------------------------------
-- Refreshing after the belt network changes

local function schedule_refresh(data, tick)
    local index = data.index
    local deadline = data.refresh_deadline
    if not (deadline and storage.refresh[index]) then
        deadline = tick + REFRESH_MAX_DELAY
        data.refresh_deadline = deadline
    end
    storage.refresh[index] = math.min(tick + REFRESH_DELAY, deadline)
    activate()
end

local function highlightable(data, entity)
    local checked = data.checked
    if not checked then return false end
    if entity.type == "entity-ghost" and not data.ghost then return false end
    if checked[entity.unit_number] then return true end
    local belt_neighbours = entity.belt_neighbours
    for _, input in pairs(belt_neighbours.inputs) do
        if checked[input.unit_number] then return true end
    end
    for _, output in pairs(belt_neighbours.outputs) do
        if checked[output.unit_number] then return true end
    end
    local belt_type = get_belt_type(entity)
    if belt_type == "underground-belt" then
        local neighbour = entity.neighbours
        if neighbour and checked[neighbour.unit_number] then return true end
    elseif belt_type == "linked-belt" then
        local neighbour = entity.linked_belt_neighbour
        if neighbour and checked[neighbour.unit_number] then return true end
    end
    return false
end

local function entity_modified(entity, tick)
    if not (entity and entity.valid) then return end
    for _, data in pairs(storage.data) do
        if highlightable(data, entity) then
            schedule_refresh(data, tick)
        end
    end
end

local function on_entity_modified(event)
    entity_modified(event.entity or event.destination or event.ghost, event.tick)
end

local filter = {{filter = "transport-belt-connectable"}}
for _, belt_type in pairs(connectable_types) do
    filter[#filter + 1] = {filter = "ghost_type", type = belt_type}
end

script.on_event(e.on_built_entity, on_entity_modified, filter)
script.on_event(e.on_robot_built_entity, on_entity_modified, filter)
script.on_event(e.on_entity_cloned, on_entity_modified, filter)
script.on_event(e.script_raised_built, on_entity_modified, filter)
script.on_event(e.script_raised_revive, on_entity_modified, filter)
script.on_event(e.on_player_mined_entity, on_entity_modified, filter)
script.on_event(e.on_robot_mined_entity, on_entity_modified, filter)
script.on_event(e.script_raised_destroy, on_entity_modified, filter)
script.on_event(e.on_entity_died, on_entity_modified, filter)
script.on_event(e.on_pre_ghost_deconstructed, on_entity_modified, filter)

-- Splitter filter/priority pasted from another splitter
script.on_event(e.on_entity_settings_pasted, function(event)
    local entity = event.destination
    if not (entity and entity.valid and connectables[get_belt_type(entity)]) then return end
    entity_modified(entity, event.tick)
end)

-- After a rotation or flip the former neighbours are no longer linked to the entity,
-- so the highlighted belts around it have to be looked up by area
local function on_entity_reoriented(event)
    local entity = event.entity
    if not (entity and entity.valid and connectables[get_belt_type(entity)]) then return end
    local belt_type = get_belt_type(entity)
    local neighbour
    if belt_type == "underground-belt" then
        neighbour = entity.neighbours
    elseif belt_type == "linked-belt" then
        neighbour = entity.linked_belt_neighbour
    end
    local is_ghost = entity.type == "entity-ghost"
    local nearby
    for _, data in pairs(storage.data) do
        local checked = data.checked
        if checked and (data.ghost or not is_ghost) then
            local hit = highlightable(data, entity) or (neighbour and neighbour.valid and highlightable(data, neighbour))
            if not hit then
                if not nearby then
                    local box = entity.bounding_box
                    local area = {
                        {box.left_top.x - 1, box.left_top.y - 1},
                        {box.right_bottom.x + 1, box.right_bottom.y + 1},
                    }
                    local surface = entity.surface
                    nearby = surface.find_entities_filtered{area = area, type = connectable_types}
                    for _, ghost in pairs(surface.find_entities_filtered{area = area, ghost_type = connectable_types}) do
                        nearby[#nearby + 1] = ghost
                    end
                end
                for _, other in pairs(nearby) do
                    if checked[other.unit_number] then
                        hit = true
                        break
                    end
                end
            end
            if hit then schedule_refresh(data, event.tick) end
        end
    end
end

script.on_event(e.on_player_rotated_entity, on_entity_reoriented)
script.on_event(e.on_player_flipped_entity, on_entity_reoriented)

---------------------------------------------------------------------------------------------------
-- Per-tick work: refreshes, destroying old renders, drawing new ones

local function destroy_renders(budget)
    local clear_queue = storage.clear
    local per_job = math.max(math.floor(budget / table_size(clear_queue)), 1)
    for renders in pairs(clear_queue) do
        local n = #renders
        if n > 0 then
            local stop = math.max(n - per_job, 0)
            for i = n, stop + 1, -1 do
                renders[i].destroy()
                renders[i] = nil
            end
            n = stop
        end
        if n == 0 then
            -- render tables saved by older versions are keyed by render id
            local c = 0
            for id, render in pairs(renders) do
                if c >= per_job then break end
                render.destroy()
                renders[id] = nil
                c = c + 1
            end
            if not next(renders) then clear_queue[renders] = nil end
        end
    end
end

on_tick = function(event)
    local tick = event.tick
    local refresh_queue = storage.refresh
    for index, due in pairs(refresh_queue) do
        if due <= tick then
            local data = storage.data[index]
            if data then
                refresh(data)
            else
                refresh_queue[index] = nil
            end
        end
    end

    local maximum = get_highlight_maximum()
    if next(storage.clear) then
        destroy_renders(maximum * 8)
    end

    local in_progress = storage.in_progress
    if next(in_progress) then
        local max_highlights = maximum / table_size(in_progress)
        for index in pairs(in_progress) do
            local data = storage.data[index]
            if not (data and data.next_entities) then
                in_progress[index] = nil
            else
                cache_belt_line(data, max_highlights)
                local next_entities = data.next_entities
                local c = 0
                while c < max_highlights do
                    local next_index = data.next_index
                    local next_data = next_entities[next_index]
                    if not next_data then break end
                    local entity = next_data.entity
                    if entity.valid then
                        highlight_entity[get_belt_type(entity)](data, entity, next_data.lanes, next_data.path)
                        c = c + 1
                    end
                    next_entities[next_index] = nil
                    data.next_index = next_index + 1
                end
                if not next_entities[data.next_index] then finish(data) end
            end
        end
    end

    if not has_work() then set_tick_handler(false) end
end
