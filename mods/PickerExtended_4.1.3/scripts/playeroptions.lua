local Event = require('__stdlib__/stdlib/event/event')
local color = require('__stdlib__/stdlib/utils/defines/color')

local function set_join_options(event)
    local player = game.players[event.player_index]
    if player.mod_settings['picker-alt-mode-default'].value then
        player.game_view_settings.show_entity_info = true
    end
end
Event.register(defines.events.on_player_joined_game, set_join_options)

local function set_player_color(event)
    local player = game.players[event.player_index]
    local set = player.mod_settings
    local chat = set["picker-chat-color"].value
    local char = set["picker-character-color"].value
    if chat ~= "default" then
        player.chat_color = color[chat]
    end
    if char ~= "default" then
        player.color = color[char]
    end
end
Event.register(defines.events.on_player_created, set_player_color)
