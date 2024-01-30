weaponTypes["shotgun-shell-birdshot"]= {
  type = "projectile",
  ignore = not settings.startup["enable-shotgun-bird"].value,
  size = 1,
  baseName = "shotgun-shell-birdshot",
  baseOrder = "b[shotgun]-f",
  base_item = "piercing-shotgun-shell",
  icon = "__base__/graphics/icons/piercing-shotgun-shell.png",
  energy_required = 0.5,
  warhead_count = 20*10,
  collide_anyway = true,
  appearance_fallbacks = {"shotgun-shell", "shotgun-shell-slug", "shotgun-shell-buckshot"},
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["piercing-shotgun-shell"]),
  projectile = table.deepcopy(data.raw.projectile["piercing-shotgun-pellet"]),
}
local shotgunActionIndex = 1
if  (data.raw.ammo["piercing-shotgun-shell"].ammo_type.action[2]) then
  shotgunActionIndex = 2
end 
weaponTypes["shotgun-shell-birdshot"].item.ammo_type.action[shotgunActionIndex].repeat_count = 20
weaponTypes["shotgun-shell-birdshot"].item.ammo_type.action[shotgunActionIndex].action_delivery = {
  type = "projectile",
  projectile = "piercing-shotgun-pellet",
  starting_speed = 1,
  starting_speed_deviation = 0.3,
  direction_deviation = 0.4,
  range_deviation = 0.5,
  max_range = 12
}

weaponTypes["shotgun-shell-buckshot"]= {
  type = "projectile",
  size = 4,
  ignore = not settings.startup["enable-shotgun-buck"].value,
  baseName = "shotgun-shell-buckshot",
  baseOrder = "b[shotgun]-e",
  base_item = "piercing-shotgun-shell",
  icon = "__base__/graphics/icons/piercing-shotgun-shell.png",
  energy_required = 0.5,
  warhead_count = 6*10,
  collide_anyway = true,
  appearance_fallbacks = {"shotgun-shell", "shotgun-shell-slug", "shotgun-shell-birdshot"},
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["piercing-shotgun-shell"]),
  projectile = table.deepcopy(data.raw.projectile["piercing-shotgun-pellet"]),
}
weaponTypes["shotgun-shell-buckshot"].item.ammo_type.action[shotgunActionIndex].repeat_count = 6

weaponTypes["shotgun-shell-slug"]= {
  type = "projectile",
  size = 14,
  ignore = not settings.startup["enable-shotgun-slug"].value,
  baseName = "shotgun-shell-slug",
  baseOrder = "b[shotgun]-d",
  base_item = "piercing-shotgun-shell",
  icon = "__base__/graphics/icons/piercing-shotgun-shell.png",
  energy_required = 0.5,
  warhead_count = 10,
  collide_anyway = true,
  appearance_fallbacks = {"shotgun-shell", "shotgun-shell-buckshot", "shotgun-shell-birdshot"},
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["piercing-shotgun-shell"]),
  projectile = table.deepcopy(data.raw.projectile["piercing-shotgun-pellet"]),
}
weaponTypes["shotgun-shell-slug"].item.ammo_type.action[shotgunActionIndex].repeat_count = 1
if weaponTypes["shotgun-shell-slug"].item.ammo_type.action[shotgunActionIndex].action_delivery.type then
  weaponTypes["shotgun-shell-slug"].item.ammo_type.action[shotgunActionIndex].action_delivery.direction_deviation = 0
else
  weaponTypes["shotgun-shell-slug"].item.ammo_type.action[shotgunActionIndex].action_delivery[1].direction_deviation = 0
end

weaponTypes["shotgun-shell"]= { -- DO NOT USE, ONLY HERE AS FALLBACK...
  type = "projectile",
  ignore = true,
  size = 3,
  baseName = "shotgun-shell",
  baseOrder = "b[shotgun]-d",
  base_item = "piercing-shotgun-shell",
  icon = "__base__/graphics/icons/piercing-shotgun-shell.png",
  energy_required = 0.5,
  warhead_count = 10,
  collide_anyway = true,
  appearance_fallbacks = {"shotgun-shell-slug", "shotgun-shell-buckshot", "shotgun-shell-birdshot"},
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["piercing-shotgun-shell"]),
  projectile = table.deepcopy(data.raw.projectile["piercing-shotgun-pellet"]),
}


weaponTypes["rounds-magazine"]= {
  type = "bullet",
  size = "tiny",
  ignore = not settings.startup["enable-magazine"].value,
  baseName = "rounds-magazine",
  baseOrder = "a[basic-clips]-d",
  base_item = "piercing-rounds-magazine",
  icon = "__base__/graphics/icons/piercing-rounds-magazine.png",
  energy_required = 0.5,
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["piercing-rounds-magazine"]),
}

if data.raw.projectile["p-r-bullet"] then
  weaponTypes["rounds-magazine"].type = "projectile"
  weaponTypes["rounds-magazine"].projectile = table.deepcopy(data.raw.projectile["p-r-bullet"])
elseif data.raw.projectile["piercing-rounds-bullet"] then
  weaponTypes["rounds-magazine"].type = "projectile"
  weaponTypes["rounds-magazine"].projectile = table.deepcopy(data.raw.projectile["piercing-rounds-bullet"])
elseif data.raw.projectile["piercing-bullet"] then
  weaponTypes["rounds-magazine"].type = "projectile"
  weaponTypes["rounds-magazine"].projectile = table.deepcopy(data.raw.projectile["piercing-bullet"])
end

weaponTypes["cannon-shell"]= {
  type = "projectile",
  size = "small",
  ignore = not settings.startup["enable-cannon-shell"].value,
  baseName = "cannon-shell",
  baseOrder = "d[explosive-cannon-shell]-cz",
  base_item = "cannon-shell",
  icon = "__base__/graphics/icons/cannon-shell.png",
  energy_required = 1,
  icons = {},
  lights = {},
  range_modifier = 3,
  image_base_shift = {-4, 0},
  item = table.deepcopy(data.raw.ammo["cannon-shell"]),
  projectile = table.deepcopy(data.raw.projectile["cannon-projectile"]),
}
weaponTypes["rocket"]= {-- DO NOT USE, ONLY HERE AS FALLBACK...
  type = "projectile",
  ignore = true,
  size = "small",
  baseName = "small-rocket",
  baseOrder = "d[rocket-launcher]-c",
  base_item = "rocket",
  icon = "__base__/graphics/icons/rocket.png",
  energy_required = 1,
  appearance_fallbacks = {"small-rocket", "big-rocket"},
  icons = {},
  lights = {},
  image_base_shift = {-4, 0},
  item = table.deepcopy(data.raw.ammo["rocket"]),
  projectile = table.deepcopy(data.raw.projectile["rocket"]),
}

weaponTypes["small-rocket"]= {
  type = "projectile",
  size = "small",
  ignore = not settings.startup["enable-small-rocket"].value,
  baseName = "small-rocket",
  baseOrder = "d[rocket-launcher]-c",
  base_item = "rocket",
  icon = "__base__/graphics/icons/rocket.png",
  energy_required = 1,
  appearance_fallbacks = {"big-rocket", "rocket"},
  icons = {},
  lights = {},
  image_base_shift = {-4, 0},
  item = table.deepcopy(data.raw.ammo["rocket"]),
  projectile = table.deepcopy(data.raw.projectile["rocket"]),
}
weaponTypes["big-rocket"]= {
  type = "projectile",
  size = "medium",
  ignore = not settings.startup["enable-big-rocket"].value,
  min_size = "tiny",
  baseName = "big-rocket",
  baseOrder = "d[rocket-launcher]-d",
  base_item = "rocket",
  icon = "__base__/graphics/icons/rocket.png",
  extra_ingredients = {{"rocket-control-unit", 5}, {"rocket-fuel", 10}},
  energy_required = 12,
  range_modifier = 3,
  cooldown_modifier = 10,
  appearance_fallbacks = {"small-rocket", "rocket"},
  icons = {},
  lights = {},
  image_base_shift = {-4, 0},
  item = table.deepcopy(data.raw.ammo["rocket"]),
  projectile = table.deepcopy(data.raw.projectile["rocket"]),
}
weaponTypes["artillery-shell"]= {
  type = "artillery",
  max_size = "large",
  min_size = "small",
  ignore = not settings.startup["enable-artillery-shell"].value,
  baseName = "artillery-shell",
  base_item = "artillery-shell",
  icon = "__base__/graphics/icons/artillery-shell.png",
  energy_required = 2,
  icons = {},
  lights = {},
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  item = table.deepcopy(data.raw.ammo["artillery-shell"]),
  projectile = table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"]),
}
weaponTypes["land-mine"]= {
  type = "land-mine",
  max_size = "huge",
  min_size = "tiny",
  ignore = not settings.startup["enable-land-mine"].value,
  baseName = "land-mine",
  base_item = "land-mine",
  icon = "__base__/graphics/icons/land-mine.png",
  energy_required = 0.5,
  icons = {},
  lights = {},
  item = table.deepcopy(data.raw.item["land-mine"]),
  landmine = table.deepcopy(data.raw["land-mine"]["land-mine"]),
}
weaponTypes["capsule"]= {
  type = "capsule",
  max_size = "medium",
  ignore = not settings.startup["enable-capsule"].value,
  baseName = "capsule",
  base_item = "grenade",
  icon = "__base__/graphics/icons/grenade.png",
  energy_required = 0.5,
  icons = {},
  lights = {},
  item = table.deepcopy(data.raw.capsule["grenade"]),
  projectile = table.deepcopy(data.raw["projectile"]["grenade"]),
}

weaponTypes["warhead-util-projectile"]= {
  type = "artillery",
  baseName = "warhead-util-projectile",
  base_item = "infinity-chest",
  icon = "__base__/graphics/icons/infinity-chest.png",
  energy_required = 3000,
  item = table.deepcopy(data.raw.ammo["artillery-shell"]),
  projectile = table.deepcopy(data.raw["artillery-projectile"]["artillery-projectile"]),
  image_base_shift = {4, 2},
  image_warhead_shift = {-8, -8},
  projectile_acceleration = 1,
  ammo_category = "artillery-shell"
}
weaponNoTech["warhead-util-projectile"] = true
