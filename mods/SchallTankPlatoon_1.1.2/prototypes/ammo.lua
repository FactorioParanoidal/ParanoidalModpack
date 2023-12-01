local TPlib = require("__SchallTankPlatoon__.lib.TPlib")
local cfg1 = require("config.config-1")



local C_shell_icon_layer =
{
  ["AP"]    = {icon = "__base__/graphics/icons/cannon-shell.png", icon_size = 64, icon_mipmaps = 4},
  ["HE"]    = {icon = "__base__/graphics/icons/explosive-cannon-shell.png", icon_size = 64, icon_mipmaps = 4},
  ["DUAP"]  = {icon = "__base__/graphics/icons/uranium-cannon-shell.png", icon_size = 64, icon_mipmaps = 4},
  ["DUHE"]  = {icon = "__base__/graphics/icons/explosive-uranium-cannon-shell.png", icon_size = 64, icon_mipmaps = 4},
}
local AC_shell_icon_layer =
{
  ["HE"]    = {icon = "__SchallTankPlatoon__/graphics/icons/explosive-autocannon-shell.png", icon_size = 64, icon_mipmaps = 4},
  ["DUHE"]  = {icon = "__SchallTankPlatoon__/graphics/icons/explosive-uranium-autocannon-shell.png", icon_size = 64, icon_mipmaps = 4},
  ["IN"]    = {icon = "__SchallTankPlatoon__/graphics/icons/incendiary-autocannon-shell.png", icon_size = 64, icon_mipmaps = 4},
}
local ROC_icon_layer =
{
  ["HEpack"] = {icon = "__SchallTankPlatoon__/graphics/icons/explosive-rocket-pack.png", icon_size = 64, icon_mipmaps = 4},
}

-- local basic_icon_spec = {suffix = "M", tint = {r=0.5, g=0.5, b=0.5, a=1}}
local IN_icon_spec = {suffix = "M", tint = {r=1, g=1, b=1, a=1}}
local NP_icon_spec = {suffix = "H", tint = {r=1, g=1, b=1, a=1}}
local PO_icon_spec = {suffix = "H", tint = {r=1, g=1, b=0, a=1}}

local function ROC_icons(spec)
  return
  {
    {icon = "__base__/graphics/icons/rocket.png", icon_size = 64, icon_mipmaps = 4},
    {icon = "__SchallTankPlatoon__/graphics/icons/rocket-to-tint-"..spec.suffix..".png", icon_size = 64, icon_mipmaps = 4, tint = spec.tint}
  }
end



data:extend
{
  -- Autocannon Shell
  {
    type = "ammo",
    name = "explosive-autocannon-shell",
    icons = { AC_shell_icon_layer.HE },
    ammo_type =
    {
      category = "autocannon-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "explosive-autocannon-projectile", --"explosive-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 20, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small" --"explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[f-explosive-autocannon-shell]-a[basic]", --"d[cannon-shell]-c[explosive]",
    magazine_size = 10, --1,
    stack_size = 200
  },
  {
    type = "ammo",
    name = "explosive-uranium-autocannon-shell",
    icons = { AC_shell_icon_layer.DUHE },
    ammo_type =
    {
      category = "autocannon-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "explosive-uranium-autocannon-projectile", --"explosive-uranium-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 20, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small" --"explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[f-explosive-autocannon-shell]-c[uranium]", --"d[explosive-cannon-shell]-c[uranium]",
    magazine_size = 10, --1,
    stack_size = 200
  },
  -- Rocket
  {
    type = "ammo",
    name = "Schall-explosive-rocket-pack",
    icons = { ROC_icon_layer.HEpack },
    ammo_type =
    {
      {
        source_type = "default",
        category = "rocket",

        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "projectile",
            projectile = "explosive-rocket",
            starting_speed = 0.1,
            min_range = 10, --0,
            source_effects =
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            }
          }
        }
      },
      {
        source_type = "vehicle",
        category = "rocket",
        target_type = "position",
        clamp_position = true,

        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "projectile",
            projectile = "Schall-explosive-rocket-pack", --"explosive-rocket"
            starting_speed = 0.1,
            source_effects =
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            }
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-b[explosive]-1[pack]",
    stack_size = 50
  },
  -- High-Caliber Cannon Shell
  {
    type = "ammo",
    name = "cannon-H1-shell",
    icons = { C_shell_icon_layer.AP,
              TPlib.caliber_H1_icon_layer },
    ammo_type =
    {
      category = "cannon-H1-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "cannon-H1-projectile",-- "cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 30, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[cannon-shell]-a[basic]-1",
    stack_size = 100
  },
  {
    type = "ammo",
    name = "cannon-H2-shell",
    icons = { C_shell_icon_layer.AP,
              TPlib.caliber_H2_icon_layer },
    ammo_type =
    {
      category = "cannon-H2-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "cannon-H2-projectile",-- "cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 35, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[cannon-shell]-a[basic]-2",
    stack_size = 50
  },
  {
    type = "ammo",
    name = "explosive-cannon-H1-shell",
    icons = { C_shell_icon_layer.HE,
              TPlib.caliber_H1_icon_layer },
    ammo_type =
    {
      category = "cannon-H1-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "explosive-cannon-H1-projectile", --"explosive-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 30, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[cannon-shell]-c[explosive]-1", --"d[cannon-shell]-c[explosive]",
    stack_size = 100
  },
  {
    type = "ammo",
    name = "explosive-cannon-H2-shell",
    icons = { C_shell_icon_layer.HE,
              TPlib.caliber_H2_icon_layer },
    ammo_type =
    {
      category = "cannon-H2-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "explosive-cannon-H2-projectile", --"explosive-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 35, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[cannon-shell]-c[explosive]-2", --"d[cannon-shell]-c[explosive]",
    stack_size = 50
  },
  {
    type = "ammo",
    name = "uranium-cannon-H1-shell",
    icons = { C_shell_icon_layer.DUAP,
              TPlib.caliber_H1_icon_layer },
    ammo_type =
    {
      category = "cannon-H1-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "uranium-cannon-H1-projectile",-- "uranium-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 30, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[cannon-shell]-c[uranium]-1",-- "d[cannon-shell]-c[uranium]",
    stack_size = 100
  },
  {
    type = "ammo",
    name = "uranium-cannon-H2-shell",
    icons = { C_shell_icon_layer.DUAP,
              TPlib.caliber_H2_icon_layer },
    ammo_type =
    {
      category = "cannon-H2-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "uranium-cannon-H2-projectile",-- "uranium-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 35, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[cannon-shell]-c[uranium]-2",-- "d[cannon-shell]-c[uranium]",
    stack_size = 50
  },
  {
    type = "ammo",
    name = "explosive-uranium-cannon-H1-shell",
    icons = { C_shell_icon_layer.DUHE,
              TPlib.caliber_H1_icon_layer },
    ammo_type =
    {
      category = "cannon-H1-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "explosive-uranium-cannon-H1-projectile",-- "explosive-uranium-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 30, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[explosive-cannon-shell]-c[uranium]-1",-- "d[explosive-cannon-shell]-c[uranium]",
    stack_size = 100
  },
  {
    type = "ammo",
    name = "explosive-uranium-cannon-H2-shell",
    icons = { C_shell_icon_layer.DUHE,
              TPlib.caliber_H2_icon_layer },
    ammo_type =
    {
      category = "cannon-H2-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "explosive-uranium-cannon-H2-projectile",-- "explosive-uranium-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 35, --30,
          min_range = 5,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[explosive-cannon-shell]-c[uranium]-2",-- "d[explosive-cannon-shell]-c[uranium]",
    stack_size = 50
  },
  -- Incendiary Autocannon Shell
  {
    type = "ammo",
    name = "incendiary-autocannon-shell",
    icons = { AC_shell_icon_layer.IN },
    ammo_type =
    {
      category = "autocannon-shell", --"cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "incendiary-autocannon-projectile", --"explosive-uranium-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 20, --30,
          min_range = 5, --0,
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small" --"explosion-gunshot"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[f-incendiary-autocannon-shell]", --"d[explosive-cannon-shell]-c[uranium]",
    magazine_size = 10, --1,
    stack_size = 200
  },
  -- Incendiary Rocket
  {
    type = "ammo",
    name = "Schall-incendiary-rocket",
    icons = ROC_icons(IN_icon_spec),
    ammo_type =
    {
      -- target_type = "position",
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "Schall-incendiary-rocket",
          starting_speed = 0.05,
          source_effects =
          {
            type = "create-entity",
            entity_name = "explosion-hit"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-d[incendiary-rocket]",
    stack_size = 200
  },
  -- Napalm Bomb
  {
    type = "ammo",
    name = "Schall-napalm-bomb",
    icons = ROC_icons(NP_icon_spec),
    ammo_type =
    {
      range_modifier = 3,
      cooldown_modifier = 3,
      target_type = "position",
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "Schall-napalm-rocket",--"atomic-rocket",
          starting_speed = 0.05,
          source_effects =
          {
            type = "create-entity",
            entity_name = "explosion-hit"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-i[napalm-bomb]",
    stack_size = 10
  },
  -- Poison Bomb
  {
    type = "ammo",
    name = "Schall-poison-bomb",
    icons = ROC_icons(PO_icon_spec),
    ammo_type =
    {
      range_modifier = 3,
      cooldown_modifier = 3,
      target_type = "position",
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "Schall-poison-rocket",
          starting_speed = 0.05,
          source_effects =
          {
            type = "create-entity",
            entity_name = "explosion-hit"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-k[poison-bomb]",
    stack_size = 10
  },
}
