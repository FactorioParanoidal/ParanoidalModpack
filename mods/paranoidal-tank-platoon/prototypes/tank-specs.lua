-- Tank classes. Every number below is the final value from the Paranoidal Beta 8 data dump
-- (SchallTankPlatoon 1.1.2 with the Beta 8 settings), per class and tier (0 = base, 1 = MK1, 2 = MK2).

local function res(fire, physical, impact, explosion, acid, laser, electric)
  local list = {}
  for _, entry in pairs({
    {"fire", fire}, {"physical", physical}, {"impact", impact}, {"explosion", explosion},
    {"acid", acid}, {"laser", laser}, {"electric", electric},
  }) do
    local decrease, percent = entry[2][1], entry[2][2]
    if decrease ~= 0 or percent ~= 0 then
      table.insert(list, {type = entry[1], decrease = decrease, percent = percent})
    end
  end
  return list
end

-- Upgrade recipes take the previous tier as the first ingredient.
local function upgrade(time, ingredients)
  return {time = time, ingredients = ingredients}
end

return {
  {
    class = "L",
    order = 1,
    tint = {r = 0.7, g = 0.7, b = 0.7, a = 1},
    scale = 0.8,
    mining_time = 0.5,
    terrain_friction_modifier = 0.2,
    turret_rotation_speed = 0.4 / 60,
    rotation_speed = 0.004,
    guns = {"tank-autocannon", "tank-machine-gun-single"},
    grid = {width_add = -1, height_add = -1},
    tiers = {
      [0] = {max_health = 1000, braking_power = "200kW", consumption = "320kW", inventory_size = 20, weight = 8000,
        effectivity = 0.95, burner_effectivity = 1, fuel_inventory_size = 1,
        resistances = res({10, 50}, {10, 50}, {40, 70}, {10, 60}, {0, 60}, {0, 0}, {0, 0}),
        recipe = {time = 3, ingredients = {{"engine-unit", 16}, {"steel-plate", 25}, {"iron-gear-wheel", 8}, {"advanced-circuit", 5}}}},
      [1] = {max_health = 1500, braking_power = "240kW", consumption = "384kW", inventory_size = 30, weight = 8000,
        effectivity = 0.95, burner_effectivity = 1, fuel_inventory_size = 1,
        resistances = res({10, 55}, {10, 55}, {42, 70}, {12, 68}, {2, 60}, {5, 20}, {5, 20}),
        recipe = upgrade(6, {{"processing-unit", 30}, {"electric-engine-unit", 10}})},
      [2] = {max_health = 2000, braking_power = "300kW", consumption = "480kW", inventory_size = 40, weight = 8000,
        effectivity = 0.95, burner_effectivity = 1, fuel_inventory_size = 1,
        resistances = res({10, 60}, {10, 60}, {45, 70}, {15, 76}, {5, 60}, {10, 40}, {10, 40}),
        recipe = upgrade(10, {{"efficiency-module-2", 16}, {"speed-module-2", 16}})},
    },
  },
  {
    class = "M",
    order = 2,
    tint = {r = 0.6, g = 0.6, b = 0.6, a = 1},
    scale = 1,
    mining_time = 0.5,
    terrain_friction_modifier = 0.2,
    turret_rotation_speed = 0.35 / 60,
    rotation_speed = 0.0035,
    guns = {"tank-cannon", "tank-machine-gun"},
    grid = {width_add = 0, height_add = 0},
    tiers = {
      [0] = {max_health = 2000, braking_power = "400kW", consumption = "600kW", inventory_size = 20, weight = 20000,
        effectivity = 0.9, burner_effectivity = 1, fuel_inventory_size = 2,
        resistances = res({15, 60}, {15, 60}, {50, 80}, {15, 70}, {0, 70}, {0, 0}, {0, 0}),
        recipe = {time = 5, ingredients = {{"engine-unit", 32}, {"steel-plate", 50}, {"iron-gear-wheel", 15}, {"advanced-circuit", 10}}}},
      [1] = {max_health = 3000, braking_power = "480kW", consumption = "720kW", inventory_size = 30, weight = 20000,
        effectivity = 0.9, burner_effectivity = 1, fuel_inventory_size = 2,
        resistances = res({15, 65}, {15, 65}, {52, 80}, {17, 77}, {2, 70}, {5, 20}, {5, 20}),
        recipe = upgrade(10, {{"processing-unit", 40}, {"electric-engine-unit", 20}})},
      [2] = {max_health = 4000, braking_power = "600kW", consumption = "900kW", inventory_size = 40, weight = 20000,
        effectivity = 0.9, burner_effectivity = 1, fuel_inventory_size = 2,
        resistances = res({15, 70}, {15, 70}, {55, 80}, {20, 81}, {5, 70}, {10, 40}, {10, 40}),
        recipe = upgrade(15, {{"efficiency-module-2", 25}, {"speed-module-2", 25}})},
    },
  },
  {
    class = "H",
    order = 3,
    tint = {r = 0.5, g = 0.5, b = 0.5, a = 1},
    scale = 1.5,
    mining_time = 1,
    terrain_friction_modifier = 0.22,
    turret_rotation_speed = 0.1 / 60,
    rotation_speed = 0.002,
    guns = {"tank-cannon-H1", "tank-machine-gun"},
    grid = {width_add = 1, height_add = 0},
    tiers = {
      [0] = {max_health = 3000, braking_power = "660kW", consumption = "1000kW", inventory_size = 20, weight = 50000,
        effectivity = 0.75, burner_effectivity = 0.875, fuel_inventory_size = 2,
        resistances = res({15, 60}, {18, 65}, {55, 80}, {18, 75}, {3, 70}, {0, 0}, {0, 0}),
        recipe = {time = 20, ingredients = {{"engine-unit", 100}, {"steel-plate", 150}, {"iron-gear-wheel", 50}, {"advanced-circuit", 30}}}},
      [1] = {max_health = 4500, braking_power = "792kW", consumption = "1200kW", inventory_size = 30, weight = 50000,
        effectivity = 0.75, burner_effectivity = 0.875, fuel_inventory_size = 2,
        resistances = res({15, 65}, {18, 70}, {57, 80}, {20, 82}, {5, 70}, {5, 20}, {5, 20}),
        recipe = upgrade(40, {{"processing-unit", 80}, {"electric-engine-unit", 60}})},
      [2] = {max_health = 6000, braking_power = "990kW", consumption = "1500kW", inventory_size = 40, weight = 50000,
        effectivity = 0.75, burner_effectivity = 0.875, fuel_inventory_size = 2,
        resistances = res({15, 70}, {18, 75}, {60, 80}, {23, 86}, {8, 70}, {10, 40}, {10, 40}),
        recipe = upgrade(60, {{"efficiency-module-2", 32}, {"speed-module-2", 32}})},
    },
  },
  {
    class = "SH",
    order = 4,
    tint = {r = 0.4, g = 0.4, b = 0.4, a = 1},
    scale = 2,
    mining_time = 2,
    terrain_friction_modifier = 0.25,
    turret_rotation_speed = 0.025 / 60,
    rotation_speed = 0.001,
    guns = {"tank-cannon-H2", "tank-cannon-H2", "tank-machine-gun"},
    grid = {width_add = 1, height_add = 1},
    tiers = {
      [0] = {max_health = 4000, braking_power = "660kW", consumption = "1000kW", inventory_size = 20, weight = 100000,
        effectivity = 0.6, burner_effectivity = 0.666, fuel_inventory_size = 2,
        resistances = res({15, 60}, {20, 70}, {60, 80}, {20, 80}, {5, 70}, {0, 0}, {0, 0}),
        recipe = {time = 60, ingredients = {{"engine-unit", 300}, {"steel-plate", 400}, {"iron-gear-wheel", 120}, {"advanced-circuit", 80}, {"military-science-pack", 200}}}},
      [1] = {max_health = 6000, braking_power = "792kW", consumption = "1200kW", inventory_size = 30, weight = 100000,
        effectivity = 0.6, burner_effectivity = 0.666, fuel_inventory_size = 2,
        resistances = res({15, 65}, {20, 75}, {62, 80}, {22, 88}, {7, 70}, {5, 20}, {5, 20}),
        recipe = upgrade(120, {{"processing-unit", 160}, {"electric-engine-unit", 120}})},
      [2] = {max_health = 8000, braking_power = "990kW", consumption = "1500kW", inventory_size = 40, weight = 100000,
        effectivity = 0.6, burner_effectivity = 0.666, fuel_inventory_size = 2,
        resistances = res({15, 70}, {20, 78}, {65, 80}, {25, 93}, {10, 70}, {10, 40}, {10, 40}),
        recipe = upgrade(180, {{"efficiency-module-2", 40}, {"speed-module-2", 40}})},
    },
  },
  {
    class = "F",
    order = 5,
    tint = {r = 1, g = 0.4, b = 0, a = 1},
    tinted_icon = true,
    scale = 1,
    mining_time = 0.5,
    terrain_friction_modifier = 0.2,
    turret_rotation_speed = 0.35 / 60,
    rotation_speed = 0.0035,
    guns = {"tank-flamethrower", "tank-machine-gun"},
    grid = {width_add = 0, height_add = 0},
    tiers = {
      [0] = {max_health = 2000, braking_power = "400kW", consumption = "600kW", inventory_size = 20, weight = 20000,
        effectivity = 0.9, burner_effectivity = 1, fuel_inventory_size = 2,
        resistances = res({50, 100}, {10, 60}, {45, 80}, {10, 60}, {0, 70}, {0, 0}, {0, 0}),
        recipe = {time = 5, ingredients = {{"engine-unit", 32}, {"steel-plate", 50}, {"iron-gear-wheel", 15}, {"advanced-circuit", 10}}}},
      [1] = {max_health = 3000, braking_power = "480kW", consumption = "720kW", inventory_size = 30, weight = 20000,
        effectivity = 0.9, burner_effectivity = 1, fuel_inventory_size = 2,
        resistances = res({50, 100}, {10, 65}, {47, 80}, {12, 68}, {2, 70}, {5, 20}, {5, 20}),
        recipe = upgrade(10, {{"processing-unit", 40}, {"electric-engine-unit", 20}})},
      [2] = {max_health = 4000, braking_power = "600kW", consumption = "900kW", inventory_size = 40, weight = 20000,
        effectivity = 0.9, burner_effectivity = 1, fuel_inventory_size = 2,
        resistances = res({50, 100}, {10, 70}, {50, 80}, {15, 76}, {5, 70}, {10, 40}, {10, 40}),
        recipe = upgrade(15, {{"efficiency-module-2", 25}, {"speed-module-2", 25}})},
    },
  },
}
