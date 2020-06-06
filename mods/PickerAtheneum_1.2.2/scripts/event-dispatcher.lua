local Event = require('__stdlib__/stdlib/event/event')
local Interface = require('__stdlib__/stdlib/scripts/interface')
--local Queue = require('__stdlib__/stdlib/misc/queue')

local tick_options = {
    protected_mode = true,
    skip_valid = true
}

-- On load/init other mod calls this and then registers for the event
function Interface.generate_event_name(string_id)
    --Event.custom_events[event_name]
    return Event.generate_event_name(string_id)
end

--Cycle through the array stored in global one time per tick and perform remote.call with the mod name and function name provided during "queue_add"
local function queue_tick()
    if global.event_queue then
        local index, queue = next(global.event_queue, global.current_event_index)
        if global.current_event_index and not index then
            index, queue = next(global.event_queue, nil)
        end
        global.current_event_index = index
        if queue then
            local ID = Event.get_event_name(queue.event_name)
            if ID then
                Event.raise_event(ID, queue)
            else
                Interface.queue_remove(queue.event_name)
            end
        end
    else
        Event.remove(defines.events.on_tick, queue_tick)
    end
end

-- add to queue
function Interface.event_queue_add(string_id, data, options)
    if not global.event_queue then
        global.event_queue = {}
        Event.register(defines.events.on_tick, queue_tick, nil, nil, tick_options)
    end
    local id = Event.get_event_name(string_id)
    if id then
        global.event_queue[string_id]={event_name = string_id, name = id, data = data, options = options}
        global.current_event_index = nil
        return true
    end
end

-- Remove from queue
function Interface.event_queue_remove(string_id)
    if global.event_queue and global.event_queue[string_id] then
        global.event_queue[string_id] = nil
        global.current_event_index = nil
        if not next(global.event_queue) then
            global.event_queue = nil
            Event.remove(defines.events.on_tick, queue_tick)
        end
    end
end

local function on_load()
    if global.event_queue then
        Event.register(defines.events.on_tick, queue_tick, nil, nil, tick_options)
    end
end
Event.on_load(on_load)
