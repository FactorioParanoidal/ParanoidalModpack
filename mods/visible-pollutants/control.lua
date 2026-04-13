Grid = require("scripts.grid")
Sprite = require("scripts.sprite")
Proximity = require("scripts.proximity")
Solar = require("scripts.solar")
Pollution = require("scripts.pollution")
Settings = require("scripts.settings")

script.on_init(function()
  Settings.update_caches()
  Settings.startup_settings_changed()
  Sprite.init_storage()
  Pollution.init_storage()
  Proximity.init_storage()
  Proximity.add_sprites_near_players()
  Solar.init_storage()
  Solar.full_synchronize()
end)

---@param event ConfigurationChangedData
script.on_configuration_changed(function(event)
  Settings.update_caches()
  Settings.startup_settings_changed()
  Sprite.init_storage()
  Pollution.init_storage()
  Proximity.init_storage()
  Proximity.add_sprites_near_players()
  Solar.init_storage()
  Solar.full_synchronize()
end)

---@param event EventData.on_runtime_mod_setting_changed
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if string.sub(event.setting, 1, #script.mod_name) ~= script.mod_name then return end
  Settings.update_caches()
  Sprite.init_storage()
  Pollution.init_storage()
  Proximity.init_storage()
  Proximity.add_sprites_near_players()
  Solar.on_setting_changed(event.setting)
end)

script.on_load(function()
  Settings.update_caches()
end)

---@param event EventData.on_player_joined_game
script.on_event(defines.events.on_player_joined_game, function(event)
  Proximity.add_sprites_near_player(game.players[event.player_index])
end)

---@param event EventData.on_player_removed
script.on_event(defines.events.on_player_removed, function(event)
  Proximity.remove_player_storage(event.player_index)
end)

---@param event EventData.on_player_changed_surface
script.on_event(defines.events.on_player_changed_surface, function(event)
  Proximity.add_sprites_near_player(game.players[event.player_index])
end)

---@param event EventData.on_player_changed_position
script.on_event(defines.events.on_player_changed_position, function(event)
  Proximity.add_sprites_near_players_if_moved()
end)

---@param event EventData.on_player_controller_changed
script.on_event(defines.events.on_player_controller_changed, function(event)
  Proximity.add_sprites_near_player(game.players[event.player_index])
end)

---@param event EventData.on_selected_entity_changed
script.on_event(defines.events.on_selected_entity_changed, function(event)
  Proximity.set_selections_for_player(game.players[event.player_index])
end)

---@param event EventData.on_tick
script.on_nth_tick(Proximity.FullScanInterval, function(event)
  Proximity.set_selections_for_players()
  Proximity.add_sprites_near_players()
end)

---@param event EventData.on_tick
script.on_nth_tick(Sprite.SpriteUpdateInterval, function(event)
  local finished = Sprite.incrementally_update_sprites_in_queue()
  if finished then
    Sprite.queue_sprites_for_update()
  end
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
  Solar.on_panel_moved(event.old_position, event.entity)
end, { { filter = "type", type = "solar-panel" } })

---@param event EventData.on_object_destroyed
script.on_event(defines.events.on_object_destroyed, function(event)
  if not Solar.OcclusionEnabled then return end
  Solar.on_panel_destroyed(event.registration_number)
end)

---@param event EventData.on_tick
script.on_nth_tick(Solar.ChunkUpdateInterval, function(event)
  if not Solar.OcclusionEnabled then return end
  local finished = Solar.incrementally_update_chunks_in_queue()
  if finished then
    Solar.queue_chunks_for_update()
  end
end)
