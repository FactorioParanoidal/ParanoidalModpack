local events = {}

---Drop-in replacement for script.on_event however it supports multiple handlers per event. You can also use 'on_built' 'on_destroyed' and 'on_init' as shortcuts for multiple events.
---@param event defines.events|defines.events[]|string
---@param f function
factorissimo.on_event = function(event, f)
    for _, event in pairs(type(event) == "table" and event or {event}) do
        event = tostring(event)
        events[event] = events[event] or {}
        table.insert(events[event], f)
    end
end

factorissimo.on_nth_tick = function(event, f)
    events[event] = events[event] or {}
    table.insert(events[event], f)
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

local powers_of_two = {}
for i = 0, 20 do
    powers_of_two[i] = 2 ^ i
end

local finalized = false
factorissimo.finalize_events = function()
    if finalized then error("Events already finalized") end
    local i = 0
    for event, functions in pairs(events) do
        local f = one_function_from_many(functions)
        if type(event) == "number" then
            script.on_nth_tick(event, f)
        elseif event == factorissimo.events.on_init() then
            script.on_init(f)
            script.on_configuration_changed(f)
        else
            script.on_event(tonumber(event) or event, f)
        end
        i = i + 1
    end
    finalized = true
    log("Finalized " .. i .. " events for " .. script.mod_name)
end

_G.gui_events = {
    [defines.events.on_gui_click] = {},
    [defines.events.on_gui_confirmed] = {},
    [defines.events.on_gui_text_changed] = {},
    [defines.events.on_gui_checked_state_changed] = {},
    [defines.events.on_gui_selection_state_changed] = {},
    [defines.events.on_gui_checked_state_changed] = {},
    [defines.events.on_gui_elem_changed] = {},
    [defines.events.on_gui_value_changed] = {},
    [defines.events.on_gui_location_changed] = {},
    [defines.events.on_gui_selected_tab_changed] = {},
    [defines.events.on_gui_switch_state_changed] = {}
}
local function process_gui_event(event)
    if event.element and event.element.valid then
        for pattern, f in pairs(gui_events[event.name]) do
            if event.element.name:match(pattern) then
                f(event); return
            end
        end
    end
end

for event, _ in pairs(gui_events) do
    factorissimo.on_event(event, process_gui_event)
end

local delayed_functions = {}
---use this to execute a script after a delay
---example:
---factorissimo.register_delayed_function('my_delayed_func', function(param1, param2, param3) ... end)
---factorissimo.execute_later('my_delayed_func', 60, param1, param2, param3)
---The above code will execute my_delayed_func after waiting for 60 ticks
---@param function_key string
---@param ticks integer
---@param ... any
function factorissimo.execute_later(function_key, ticks, ...)
    local marked_for_death_render_object = rendering.draw_line {
        color = {0, 0, 0, 0},
        width = 0,
        filled = false,
        from = {0, 0},
        to = {0, 0},
        create_build_effect_smoke = false,
        surface = "nauvis",
        time_to_live = ticks
    }
    storage._delayed_functions = storage._delayed_functions or {}
    storage._delayed_functions[script.register_on_object_destroyed(marked_for_death_render_object)] = {function_key, {...}}
end

factorissimo.on_event(defines.events.on_object_destroyed, function(event)
    if not storage._delayed_functions then return end
    local registration_number = event.registration_number
    local data = storage._delayed_functions[registration_number]
    if not data then return end
    storage._delayed_functions[registration_number] = nil

    local f = delayed_functions[data[1]]
    if not f then error("No function found for key: " .. function_key) end
    f(table.unpack(data[2]))
end)

function factorissimo.register_delayed_function(key, func)
    delayed_functions[key] = func
end

--- Sentinel values for defining groups of events
factorissimo.events = {
    --- Called after an entity is constructed.
    --- Note: Using this event may be bad practice. Consider instead defining `created_effect` in the entity prototype.
    ---
    --- entity.created_effect = {
    --- 	type = 'direct',
    --- 	action_delivery = {
    --- 		type = 'instant',
    --- 		source_effects = {
    --- 			type = 'script',
    --- 			effect_id = 'on_built_[ENTITY NAME]'
    --- 		}
    --- 	}
    --- }
    on_built = function()
        return {
            defines.events.on_built_entity,
            defines.events.on_robot_built_entity,
            defines.events.script_raised_built,
            defines.events.script_raised_revive,
            defines.events.on_space_platform_built_entity,
            defines.events.on_biter_base_built
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
        return "ON INIT EVENT"
    end,
    --- Custom event for when a player clicks on an entity
    on_entity_clicked = function()
        return "build"
    end
}
