local shared = require("prototypes.shared")

local base_icon = "__base__/graphics/icons/"

local function shell(spec)
  return {
    type = "ammo",
    name = spec.name,
    icons = spec.icons,
    ammo_category = spec.category,
    ammo_type = {
      target_type = "direction",
      action = {
        type = "direct",
        action_delivery = {
          type = "projectile",
          projectile = spec.projectile,
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = spec.max_range,
          min_range = 5,
          source_effects = {type = "create-explosion", entity_name = spec.muzzle or "explosion-gunshot"}
        }
      }
    },
    magazine_size = spec.magazine_size,
    subgroup = "ammo",
    order = spec.order,
    stack_size = spec.stack_size
  }
end

local function autocannon_shell(name, projectile, icon, order)
  return shell({
    name = name, category = "autocannon-shell", projectile = projectile,
    icons = {{icon = shared.icons .. icon}}, max_range = 20, muzzle = "explosion-gunshot-small",
    magazine_size = 10, order = order, stack_size = 200
  })
end

-- High-calibre cannon shells: same icon as the 75 mm shell plus a calibre mark.
local function cannon_shell(name, caliber, base, order)
  local heavy = caliber == "H2"
  return shell({
    name = name, category = "cannon-" .. caliber .. "-shell", projectile = (name:gsub("%-shell$", "-projectile")),
    icons = {{icon = base_icon .. base .. ".png"}, shared.caliber_icon[caliber]},
    max_range = heavy and 35 or 30, order = order, stack_size = heavy and 50 or 100
  })
end

local function sniper_magazine(name, base, damage, order)
  return {
    type = "ammo",
    name = name,
    icons = {{icon = base_icon .. base .. ".png"}, {icon = shared.icons .. "sniper-bullet.png", icon_size = 128}},
    ammo_category = "Schall-sniper-bullet",
    ammo_type = {
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {type = "create-explosion", entity_name = "explosion-gunshot"},
          target_effects = {
            {type = "create-entity", entity_name = "explosion-hit"},
            {type = "damage", damage = {amount = damage, type = "physical"}}
          }
        }
      }
    },
    magazine_size = 10,
    subgroup = "ammo",
    order = order,
    stack_size = 200
  }
end

data:extend({
  autocannon_shell("explosive-autocannon-shell", "explosive-autocannon-projectile", "explosive-autocannon-shell.png", "d[f-explosive-autocannon-shell]-a[basic]"),
  autocannon_shell("explosive-uranium-autocannon-shell", "explosive-uranium-autocannon-projectile", "explosive-uranium-autocannon-shell.png", "d[f-explosive-autocannon-shell]-c[uranium]"),
  autocannon_shell("incendiary-autocannon-shell", "incendiary-autocannon-projectile", "incendiary-autocannon-shell.png", "d[f-incendiary-autocannon-shell]"),

  cannon_shell("cannon-H1-shell", "H1", "cannon-shell", "d[cannon-shell]-a[basic]-1"),
  cannon_shell("cannon-H2-shell", "H2", "cannon-shell", "d[cannon-shell]-a[basic]-2"),
  cannon_shell("explosive-cannon-H1-shell", "H1", "explosive-cannon-shell", "d[cannon-shell]-c[explosive]-1"),
  cannon_shell("explosive-cannon-H2-shell", "H2", "explosive-cannon-shell", "d[cannon-shell]-c[explosive]-2"),
  cannon_shell("uranium-cannon-H1-shell", "H1", "uranium-cannon-shell", "d[cannon-shell]-c[uranium]-1"),
  cannon_shell("uranium-cannon-H2-shell", "H2", "uranium-cannon-shell", "d[cannon-shell]-c[uranium]-2"),
  cannon_shell("explosive-uranium-cannon-H1-shell", "H1", "explosive-uranium-cannon-shell", "d[explosive-cannon-shell]-c[uranium]-1"),
  cannon_shell("explosive-uranium-cannon-H2-shell", "H2", "explosive-uranium-cannon-shell", "d[explosive-cannon-shell]-c[uranium]-2"),

  {
    type = "ammo",
    name = "Schall-incendiary-rocket",
    icons = {
      {icon = base_icon .. "rocket.png"},
      {icon = shared.icons .. "rocket-to-tint-M.png", tint = {r = 1, g = 1, b = 1, a = 1}}
    },
    ammo_category = "rocket",
    ammo_type = {
      action = {
        type = "direct",
        action_delivery = {
          type = "projectile",
          projectile = "Schall-incendiary-rocket",
          starting_speed = 0.05,
          source_effects = {type = "create-entity", entity_name = "explosion-hit"}
        }
      }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-d[incendiary-rocket]",
    stack_size = 200
  },

  sniper_magazine("Schall-sniper-firearm-magazine", "firearm-magazine", 10, "a[basic-clips]-s[sniper-rifle]-a[firearm-magazine]"),
  sniper_magazine("Schall-sniper-piercing-rounds-magazine", "piercing-rounds-magazine", 16, "a[basic-clips]-s[sniper-rifle]-b[piercing-rounds-magazine]"),
  sniper_magazine("Schall-sniper-uranium-rounds-magazine", "uranium-rounds-magazine", 48, "a[basic-clips]-s[sniper-rifle]-c[uranium-rounds-magazine]"),
})
