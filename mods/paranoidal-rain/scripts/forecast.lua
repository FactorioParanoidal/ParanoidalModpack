-- Weather forecast for the forces that researched "prain-weather-forecast".
-- At dawn (DAWN_SHARE of the way from "morning" to "dawn" of the surface: it is already visibly lighter) of the first
-- and of the middle day of a NightBrightness season (days 1 and 4 of a 6-day season), or of every third day without
-- seasons, each such force gets one chat line about the whole window until the next forecast: "clear", "rain" or
-- "storm" (the strongest weather the plan of scripts/weather.lua has there, the current rain included), without days.
-- Reliability p of the force's radar network on the surface: points = sum of RADAR_WEIGHT of working radars,
-- 1 point -> 10 %, 10 -> 50 %, 100 and more -> 100 % (log scale). With probability p the forecast tells the truth,
-- otherwise it lies boldly: something that certainly will not happen (clear -> rain or storm, rain/storm -> clear).
-- The word ("unlikely" < 40 % <= "likely" < 100 % = "certain") shows p, not the truth; winter rain can be forecast too.
-- Cost: one check of the daytime every CHECK ticks while a force has the technology, one radar search per forecast.
local R = require("scripts.registry")

local M = {}
R.forecast = M

M.TECH = "prain-weather-forecast"
M.CHECK = 300
local DAWN_SHARE = 0.6
local DAYS_WITHOUT_SEASONS = 3
local RADAR_WEIGHT = { radar = 1, ["bob-radar-2"] = 2, ["bob-radar-3"] = 3, ["bob-radar-4"] = 4, ["bob-radar-5"] = 5 }
local COLOR = { r = 0.62, g = 0.82, b = 1 }

local function st()
  local f = storage.forecast
  if not f then
    f = { forces = {}, dawns = 0 }
    storage.forecast = f
  end
  return f
end

-- Forces with the technology (init, configuration change, merged forces).
function M.reconcile()
  local f = st()
  f.forces = {}
  for _, force in pairs(game.forces) do
    local tech = force.technologies[M.TECH]
    if tech and tech.researched then f.forces[force.index] = true end
  end
end

function M.on_research(event, researched)
  local tech = event.research
  if tech.name ~= M.TECH then return end
  st().forces[tech.force.index] = researched or nil
end

-- The surface of the forecast: Nauvis if it rains there, otherwise the first rain surface.
local function forecast_surface()
  local indices = R.surfaces.rain_indices()
  local chosen
  for i = 1, #indices do
    local surface = R.surfaces.get(indices[i])
    if surface and surface.name == "nauvis" then return surface end
    chosen = chosen or surface
  end
  return chosen
end

local function points_of(force, surface)
  local points = 0
  local radars = surface.find_entities_filtered { type = "radar", force = force }
  local working = defines.entity_status.working
  for i = 1, #radars do
    local radar = radars[i]
    if radar.status == working then points = points + (RADAR_WEIGHT[radar.name] or 1) end
  end
  return points
end

function M.reliability(points)
  if points <= 0 then return 0 end
  local x = math.log(points) / math.log(10)
  if x <= 1 then return 0.1 + 0.4 * x end
  return math.min(1, 0.5 + 0.5 * (x - 1))
end

local function lie(truth)
  if truth == "clear" then return math.random() < 0.5 and "rain" or "storm" end
  return "clear"
end

local function announce(force, surface, truth, days)
  local points = points_of(force, surface)
  if points <= 0 then
    force.print({ "prain-forecast.silent" }, { color = COLOR })
    return
  end
  local p = M.reliability(points)
  local shown = truth
  if math.random() >= p then shown = lie(truth) end
  local word = p >= 1 and "certain" or (p >= 0.4 and "likely" or "unlikely")
  force.print({ "prain-forecast.message", days, { "prain-forecast." .. word }, { "prain-forecast." .. shown },
    math.floor(p * 100 + 0.5) }, { color = COLOR })
end

-- Days covered by a forecast made today, or nil if today is not a forecast day.
local function window_days(f)
  local api = remote.interfaces["NightBrightness"]
  if storage.cfg.seasons and api and api.get_state then
    local ok, state = pcall(remote.call, "NightBrightness", "get_state")
    if ok and type(state) == "table" and state.season and type(state.season_day) == "number"
        and type(state.season_length) == "number" and state.season_length >= 2 then
      local half = math.floor(state.season_length / 2)
      if state.season_day == 1 then return half end
      if state.season_day == half + 1 then return state.season_length - half end
      return nil
    end
  end
  if (f.dawns - 1) % DAYS_WITHOUT_SEASONS == 0 then return DAYS_WITHOUT_SEASONS end
  return nil
end

function M.make(surface, days)
  local index = surface.index
  local truth = R.weather.outlook(index, game.tick + days * surface.ticks_per_day)
  for force_index in pairs(st().forces) do
    local force = game.forces[force_index]
    if force and force.valid then announce(force, surface, truth, days) end
  end
end

-- on_nth_tick(CHECK): look for the moment of dawn.
function M.check()
  local f = storage.forecast
  if not (f and next(f.forces)) then return end
  local c = storage.cfg
  if not (c and c.enabled) then return end
  local surface = forecast_surface()
  if not surface then return end
  local p = surface.daytime_parameters
  local threshold = p.morning + (p.dawn - p.morning) * DAWN_SHARE
  local t = surface.daytime
  local last = f.last_daytime
  f.last_daytime = t
  if not last or last == t then return end
  local crossed
  if last < t then
    crossed = last < threshold and t >= threshold
  else -- the day wrapped around 1 -> 0
    crossed = last < threshold or t >= threshold
  end
  if not crossed then return end
  f.dawns = f.dawns + 1
  local days = window_days(f)
  if days then M.make(surface, days) end
end

return M
