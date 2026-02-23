-------------------------------------------------------------------------------
--[Player Options]--
-------------------------------------------------------------------------------
local Event = require('__kry_stdlib__/stdlib/event/event')
local color = require('__kry_stdlib__/stdlib/utils/defines/color')

-- Enable alt mode on first load or when joining multiplayer game
local function set_alt_mode_option(event)
    local player = game.players[event.player_index]
    if player.mod_settings['picker-alt-mode-default'].value then
        player.game_view_settings.show_entity_info = true
    end
end
Event.register(defines.events.on_player_joined_game, set_alt_mode_option)
Event.register(defines.events.on_cutscene_cancelled, set_alt_mode_option)

-- Set player colors upon initial creation (first load, includes multiplayer)
local function set_player_color(event)
    local player = game.players[event.player_index]
    local chat = player.mod_settings["picker-chat-color"].value
    local char = player.mod_settings["picker-character-color"].value
    if chat ~= "default" then
        player.chat_color = color[chat]
    end
    if char ~= "default" then
        player.color = color[char]
    end
end
Event.register(defines.events.on_player_created, set_player_color)

-- Changes player color when modlist is modified (includes fresh install)
local function change_color_on_first_load(data)
	if game.players then if game.players[1] then
		local player = game.players[1]	-- player who loads a multiplayer game is always index 1
		local set = player.mod_settings
		local chat = set["picker-chat-color"].value
		local char = set["picker-character-color"].value
		if chat ~= "default" then
			player.chat_color = color[chat]
		end
		if char ~= "default" then
			player.color = color[char]
		end
	end end
end
Event.on_configuration_changed(change_color_on_first_load)

-- Change existing player colors when relevant mod settings are changed (during runtime)
local function change_player_color(event)
	-- Only attempt to change colors if the relevant settings were modified
	if event.setting == "picker-chat-color" or event.setting == "picker-character-color" then
		local player = game.players[event.player_index]
		local chat = player.mod_settings["picker-chat-color"].value
		local char = player.mod_settings["picker-character-color"].value
		player.chat_color = color[chat]
		player.color = color[char]
	end
end
Event.register(defines.events.on_runtime_mod_setting_changed, change_player_color)