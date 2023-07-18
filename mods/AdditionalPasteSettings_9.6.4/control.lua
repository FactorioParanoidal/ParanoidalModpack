local Smarts = require("smarts")

---@alias Player_dictionaries table<int, Item_types>
---@alias Item_types table<string, Item_names>
---@alias Item_names table<string, string>

local function init_globals()
    -- enity_deta_data

    global.event_backup = global.event_backup or {}
    global.entity_data = global.entity_data or {} ---@type table<uint, EntityData>
    global.locale_dictionaries = global.locale_dictionaries or {}
end

local function register_events()
    if remote.interfaces["Babelfish"] then
        local on_translations_complete_event = remote.call("Babelfish", "get_on_translations_complete_event")
        script.on_event(on_translations_complete_event, Smarts.get_translations)
    end
end

local function on_init()
    init_globals()
    register_events()
end

local function on_load()
    register_events()
end

local function on_configuration_changed(e)
    init_globals()
    register_events()
end

-- Event register

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)

script.on_event("additional-paste-settings-hotkey", Smarts.on_hotkey_pressed)
script.on_event("additional-paste-settings-hotkey-alt", Smarts.on_hotkey_pressed)

script.on_event(defines.events.on_pre_entity_settings_pasted, Smarts.on_vanilla_pre_paste)
script.on_event(defines.events.on_entity_settings_pasted, Smarts.on_vanilla_paste)
