local start = require("scripts.start")
local mining = require("scripts.mining")
local generator = require("scripts.generator")

local function state()
    local s = storage.shipwreck
    if not s then
        s = {qualities = {}, start = {}, targets = {}}
        storage.shipwreck = s
    end
    return s
end

script.on_init(function()
    start.init(state())
    generator.refresh()
end)

script.on_configuration_changed(function()
    state()
    generator.refresh()
end)

script.on_event(defines.events.on_player_created, function(event)
    start.on_player_created(state(), event)
end)

-- Every 5 ticks: the start fill tolerates the delay and the wreck selection lag (83 ms) is invisible.
script.on_nth_tick(5, function(event)
    local s = storage.shipwreck
    if not s then return end
    start.on_tick(s, event.tick)
    mining.on_tick(s)
end)

local mined_filters = mining.filters()
if not mined_filters[1] then mined_filters = nil end
local function on_mined(event) mining.on_mined(state(), event) end
script.on_event(defines.events.on_player_mined_entity, on_mined, mined_filters)
script.on_event(defines.events.on_robot_mined_entity, on_mined, mined_filters)
script.on_event(defines.events.on_pre_player_mined_item, function(event)
    mining.on_pre_player_mined(state(), event)
end, mined_filters)
script.on_event(defines.events.on_object_destroyed, function(event)
    local s = storage.shipwreck
    if s then mining.on_destroyed(s, event) end
end)

local built_filters = generator.filters()
if built_filters then
    for _, name in ipairs({"on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive"}) do
        script.on_event(defines.events[name], generator.on_built, built_filters)
    end
    script.on_event(defines.events.on_entity_cloned, generator.on_built, built_filters)
end
