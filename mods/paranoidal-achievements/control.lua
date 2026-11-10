-- paranoidal-achievements: milestones (former Milestones, milestones/*) and achievements (former
-- MxlChievements-Reforged, scripts/achievements.lua + scripts/trackers.lua) in one Lua state.
--   * every event is registered once (scripts/events.lua);
--   * one on_tick handler: the milestones statistics cycle every tick, the achievement polls every
--     60 ticks, the delayed milestone chat messages every 240 ticks (before: on_tick, on_nth_tick(60)
--     and on_nth_tick(240) of two mods);
--   * the production statistics are read only by the milestones cycle; the achievements that need
--     them are its consumers (add_statistics_consumer in milestones/tracker.lua).
-- Storage: storage.forces, storage.players, storage.tracker... (milestones, as before) and
-- storage.mxlr (achievements, as before).

local events = require("scripts.events")
local identity = require("milestones.identity")
local force_merge = require("milestones.force_merge")

require("milestones.commands")
require("milestones.remote_interface")
require("milestones.tracker")
require("milestones.gui")
require("milestones.presets_loader")
require("milestones.milestones_util")
require("milestones.util")
require("milestones.storage_init")

-- After milestones.tracker: registers its handlers and the statistics consumers.
local achievements = require("scripts.achievements")

---------------------------------------------------------------------------------------------------
-- Milestones

local function milestones_on_init()
    storage.delayed_chat_messages = {}
    storage.forces = {}
    storage.players = {}
    storage.milestones_revision = 0
    storage.milestones_check_frequency_setting = settings.global["milestones_check_frequency"].value

    local initial_preset
    local initial_preset_string = settings.global["milestones_initial_preset"].value
    if initial_preset_string ~= "" then
        local err
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
end

local function delete_invalid_flow_statistics(flow_statistics_table)
    -- Reverse iterating to delete in-place
    for i=#flow_statistics_table,1,-1 do
        if not flow_statistics_table[i].valid then
            table.remove(flow_statistics_table, i)
        end
    end
end

events.on(defines.events.on_surface_created, function(event)
    local surface = game.get_surface(event.surface_index)
    if surface and is_ignored_surface_name(surface.name) then return end
    for _, force in pairs(game.forces) do
        local storage_force = storage.forces[force.name]
        if storage_force then
            table.insert(storage_force.item_stats, force.get_item_production_statistics(event.surface_index))
            table.insert(storage_force.fluid_stats, force.get_fluid_production_statistics(event.surface_index))
            table.insert(storage_force.kill_stats, force.get_kill_count_statistics(event.surface_index))
        end
    end
    reset_milestones_tracker()
end)

events.on(defines.events.on_surface_deleted, function(event)
    -- We can't check which LuaFlowStatistics belonged to that surface id
    -- Iterating through everything is wasteful, but it shouldn't happen very often so it's fine
    for _, storage_force in pairs(storage.forces) do
        delete_invalid_flow_statistics(storage_force.item_stats)
        delete_invalid_flow_statistics(storage_force.fluid_stats)
        delete_invalid_flow_statistics(storage_force.kill_stats)
    end
    reset_milestones_tracker()
end)

events.on(defines.events.on_force_created, function(event)
    initialize_force_if_needed(event.force)
end)

events.on(defines.events.on_player_changed_force, function(event)
    local player = game.get_player(event.player_index)
    if not storage.players[event.player_index] then -- Can happen if a mod changes a player's force during on_init
        initialize_player(player)
    end
    initialize_force_if_needed(player.force)
    storage.players[player.index].editing_milestone_id = nil
    storage.players[player.index].display_page = 1
    refresh_gui_for_player(player)
end)

events.on(defines.events.on_forces_merged, function(event)
    force_merge.merge(event.source_name, event.destination)
end)

events.on(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    if not storage.players[event.player_index] then -- storage.players could already exist if on_player_changed_force created it already
        initialize_player(player)
    end
    if storage.forces[player.force.name] == nil then -- Can happen if new player is added to empty force e.g. vanilla freeplay
        initialize_force_if_needed(player.force)
    end
end)

events.on(defines.events.on_player_removed, function(event)
    clear_player(event.player_index)
end)

events.on(defines.events.on_runtime_mod_setting_changed, function(event)
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

local function milestones_on_configuration_changed(event)
    -- No version migrations: the storage of this mod is created by on_init in the current layout
    -- (the Milestones migrations up to 9.4.8 belonged to the old mod name).
    remove_ignored_forces()
    remove_ignored_surface_statistics()

    if next(event.mod_changes) ~= nil then
        fetch_remote_presets()
        -- on_load is called before on_configuration_changed so we have to redo add_remote_presets_to_preset_tables here
        add_remote_presets_to_preset_tables()
        local added_presets = reload_presets()
        upgrade_unmodified_preset(added_presets)
    end
    remove_invalid_milestones_all_forces()
    remove_invalid_aliases()
    for _, storage_force in pairs(storage.forces) do identity.ensure(storage_force) end
    for _, player in pairs(game.players) do
        if storage.players[player.index] and storage.players[player.index].gui_version ~= 1 then
            reinitialize_player(player.index)
        else
            refresh_gui_for_player(player)
        end
    end
    reset_milestones_tracker()
end

---------------------------------------------------------------------------------------------------
-- Lifecycle and the one tick handler

script.on_init(function()
    milestones_on_init()
    achievements.on_init()
end)

script.on_load(function()
    add_remote_presets_to_preset_tables()
    achievements.on_load()
end)

script.on_configuration_changed(function(event)
    milestones_on_configuration_changed(event)
    achievements.on_configuration_changed()
end)

events.on(defines.events.on_tick, function(event)
    track_item_creation(event)
    local tick = event.tick
    if tick % 60 == 0 then
        achievements.poll(tick)
        if tick % DELAYED_CHAT_DELAY == 0 then print_chat_delayed(event) end
    end
end)

events.register()
