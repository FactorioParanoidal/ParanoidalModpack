local events = require('scripts/events')
local Queue = require('scripts/hash_queue')
local interface = {}

-- Queue resets, run by reset_queue(name); scripts/roboport-interface.lua adds 'cell_queue'.
interface.queue_resets = {}

function interface.reset_mod(are_you_sure)
    local player_name = game.player and game.player.name or 'script'
    if are_you_sure then
        storage = {}
        events.dispatch('on_init')
        game.print('Full Reset Completed by ' .. player_name)
    else
        game.print('Full reset attempted but ' .. player_name .. ' was not sure')
    end
end

function interface.reset_queue(queue)
    queue = queue or 'nano_queue'
    local reset = interface.queue_resets[queue]
    if storage[queue] and reset then
        game.print('Resetting ' .. queue)
        reset()
    end
end

function interface.count_queue(queue)
    queue = queue or 'nano_queue'
    if storage[queue] then
        local a, b = Queue.count(storage[queue])
        game.print('Queued:' .. a .. ' Hashed:' .. b)
    end
end

return interface
