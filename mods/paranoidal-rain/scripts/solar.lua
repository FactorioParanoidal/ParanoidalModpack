-- Solar power while it rains: the surface property "solar-power" is set to prain-solar-percent of the value it had
-- when the rain began (75 % by default) and restored exactly afterwards (baseline read at the start, Real Rain).
-- -1 turns the effect off.
local R = require("scripts.registry")

local M = {}
R.solar = M

local PROPERTY = "solar-power"

local function st(index)
  storage.solar = storage.solar or {}
  local s = storage.solar[index]
  if not s then
    s = { active = false }
    storage.solar[index] = s
  end
  return s
end

local function reset(surface, s)
  if s.active and surface and surface.valid and type(s.baseline) == "number" then
    surface.set_property(PROPERTY, s.baseline)
  end
  s.active, s.baseline, s.applied = false, nil, nil
end

function M.sync(index, surface, raining)
  local s = st(index)
  local percent = storage.cfg.solar_percent
  if not raining or percent < 0 or not storage.cfg.enabled then
    if s.active then reset(surface, s) end
    return
  end
  if not s.active then
    s.baseline = surface.get_property(PROPERTY)
    if type(s.baseline) ~= "number" then return end
  end
  local target = s.baseline * percent / 100
  if not s.active or s.applied ~= target then
    surface.set_property(PROPERTY, target)
    s.active, s.applied = true, target
  end
end

-- Settings or surface list changed: restore everything; the next tick applies the current values again.
function M.reset_all()
  if not storage.solar then return end
  for index, s in pairs(storage.solar) do
    local surface = game.surfaces[index]
    if surface then reset(surface, s) end
    if not surface or not R.surfaces.is_rain(index) then storage.solar[index] = nil end
  end
end

function M.forget(index)
  if storage.solar then storage.solar[index] = nil end
end

return M
