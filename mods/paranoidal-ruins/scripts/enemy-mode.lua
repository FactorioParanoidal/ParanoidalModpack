local M = {}

-- Scripted ruins bypass autoplace. Peaceful mode alone does not remove native fauna.
function M.enabled(surface)
  local mgs = surface.map_gen_settings
  local control = mgs.autoplace_controls and mgs.autoplace_controls["enemy-base"]
  return not (mgs.no_enemies_mode or (control and control.size == 0))
end

function M.is_fauna(prototype)
  local kind = prototype.type
  if kind == "unit-spawner" or kind == "turret" or kind == "spider-unit" or kind == "segmented-unit" then return true end
  if kind ~= "unit" then return false end
  local name = prototype.name
  -- Native combat units used by the templates. Humanoid actors, robots and corpses are not fauna.
  return name:find("biter", 1, true) ~= nil or name:find("spitter", 1, true) ~= nil
end

return M
