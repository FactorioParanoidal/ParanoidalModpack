-------------------------------------------------------------------------------
--[Player Searchlight]--
-------------------------------------------------------------------------------
--Code originally modified from Searching-flashlights, by RK84
local events = require('utils/events')
local lib = require('utils/lib')
local atan2, pi, floor = math.atan2, math.pi, math.floor

local function orient_players(event)
    local player, pdata = lib.get_player(event.player_index)
    local character = player.character
    if character and (pdata.last_sel_tick or 0) <= (game.tick - 10) and player.selected and not player.vehicle and not player.walking_state.walking then
        if player.mod_settings['picker-search-light'].value then
            --Code optimization by GotLag
            local ppos, spos = player.position, player.selected.position
            local dx = ppos.x - spos.x
            local dy = spos.y - ppos.y
            local orientation = (atan2(dx, dy) / pi + 1) / 2
            character.direction = floor(orientation * 16 + 0.5) % 16
            pdata.last_sel_tick = game.tick
        end
    end
end
events.on(defines.events.on_selected_entity_changed, orient_players)
