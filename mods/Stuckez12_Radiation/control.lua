require("scripts.mod_api")
require("scripts.commands")

local radiation_funcs = require("scripts.radiation_damage")
local player_management = require("scripts.player_management")
local mod_addons = require("scripts.mod_integrations")
local chunk_func = require("scripts.chunk_func")


-- Global Variables
storage.active_characters = storage.active_characters or {}
storage.player_connections = storage.player_connections or {}
storage.radiation_items = storage.radiation_items or {}
storage.radiation_fluids = storage.radiation_fluids or {}
storage.integrated_mods = storage.integrated_mods or {}
storage.chunk_data = storage.chunk_data or {}
storage.biters = storage.biters or {}
storage.chunk_que = storage.chunk_que or {}
storage.residual_records = storage.residual_records or {}


-- Mod Config
script.on_init(mod_addons.integrate_mods)
script.on_configuration_changed(mod_addons.integrate_mods)


-- Interval damage event
script.on_nth_tick(20, radiation_funcs.player_radiation_damage)
script.on_nth_tick(4, function()
    radiation_funcs.update_gui_logo()
    chunk_func.update_chunks_in_que()
end)


-- Events when a player character is created
script.on_event(defines.events.on_player_created, player_management.add_player)
script.on_event(defines.events.on_player_respawned, player_management.add_player)
script.on_event(defines.events.on_player_joined_game, player_management.add_player)


-- Events when a player character is destroyed
script.on_event(defines.events.on_player_died, player_management.verify_character_references)


-- Other player events
script.on_event(defines.events.on_player_changed_position, radiation_funcs.update_character_pos)


-- Chest events
local built_events = {
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
}
local removal_events = {
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity,
    defines.events.on_entity_died,
}


script.on_event(built_events, chunk_func.chest_placed)
script.on_event(removal_events, chunk_func.chest_removed)


-- Residual Spawining Event
script.on_event(defines.events.on_script_trigger_effect, function(event)
    if event.effect_id == "on-atomic-detonation" then
        local surface = event.target_entity and event.target_entity.surface or game.surfaces[1]

        local residual_radiation = surface.create_entity{
            name = "residual-radiation",
            position = event.cause_entity.position,
            force = "player"
        }

        radiation_funcs.add_atomic_radiation(residual_radiation)
    end
end)
