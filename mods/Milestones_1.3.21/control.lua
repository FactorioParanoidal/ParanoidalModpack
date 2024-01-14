require("scripts.commands")
require("scripts.remote_interface")
require("scripts.tracker")
require("scripts.gui")
require("scripts.presets_loader")
require("scripts.milestones_util")
require("scripts.util")
require("scripts.global_init")
local migrations = require("scripts.migrations")

local migration = require("__flib__.migration")


script.on_init(function()
    global.delayed_chat_messages = {}
    global.forces = {}
    global.players = {}
    global.milestones_check_frequency_setting = settings.global["milestones_check_frequency"].value

    initial_preset_string = settings.global["milestones_initial_preset"].value
    if initial_preset_string ~= "" then
        initial_preset, err = convert_and_validate_imported_json(initial_preset_string)
        if initial_preset == nil then
            table.insert(global.delayed_chat_messages, {"milestones.message_invalid_initial_preset"})
            table.insert(global.delayed_chat_messages, err)
        else
            global.current_preset_name = "Imported"
            global.loaded_milestones = initial_preset
            table.insert(global.delayed_chat_messages, {"milestones.message_loaded_initial_preset"})
        end
    end

    load_presets()
    if initial_preset == nil then
        load_preset_addons()
    end
    initialize_alias_table()

    -- Initialize for existing forces in existing save file
    local backfilled_anything = false
    for _, force in pairs(game.forces) do
        local backfilled_anything_from_this_force = initialize_force_if_needed(force)
        backfilled_anything = backfilled_anything or backfilled_anything_from_this_force
    end
    if backfilled_anything then
        table.insert(global.delayed_chat_messages, {"milestones.message_loaded_into_exiting_game"})
    end
    remove_invalid_milestones_all_forces()

    -- Initialize for existing players in existing save file
    for _, player in pairs(game.players) do
        initialize_player(player)
    end

    if next(global.delayed_chat_messages) ~= nil then
        create_delayed_chat()
    end
end)

script.on_load(function()
    if global.delayed_chat_messages ~= nil and next(global.delayed_chat_messages) ~= nil then
        create_delayed_chat()
    end
end)

script.on_event(defines.events.on_force_created, function(event)
    initialize_force_if_needed(event.force)
end)

script.on_event(defines.events.on_player_changed_force, function(event)
    local player = game.get_player(event.player_index)
    initialize_force_if_needed(player.force)
    refresh_gui_for_player(player)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    clear_force(event.source_name)
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    initialize_player(player)
    if global.forces[player.force.name] == nil then -- Possible if new player is added to empty force e.g. vanilla freeplay
        initialize_force_if_needed(player.force)
    end
end)

script.on_event(defines.events.on_player_removed, function(event)
    clear_player(event.player_index)
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    local setting_name = event.setting
    if setting_name == "milestones_check_frequency" then
        global.milestones_check_frequency_setting = settings.global["milestones_check_frequency"].value
    elseif setting_name == "milestones_compact_list" or setting_name == "milestones_list_by_group" or setting_name == "milestones_show_estimations" then
        refresh_gui_for_player(game.get_player(event.player_index))
    end
end)


script.on_configuration_changed(function(event)
    -- Run migrations for version changes
    migration.on_config_changed(event, migrations)

    if next(event.mod_changes) ~= nil then
        reload_presets()
    end
    remove_invalid_milestones_all_forces()

    -- We also do this here because for some reason on_nth_tick sometimes doesn't work in on_init
    -- I don't know why
    if next(global.delayed_chat_messages) ~= nil then
        create_delayed_chat()
    end
end)
