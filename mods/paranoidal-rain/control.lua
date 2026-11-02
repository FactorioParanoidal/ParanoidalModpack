-- Paranoidal Rain: weather, rain, thunder and lightning (fork of Dynamic Rain 1.2.0 by valertron with parts of
-- Real Rain 1.2.15 by Squishy1870; see README.md). Modules (scripts/):
--   config     settings snapshot (storage.cfg)        surfaces  rain surfaces (setting prain-allowed-surfaces)
--   players    players by surface, per-player hiding   weather   dry/wet phases and storm stages
--   visual     drops, splashes, puddles, wind          sound     rain loop speakers
--   thunder    thunder events, flashes, thunder sound  lightning strikes and their effects ([2.0] scripted)
--   fire       rain slowly puts fires out              combat    fire/acid damage weakened in the rain
--   solar      solar power in the rain                 pollution rain washes pollution out
--   chunks     chunk counts for the thunder rate       jobs      delayed jobs by tick
-- All game state lives in storage.
local R = require("scripts.registry")
local events = require("scripts.events")
require("scripts.config")
require("scripts.jobs")
require("scripts.surfaces")
require("scripts.players")
require("scripts.weather")
require("scripts.visual")
require("scripts.sound")
require("scripts.thunder")
require("scripts.lightning")
require("scripts.fire")
require("scripts.combat")
require("scripts.solar")
require("scripts.pollution")
require("scripts.chunks")
local commands_module = require("scripts.commands")

local E = defines.events

-- Rebuild everything that depends on settings and the surface list.
local function reconcile()
  R.cfg.load()
  R.surfaces.rebuild()
  R.weather.ensure()
  R.chunks.reconcile()
  R.pollution.reconcile()
  R.solar.reset_all()
  R.sound.reconcile()
  R.jobs.purge()
  R.thunder.clear_sounds()
  if storage.weather then
    for index in pairs(storage.weather) do
      if not R.surfaces.is_rain(index) then
        R.weather.forget(index)
        R.fire.forget(index)
        R.thunder.forget(index)
      end
    end
  end
  R.combat.sync()
end

-- Called by the weather model on every phase change.
function R.on_phase(index, old_phase, phase)
  if phase == "wet" then R.fire.on_rain_start(index) end
  R.combat.sync()
end

script.on_init(function()
  reconcile()
  R.players.refresh_all_hide()
end)

script.on_configuration_changed(function()
  reconcile()
  R.players.refresh_all_hide()
  R.sound.queue_all()
end)

script.on_load(function()
  R.combat.on_load()
end)

script.on_event(E.on_runtime_mod_setting_changed, function(event)
  local name = event.setting
  if string.sub(name, 1, #R.cfg.PREFIX) ~= R.cfg.PREFIX then return end
  if event.setting_type == "runtime-per-user" then
    if event.player_index then R.players.refresh_hide(event.player_index) end
    return
  end
  reconcile()
  if not storage.cfg.enabled then
    R.sound.stop_all()
    R.thunder.clear_sounds()
  end
end)

local function on_tick(event)
  local tick = event.tick
  R.jobs.run(tick)
  local c = storage.cfg
  if not c.enabled then return end
  R.thunder.process_sounds(tick)
  R.weather.on_tick()
  R.sound.process_restarts()

  local by_surface = R.players.by_surface()
  local weather = storage.weather
  local indices = R.surfaces.rain_indices()
  for i = 1, #indices do
    local index = indices[i]
    local surface = R.surfaces.get(index)
    local w = weather[index]
    if surface and w then
      local players = by_surface[index] or {}
      local raining = w.phase == "wet"
      local strength = R.weather.ramp(index)

      R.solar.sync(index, surface, raining)
      if raining then R.pollution.on_tick(index, surface) end
      if raining or w.tLeft < R.cfg.THUNDER_LEAD_TICKS then R.thunder.update(index, surface, players) end

      local volume = c.rain_volume * math.sqrt(strength) * math.min(1, R.weather.stage_data(index).sound)
      R.sound.sync(index, surface, players, volume)

      if #players > 0 then
        if strength > 0 then
          R.visual.rain(index, surface, players, strength)
        else
          local post = R.weather.post_factor(index)
          if post > 0 then R.visual.post_rain(index, surface, players, post) end
        end
      end
    end
  end
end
script.on_event(E.on_tick, on_tick)

local function player_changed(event)
  R.players.invalidate()
  local player = game.get_player(event.player_index)
  if player and storage.cfg.enabled and R.surfaces.is_rain(player.surface_index) then
    R.sound.queue(player.surface_index)
  end
end
script.on_event(E.on_player_joined_game, function(event)
  R.players.refresh_hide(event.player_index)
  player_changed(event)
end)
script.on_event(E.on_player_changed_surface, player_changed)
script.on_event(E.on_player_changed_force, player_changed)
script.on_event(E.on_player_left_game, function(event)
  R.players.invalidate()
  R.visual.forget_player(event.player_index)
end)
script.on_event(E.on_player_removed, function(event)
  if storage.hide then storage.hide[event.player_index] = nil end
  R.visual.forget_player(event.player_index)
end)
script.on_event(E.on_forces_merged, function() R.sound.queue_all() end)
-- the rain note is not saved: restart the speakers when a game is loaded
script.on_event(E.on_singleplayer_init, function() R.sound.queue_all() end)
script.on_event(E.on_multiplayer_init, function() R.sound.queue_all() end)

local function surfaces_changed()
  R.surfaces.rebuild()
  R.weather.ensure()
  R.chunks.reconcile()
end
script.on_event(E.on_surface_created, surfaces_changed)
script.on_event(E.on_surface_imported, surfaces_changed)
script.on_event(E.on_surface_renamed, surfaces_changed)
script.on_event(E.on_surface_cleared, function(event)
  R.chunks.forget(event.surface_index)
  R.pollution.forget(event.surface_index)
  R.fire.forget(event.surface_index)
  R.chunks.reconcile()
end)
script.on_event(E.on_surface_deleted, function(event)
  local index = event.surface_index
  R.sound.stop(index)
  R.weather.forget(index)
  R.fire.forget(index)
  R.thunder.forget(index)
  R.solar.forget(index)
  R.pollution.forget(index)
  R.chunks.forget(index)
  R.jobs.purge(index)
  if storage.wind then storage.wind[index] = nil end
  R.surfaces.rebuild()
  R.combat.sync()
end)

script.on_event(E.on_chunk_generated, function(event)
  local index = event.surface.index
  if not R.surfaces.is_rain(index) then return end
  R.chunks.on_chunk_generated(index)
  R.pollution.on_chunk_generated(index, event.position)
end)

script.on_event(E.on_trigger_created_entity, R.fire.on_marker)

commands_module.register()

local function surface_of(index)
  if type(index) ~= "number" or not R.surfaces.is_rain(index) then return nil end
  return index
end

remote.add_interface("paranoidal-rain", {
  -- true/false for a rain surface, nil for others
  is_raining = function(index)
    if not surface_of(index) then return nil end
    return storage.cfg.enabled and R.weather.is_raining(index) or false
  end,
  -- "clear" | "drizzle" | "rain" | "heavy" | "storm" | "monsoon"
  stage = function(index)
    if not surface_of(index) or not storage.cfg.enabled then return "clear" end
    return R.weather.stage(index)
  end,
  time_left = function(index)
    if not surface_of(index) or not storage.cfg.enabled then return nil end
    return R.weather.time_left(index)
  end,
  -- How many times slower hazards (burning tanks, fuses, ammunition cook-off) develop: >1 while it rains.
  hazard_slowdown = function(index)
    if not surface_of(index) or not storage.cfg.enabled or not R.weather.is_raining(index) then return 1 end
    return storage.cfg.hazard_slowdown
  end,
  -- Dynamic Rain compatible: phase "wet"/"dry", duration in ticks, options {intensity, thunderstorm,
  -- fire_quench, pollution_cleanup_per_minute, pollution_max_chunks_per_tick}.
  start_phase = function(index, phase, duration_ticks, options)
    if type(index) ~= "number" or not game.surfaces[index] then return false end
    if phase ~= "wet" and phase ~= "dry" then return false end
    R.weather.start_phase(index, phase, math.max(1, math.floor(tonumber(duration_ticks) or 3600)), options)
    R.chunks.reconcile()
    return true
  end,
  get_events = function()
    return { on_phase_changed = events.on_phase_changed, on_rain_pollution_cleaned = events.on_rain_pollution_cleaned }
  end,
})
