local cfg1 = require("config.config-1")
local TPpt = require("lib.TPpt")



local VEH_specs =
{
  ["tank-L"] = {
    name = "Schall-tank-L",
    enable = true,
    tint = {r=0.7, g=0.7, b=0.7, a=1},
    icon_base = "ori",
    scale = 0.8,  --1,
    mining_time = 0.5,
    subcat = "b[tank]-c[conventional]-1-",
    base_health = 10000, --2000, --DrD x10
    base_braking_power = 200, --400,
    base_consumption = 320, --600,
    effectivity = 0.95, --0.9,
    burner_effectivity = 1,
    burner_fuel_inventory_size = 1, --2,
    terrain_friction_modifier = 0.2,
    weight = 8000, --20000,
    base_inventory_size = 20,
    turret_rotation_speed = 0.4 / 60, --0.35 / 60,
    rotation_speed = 0.004, --0.0035,
    base_resistances = {
      fire      = { decrease = 10,  percent = 50 },
      physical  = { decrease = 10,  percent = 50 },
      impact    = { decrease = 40,  percent = 70 },
      explosion = { decrease = 10,  percent = 60 },
      acid      = { decrease =  0,  percent = 60 },
      laser     = { decrease =  0,  percent =  0 },
      electric  = { decrease =  0,  percent =  0 }
    },
    grid = {
      width_add = -1,
      height_add = -1,
      equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank"}
    },
    guns = {
      [0] = { "tank-autocannon", "tank-machine-gun-single" },
      [1] = { "tank-autocannon", "tank-machine-gun-single" },
      [2] = { "tank-autocannon", "tank-machine-gun-single" },
      [3] = { "tank-autocannon", "tank-machine-gun-single" },
    },
    recipe_specs = {
      [0] = {
        normal =
        {
          energy_required = 3,
          ingredients =
          {
            {"engine-unit", 16},
            {"steel-plate", 250}, --DrD x10
            {"iron-gear-wheel", 80}, --DrD x10
            {"advanced-circuit", 50} --DrD x10
          }
        },
        expensive =
        {
          energy_required = 5,
          ingredients =
          {
            {"engine-unit", 32},
            {"steel-plate", 50},
            {"iron-gear-wheel", 15},
            {"advanced-circuit", 10}
          }
        }
      },
      [1] = {
        energy_required = 6,
        ingredients =
        {
          {"__VEH__0__", 1},  -- Special string to call for name generation
          {"processing-unit", 30},
          {"electric-engine-unit", 10},
        }
      },
      [2] = {
        energy_required = 10,
        ingredients =
        {
          {"__VEH__1__", 1},
          {"effectivity-module-2", 16},
          {"speed-module-2", 16},
        }
      },
      [3] = {
        energy_required = 15,
        ingredients =
        {
          {"__VEH__2__", 1},
          {"alien-artifact", 300},
          {"low-density-structure", 30},
          {"space-science-pack", 30},
          {"vehicle-nuclear-reactor-equipment", 1}
        }
      },
    },
  },
  ["tank-M"] = {
    name = "Schall-tank-M",
    enable = true,
    tint = {r=0.6, g=0.6, b=0.6, a=1},
    icon_base = "ori",
    scale = 1,
    mining_time = 0.5,
    subcat = "b[tank]-c[conventional]-2-",
    base_health = 20000, --DrD x10
    base_braking_power = 400,
    base_consumption = 600,
    effectivity = 0.9,
    burner_effectivity = 1,
    burner_fuel_inventory_size = 2,
    terrain_friction_modifier = 0.2,
    weight = 20000,
    base_inventory_size = 20,
    turret_rotation_speed = 0.35 / 60,
    rotation_speed = 0.0035,
    base_resistances = {
      fire      = { decrease = 15,  percent = 60 },
      physical  = { decrease = 15,  percent = 60 },
      impact    = { decrease = 50,  percent = 80 },
      explosion = { decrease = 15,  percent = 70 },
      acid      = { decrease =  0,  percent = 70 },
      laser     = { decrease =  0,  percent =  0 },
      electric  = { decrease =  0,  percent =  0 }
    },
    grid = {
      width_add = 0,
      height_add = 0,
      equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M"}
    },
    guns = {
      [0] = { "tank-cannon", "tank-machine-gun" },
      [1] = { "tank-cannon", "tank-machine-gun" },
      [2] = { "tank-cannon", "tank-machine-gun" },
      [3] = { "tank-cannon", "tank-machine-gun" },
    },
    recipe_specs = {
      [0] = {
        normal =
        {
          energy_required = 5,
          ingredients =
          {
            {"engine-unit", 32},
            {"steel-plate", 500}, --DrD x10
            {"iron-gear-wheel", 150}, --DrD x10
            {"advanced-circuit", 100} --DrD x10
          }
        },
        expensive =
        {
          energy_required = 8,
          ingredients =
          {
            {"engine-unit", 64},
            {"steel-plate", 100},
            {"iron-gear-wheel", 30},
            {"advanced-circuit", 20}
          }
        }
      },
      [1] = {
        energy_required = 10,
        ingredients =
        {
          {"__VEH__0__", 1},  -- Special string to call for name generation
          {"processing-unit", 40},
          {"electric-engine-unit", 20},
        }
      },
      [2] = {
        energy_required = 15,
        ingredients =
        {
          {"__VEH__1__", 1},
          {"effectivity-module-2", 25},
          {"speed-module-2", 25},
        }
      },
      [3] = {
        energy_required = 20,
        ingredients =
        {
          {"__VEH__2__", 1},
          {"alien-artifact", 600},
          {"low-density-structure", 60},
          {"space-science-pack", 60},
          {"vehicle-nuclear-reactor-equipment", 2}
        }
      },
    },
  },
  ["tank-H"] = {
    name = "Schall-tank-H",
    enable = true,
    tint = {r=0.5, g=0.5, b=0.5, a=1},
    icon_base = "ori",
    scale = 1.5, --1,
    mining_time = 1,  --0.5,
    subcat = "b[tank]-c[conventional]-3-",
    base_health = 30000, --2000,  --DrD x10
    base_braking_power = 660, --400,
    base_consumption = 1000, --600,
    effectivity = 0.75,  --0.9,
    burner_effectivity = 0.875,  --1,
    burner_fuel_inventory_size = 2,
    terrain_friction_modifier = 0.22,  --0.2,
    weight = 50000,  --20000,
    base_inventory_size = 20,
    turret_rotation_speed = 0.1 / 60,  --0.35 / 60,
    rotation_speed = 0.002,  --0.0035,
    base_resistances = {
      fire      = { decrease = 15,  percent = 60 },
      physical  = { decrease = 18,  percent = 65 },
      impact    = { decrease = 55,  percent = 80 },
      explosion = { decrease = 18,  percent = 75 },
      acid      = { decrease =  3,  percent = 70 },
      laser     = { decrease =  0,  percent =  0 },
      electric  = { decrease =  0,  percent =  0 }
    },
    grid = {
      width_add = 1,
      height_add = 0,
      equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H"}
    },
    guns = {
      [0] = { "tank-cannon-H1", "tank-machine-gun" },
      [1] = { "tank-cannon-H1", "tank-machine-gun" },
      [2] = { "tank-cannon-H1", "tank-machine-gun" },
      [3] = { "tank-cannon-H1", "tank-machine-gun" },
    },
    recipe_specs = {
      [0] = {
        normal =
        {
          energy_required = 20,
          ingredients =
          {
            {"engine-unit", 100},
            {"steel-plate", 1500}, --DrD x10
            {"iron-gear-wheel", 500}, --DrD x10
            {"advanced-circuit", 300} --DrD x10
          }
        },
        expensive =
        {
          energy_required = 32,
          ingredients =
          {
            {"engine-unit", 200},
            {"steel-plate", 300},
            {"iron-gear-wheel", 100},
            {"advanced-circuit", 60}
          }
        }
      },
      [1] = {
        energy_required = 40,
        ingredients =
        {
          {"__VEH__0__", 1},  -- Special string to call for name generation
          {"processing-unit", 80},
          {"electric-engine-unit", 60},
        }
      },
      [2] = {
        energy_required = 60,
        ingredients =
        {
          {"__VEH__1__", 1},
          {"effectivity-module-2", 32},
          {"speed-module-2", 32},
        }
      },
      [3] = {
        energy_required = 80,
        ingredients =
        {
          {"__VEH__2__", 1},
          {"alien-artifact", 1800},
          {"low-density-structure", 180},
          {"space-science-pack", 180},
          {"vehicle-nuclear-reactor-equipment", 6}
        }
      },
    },
  },
  ["tank-SH"] = {
    name = "Schall-tank-SH",
    enable = true,
    tint = {r=0.4, g=0.4, b=0.4, a=1},
    icon_base = "ori",
    scale = 2, --1,
    mining_time = 2,  --0.5,
    subcat = "b[tank]-c[conventional]-4-",
    base_health = 50000, --2000, --DrD x10
    base_braking_power = 660, --400,
    base_consumption = 1000, --600,
    effectivity = 0.5,  --0.9,
    burner_effectivity = 0.666,  --1,
    burner_fuel_inventory_size = 2,
    terrain_friction_modifier = 0.25,  --0.2,
    weight = 100000,  --20000,
    base_inventory_size = 20,
    turret_rotation_speed = 0.025 / 60,  --0.35 / 60,
    rotation_speed = 0.001,  --0.0035,
    base_resistances = {
      fire      = { decrease = 15,  percent = 60 },
      physical  = { decrease = 20,  percent = 70 },
      impact    = { decrease = 60,  percent = 80 },
      explosion = { decrease = 20,  percent = 80 },
      acid      = { decrease =  5,  percent = 70 },
      laser     = { decrease =  0,  percent =  0 },
      electric  = { decrease =  0,  percent =  0 }
    },
    grid = {
      width_add = 1,
      height_add = 1,
      equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-M", "tank-H", "tank-SH"}
    },
    guns = {
      [0] = { "tank-cannon-H2", "tank-cannon-H2", "tank-machine-gun" },
      [1] = { "tank-cannon-H2", "tank-cannon-H2", "tank-machine-gun" },
      [2] = { "tank-cannon-H2", "tank-cannon-H2", "tank-machine-gun" },
      [3] = { "tank-cannon-H2", "tank-cannon-H2", "tank-machine-gun" },
    },
    recipe_specs = {
      [0] = {
        normal =
        {
          energy_required = 60,
          ingredients =
          {
            {"engine-unit", 300},
            {"steel-plate", 5000}, --DrD x10
            {"iron-gear-wheel", 500}, --DrD x10
            {"advanced-circuit", 100}, --DrD x10
            {"military-science-pack", 200}
          }
        },
        expensive =
        {
          energy_required = 100,
          ingredients =
          {
            {"engine-unit", 600},
            {"steel-plate", 800},
            {"iron-gear-wheel", 240},
            {"advanced-circuit", 160},
            {"military-science-pack", 400}
          }
        }
      },
      [1] = {
        energy_required = 120,
        ingredients =
        {
          {"__VEH__0__", 1},  -- Special string to call for name generation
          {"processing-unit", 160},
          {"electric-engine-unit", 120},
        }
      },
      [2] = {
        energy_required = 180,
        ingredients =
        {
          {"__VEH__1__", 1},
          {"effectivity-module-2", 40},
          {"speed-module-2", 40},
        }
      },
      [3] = {
        energy_required = 240,
        ingredients =
        {
          {"__VEH__2__", 1},
          {"alien-artifact", 4800},
          {"low-density-structure", 480},
          {"space-science-pack", 480},
          {"vehicle-nuclear-reactor-equipment", 16}
        }
      },
    },
  },
  ["tank-F"] = {
    name = "Schall-tank-F",
    enable = true,
    tint = {r=1.0, g=0.4, b=0.0, a=1},
    icon_base = "tint", --"ori",
    scale = 1,
    mining_time = 0.5,
    subcat = "b[tank]-c[conventional]-5-",
    base_health = 20000,  --DrD x10
    base_braking_power = 400,
    base_consumption = 600,
    effectivity = 0.9,
    burner_effectivity = 1,
    burner_fuel_inventory_size = 2,
    terrain_friction_modifier = 0.2,
    weight = 20000,
    base_inventory_size = 20,
    turret_rotation_speed = 0.35 / 60,
    rotation_speed = 0.0035,
    base_resistances = {
      fire      = { decrease = 50,  percent = 100 },
      physical  = { decrease = 10,  percent = 60 },
      impact    = { decrease = 45,  percent = 80 },
      explosion = { decrease = 10,  percent = 60 },
      acid      = { decrease =  0,  percent = 70 },
      laser     = { decrease =  0,  percent =  0 },
      electric  = { decrease =  0,  percent =  0 }
    },
    grid = {
      width_add = 0,
      height_add = 0,
      equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "tank-F"}
    },
    guns = {
      [0] = { "tank-flamethrower", "tank-machine-gun" },
      [1] = { "tank-flamethrower", "tank-machine-gun" },
      [2] = { "tank-flamethrower", "tank-machine-gun" },
      [3] = { "tank-flamethrower", "tank-machine-gun" },
    },
    recipe_specs = {
      [0] = {
        normal =
        {
          energy_required = 5,
          ingredients =
          {
            {"engine-unit", 32},
            {"steel-plate", 500}, --DrD x10
            {"iron-gear-wheel", 150}, --DrD x10
            {"advanced-circuit", 100} --DrD x10
          }
        },
        expensive =
        {
          energy_required = 8,
          ingredients =
          {
            {"engine-unit", 64},
            {"steel-plate", 100},
            {"iron-gear-wheel", 30},
            {"advanced-circuit", 20}
          }
        }
      },
      [1] = {
        energy_required = 10,
        ingredients =
        {
          {"__VEH__0__", 1},  -- Special string to call for name generation
          {"processing-unit", 40},
          {"electric-engine-unit", 20},
        }
      },
      [2] = {
        energy_required = 15,
        ingredients =
        {
          {"__VEH__1__", 1},
          {"effectivity-module-2", 25},
          {"speed-module-2", 25},
        }
      },
      [3] = {
        energy_required = 20,
        ingredients =
        {
          {"__VEH__2__", 1},
          {"alien-artifact", 600},
          {"low-density-structure", 60},
          {"space-science-pack", 60},
          {"vehicle-nuclear-reactor-equipment", 2}
        }
      },
    },
  },
  ["ht-RA"] = {
    name = "Schall-ht-RA",
    enable = cfg1.class_on["ht-RA"],
    tint = {r=0.8, g=0.0, b=0.0, a=1},
    icon_base = "tint",  -- "ori",
    scale = 1,
    mining_time = 0.5,
    subcat = "b[tank]-r[rocket]-1-",
    base_health = 20000, --DrD x10
    base_braking_power = 400,
    base_consumption = 600,
    effectivity = 0.9,
    burner_effectivity = 1,
    burner_fuel_inventory_size = 2,
    terrain_friction_modifier = 0.2,
    weight = 40000, -- 20000,
    base_inventory_size = 20,
    turret_rotation_speed = 0.35 / 60,
    rotation_speed = 0.0035,
    base_resistances = {
      fire      = { decrease = 10,  percent = 40 },
      physical  = { decrease =  0,  percent = 50 },
      impact    = { decrease = 30,  percent = 60 },
      explosion = { decrease = 10,  percent = 50 },
      acid      = { decrease =  0,  percent = 60 },
      laser     = { decrease =  0,  percent =  0 },
      electric  = { decrease =  0,  percent =  0 }
    },
    grid = {
      width_add = 0,
      height_add = 0,
      equipment_categories = {"armor", "vehicle", "armoured-vehicle", "tank", "artillery-rocket"}
    },
    guns = {
      [0] = { "Schall-tactical-missile-launcher", "Schall-multiple-rocket-launcher", "tank-machine-gun-single" },
      [1] = { "Schall-tactical-missile-launcher", "Schall-multiple-rocket-launcher", "tank-machine-gun-single" },
      [2] = { "Schall-tactical-missile-launcher", "Schall-multiple-rocket-launcher", "tank-machine-gun-single" },
      [3] = { "Schall-tactical-missile-launcher", "Schall-multiple-rocket-launcher", "tank-machine-gun-single" },
    },
    recipe_specs = {
      [0] = {
        normal =
        {
          energy_required = 5,
          ingredients =
          {
            {"engine-unit", 32},
            {"steel-plate", 500}, --DrD x10
            {"iron-gear-wheel", 150}, --DrD x10
            {"advanced-circuit", 100} --DrD x10
          }
        },
        expensive =
        {
          energy_required = 8,
          ingredients =
          {
            {"engine-unit", 64},
            {"steel-plate", 100},
            {"iron-gear-wheel", 30},
            {"advanced-circuit", 20}
          }
        }
      },
      [1] = {
        energy_required = 10,
        ingredients =
        {
          {"__VEH__0__", 1},  -- Special string to call for name generation
          {"processing-unit", 40},
          {"electric-engine-unit", 20},
        }
      },
      [2] = {
        energy_required = 15,
        ingredients =
        {
          {"__VEH__1__", 1},
          {"effectivity-module-2", 25},
          {"speed-module-2", 25},
        }
      },
      [3] = {
        energy_required = 20,
        ingredients =
        {
          {"__VEH__2__", 1},
          {"alien-artifact", 600},
          {"low-density-structure", 60},
          {"space-science-pack", 60},
          {"vehicle-nuclear-reactor-equipment", 2}
        }
      },
    },
  },
}



local dataextendlist = {}


local tier_max = cfg1.tier_max

for name, spec in pairs(VEH_specs) do
  if spec.enable then
    for tier = 0,tier_max,1 do
      if cfg1.tier_on[tier] then
        table.insert( dataextendlist, TPpt.VEH_item(spec, tier) )
        table.insert( dataextendlist, TPpt.VEH_entity(spec, tier) )
        table.insert( dataextendlist, TPpt.VEH_recipe(spec, tier) )
        table.insert( dataextendlist, TPpt.VEH_grid(spec, tier) )
      end
    end
  end
end

data:extend(dataextendlist)
