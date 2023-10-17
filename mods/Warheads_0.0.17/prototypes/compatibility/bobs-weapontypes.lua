
weaponTypes["small-rocket"].base_item = "rocket-body"
weaponTypes["small-rocket"].item = table.deepcopy(data.raw.ammo["bob-rocket"])
weaponTypes["small-rocket"].projectile = table.deepcopy(data.raw.projectile["bob-rocket"])

weaponTypes["big-rocket"].base_item = "rocket-body"
weaponTypes["big-rocket"].item = table.deepcopy(data.raw.ammo["bob-rocket"])
weaponTypes["big-rocket"].projectile = table.deepcopy(data.raw.projectile["bob-rocket"])

weaponTypes["rocket"].base_item = "rocket-body"
weaponTypes["rocket"].item = table.deepcopy(data.raw.ammo["bob-rocket"])
weaponTypes["rocket"].projectile = table.deepcopy(data.raw.projectile["bob-rocket"])



weaponTypes["rounds-magazine"].base_item = "piercing-rounds-magazine"

weaponTypes["rounds-magazine"].icon = "__bobwarfare__/graphics/icons/bullet-magazine.png"
weaponTypes["rounds-magazine"].extra_ingredients = {
  {"bullet-casing", 5},
  {"cordite", 5}
}

weaponTypes["rounds-magazine"].item = table.deepcopy(data.raw.ammo["bullet-magazine"])


weaponTypes["shotgun-shell"].base_item = "shotgun-shell-casing"
weaponTypes["shotgun-shell"].extra_ingredients = {{"cordite", 1}}
weaponTypes["shotgun-shell"].icon = {icon = "__bobwarfare__/graphics/icons/shotgun-shell.png", icon_size = 32}
weaponTypes["shotgun-shell"].item = table.deepcopy(data.raw.ammo["better-shotgun-shell"])
weaponTypes["shotgun-shell"].projectile = table.deepcopy(data.raw.projectile["better-shotgun-projectile"])


weaponTypes["shotgun-shell-slug"].base_item = "shotgun-shell-casing"
weaponTypes["shotgun-shell-slug"].extra_ingredients = {{"cordite", 1}}
weaponTypes["shotgun-shell-slug"].icon = {icon = "__bobwarfare__/graphics/icons/shotgun-shell.png", icon_size = 32}
weaponTypes["shotgun-shell-slug"].projectile = table.deepcopy(data.raw.projectile["better-shotgun-projectile"])


weaponTypes["shotgun-shell-buckshot"].base_item = "shotgun-shell-casing"
weaponTypes["shotgun-shell-buckshot"].extra_ingredients = {{"cordite", 1}}
weaponTypes["shotgun-shell-buckshot"].icon = {icon = "__bobwarfare__/graphics/icons/shotgun-shell.png", icon_size = 32}
weaponTypes["shotgun-shell-buckshot"].projectile = table.deepcopy(data.raw.projectile["better-shotgun-projectile"])


weaponTypes["shotgun-shell-birdshot"].base_item = "shotgun-shell-casing"
weaponTypes["shotgun-shell-birdshot"].extra_ingredients = {{"cordite", 1}}
weaponTypes["shotgun-shell-birdshot"].icon = {icon = "__bobwarfare__/graphics/icons/shotgun-shell.png", icon_size = 32}
weaponTypes["shotgun-shell-birdshot"].projectile = table.deepcopy(data.raw.projectile["better-shotgun-projectile"])