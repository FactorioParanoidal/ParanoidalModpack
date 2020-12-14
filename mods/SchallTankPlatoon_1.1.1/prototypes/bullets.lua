local cfg1 = require("config.config-1")
-- local TPpt = require("lib.TPpt")



local BLT_icon_layer =
{
  [1] = {icon = "__base__/graphics/icons/firearm-magazine.png", icon_size = 64, icon_mipmaps = 4},
  [2] = {icon = "__base__/graphics/icons/piercing-rounds-magazine.png", icon_size = 64, icon_mipmaps = 4},
  [3] = {icon = "__base__/graphics/icons/uranium-rounds-magazine.png", icon_size = 64, icon_mipmaps = 4},
}
local BLT_sniper_icon_layer = {icon = "__SchallTankPlatoon__/graphics/icons/sniper-bullet.png", icon_size = 128, icon_mipmaps = 3}

local BLT_sniper_damage_modifier = 2 -- Normal value is 1
local BLT_scale = 1 -- Normal value is 1
local BLT_collision_box = cfg1.collision_box_bullet
local BLT_force_condition = settings.startup["tankplatoon-bullet-force-condition"].value

local BLT_proj = cfg1.bullet_proj
local dra = data.raw.ammo



local DLV_specs =
{
  ["standard"] = {
    starting_speed = 1,                 -- Cannon : 1, Shotgun : 1
    starting_speed_deviation = 0.02,    -- Cannon : 0, Shotgun : 0.1
    direction_deviation = 0.05,         -- Cannon : 0.1, Shotgun : 0.3
    range_deviation = 0.05,             -- Cannon : 0.1, Shotgun : 0.3
    max_range = 22,
  },
  ["sniper"] = {
    starting_speed = 1.5,
    starting_speed_deviation = 0.01,
    direction_deviation = 0.01,
    range_deviation = 0.01,
    max_range = 48,
    min_range = 5,
  },
}


local BLT_specs =
{
  ["bullet-1"] = {
    name_AMMO = "firearm-magazine",
    name_PROJ = "Schall-firearm-bullet-projectile",
    category = "bullet",
    ammo = {
      icons = { BLT_icon_layer[1] },
      order = "a[basic-clips]-a[firearm-magazine]",
      magazine_size = 10,
      stack_size = 200,
    },
    damage = { amount = 5 , type = "physical" },
    delivery = DLV_specs.standard,
  },
  ["bullet-2"] = {
    name_AMMO = "piercing-rounds-magazine",
    name_PROJ = "Schall-piercing-rounds-bullet-projectile",
    category = "bullet",
    ammo = {
      icons = { BLT_icon_layer[2] },
      order = "a[basic-clips]-b[piercing-rounds-magazine]",
      magazine_size = 10,
      stack_size = 200,
    },
    damage = { amount = 8 , type = "physical" },
    delivery = DLV_specs.standard,
  },
  ["bullet-3"] = {
    name_AMMO = "uranium-rounds-magazine",
    name_PROJ = "Schall-uranium-rounds-bullet-projectile",
    category = "bullet",
    ammo = {
      icons = { BLT_icon_layer[3] },
      order = "a[basic-clips]-c[uranium-rounds-magazine]",
      magazine_size = 10,
      stack_size = 200,
    },
    damage = { amount = 24 , type = "physical" },
    delivery = DLV_specs.standard,
  },
  ["sniper-bullet-1"] = {
    name_AMMO = "Schall-sniper-firearm-magazine",
    name_PROJ = "Schall-sniper-firearm-bullet-projectile",
    category = "Schall-sniper-bullet",
    ammo = {
      icons = { BLT_icon_layer[1],
                BLT_sniper_icon_layer },
      order = "a[basic-clips]-s[sniper-rifle]-a[firearm-magazine]",
      magazine_size = 10,
      stack_size = 200,
    },
    damage = { amount = 5*BLT_sniper_damage_modifier , type = "physical" },
    delivery = DLV_specs.sniper,
  },
  ["sniper-bullet-2"] = {
    name_AMMO = "Schall-sniper-piercing-rounds-magazine",
    name_PROJ = "Schall-sniper-piercing-rounds-bullet-projectile",
    category = "Schall-sniper-bullet",
    ammo = {
      icons = { BLT_icon_layer[2],
                BLT_sniper_icon_layer },
      order = "a[basic-clips]-s[sniper-rifle]-b[piercing-rounds-magazine]",
      magazine_size = 10,
      stack_size = 200,
    },
    damage = { amount = 8*BLT_sniper_damage_modifier , type = "physical" },
    delivery = DLV_specs.sniper,
  },
  ["sniper-bullet-3"] = {
    name_AMMO = "Schall-sniper-uranium-rounds-magazine",
    name_PROJ = "Schall-sniper-uranium-rounds-bullet-projectile",
    category = "Schall-sniper-bullet",
    ammo = {
      icons = { BLT_icon_layer[3],
                BLT_sniper_icon_layer },
      order = "a[basic-clips]-s[sniper-rifle]-c[uranium-rounds-magazine]",
      magazine_size = 10,
      stack_size = 200,
    },
    damage = { amount = 24*BLT_sniper_damage_modifier , type = "physical" },
    delivery = DLV_specs.sniper,
  },
}


local function BLT_ammo_PROJ_ammo_type(spec)
  return
  {
    category = spec.category,
    target_type = "direction",
    clamp_position = true,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = spec.name_PROJ,
        starting_speed = spec.delivery.starting_speed or 1,
        starting_speed_deviation = spec.delivery.starting_speed_deviation or 0,
        direction_deviation = spec.delivery.direction_deviation or 0,
        range_deviation = spec.delivery.range_deviation or 0,
        max_range = spec.delivery.max_range or 18,
        min_range = spec.delivery.min_range or 0,
        source_effects =
        {
          type = "create-explosion",
          entity_name = "explosion-gunshot"
        }
      }
    }
  }
end

local function BLT_ammo_INST_ammo_type(spec)
  return
  {
    category = spec.category,
    action =
    {
      {
        type = "direct",
        action_delivery =
        {
          {
            type = "instant",
            source_effects =
            {
              {
                type = "create-explosion",
                entity_name = "explosion-gunshot"
              }
            },
            target_effects =
            {
              {
                type = "create-entity",
                entity_name = "explosion-hit"
              },
              {
                type = "damage",
                damage = spec.damage or { amount = 5 , type = "physical" }
              }
            }
          }
        }
      }
    }
  }
end

local function BLT_ammo(spec)
  local item =
  {
    type = "ammo",
    name = spec.name_AMMO,
    icons = spec.ammo.icons,
    ammo_type = BLT_ammo_INST_ammo_type(spec),
    magazine_size = spec.ammo.magazine_size or 10,
    subgroup = "ammo",
    order = spec.ammo.order,
    stack_size = spec.ammo.stack_size or 200
  }
  if BLT_proj then
    item.ammo_type = BLT_ammo_PROJ_ammo_type(spec)
  else
    item.ammo_type = BLT_ammo_INST_ammo_type(spec)
  end
  return item
end

local function BLT_projectile(spec)
  return
  {
    type = "projectile",
    name = spec.name_PROJ,
    flags = {"not-on-map"},
    collision_box = BLT_collision_box,
    force_condition = BLT_force_condition,
    acceleration = 0,
    direction_only = true,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = spec.damage
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high",
      scale = BLT_scale,
    }
  }
end



local dataextendlist = {}


for _, spec in pairs(BLT_specs) do
  if dra[spec.name_AMMO] then
    if BLT_proj and spec.ammo then
      dra[spec.name_AMMO].ammo_type = BLT_ammo_PROJ_ammo_type(spec)
    end
  else
    table.insert( dataextendlist, BLT_ammo(spec) )
  end
  if BLT_proj then
    table.insert( dataextendlist, BLT_projectile(spec) )
  end
end

if next(dataextendlist) ~= nil then
  data:extend(dataextendlist)
end