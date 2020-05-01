local Event = require('__stdlib__/stdlib/event/event')

-- Code from: "Flashlight On Off", by: "devilwarriors",
local function toggle_flashlight(event)
    local player = game.get_player(event.player_index)
    local character = player.character

    if character then
        if character.is_flashlight_enabled() then
            character.disable_flashlight()
        else
            character.enable_flashlight()
        end
        player.play_sound({path = 'utility/wire_connect_pole', position = player.position, volume = 1})
    end
end
Event.register('toggle-flashlight', toggle_flashlight)
