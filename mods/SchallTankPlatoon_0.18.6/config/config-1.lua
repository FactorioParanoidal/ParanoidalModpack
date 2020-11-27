local config = {}

config.class_on =
{
  ["ht-RA"] = settings.startup["tankplatoon-ht-RA-enable"].value or mods["SchallMissileCommand"],
  ["armor-t3"] = mods["SchallAlienTech"] and settings.startup["alientech-armor-t3-enable"].value,
}

local tank_t1_on = settings.startup["tankplatoon-tank-t1-enable"].value
local tank_t2_on = tank_t1_on and settings.startup["tankplatoon-tank-t2-enable"].value
local tank_t3_on = config.class_on["armor-t3"] and tank_t2_on and settings.startup["alientech-tank-t3-enable"].value

config.tier_max = 3

config.tier_on =
{
  [0] = true,
  [1] = tank_t1_on,
  [2] = tank_t2_on,
  [3] = tank_t3_on,
}

config.tier_suffix =
{
  [0] = "",
  [1] = "-mk1",
  [2] = "-mk2",
  [3] = "-mk3",
}

config.hide_resistances = settings.startup["tankplatoon-vehicle-hide-resistances"].value

config.resistances_add = {
  [0] = {
    },
  [1] = {
      fire      = { decrease =  0,  percent =  5 },
      physical  = { decrease =  0,  percent =  5 },
      impact    = { decrease =  2,  percent =  0 },
      explosion = { decrease =  2,  percent =  8 },
      acid      = { decrease =  2,  percent =  0 },
      laser     = { decrease =  5,  percent = 20 },
      electric  = { decrease =  5,  percent = 20 }
    },
  [2] = {
      fire      = { decrease =  0,  percent = 10 },
      physical  = { decrease =  0,  percent = 10 },
      impact    = { decrease =  5,  percent =  0 },
      explosion = { decrease =  5,  percent = 16 },
      acid      = { decrease =  5,  percent =  0 },
      laser     = { decrease = 10,  percent = 40 },
      electric  = { decrease = 10,  percent = 40 }
    },
  [3] = {
      fire      = { decrease =  0,  percent = 15 },
      physical  = { decrease =  0,  percent = 15 },
      impact    = { decrease = 10,  percent =  0 },
      explosion = { decrease = 10,  percent = 24 },
      acid      = { decrease =  5,  percent =  5 },
      laser     = { decrease = 15,  percent = 60 },
      electric  = { decrease = 15,  percent = 60 }
    },
}

config.tier_health_mul =
{
  [0] = 1,
  [1] = 1.5,
  [2] = 2,
  [3] = 2.5,
}

config.tier_power_mul =
{
  [0] = 1,
  [1] = 1.2,
  [2] = 1.5,
  [3] = 3,
}

config.tier_weight_mul =
{
  [0] = 1,
  [1] = 1,
  [2] = 1,
  [3] = 1.5,
}

config.tier_inventory_size_add =
{
  [0] = 0,
  [1] = 10,
  [2] = 20,
  [3] = 40,
}

config.collision_box_none = {{0, 0}, {0, 0}}
config.collision_box_ori = {{-0.3, -1.1}, {0.3, 1.1}}



return config