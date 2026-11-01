-------------------------------------------------------------------------------
--[[Events]] -- Minimal event registry: one engine registration per event for the whole mod.
-------------------------------------------------------------------------------
-- Several handlers of one event run in registration order. Handlers are called directly: an error
-- ends the game with its own traceback instead of being printed and leaving a half-done action.
-- on_tick is not managed here: the item count registers it itself while a blueprint preview loads.

local events = {}

local registry = {}

local function runner(list)
    if #list == 1 then
        return list[1]
    end
    return function(event)
        for i = 1, #list do
            list[i](event)
        end
    end
end

local bootstrap = {
    on_init = function(list)
        script.on_init(function()
            for i = 1, #list do
                list[i]()
            end
        end)
    end,
    on_load = function(list)
        script.on_load(function()
            for i = 1, #list do
                list[i]()
            end
        end)
    end,
    on_configuration_changed = function(list)
        script.on_configuration_changed(function(event)
            for i = 1, #list do
                list[i](event)
            end
        end)
    end
}

local lists = {}

--- Register a handler for one event id or an array of ids: defines.events, a custom-input name, or
--- 'on_init' / 'on_load' / 'on_configuration_changed'. Engine registration happens in events.finish().
function events.on(ids, handler)
    if type(ids) ~= 'table' then
        ids = {ids}
    end
    for _, id in ipairs(ids) do
        local list = registry[id]
        if not list then
            list = {}
            registry[id] = list
            lists[#lists + 1] = id
        end
        list[#list + 1] = handler
    end
end

--- Register every collected event with the engine; called once at the end of control.lua.
function events.finish()
    for _, id in ipairs(lists) do
        local list = registry[id]
        if bootstrap[id] then
            bootstrap[id](list)
        else
            script.on_event(id, runner(list))
        end
    end
end

--- Register a GUI handler for elements whose name matches `pattern`; event.match holds the
--- match, as with the kry_stdlib Gui module.
local function on_gui(id, pattern, handler)
    events.on(id, function(event)
        local element = event.element
        if element and element.valid then
            local match = element.name:match(pattern)
            if match then
                event.match = match
                return handler(event, match)
            end
        end
    end)
end

function events.on_click(pattern, handler)
    on_gui(defines.events.on_gui_click, pattern, handler)
end

function events.on_confirmed(pattern, handler)
    on_gui(defines.events.on_gui_confirmed, pattern, handler)
end

return events
