local event = require("__flib__.event")
local dictionary = require("__flib__.dictionary")
local migration = require("__flib__.migration")
local Smarts = require("smarts")

---@alias Player_dictionaries table<int, Item_types>
---@alias Item_types table<string, Item_names>
---@alias Item_names table<string, string>

local function create_dictionaries()
    for _, type in pairs { "entity", "fluid", "item", "recipe", "technology", "tile", "virtual_signal" } do
        -- If the object's name doesn't have a translation, use its internal name as the translation
        local Names = dictionary.new(type, true)
        for name, prototype in pairs(game[type .. "_prototypes"]) do
            Names:add(name, prototype.localised_name)
        end
    end
end

local function init_globals()
    -- enity_deta_data

    global.event_backup = global.event_backup or {}
    global.entity_data = global.entity_data or {} ---@type table<uint, EntityData>
    global.player_dictionaries = global.player_dictionaries or {} ---@type Player_dictionaries
end

local function on_init()
    init_globals()
    dictionary.init()
    create_dictionaries()
end

local function on_configuration_changed(e)
    init_globals()
    if migration.on_config_changed(e, {}) then
        -- Reset the module to effectively cancel all ongoing translations and wipe all dictionaries
        dictionary.init()
        create_dictionaries()

        -- Request translations for all connected players
        for _, player in pairs(game.players) do
            if player.connected then
                dictionary.translate(player)
            end
        end
    end
end

local function on_player_created(e)
    local player = game.get_player(e.player_index)
    -- Only translate if they're connected - if they're not, then it will not work!
    if player.connected then
        dictionary.translate(player)
    end
end

local function on_player_joined_game(e)
    dictionary.translate(game.get_player(e.player_index))
end

local function on_player_left_game(e)
    dictionary.cancel_translation(e.player_index)
end

local function on_string_translated(e)
    local language_data = dictionary.process_translation(e)
    if language_data then
        for _, player_index in pairs(language_data.players) do
            global.player_dictionaries[player_index] = language_data.dictionaries
        end
    end
end

-- Event register

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)

event.on_tick(dictionary.check_skipped)
event.on_player_created(on_player_created)
event.on_player_joined_game(on_player_joined_game)
event.on_player_left_game(on_player_left_game)
event.on_string_translated(on_string_translated)

script.on_event("additional-paste-settings-hotkey", Smarts.on_hotkey_pressed)
script.on_event("additional-paste-settings-hotkey-alt", Smarts.on_hotkey_pressed)

script.on_event(defines.events.on_pre_entity_settings_pasted, Smarts.on_vanilla_pre_paste)
script.on_event(defines.events.on_entity_settings_pasted, Smarts.on_vanilla_paste)
