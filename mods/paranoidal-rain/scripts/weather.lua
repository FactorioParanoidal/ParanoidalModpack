-- Weather model per surface (storage.weather[surface_index]).
-- Dry and wet phases with durations in real minutes (Dynamic Rain); a wet phase walks through a staged sequence
-- drizzle -> rain -> heavy -> storm -> monsoon and back (Real Rain), which scales drops, splashes, sound and thunder.
-- A phase change raises the custom event on_phase_changed and calls R.on_phase (control.lua).
-- The rains are planned ahead (w.plan: {start, finish, sequence, severity}, at least PLAN_DAYS game days ahead), so
-- the weather forecast (scripts/forecast.lua) only reads the future and never changes it. Seasons of NightBrightness
-- (remote get_state, setting prain-seasons): no rain in winter, one try with SUMMER_CHANCE per summer, spring and fall
-- as usual; a rain does not last into winter. Without NightBrightness (or with frozen days) it rains all year.
-- Commands and the remote start_phase override the plan: planned rains they cover are dropped.
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

local PLAN_DAYS = 4
local SUMMER_CHANCE = 0.1
local WINTER_MARGIN = 1200 -- a fall rain ends this many ticks before the winter

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
  -- tLeft = 1: the first tick computes the dry spell from the plan (no phase change)
  return { phase = "dry", tLeft = 1, total = 0, stage = "clear", post_left = 0, post_total = 0, plan = {},
    cursor = game.tick + minutes(first + random() * math.max(1, first)), first = true }
end

-- Seasons ---------------------------------------------------------------------------------------------------------
-- NightBrightness counts days at midnight (daytime 0.5) and names the season of a day by its place in the cycle
-- (NightBrightness/season.lua M.name, copied here: summer from 7/8 to 1/8, fall, winter, spring).
local function season_name(day, period)
  local part = (day % period) / period
  if part < 0.125 or part >= 0.875 then return "summer" end
  if part < 0.375 then return "fall" end
  if part < 0.625 then return "winter" end
  return "spring"
end

local function season_clock(surface)
  if not storage.cfg.seasons or not surface or surface.freeze_daytime then return nil end
  local api = remote.interfaces["NightBrightness"]
  if not (api and api.get_state) then return nil end
  local ok, state = pcall(remote.call, "NightBrightness", "get_state")
  if not ok or type(state) ~= "table" or not state.season or type(state.cycle_day) ~= "number"
      or type(state.period) ~= "number" or state.period < 4 then
    return nil
  end
  local tpd = surface.ticks_per_day
  local now = game.tick
  return { day = state.cycle_day, period = state.period, tpd = tpd,
    midnight = now + math.max(1, floor(((0.5 - surface.daytime) % 1) * tpd + 0.5)) }
end
M.season_clock = season_clock

local function day_at(clock, tick)
  if tick < clock.midnight then return clock.day end
  return clock.day + 1 + floor((tick - clock.midnight) / clock.tpd)
end

local function day_start(clock, day)
  return clock.midnight + (day - clock.day - 1) * clock.tpd
end

-- Season of a tick and the ticks where it began and ends.
local function season_span(clock, tick)
  local day, period = day_at(clock, tick), clock.period
  local name = season_name(day, period)
  local first, last = day, day
  while day - first < period and season_name(first - 1, period) == name do first = first - 1 end
  while last - first < period and season_name(last + 1, period) == name do last = last + 1 end
  return name, day_start(clock, first), day_start(clock, last + 1), first
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

-- Plan -------------------------------------------------------------------------------------------------------------
local function add_entry(w, start, finish)
  local sequence, severity = choose_sequence()
  w.plan[#w.plan + 1] = { start = start, finish = finish, sequence = sequence, severity = severity }
end

-- Extend the plan to PLAN_DAYS game days ahead. w.cursor: the end of the last planned (or forced) rain.
local function extend(index, w)
  w.plan = w.plan or {}
  local now = game.tick
  local surface = R.surfaces.get(index)
  local tpd = surface and surface.ticks_per_day or 25000
  local horizon = now + PLAN_DAYS * tpd
  local cursor = math.max(w.cursor or now, now)
  if cursor >= horizon then return end
  local clock = season_clock(surface)
  local guard = 0
  while cursor < horizon and guard < 200 do
    guard = guard + 1
    local start = cursor + (w.first and 0 or minutes(sample_dry())) -- the first rain right after the start dry spell
    w.first = nil
    local season, first, last, first_day
    if clock then season, first, last, first_day = season_span(clock, start) end
    if season == "winter" then
      cursor = last
    elseif season == "summer" then
      if w.summer ~= first_day then -- one try per summer
        w.summer = first_day
        if random() < SUMMER_CHANCE then
          local duration = minutes(sample_wet())
          local s = first + floor(random() * math.max(1, last - first - duration))
          if s >= cursor then
            add_entry(w, s, s + duration)
            cursor = s + duration
          end
        end
      end
      cursor = math.max(cursor, last)
    else
      local finish = start + minutes(sample_wet())
      if clock and season == "fall" and finish > last - WINTER_MARGIN then finish = last - WINTER_MARGIN end
      if finish - start >= minutes(1) then add_entry(w, start, finish) end
      cursor = math.max(start, finish)
    end
  end
  w.cursor = cursor
end

-- Drop planned rains starting before tick (a forced phase covers them).
local function drop_before(w, tick)
  local plan, kept = w.plan or {}, {}
  for i = 1, #plan do
    if plan[i].start >= tick then kept[#kept + 1] = plan[i] end
  end
  w.plan = kept
  if (w.cursor or 0) < tick then w.cursor = tick end
end

-- Ticks of the dry spell until the next planned rain (w.wet_next: the spell ends in rain, so the rain may fade in).
local function dry_left(index, w)
  extend(index, w)
  local now = game.tick
  local entry = w.plan[1]
  if entry then
    w.wet_next = true
    return math.max(1, entry.start - now)
  end
  -- nothing planned yet: look again when the plan horizon reaches the cursor (later plans start after it)
  w.wet_next = false
  local surface = R.surfaces.get(index)
  local tpd = surface and surface.ticks_per_day or 25000
  return math.max(1, math.min(36000, (w.cursor or now) - PLAN_DAYS * tpd - now + 1))
end

local function enter(index, w, phase, duration, entry)
  local old = w.phase
  w.phase = phase
  w.tLeft = duration
  w.total = duration
  w.forced_stage = w.pending_stage
  w.pending_stage = nil
  if phase == "wet" then
    w.wet_next = nil
    if entry then
      w.sequence, w.severity = entry.sequence, entry.severity
    else
      w.sequence, w.severity = choose_sequence()
    end
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

local function start_wet(index, w, forced_duration)
  local now = game.tick
  local entry
  if not forced_duration then
    extend(index, w)
    entry = w.plan[1]
    if entry and entry.start <= now + 1 then
      table.remove(w.plan, 1)
    else
      entry = nil
    end
  end
  local duration = forced_duration or (entry and math.max(60, entry.finish - now)) or minutes(sample_wet())
  drop_before(w, now + duration) -- a forced rain covers the planned ones
  enter(index, w, "wet", duration, entry)
end

local function start_dry(index, w, forced_duration)
  local now = game.tick
  if forced_duration then
    drop_before(w, now + forced_duration)
    enter(index, w, "dry", forced_duration)
    return -- after it the spell goes on until the next planned rain (on_tick)
  end
  w.wet_next = false
  enter(index, w, "dry", 1)
  local left = dry_left(index, w)
  w.tLeft, w.total = left, left
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
      local forced = w.pending_duration
      w.pending_duration = nil
      if w.phase == "wet" then
        w.options = nil
        start_dry(index, w, forced)
      elseif forced or w.force_wet then
        w.force_wet = nil
        start_wet(index, w, forced)
      else
        extend(index, w)
        local entry = w.plan[1]
        if entry and entry.start <= game.tick + 1 then
          w.options = nil
          start_wet(index, w)
        else
          local left = dry_left(index, w) -- stays dry (winter, no rain planned yet)
          w.tLeft, w.total = left, math.max(w.total or 0, left)
        end
      end
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
  if w.phase ~= "wet" then return w.wet_next and 0.18 or 0 end -- thunder before the rain
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
  if w.wet_next and w.tLeft <= ramp then return 1 - w.tLeft / ramp end
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
    if phase == "wet" then
      w.wet_next = true
      w.force_wet = true
    end
  else
    w.tLeft = duration
    w.total = duration
    drop_before(w, game.tick + duration)
    if phase == "dry" then w.wet_next = false end
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
      drop_before(w, game.tick + duration)
      if phase == "dry" then w.wet_next = false end
    end
    return stage ~= nil or duration ~= nil
  end
  w.tLeft = 1
  w.pending_duration = duration
  if phase == "wet" then w.force_wet = true end
  return true
end

-- Forecast: the strongest weather on the surface from now until until_tick: "clear", "rain" or "storm".
-- Reads the current rain and the plan; never changes the weather (it only extends the plan, which is fixed anyway).
local function class_of(sequence)
  return (sequence == "storm" or sequence == "monsoon") and "storm" or "rain"
end

function M.outlook(index, until_tick)
  local w = state(index)
  if not w then return "clear" end
  extend(index, w)
  local best = "clear"
  local function take(sequence)
    local c = class_of(sequence)
    if c == "storm" or best == "clear" then best = c end
  end
  if w.phase == "wet" then take(w.sequence) end
  for _, entry in ipairs(w.plan) do
    if entry.start < until_tick then take(entry.sequence) end
  end
  return best
end

-- Thunder may start before a rain: the dry spell ends in rain within THUNDER_LEAD_TICKS.
function M.rain_soon(index)
  local w = state(index)
  return w ~= nil and w.phase == "dry" and w.wet_next == true and w.tLeft < R.cfg.THUNDER_LEAD_TICKS
end

return M
