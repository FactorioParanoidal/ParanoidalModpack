-- Mods can directly require this file to set up an intra mod event ticker. (only ticks for that mod)

local Event = require('__stdlib__/stdlib/event/event')
local Queue = require('__stdlib__/stdlib/misc/queue')

local tick_options = {
    protected_mode = true,
    skip_valid = true
}

local function on_tick()
    if global.tick_queue then
        -- Pop an event off the queue
        local event = global.tick_queue()
        if event then
            Event.raise_event(event.name, event)
        else
            Event.remove(defines.events.on_tick, on_tick)
            global.tick_queue = nil
        end
    else
        Event.remove(defines.events.on_tick, on_tick)
    end
end

local function push_tick(event)
    if not global.tick_queue then
        global.tick_queue = Queue()
        Event.on_event(defines.events.on_tick, on_tick, nil, nil, tick_options)
    end
    -- Push an event into the queue
    global.tick_queue(event)
end

-- On load,  load the metatable into the queue if it exsits and start the ticker
local function on_load()
    if global.tick_queue then
        Queue.load(global.tick_queue)
        Event.on_event(defines.events.on_tick, on_tick, nil, nil, tick_options)
    end
end
Event.on_load(on_load)

return push_tick
