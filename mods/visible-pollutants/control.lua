Grid = require("scripts.grid")
Sprite = require("scripts.sprite")
Proximity = require("scripts.proximity")
Solar = require("scripts.solar")
Pollution = require("scripts.pollution")
Settings = require("scripts.settings")

-- Paranoidal portal-patch: refresh our factor when NightBrightness changes season.
remote.add_interface("visible-pollutants", {
  refresh_solar_multiplier = Solar.refresh_solar_multiplier,
  get_surface_status = Solar.get_surface_status,
})

script.on_init(function()
  Settings.update_caches()
  Settings.startup_settings_changed()
  Sprite.init_storage()
  Pollution.init_storage()
  Proximity.init_storage()
  Solar.init_storage()
  Solar.full_synchronize()
end)

---@param event ConfigurationChangedData
script.on_configuration_changed(function(event)
  Settings.update_caches()
  Settings.startup_settings_changed()
  Sprite.prepare_storage()
  Sprite.invalidate_samples()
  Pollution.init_storage()
  Proximity.init_storage()
  Solar.init_storage()
  Solar.full_synchronize()
end)

---@param event EventData.on_runtime_mod_setting_changed
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if string.sub(event.setting, 1, #script.mod_name) ~= script.mod_name then return end
  Settings.update_caches()
  if event.setting == Settings.MinConsideredPollution
      or event.setting == Settings.MaxConsideredPollution
      or event.setting == Settings.PollutionRangeExponent then
    Sprite.invalidate_samples()
  end
  -- The solar handler dispatches only its own/shared curve settings. Visual
  -- changes converge in bounded work and never trigger solar synchronization.
  Solar.on_setting_changed(event.setting)
end)

script.on_load(function()
  Settings.update_caches()
end)

script.on_event({
  defines.events.on_player_created,
  defines.events.on_player_joined_game,
  defines.events.on_player_changed_surface,
  defines.events.on_player_changed_position,
  defines.events.on_player_controller_changed,
  defines.events.on_selected_entity_changed,
  defines.events.on_player_display_resolution_changed,
  defines.events.on_player_display_scale_changed,
}, function(event)
  Proximity.mark_player(event.player_index)
end)

script.on_event({ defines.events.on_player_removed, defines.events.on_player_left_game }, function(event)
  Proximity.remove_player_storage(event.player_index)
end)

script.on_nth_tick(Sprite.SpriteUpdateInterval, function()
  Proximity.step()
end)

---@param event EventData.on_robot_built_entity
script.on_event(defines.events.on_robot_built_entity, function(event)
  if not Solar.OcclusionEnabled then return end
  Solar.on_panel_placed(event.entity)
end, { { filter = "type", type = "solar-panel" } })

---@param event EventData.on_built_entity
script.on_event(defines.events.on_built_entity, function(event)
  if not Solar.OcclusionEnabled then return end
  Solar.on_panel_placed(event.entity)
end, { { filter = "type", type = "solar-panel" } })

---@param event EventData.script_raised_built
script.on_event(defines.events.script_raised_built, function(event)
  if not Solar.OcclusionEnabled then return end
  Solar.on_panel_placed(event.entity)
end, { { filter = "type", type = "solar-panel" } })

---@param event EventData.script_raised_revive
script.on_event(defines.events.script_raised_revive, function(event)
  if not Solar.OcclusionEnabled then return end
  Solar.on_panel_placed(event.entity)
end, { { filter = "type", type = "solar-panel" } })

---@param event EventData.script_raised_teleported
script.on_event(defines.events.script_raised_teleported, function(event)
  if not Solar.OcclusionEnabled then return end
  Solar.on_panel_moved(event.entity)
end, { { filter = "type", type = "solar-panel" } })

---@param event EventData.on_entity_cloned
script.on_event(defines.events.on_entity_cloned, function(event)
  if not Solar.OcclusionEnabled then return end
  Solar.on_panel_placed(event.destination)
end, { { filter = "type", type = "solar-panel" } })

---@param event EventData.on_object_destroyed
script.on_event(defines.events.on_object_destroyed, function(event)
  Solar.on_panel_destroyed(event.registration_number)
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  storage.sprites_by_surface_cells[event.surface_index] = nil
  if storage.sprite_update_ticks then storage.sprite_update_ticks[event.surface_index] = nil end
  storage.pollutant_color_by_surface[event.surface_index] = nil
  Proximity.on_surface_deleted(event.surface_index)
  Solar.on_surface_deleted(event.surface_index)
end)

---@param event EventData.on_tick
script.on_nth_tick(Solar.ChunkUpdateInterval, function(event)
  if not Solar.OcclusionEnabled then return end
  local finished = Solar.incrementally_update_chunks_in_queue()
  if finished then
    Solar.queue_chunks_for_update()
  end
end)
