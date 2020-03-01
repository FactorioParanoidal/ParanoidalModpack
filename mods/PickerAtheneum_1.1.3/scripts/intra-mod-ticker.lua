-- Mods can directly require this file to set up an intra mod event ticker. (only ticks for that mod)

local Event = require('__stdlib__/stdlib/event/event')
local Queue = require('__stdlib__/stdlib/misc/queue')

local tick_options = {
    protected_mode = true,
    skip_valid = true
}

local function on_tick()
    if global.tick_queue then
        local queue = global.tick_queue() -- pop goes the weasel
        if queue then
            if queue.event_name then
                Event.raise_event(queue.event_name, queue)
            end
        else
            Event.remove(defines.events.on_tick, on_tick)
            global.tick_queue = nil
        end
    else
        Event.remove(defines.events.on_tick, on_tick)
    end
end

local function start_tick(queue)
    if not global.tick_queue then
        global.tick_queue = Queue()
        Event.on_event(defines.events.on_tick, on_tick, nil, nil, tick_options)
    end
    global.tick_queue(queue)
end

local function on_load()
    if global.tick_queue then
        Queue.load(global.tick_queue)
        Event.on_event(defines.events.on_tick, on_tick, nil, nil, tick_options)
    end
end
Event.on_load(on_load)

return start_tick
