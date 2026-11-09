local M = {
  setting = "paranoidal-flamethrower-fuels",
  reference_joules = 560000,
  fuels = {
    {name = "crude-oil"},
    {name = "angels-liquid-naphtha"},
    {name = "angels-liquid-fuel-oil"},
    {name = "bob-liquid-fuel"},
    {name = "diesel-fuel"},
    {name = "bob-alien-fire"},
  },
}

function M.describe(name, joules, modifier, native)
  local p = {fluid = name, fuel_joules = joules, energy_ratio = joules / M.reference_joules,
    damage_modifier = modifier}
  if native then
    for _, key in ipairs({"ground_initial_ticks", "ground_max_ticks", "ground_extend_ticks", "burn_ticks",
      "fire", "sticker", "stream"}) do p[key] = native[key] end
    p.impact_damage = native.impact_damage * modifier
    p.ground_dps = native.ground_dps * modifier
    p.burn_dps = native.burn_dps * modifier
    p.ground_initial_seconds, p.burn_seconds = native.ground_initial_ticks / 60, native.burn_ticks / 60
  end
  return p
end

function M.calculate(name, joules, native)
  if type(joules) ~= "number" or joules <= 0 then return nil end
  for _, entry in ipairs(M.fuels) do
    if entry.name == name and entry.enabled ~= false then
      local efficiency = entry.efficiency or 1
      if efficiency <= 0 then return nil end
      return M.describe(name, joules, joules / M.reference_joules * efficiency, native)
    end
  end
end

return M
