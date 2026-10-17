-- Event dispatcher: several handlers per event, optional event filters, delayed function calls.

local events = {}     -- event id or custom input name -> {handlers = {}, filters = {}, unfiltered = bool}
local nth_ticks = {}  -- tick interval -> handlers
local ON_INIT = "ON INIT EVENT"

local function filter_key(filter)
    return tostring(filter.filter) .. "|" .. tostring(filter.type) .. "|" .. tostring(filter.name) .. "|" .. tostring(filter.mode) .. "|" .. tostring(filter.invert)
end

---Drop-in replacement for script.on_event that supports multiple handlers per event.
---`event` may also be one of the factorissimo.events groups.
---`filters` (optional) is an event filter array. The event is registered with the union of the filters
---of all its handlers; if any handler of the event is registered without filters, the event is unfiltered.
---Handlers must still check their own conditions: they also receive entities matched by other handlers' filters.
---@param event defines.events|defines.events[]|string
---@param f function
---@param filters table?
factorissimo.on_event = function(event, f, filters)
    for _, e in pairs(type(event) == "table" and event or {event}) do
        local entry = events[e]
        if not entry then
            entry = {handlers = {}, handler_filters = {}, filters = {}, seen = {}, unfiltered = false}
            events[e] = entry
        end
        entry.handlers[#entry.handlers + 1] = f
        entry.handler_filters[#entry.handlers] = filters or false
        if filters then
            for _, filter in pairs(filters) do
                local key = filter_key(filter)
                if not entry.seen[key] then
                    entry.seen[key] = true
                    entry.filters[#entry.filters + 1] = filter
                end
            end
        else
            entry.unfiltered = true
        end
    end
end

factorissimo.on_nth_tick = function(tick, f)
    nth_ticks[tick] = nth_ticks[tick] or {}
    table.insert(nth_ticks[tick], f)
end

local function one_function_from_many(functions)
    local l = #functions
    if l == 1 then return functions[1] end

    return function(arg)
        for i = 1, l do
            functions[i](arg)
        end
    end
end

_G.gui_events = {
    [defines.events.on_gui_click] = {},
    [defines.events.on_gui_confirmed] = {},
    [defines.events.on_gui_text_changed] = {},
    [defines.events.on_gui_checked_state_changed] = {},
    [defines.events.on_gui_selection_state_changed] = {},
    [defines.events.on_gui_elem_changed] = {},
    [defines.events.on_gui_value_changed] = {},
    [defines.events.on_gui_location_changed] = {},
    [defines.events.on_gui_selected_tab_changed] = {},
    [defines.events.on_gui_switch_state_changed] = {}
}
local function process_gui_event(event)
    local element = event.element
    if element and element.valid then
        local name = element.name
        for pattern, f in pairs(gui_events[event.name]) do
            if name:match(pattern) then
                f(event); return
            end
        end
    end
end

--- Lua-side check of the simple filters this mod uses (type / name / ghost_type / ghost_name, "or" mode).
--- Returns nil when the filters cannot be checked here; the handler then always runs.
local function compile_filters(filters)
    local compiled = {types = {}, names = {}, ghost_types = {}, ghost_names = {}}
    for _, filter in pairs(filters) do
        if filter.invert or filter.mode == "and" then return nil end
        local kind = filter.filter
        if kind == "type" then
            compiled.types[filter.type] = true
        elseif kind == "name" then
            compiled.names[filter.name] = true
        elseif kind == "ghost_type" then
            compiled.ghost_types[filter.type] = true
        elseif kind == "ghost_name" then
            compiled.ghost_names[filter.name] = true
        else
            return nil
        end
    end
    return compiled
end

--- For an event the engine delivers unfiltered (one of its handlers needs every entity), handlers that
--- registered filters are called only for entities matching them.
local function prefiltered_function(entry)
    local handlers, checks, n = entry.handlers, {}, #entry.handlers
    local any = false
    for i = 1, n do
        local filters = entry.handler_filters[i]
        checks[i] = filters and compile_filters(filters) or false
        if checks[i] then any = true end
    end
    if not any then return one_function_from_many(handlers) end

    return function(event)
        local entity = event.entity
        local etype, ename, gtype, gname
        if entity and entity.valid then
            etype, ename = entity.type, entity.name
            if etype == "entity-ghost" then gtype, gname = entity.ghost_type, entity.ghost_name end
        end
        for i = 1, n do
            local check = checks[i]
            if not check or not etype
                or check.types[etype] or check.names[ename]
                or (gtype and (check.ghost_types[gtype] or check.ghost_names[gname])) then
                handlers[i](event)
            end
        end
    end
end

local finalized = false
factorissimo.finalize_events = function()
    if finalized then error("Events already finalized") end

    -- GUI events are registered only when some file added a handler pattern for them.
    for event, patterns in pairs(gui_events) do
        if next(patterns) then factorissimo.on_event(event, process_gui_event) end
    end

    local i = 0
    for event, entry in pairs(events) do
        local f = one_function_from_many(entry.handlers)
        if event == ON_INIT then
            script.on_init(f)
            script.on_configuration_changed(f)
            i = i + 1
        elseif entry.unfiltered then
            script.on_event(event, prefiltered_function(entry))
            i = i + 1
        elseif entry.filters[1] then
            script.on_event(event, f, entry.filters)
            i = i + 1
        end
        -- Otherwise every handler asked for filters that match no prototype: nothing to listen to.
    end
    for tick, functions in pairs(nth_ticks) do
        script.on_nth_tick(tick, one_function_from_many(functions))
        i = i + 1
    end
    finalized = true
    log("Finalized " .. i .. " events for " .. script.mod_name)
end

-- DELAYED FUNCTIONS --

local delayed_functions = {}
local max = math.max
local floor = math.floor
local unpack = table.unpack

---Registers a function that can be executed later with factorissimo.execute_later.
---@param key string
---@param func function
function factorissimo.register_delayed_function(key, func)
    delayed_functions[key] = func
end

local function run_delayed_function(key, args)
    local f = delayed_functions[key]
    if not f then error("No function found for key: " .. tostring(key)) end
    f(unpack(args, 1, args.n or #args))
end

---use this to execute a script after a delay
---example:
---factorissimo.register_delayed_function('my_delayed_func', function(param1, param2, param3) ... end)
---factorissimo.execute_later('my_delayed_func', 60, param1, param2, param3)
---The above code will execute my_delayed_func after waiting for 60 ticks
---@param function_key string
---@param ticks integer
---@param ... any
function factorissimo.execute_later(function_key, ticks, ...)
    local scheduled = storage._scheduled_functions
    if not scheduled then
        scheduled = {}
        storage._scheduled_functions = scheduled
    end
    local tick = game.tick + max(1, floor(ticks or 1))
    local list = scheduled[tick]
    if not list then
        list = {}
        scheduled[tick] = list
    end
    list[#list + 1] = {function_key, table.pack(...)}
end

factorissimo.on_event(defines.events.on_tick, function(event)
    local scheduled = storage._scheduled_functions
    if not scheduled then return end
    local tick = event.tick
    local list = scheduled[tick]
    if not list then return end
    scheduled[tick] = nil
    for i = 1, #list do
        local entry = list[i]
        run_delayed_function(entry[1], entry[2])
    end
end)

-- Calls scheduled before the tick-based scheduler used render objects with on_object_destroyed.
factorissimo.on_event(defines.events.on_object_destroyed, function(event)
    local legacy = storage._delayed_functions
    if not legacy then return end
    local registration_number = event.registration_number
    local data = legacy[registration_number]
    if not data then return end
    legacy[registration_number] = nil
    if not next(legacy) then storage._delayed_functions = nil end
    run_delayed_function(data[1], data[2])
end)

factorissimo.on_event(ON_INIT, function()
    -- Entries for ticks that already passed (cannot normally happen) are moved to the next tick instead of leaking.
    local scheduled = storage._scheduled_functions
    if not scheduled then return end
    local now = game.tick
    local overdue = {}
    for tick in pairs(scheduled) do
        if tick <= now then overdue[#overdue + 1] = tick end
    end
    if not overdue[1] then return end
    table.sort(overdue)
    local target = scheduled[now + 1] or {}
    scheduled[now + 1] = target
    for _, tick in ipairs(overdue) do
        for _, entry in ipairs(scheduled[tick]) do target[#target + 1] = entry end
        scheduled[tick] = nil
    end
end)

--- Sentinel values for defining groups of events
factorissimo.events = {
    --- Called after an entity is constructed.
    on_built = function()
        return {
            defines.events.on_built_entity,
            defines.events.on_robot_built_entity,
            defines.events.script_raised_built,
            defines.events.script_raised_revive,
            defines.events.on_space_platform_built_entity,
        }
    end,
    --- Called after the results of an entity being mined are collected just before the entity is destroyed. [...]
    on_destroyed = function()
        return {
            defines.events.on_player_mined_entity,
            defines.events.on_robot_mined_entity,
            defines.events.on_entity_died,
            defines.events.script_raised_destroy,
            defines.events.on_space_platform_mined_entity
        }
    end,
    --- Called after a tile is built.
    on_built_tile = function()
        return {
            defines.events.on_robot_built_tile,
            defines.events.on_player_built_tile,
            defines.events.on_space_platform_built_tile,
        }
    end,
    on_mined_tile = function()
        return {
            defines.events.on_player_mined_tile,
            defines.events.on_robot_mined_tile,
            defines.events.on_space_platform_mined_tile,
        }
    end,
    --- Called for on_init and on_configuration_changed
    on_init = function()
        return ON_INIT
    end,
}

---Builds an entity event filter array from entity type names, skipping types that have no prototypes
---(the engine rejects filters with unknown types). A value of `types` that is not a type but an entity
---name is added as a name filter.
---@param types string[]
---@param names string[]?
---@return table
function factorissimo.entity_filters(types, names)
    local existing = factorissimo.existing_entity_types()
    local entities = prototypes.entity
    local filters = {}
    for _, t in pairs(types) do
        if existing[t] then
            filters[#filters + 1] = {filter = "type", type = t}
        elseif entities[t] then
            filters[#filters + 1] = {filter = "name", name = t}
        end
    end
    for _, name in pairs(names or {}) do
        if entities[name] then filters[#filters + 1] = {filter = "name", name = name} end
    end
    return filters
end

---Same as factorissimo.entity_filters, but matches ghosts of these entity types or names.
---@param types string[]
---@param names string[]?
---@return table
function factorissimo.ghost_filters(types, names)
    local filters = {}
    for _, filter in pairs(factorissimo.entity_filters(types, names)) do
        if filter.filter == "type" then
            filters[#filters + 1] = {filter = "ghost_type", type = filter.type}
        else
            filters[#filters + 1] = {filter = "ghost_name", name = filter.name}
        end
    end
    return filters
end

---Concatenates filter arrays.
function factorissimo.join_filters(...)
    local result = {}
    for _, filters in pairs {...} do
        for _, filter in pairs(filters) do result[#result + 1] = filter end
    end
    return result
end

local existing_entity_types
function factorissimo.existing_entity_types()
    if not existing_entity_types then
        existing_entity_types = {}
        for _, prototype in pairs(prototypes.entity) do
            existing_entity_types[prototype.type] = true
        end
    end
    return existing_entity_types
end
