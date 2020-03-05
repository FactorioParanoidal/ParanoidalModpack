local Event = require('__stdlib__/stdlib/event/event')
local Queue = require('scripts/hash_queue')
local interface = {}

function interface.reset_mod(are_you_sure)
    local player_name = game.player and game.player.name or 'script'
    if are_you_sure then
        global = {}
        Event.dispatch({name = Event.core_events.init})
        game.print('Full Reset Completed by ' .. player_name)
    else
        game.print('Full reset attempted but ' .. player_name .. ' was not sure')
    end
end

function interface.reset_queue(queue)
    queue = queue or 'nano_queue'
    local name = 'reset_' .. queue
    local id = Event.get_event_name(name)
    if global[queue] and id then
        game.print('Resetting ' .. queue)
        Event.dispatch({name = id})
    end
end

function interface.count_queue(queue)
    queue = queue or 'nano_queue'
    if global[queue] then
        local a, b = Queue.count(global[queue])
        game.print('Queued:' .. a .. ' Hashed:' .. b)
    end
end

return interface
