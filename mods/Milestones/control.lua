require("scripts.commands")
require("scripts.remote_interface")
require("scripts.tracker")
require("scripts.gui")
require("scripts.presets_loader")
require("scripts.milestones_util")
require("scripts.util")
require("scripts.storage_init")
local migrations = require("scripts.migrations")

local migration = require("__flib__.migration")


script.on_init(function()
    storage.delayed_chat_messages = {}
    storage.forces = {}
    storage.players = {}
    storage.milestones_check_frequency_setting = settings.global["milestones_check_frequency"].value

    initial_preset_string = settings.global["milestones_initial_preset"].value
    if initial_preset_string ~= "" then
        initial_preset, err = convert_and_validate_imported_json(initial_preset_string)
        if initial_preset == nil then
            table.insert(storage.delayed_chat_messages, {"milestones.message_invalid_initial_preset"})
            table.insert(storage.delayed_chat_messages, err)
        else
            storage.current_preset_name = "Imported"
            storage.loaded_milestones = initial_preset
            table.insert(storage.delayed_chat_messages, {"milestones.message_loaded_initial_preset"})
        end
    end

    fetch_remote_presets()
    add_remote_presets_to_preset_tables()
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
        table.insert(storage.delayed_chat_messages, {"milestones.message_loaded_into_exiting_game"})
    end
    remove_invalid_milestones_all_forces()

    -- Initialize for existing players in existing save file
    for _, player in pairs(game.players) do
        initialize_player(player)
    end
end)

script.on_event(defines.events.on_surface_created, function(event)
    for _, force in pairs(game.forces) do
        local storage_force = storage.forces[force.name]
        if storage_force then
            table.insert(storage_force.item_stats, force.get_item_production_statistics(event.surface_index))
            table.insert(storage_force.fluid_stats, force.get_fluid_production_statistics(event.surface_index))
            table.insert(storage_force.kill_stats, force.get_kill_count_statistics(event.surface_index))
        end
    end
end)

local function delete_invalid_flow_statistics(flow_statistics_table)
    -- Reverse iterating to delete in-place
    for i=#flow_statistics_table,1,-1 do
        if not flow_statistics_table[i].valid then
            table.remove(flow_statistics_table, i)
        end
    end
end

script.on_event(defines.events.on_surface_deleted, function(event)
    -- We can't check which LuaFlowStatistics belonged to that surface id
    -- Iterating through everything is wasteful, but it shouldn't happen very often so it's fine
    for _, storage_force in pairs(storage.forces) do
        delete_invalid_flow_statistics(storage_force.item_stats)
        delete_invalid_flow_statistics(storage_force.fluid_stats)
        delete_invalid_flow_statistics(storage_force.kill_stats)
    end
end)

script.on_load(function()
    add_remote_presets_to_preset_tables()
end)

script.on_event(defines.events.on_force_created, function(event)
    initialize_force_if_needed(event.force)
end)

script.on_event(defines.events.on_player_changed_force, function(event)
    local player = game.get_player(event.player_index)
    if not storage.players[event.player_index] then -- Can happen if a mod changes a player's force during on_init
        initialize_player(player)
    end
    initialize_force_if_needed(player.force)
    refresh_gui_for_player(player)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    clear_force(event.source_name)
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    if not storage.players[event.player_index] then -- storage.players could already exist if on_player_changed_force created it already
        initialize_player(player)
    end
    if storage.forces[player.force.name] == nil then -- Can happen if new player is added to empty force e.g. vanilla freeplay
        initialize_force_if_needed(player.force)
    end
end)

script.on_event(defines.events.on_player_removed, function(event)
    clear_player(event.player_index)
end)


script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    local setting_name = event.setting
    if setting_name == "milestones_check_frequency" then
        storage.milestones_check_frequency_setting = settings.global["milestones_check_frequency"].value
    elseif setting_name == "milestones_compact_list"
        or setting_name == "milestones_list_by_group"
        or setting_name == "milestones_show_estimations"
        or setting_name == "milestones_show_incomplete" then
        refresh_gui_for_player(game.get_player(event.player_index))
    end
end)

script.on_configuration_changed(function(event)
    -- Run migrations for version changes
    migration.on_config_changed(event, migrations)

    if next(event.mod_changes) ~= nil then
        fetch_remote_presets()
        -- on_load is called before on_configuration_changed so we have to redo add_remote_presets_to_preset_tables here
        add_remote_presets_to_preset_tables()
        reload_presets()
    end
    remove_invalid_milestones_all_forces()
    remove_invalid_aliases()
end)
