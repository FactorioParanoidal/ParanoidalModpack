local Player = require('__stdlib__/stdlib/event/player')
-------------------------------------------------------------------------------
--[Lights]--
-------------------------------------------------------------------------------
--Code modified from Searching-flashlights, by RK84
local Event = require('__stdlib__/stdlib/event/event')
local atan2, pi, floor = math.atan2, math.pi, math.floor

local function orient_players(event)
    local player, pdata = Player.get(event.player_index)
    if (pdata.last_sel_tick or 0) <= (game.tick - 10) and player.selected and player.character and not player.vehicle and not player.walking_state.walking then
        if player.mod_settings['picker-search-light'].value then
            --Code optimization by GotLag
            local dx = player.position.x - player.selected.position.x
            local dy = player.selected.position.y - player.position.y
            local orientation = (atan2(dx, dy) / pi + 1) / 2
            player.character.direction = floor(orientation * 8 + 0.5) % 8
            pdata.last_sel_tick = game.tick
        end
    end
end
Event.register(defines.events.on_selected_entity_changed, orient_players)

-------------------------------------------------------------------------------
--[Flashlight on/off]--
-------------------------------------------------------------------------------
--Code from: "Flashlight On Off", by: "devilwarriors",
local function toggle_flashlight(event)
    local player, pdata = Player.get(event.player_index)

    if player.character then
        if pdata.flashlight_off then
            pdata.flashlight_off = nil
            player.character.enable_flashlight()
        else
            pdata.flashlight_off = true
            player.character.disable_flashlight()
        end
        player.play_sound({path = 'utility/wire_connect_pole', position = player.position, volume = 1})
    end
end
Event.register('picker-flashlight-toggle', toggle_flashlight)
