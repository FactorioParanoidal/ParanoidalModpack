local Event = require('__stdlib__/stdlib/event/event')

-- (( Switch player gun while driving ))--
local function switch_player_gun_while_driving(event)
    local player = game.players[event.player_index]
    local character = player.character
    if character and player.vehicle then
        local index = character.selected_gun_index
        local gun_inv = character.get_inventory(defines.inventory.character_guns)
        local start = index
        repeat
            index = index < #gun_inv and (index + 1) or 1
            if gun_inv[index].valid_for_read then
                character.selected_gun_index = index
                break
            end
        until index == start
    end
end
Event.register('switch-player-gun-while-driving', switch_player_gun_while_driving)
