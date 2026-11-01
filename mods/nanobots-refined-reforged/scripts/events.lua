-------------------------------------------------------------------------------
--[[Events]] -- Minimal event registry (Paranoidal; replaces the stdlib2 dispatcher).
-------------------------------------------------------------------------------
-- Several handlers of one event run in registration order. As in the stdlib protected mode, a
-- handler error is logged and printed to the connected players instead of ending the game; with
-- nobody connected (or in on_load) it is raised.

local events = {}

local registry = {}
local mod_name = script.mod_name

local function report(err)
    local msg = tostring(err)
    if game and #game.connected_players > 0 then
        log(mod_name .. ':' .. msg)
        game.print(msg)
    else
        log(msg)
        error(msg, 0)
    end
end

local function run(list, event)
    for i = 1, #list do
        local ok, err = pcall(list[i], event)
        if not ok then
            report(err)
        end
    end
end

local bootstrap = {
    on_init = function(list)
        script.on_init(function()
            run(list, {name = 'on_init', tick = game.tick})
        end)
    end,
    on_load = function(list)
        script.on_load(function()
            run(list, {name = 'on_load', tick = -1})
        end)
    end,
    on_configuration_changed = function(list)
        script.on_configuration_changed(function(event)
            event.name = 'on_configuration_changed'
            run(list, event)
        end)
    end
}

--- Register a handler for one event id or an array of ids: defines.events, a custom-input name, or
--- 'on_init' / 'on_load' / 'on_configuration_changed'.
function events.on(ids, handler)
    if type(ids) ~= 'table' then
        ids = {ids}
    end
    for _, id in ipairs(ids) do
        local list = registry[id]
        if not list then
            list = {}
            registry[id] = list
            if bootstrap[id] then
                bootstrap[id](list)
            else
                script.on_event(id, function(event)
                    run(list, event)
                end)
            end
        end
        list[#list + 1] = handler
    end
end

--- Run the handlers registered for `id` with a script-made event table.
function events.dispatch(id, event)
    local list = registry[id]
    if list then
        event = event or {}
        event.name = event.name or id
        event.tick = event.tick or (game and game.tick) or 0
        run(list, event)
    end
end

events.build_events = {
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
    defines.events.on_entity_cloned
}

events.mined_events = {
    defines.events.on_pre_player_mined_item,
    defines.events.on_robot_pre_mined,
    defines.events.script_raised_destroy
}

return events
