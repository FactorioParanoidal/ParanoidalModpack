-- Reliability of a picked robot: tougher robots (more health than the vanilla logistic robot) and better quality
-- crash less. Crash chance = min(1, reference health / health) × quality_k / (quality_k + quality level).
local shared = require("shared")

local M = {}

local healths, reference = {}, nil

local function health_of(name)
  local health = healths[name]
  if not health then
    local prototype = prototypes.entity[name]
    health = prototype and prototype.get_max_health() or 1
    healths[name] = health
  end
  return health
end

function M.crash_chance(robot)
  reference = reference or (prototypes.entity["logistic-robot"] and health_of("logistic-robot")) or 100
  local health = health_of(robot.name)
  local tier = health > reference and reference / health or 1
  local level = robot.quality.level
  if level < 0 then level = 0 end
  return tier * shared.quality_k / (shared.quality_k + level)
end

-- hooks.spare entry.
function M.spare(robot)
  local chance = M.crash_chance(robot)
  if chance >= 1 then return false end
  return math.random() >= chance
end

return M
