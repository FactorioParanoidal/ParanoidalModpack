weaponTypes["Schall-sniper-magazine"]= {
  type = "bullet",
  size = 13,
  ignore = not settings.startup["enable-sniper-magazine"].value,
  baseName = "Schall-sniper-magazine",
  baseOrder = "a[basic-clips]-s[sniper-rifle]-d",
  base_item = "Schall-sniper-piercing-rounds-magazine",
  ammo_category = "Schall-sniper-bullet",
  icon = "__base__/graphics/icons/piercing-rounds-magazine.png",
  addon_icon = {icon = "__SchallTankPlatoon__/graphics/icons/sniper-bullet.png", icon_size = 128, icon_mipmaps = 3},
  energy_required = 1,
  warhead_count = 10,
  appearance_fallback = "rounds-magazine",
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["piercing-rounds-magazine"]),
}
weaponTypes["autocannon-shell"]= {
  type = "projectile",
  size = 17,
  ignore = not settings.startup["enable-autocannon"].value,
  baseName = "autocannon-shell",
  baseOrder = "d[f-z-autocannon-shell]-a",
  base_item = "explosive-autocannon-shell",
  ammo_category = "autocannon-shell",
  energy_required = 1,
  range_modifier = 3,
  icons = {},
  lights = {},
  item = table.deepcopy(data.raw.ammo["explosive-autocannon-shell"]),
  projectile = table.deepcopy(data.raw.projectile["explosive-autocannon-projectile"]),
}
--weaponTypes["cannon-shell-75"]= weaponTypes["cannon-shell"]
--
--weaponTypes["cannon-shell-75"].baseName = "cannon-shell-75"
--
--weaponTypes["cannon-shell-75"].appearance_fallback = "cannon-shell"
--
--weaponTypes["cannon-shell"].ignore = true

weaponTypes["cannon-shell-88"]= {
  type = "projectile",
  size = 24,
  ignore = not settings.startup["enable-cannon-shell-88"].value,
  baseName = "cannon-shell-88",
  baseOrder = "d[cannon-shell]-d",
  base_item = "cannon-H1-shell",
  ammo_category = "cannon-H1-shell",
  icon = "__base__/graphics/icons/cannon-shell.png",
  addon_icon = {icon = "__SchallTankPlatoon__/graphics/icons/H1.png", icon_size = 128, icon_mipmaps = 3},
  energy_required = 1,
  range_modifier = 3,
  appearance_fallback = "cannon-shell",
  icons = {},
  lights = {},
  image_base_shift = {-4, 0},
  image_warhead_shift = {8, 8},
  item = table.deepcopy(data.raw.ammo["cannon-H1-shell"]),
  projectile = table.deepcopy(data.raw.projectile["cannon-H1-projectile"]),
}
weaponTypes["cannon-shell-128"]= {
  type = "projectile",
  size = 27,
  ignore = not settings.startup["enable-cannon-shell-128"].value,
  baseName = "cannon-shell-128",
  baseOrder = "d[cannon-shell]-d",
  base_item = "cannon-H2-shell",
  ammo_category = "cannon-H2-shell",
  icon = "__base__/graphics/icons/cannon-shell.png",
  addon_icon = {icon = "__SchallTankPlatoon__/graphics/icons/H2.png", icon_size = 128, icon_mipmaps = 3},
  energy_required = 1,
  range_modifier = 3,
  appearance_fallback = "cannon-shell",
  icons = {},
  lights = {},
  image_base_shift = {-4, 0},
  image_warhead_shift = {8, 8},
  item = table.deepcopy(data.raw.ammo["cannon-H2-shell"]),
  projectile = table.deepcopy(data.raw.projectile["cannon-H2-projectile"]),
}
