-- Д-ОК (M-O). Handlers are registered here, with filters where the game has them, so building or mining anything else
-- never reaches the script.
local shared = require("shared")
local state = require("script.state")
local droid = require("script.droid")
local tracks = require("script.tracks")
local reactions = require("script.reactions")

local ensure_storage = function()
  storage.droid = storage.droid or droid.new_storage()
  local s = storage.droid
  for key, value in pairs(droid.new_storage()) do
    if s[key] == nil then
      s[key] = value
    end
  end
  state.s = s
end

script.on_init(function()
  ensure_storage()
end)

script.on_load(function()
  state.s = storage.droid
end)

script.on_configuration_changed(function()
  ensure_storage()
  -- Worked out again when next wanted, in case the technologies changed.
  state.s.forces = {}
  droid.rebuild_indexes()
end)

local dock_filter = {{filter = "name", name = shared.dock}}
local bot_filter = {{filter = "name", name = shared.bot}}

for _, event in pairs
{
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive
} do
  script.on_event(event, droid.on_built, dock_filter)
end

script.on_event(defines.events.on_entity_cloned, droid.on_entity_cloned,
  {{filter = "name", name = shared.dock}, {filter = "name", name = shared.bot}, {filter = "name", name = shared.proxy}})
script.on_event(defines.events.on_player_mined_entity, droid.on_dock_mined, dock_filter)
script.on_event(defines.events.on_robot_mined_entity, droid.on_dock_mined, dock_filter)
script.on_event(defines.events.on_entity_died, droid.on_bot_died, bot_filter)
script.on_event(defines.events.on_entity_damaged, droid.on_bot_damaged, bot_filter)
script.on_event(defines.events.on_player_rotated_entity, droid.on_dock_turned)
script.on_event(defines.events.on_player_flipped_entity, droid.on_dock_turned)
script.on_event(defines.events.on_object_destroyed, droid.on_object_destroyed)
script.on_event(defines.events.on_surface_deleted, droid.on_surface_gone)
script.on_event(defines.events.on_surface_cleared, droid.on_surface_gone)
script.on_event(defines.events.on_ai_command_completed, droid.on_ai_command_completed)
script.on_event(defines.events.on_script_trigger_effect, droid.on_script_trigger_effect)
script.on_event(defines.events.on_research_finished, droid.on_research_changed)
script.on_event(defines.events.on_research_reversed, droid.on_research_changed)
script.on_event(defines.events.on_force_created, droid.on_force_changed)
script.on_event(defines.events.on_forces_merged, droid.on_forces_merged)
script.on_event(defines.events.on_force_reset, droid.on_force_changed)
script.on_event(defines.events.on_technology_effects_reset, droid.on_force_changed)
script.on_event(defines.events.on_tick, droid.on_tick)
script.on_event(defines.events.on_player_changed_position, tracks.on_player_changed_position)
script.on_event(defines.events.on_player_removed, function(event)
  tracks.on_player_removed(event)
  reactions.forget_player(event.player_index)
end)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  tracks.on_setting_changed(event)
  reactions.on_setting_changed(event)
end)
script.on_nth_tick(droid.forget_interval, droid.forget)

remote.add_interface("droid-m-o", droid.remote)
