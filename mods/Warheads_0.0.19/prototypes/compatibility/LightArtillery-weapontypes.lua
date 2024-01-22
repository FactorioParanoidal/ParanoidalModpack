local icon
if mods["lightArtillery"] then
  icon = "__lightArtillery__/graphics/icons/artillery-shell.png"
elseif mods["lightArtillery-Balanced"] then
  icon = "__lightArtillery-Balanced__/graphics/icons/artillery-shell.png"
end
weaponTypes["derpy-artillery-ammo"]= {
  type = "artillery",
  max_size = "small",
  min_size = "tiny",
  ignore = not settings.startup["enable-derpy-artillery"].value,
  baseName = "derpy-artillery-ammo",
  base_item = "derpy-artillery-ammo",
  icon = icon,
  energy_required = 1,
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["derpy-artillery-ammo"]),
  projectile = table.deepcopy(data.raw["artillery-projectile"]["derpy-artillery-projectile"]),
}
