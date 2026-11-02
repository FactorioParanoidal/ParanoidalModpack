-- Weather model per surface (storage.weather[surface_index]).
-- Dry and wet phases with durations in real minutes (Dynamic Rain); a wet phase walks through a staged sequence
-- drizzle -> rain -> heavy -> storm -> monsoon and back (Real Rain), which scales drops, splashes, sound and thunder.
-- A phase change raises the custom event on_phase_changed and calls R.on_phase (control.lua).
local R = require("scripts.registry")
local events = require("scripts.events")

local M = {}
R.weather = M

local floor, random = math.floor, math.random

-- visual: drop density; thunder: thunder rate; splash: splash chance; sound: rain loudness.
local STAGES = {
  drizzle = { visual = 0.40, thunder = 0.02, splash = 0.35, sound = 0.55 },
  rain    = { visual = 0.80, thunder = 0.18, splash = 0.70, sound = 0.78 },
  heavy   = { visual = 1.20, thunder = 0.55, splash = 1.05, sound = 1.00 },
  storm   = { visual = 1.60, thunder = 1.18, splash = 1.40, sound = 1.10 },
  monsoon = { visual = 2.00, thunder = 1.75, splash = 1.80, sound = 1.18 },
}
M.STAGES = STAGES

local SEQUENCES = {
  light = { { 0, "drizzle" }, { 0.22, "rain" }, { 0.74, "drizzle" } },
  normal = { { 0, "drizzle" }, { 0.15, "rain" }, { 0.48, "heavy" }, { 0.72, "rain" }, { 0.90, "drizzle" } },
  storm = { { 0, "drizzle" }, { 0.10, "rain" }, { 0.30, "heavy" }, { 0.52, "storm" }, { 0.70, "heavy" },
    { 0.86, "rain" }, { 0.95, "drizzle" } },
  monsoon = { { 0, "drizzle" }, { 0.08, "rain" }, { 0.20, "heavy" }, { 0.38, "storm" }, { 0.56, "monsoon" },
    { 0.68, "storm" }, { 0.80, "heavy" }, { 0.90, "rain" }, { 0.97, "drizzle" } },
}

local function minutes(m)
  return math.max(1, floor(m * R.cfg.TICKS_PER_MINUTE + 0.5))
end

local function u01()
  local u = random()
  if u <= 0 then u = 1e-12 end
  if u >= 1 then u = 1 - 1e-12 end
  return u
end

local function sample_wet()
  local c = storage.cfg
  return c.wet_min + (c.wet_max - c.wet_min) * u01() ^ c.wet_power
end

local function sample_dry()
  return -storage.cfg.dry_mean * math.log(1 - u01())
end

-- A new surface (or a save that just got the mod) stays dry for the start (zzzparanoidal-start-bnl fires).
local function new_state()
  local first = storage.cfg.first_dry
  return { phase = "dry", tLeft = minutes(first + random() * math.max(1, first)), total = 0, stage = "clear",
    post_left = 0, post_total = 0 }
end

local function choose_sequence()
  local c = storage.cfg
  if not c.storm_stages then return "normal", 0.55 end
  local r = random()
  local monsoon = math.max(0, math.min(1, c.monsoon_chance))
  if r < monsoon then return "monsoon", 1 end
  if r < monsoon + 0.32 then return "storm", 0.75 + random() * 0.25 end
  if r < monsoon + 0.74 then return "normal", 0.45 + random() * 0.35 end
  return "light", 0.2 + random() * 0.35
end

local function update_stage(w)
  if w.phase ~= "wet" then
    w.stage = "clear"
    return
  end
  if w.forced_stage then
    w.stage = w.forced_stage
    return
  end
  local seq = SEQUENCES[w.sequence or "normal"] or SEQUENCES.normal
  local progress = 1 - math.max(0, w.tLeft) / math.max(1, w.total or 1)
  local stage = seq[1][2]
  for i = 1, #seq do
    if progress >= seq[i][1] then stage = seq[i][2] else break end
  end
  w.stage = stage
end

local function enter(index, w, phase, duration)
  local old = w.phase
  w.phase = phase
  w.tLeft = duration
  w.total = duration
  w.forced_stage = w.pending_stage
  w.pending_stage = nil
  if phase == "wet" then
    w.sequence, w.severity = choose_sequence()
    w.storm = 0.75 + w.severity * 0.5
    w.post_left, w.post_total = 0, 0
  else
    w.severity, w.storm, w.sequence = 0, 1, nil
    if storage.cfg.post_rain and old == "wet" then
      w.post_total = floor((35 + random() * 85) * 60)
      w.post_left = w.post_total
    end
  end
  update_stage(w)
  script.raise_event(events.on_phase_changed, {
    surface_index = index, old_phase = old, phase = phase, duration_ticks = duration,
  })
  if R.on_phase then R.on_phase(index, old, phase) end
end

function M.ensure()
  storage.weather = storage.weather or {}
  for _, index in ipairs(R.surfaces.rain_indices()) do
    if not storage.weather[index] then storage.weather[index] = new_state() end
  end
end

function M.forget(index)
  if storage.weather then storage.weather[index] = nil end
end

function M.on_tick()
  local weather = storage.weather
  local indices = R.surfaces.rain_indices()
  for i = 1, #indices do
    local index = indices[i]
    local w = weather[index]
    if not w then
      w = new_state()
      weather[index] = w
    end
    if w.post_left > 0 then w.post_left = w.post_left - 1 end
    w.tLeft = w.tLeft - 1
    if w.tLeft <= 0 then
      local phase = w.phase == "wet" and "dry" or "wet"
      local duration = w.pending_duration
      w.pending_duration = nil
      if not duration then
        w.options = nil
        duration = minutes(phase == "wet" and sample_wet() or sample_dry())
      end
      enter(index, w, phase, duration)
    elseif w.phase == "wet" and not w.forced_stage and w.tLeft % 60 == 0 then
      update_stage(w)
    end
  end
end

local function state(index)
  if not R.surfaces.is_rain(index) then return nil end
  return storage.weather and storage.weather[index]
end

function M.is_raining(index)
  local w = state(index)
  return w ~= nil and w.phase == "wet"
end

function M.time_left(index)
  local w = state(index)
  return w and w.tLeft or 0
end

function M.stage(index)
  local w = state(index)
  return w and w.phase == "wet" and w.stage or "clear"
end

function M.stage_data(index)
  return STAGES[M.stage(index)] or STAGES.rain
end

-- Drop density factor: stage x storm severity x options.intensity.
function M.visual_factor(index)
  local w = state(index)
  if not w then return 0 end
  local stage = STAGES[w.stage] or STAGES.rain
  local options = w.options
  local intensity = options and options.intensity or 1
  return stage.visual * (w.storm or 1) * intensity
end

function M.thunder_factor(index)
  local w = state(index)
  if not w then return 0 end
  if w.options and w.options.thunderstorm == false then return 0 end
  if w.phase ~= "wet" then return 0.18 end -- thunder before the rain
  local stage = STAGES[w.stage] or STAGES.rain
  return stage.thunder * (0.75 + (w.severity or 0.5) * 0.5)
end

-- 0..1: rain fading in at the end of a dry spell, full while wet, fading out at its end.
function M.ramp(index)
  local w = state(index)
  if not w then return 0 end
  local ramp = R.cfg.RAMP_TICKS
  if w.phase == "wet" then
    if w.tLeft <= ramp then return w.tLeft / ramp end
    return 1
  end
  if w.tLeft <= ramp then return 1 - w.tLeft / ramp end
  return 0
end

function M.post_factor(index)
  local w = state(index)
  if not w or w.phase ~= "dry" or w.post_left <= 0 or w.post_total <= 0 then return 0 end
  return w.post_left / w.post_total
end

function M.option(index, key)
  local w = state(index)
  return w and w.options and w.options[key]
end

-- Remote: switch to a phase for duration_ticks with options (intensity, thunderstorm, fire_quench, ...).
-- A different phase comes after the usual 600-tick transition (Dynamic Rain start_phase).
function M.start_phase(index, phase, duration, options)
  R.surfaces.add(index)
  M.ensure()
  local w = storage.weather[index]
  w.options = options
  w.pending_duration = nil
  if w.phase ~= phase then
    w.tLeft = R.cfg.RAMP_TICKS
    w.pending_duration = duration
  else
    w.tLeft = duration
    w.total = duration
  end
end

-- Command: start rain or a dry spell now (after the transition). Returns false if already in that phase.
function M.request(index, phase, duration, stage)
  local w = state(index)
  if not w then return nil end
  w.options = nil
  w.pending_stage = stage
  if w.phase == phase then
    if stage then
      w.forced_stage = stage
      update_stage(w)
    end
    if duration then
      w.tLeft, w.total = duration, duration
    end
    return stage ~= nil or duration ~= nil
  end
  w.tLeft = 1
  w.pending_duration = duration
  return true
end

return M
