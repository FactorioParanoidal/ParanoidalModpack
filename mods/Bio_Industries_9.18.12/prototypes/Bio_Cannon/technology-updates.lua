--~ local BioInd = require('common')('Bio_Industries')

if not mods["Natural_Evolution_Buildings"] and BI.Settings.Bio_Cannon then
  -- Don't duplicate what NE does
  if not mods["Natural_Evolution_Buildings"] then

    table.insert(data.raw.technology["physical-projectile-damage-5"].effects, {
      type = "ammo-damage",
      ammo_category = "Bio_Cannon_Ammo",
      modifier = 0.9
    })
    table.insert(data.raw.technology["physical-projectile-damage-6"].effects, {
      type = "ammo-damage",
      ammo_category = "Bio_Cannon_Ammo",
      modifier = 1.3
    })
    table.insert(data.raw.technology["physical-projectile-damage-7"].effects, {
      type = "ammo-damage",
      ammo_category = "Bio_Cannon_Ammo",
      modifier = 1
    })
    table.insert(data.raw.technology["artillery-shell-speed-1"].effects, {
      type = "gun-speed",
      ammo_category = "Bio_Cannon_Ammo",
      modifier = 1
    })
    table.insert(data.raw.technology["weapon-shooting-speed-5"].effects, {
      type = "gun-speed",
      ammo_category = "Bio_Cannon_Ammo",
      modifier = 0.8
    })
    table.insert(data.raw.technology["weapon-shooting-speed-6"].effects, {
      type = "gun-speed",
      ammo_category = "Bio_Cannon_Ammo",
      modifier = 1.5
    })
  end
end
