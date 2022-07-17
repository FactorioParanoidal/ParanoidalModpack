-------------------------------------------------------------------------------
--[[on-tick queue]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela
--[[

To add your mod to the queue copy the following code somewhere in your mod at a point where it's been determined that the work needs to be distributed:
--STDLIB-----------------------------------------------------------------------
local token = remote.call("PickerAtheneum","queue_add",{mod_name = "YourModName_QueuedTaskAbbreviation"}) --The additional queued task abbreviation allows you to queue multiple things within the same mod
global.remote_queue_token = token
Event.register(token, function_to_call_each_turn)
--NO STD LIB-------------------------------------------------------------------
local token = remote.call("PickerAtheneum","queue_add",{mod_name = "YourModName_QueuedTaskAbbreviation"}) --The additional queued task abbreviation allows you to queue multiple things within the same mod
global.remote_queue_token = token
script.on_event(token, function_to_call_each_turn)


To remove your mod from the queue and de-register the listener, add this code somewhere in your mod once the work is done:
--STDLIB-----------------------------------------------------------------------
remote.call("PickerAtheneum","queue_remove",{token = global.remote_queue_token})
--NO STD LIB-------------------------------------------------------------------
remote.call("PickerAtheneum","queue_remove",{token = global.remote_queue_token})

]]
local Event = require('__stdlib__/stdlib/event/event')
local Interface = require('__stdlib__/stdlib/scripts/interface')
local Queue = require('__stdlib__/stdlib/misc/queue')

local options = {
    protected_mode = false,
    skip_valid = true
}

--Cycle through the array stored in global one time per tick and perform remote.call with the mod name and function name provided during "queue_add"
local function queue_tick()
    local queue = global.remote_queue:pop_and_push()
    if queue then
        if remote.interfaces[queue.interface] and remote.interfaces[queue.interface][queue.func_name] then
            remote.call(queue.interface, queue.func_name)
        else
            Interface.queue_remove(queue.interface, queue.func_name)
        end
    end
end

--Add a mod to the queue. Initializes the queue system if it isn't running. A mod calls remote.call and provides a table with name and f_name parameters, and it is stored in a global array.
--@tparam name The name of the calling mod
--@tparam f_name The name of the function assigned to the interface in the remote mod
Interface['queue_add'] = function(interface, func_name)
    if not global.remote_queue then
        global.remote_queue = Queue()
        Event.register(defines.events.on_tick, queue_tick, nil, nil, options)
    end
    global.remote_queue {interface = interface, func_name = func_name}
    return true
end

--Remove a mod from the queue. Searches for the relevant mod by the provided name from the remote.call and removes the entry from the queue. Also makes sure index stays within bounds. Also unregisters the on_tick handler if the queue is empty.
--@tparam name The name of the calling mod
Interface['queue_remove'] = function(interface, func_name)
    if global.remote_queue then
        for k, v in global.remote_queue:pairs() do
            if v.interface == interface and v.func_name == func_name then
                global.remote_queue.objects[k] = nil
            end
        end
        global.remote_queue:sort()
        if #global.remote_queue == 0 then -- Check if queue is empty
            global.remote_queue = nil
            Event.remove(defines.events.on_tick, queue_tick) -- Unregister event handler if empty
        end
        return true
    end
    return false
end

local function on_load()
    if global.remote_queue then
        Queue.load(global.remote_queue)
        Event.register(defines.events.on_tick, queue_tick, nil, nil, options)
    end
end
Event.on_load(on_load)
