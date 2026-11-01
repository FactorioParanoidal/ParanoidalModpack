local interface = require('interface')

local function commands_handler(event)
    local player = game.players[event.player_index]
    if player.admin then
        local params = {}
        for word in (event.parameter or ''):gmatch('%S+') do
            params[#params + 1] = word
        end
        if params[1] == 'reset' then
            if params[2] == 'mod' then
                interface.reset_mod(true)
            elseif params[2] == 'cell_queue' then
                interface.reset_queue('cell_queue')
            elseif params[2] == 'nano_queue' then
                interface.reset_queue('nano_queue')
            end
        elseif params[1] == 'count' then
            interface.count_queue(params[2])
        end
    end
end

return commands_handler
