-- Fire safety turret zones (scripts/fire-safety.lua): nothing catches fire, explodes or cooks off within
-- the zone of a turret that has water. Checked only right before an ignition, detonation or explosion
-- would start; a direct call into the turret index, free while no turret is active.
local FO = require("scripts.registry")

local M = {}
FO.protection = M

function M.covers(surface, position)
  return FO.safety.covers(surface, position)
end

function M.entity(entity)
  return entity.valid and FO.safety.covers(entity.surface, entity.position)
end

return M
