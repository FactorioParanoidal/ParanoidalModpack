local M = {}

local function managed(name)
  return name == "flamethrower-turret" or name == "flamethrower-wagon-turret"
    or name:match("^hero%-turret%-%d+%-for%-flamethrower%-turret$")
    or name:match("^hero%-turret%-%d+%-for%-flamethrower%-wagon%-turret$")
end

-- Called only from init/configuration_changed. The engine handles every shot and fire tick.
function M.sync()
  storage.paranoidal_flamethrower_fuels = nil
  local amount, count = 0, 0
  for _, surface in pairs(game.surfaces) do
    for _, turret in pairs(surface.find_entities_filtered{type = "fluid-turret"}) do
      if managed(turret.name) then
        local allowed = {}
        for _, entry in pairs(turret.prototype.attack_parameters.fluids or {}) do allowed[entry.type] = true end
        local removed = false
        for index = 1, turret.fluids_count do
          if not turret.get_fluid_box_prototype(index) then
            local fluid = turret.get_fluid(index)
            if fluid and not allowed[fluid.name] then
              local cleared = turret.clear_fluid(index)
              amount = amount + (cleared and cleared.amount or 0)
              removed = true
            end
          end
        end
        if removed then count = count + 1 end
      end
    end
  end
  if count > 0 then game.print({"paranoidal-flame.removed-gas", string.format("%.1f", amount), count}) end
  return {removed_amount = amount, turrets = count}
end

return M
