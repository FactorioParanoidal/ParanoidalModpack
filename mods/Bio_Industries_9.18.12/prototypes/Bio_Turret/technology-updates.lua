local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

if not mods["Natural_Evolution_Buildings"] then
  -- Simplified code in 0.17.39/0.18.6
  local techs = data.raw.technology
  -- Turret attack modifier
  for index, modifier in pairs({
    -- Keeping indices isn't really necessary here (and in the following), but should help
    -- to avoid mistakes if this file is edited in the future.
    [1] = 0.1,
    [2] = 0.1,
    [3] = 0.2,
    [4] = 0.2,
    [5] = 0.2,
    [6] = 0.4,
    [7] = 0.7,
  }) do
    table.insert(techs["physical-projectile-damage-" .. tostring(index)].effects, {
      type = "turret-attack",
      turret_id = "bi-dart-turret",
      modifier = modifier
    })
  end

  -- Shooting speed modifier
  for index, modifier in pairs({
    [1] = 0.1,
    [2] = 0.2,
    [3] = 0.2,
    [4] = 0.2,
    [5] = 0.2,
    [6] = 0.4,
  }) do
    table.insert(techs["weapon-shooting-speed-" .. tostring(index)].effects, {
      type = "gun-speed",
      ammo_category = "Bio_Turret_Ammo",
      modifier = modifier
    })
  end

  -- Ammo damage modifier
  for index, modifier in pairs({
    [1] = 0.1,
    [2] = 0.1,
    [3] = 0.2,
    [4] = 0.2,
    [5] = 0.2,
    [6] = 0.4,
    [7] = 0.4,
  }) do
    table.insert(techs["physical-projectile-damage-" .. tostring(index)].effects, {
      type = "ammo-damage",
      ammo_category = "Bio_Turret_Ammo",
      modifier = modifier
    })
  end
end
