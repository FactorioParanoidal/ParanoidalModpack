local Event = require('__stdlib2__/stdlib/event/event').set_protected_mode(true)
local config = require('config')

local nanobots_auto_mode = settings.startup["nanobots-auto"].value

-- ----Local function forward declarations---- --
local is_connected_player_ready

--[[ EVENTS --]]
-- The Tick Handler
--- @param event on_tick
local function poll_players(event)
    local tick = event.tick
    
    --queue tasks must process every tick
    if nanobots_auto_mode then
        NanobotsAuto.process_queue_tasks(tick)
    end

    --By using modulus on poll_rate/#players, we can poll each player once per poll_rate ticks, evenly distributed.
    if tick % math.max(1, math.floor(config.POLL_RATE / #game.connected_players)) == 0 then
        local last_player, player = next(game.connected_players, storage._last_player)
        
        -- Establish player has character (i.e. has spawned)
        if is_connected_player_ready(player) then
            ArmorMods.prepare_chips(player)
        
            if nanobots_auto_mode then
                NanobotsAuto.fill_player_queue(player, tick)
            end
        end
        
        storage._last_player = last_player
    end
    
end
Event.register(defines.events.on_tick, poll_players)

-- Reset last player when players join or leave
local function players_changed()
    storage._last_player = nil
end
Event.register({ defines.events.on_player_joined_game, defines.events.on_player_left_game }, players_changed)

-- ----Local functions---- --

is_connected_player_ready = function(player)
    return player and player.character
    
    --AFK check? It was annoying (but work-around-able) for riding belts
    --And it probably saves some processing power on large servers...?
    --Eh.
end
