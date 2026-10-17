-- Paranoidal fire safety turret (zzzparanoidal, remote "paranoidal_fire_safety"): nothing catches
-- fire or cooks off within the radius of a turret that has water. Checked only right before an
-- ignition, detonation or explosion would start, never per damage event.
local FO = require("scripts.registry")

local M = {}
FO.protection = M

function M.covers(surface, position)
  if not remote.interfaces["paranoidal_fire_safety"] then return false end
  return remote.call("paranoidal_fire_safety", "is_protected", surface, position) == true
end

function M.entity(entity)
  return entity.valid and M.covers(entity.surface, entity.position)
end

return M
