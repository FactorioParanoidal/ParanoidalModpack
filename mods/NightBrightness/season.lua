-- NightBrightness 1.1.8 / Paranoidal Beta 8 formulas and the calendar, without engine state.
local M = {}

M.NAMES = {"summer", "fall", "winter", "spring"}

function M.name(day, period)
  local part = (day % period) / period
  if part < 0.125 or part >= 0.875 then return "summer" end
  if part < 0.375 then return "fall" end
  if part < 0.625 then return "winter" end
  return "spring"
end

function M.parameters(day, period, minimum, maximum)
  local phase = math.cos(day / period * 2 * math.pi)
  local tilt = 0.15 * phase
  return {
    min_brightness = (maximum + minimum) / 2 + (maximum - minimum) / 2 * phase,
    dusk = 0.2 + tilt,
    evening = 0.3 + tilt,
    morning = 0.7 - tilt,
    dawn = 0.8 - tilt,
    solar = 0.75 + 0.25 * phase,
    season = M.name(day, period),
  }
end

-- Day of the current season (1-based) and its length in days, for any year length.
function M.season_span(day, period)
  local current = M.name(day, period)
  local before, after = 0, 0
  while before < period - 1 and M.name(day - before - 1, period) == current do before = before + 1 end
  while before + after < period - 1 and M.name(day + after + 1, period) == current do after = after + 1 end
  return before + 1, before + after + 1
end

-- Midnights (daytime 0.5) between the start of the map and now, if the day never stopped or
-- changed length: the estimate for saves made before the calendar existed.
function M.midnights_since_start(tick, ticks_per_day, daytime)
  local now = daytime
  local start = now - tick / math.max(1, ticks_per_day)
  return math.max(0, math.floor(now - 0.5) - math.floor(start - 0.5))
end

-- True if daytime passed midnight (0.5) going from last to now (daytime grows and wraps at 1).
-- A step back of less than half a day is a script setting the time back, not a wrap of the day.
function M.passed_midnight(last, now)
  if now >= last then return last < 0.5 and now >= 0.5 end
  if last - now < 0.5 then return false end
  return last < 0.5 or now >= 0.5
end

-- True if daytime moved by itself from last to now in `ticks` ticks (within a small tolerance), false if a
-- script set it (freeplay sets 0.7 for the crash site at the start; console commands). Only time that
-- passed by itself counts for the calendar.
M.TOLERANCE = 0.02
function M.moved_by_itself(last, now, ticks, ticks_per_day, frozen)
  local expected = frozen and 0 or ticks / math.max(1, ticks_per_day)
  local difference = math.abs((now - last) % 1 - expected % 1)
  return math.min(difference, 1 - difference) <= M.TOLERANCE
end

-- Time of day as on the EvoUI clock: 0.5 is midnight 00:00, 0 is noon 12:00.
function M.clock(daytime)
  local minutes = math.floor(((daytime + 0.5) % 1) * 24 * 60 + 0.5) % (24 * 60)
  return string.format("%d:%02d", math.floor(minutes / 60), minutes % 60)
end

return M
