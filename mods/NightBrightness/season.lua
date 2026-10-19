-- NightBrightness 1.1.8 / Paranoidal Beta 8 formulas, without engine state.
local M = {}

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

-- The engine validates each assignment, not just the final set of values.
function M.set_day_parameters(surface, p)
  surface.dusk = 0.00001
  surface.evening = 0.00002
  surface.morning = 0.00003
  surface.dawn = 0.00004
  surface.dawn = p.dawn
  surface.morning = p.morning
  surface.evening = p.evening
  surface.dusk = p.dusk
end

return M
