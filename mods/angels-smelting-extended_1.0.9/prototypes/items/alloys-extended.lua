if mods["bobplates"] then
  data:extend(
    {
      --ALLOYS
      {
      type = "fluid",
      name = "liquid-molten-bronze",
      icon = "__angelssmelting__/graphics/icons/molten-bronze.png",
      icon_size=32,
      default_temperature = 100,
      heat_capacity = "0KJ",
      base_color = {r = 0.1, g = 0.1, b = 0.1},
      flow_color = {r = 0.1, g = 0.1, b = 0.1},
      max_temperature = 100,
      pressure_to_speed_ratio = 0.4,
      flow_to_energy_ratio = 0.59,
      auto_barrel = false
      },
      {
      type = "item",
      name = "angels-plate-bronze",
      icon = "__angelssmelting__/graphics/icons/plate-bronze.png",
      icon_size=32,
      flags={"hidden"},
      subgroup = "angels-copper-casting",
      order = "ya",
      stack_size = 200
      },
      {
      type = "fluid",
      name = "liquid-molten-brass",
      icon = "__angelssmelting__/graphics/icons/molten-bronze.png",
      icon_size=32,
      default_temperature = 100,
      heat_capacity = "0KJ",
      base_color = {r = 0.1, g = 0.1, b = 0.1},
      flow_color = {r = 0.1, g = 0.1, b = 0.1},
      max_temperature = 100,
      pressure_to_speed_ratio = 0.4,
      flow_to_energy_ratio = 0.59,
      auto_barrel = false
      },
      {
      type = "item",
      name = "angels-plate-brass",
      icon = "__angelssmelting__/graphics/icons/plate-brass.png",
      icon_size=32,
      flags={"hidden"},
      subgroup = "angels-copper-casting",
      order = "yb",
      stack_size = 200
      },
      {
      type = "fluid",
      name = "liquid-molten-gunmetal",
      icon = "__angelssmelting__/graphics/icons/molten-bronze.png",
      icon_size=32,
      default_temperature = 100,
      heat_capacity = "0KJ",
      base_color = {r = 0.1, g = 0.1, b = 0.1},
      flow_color = {r = 0.1, g = 0.1, b = 0.1},
      max_temperature = 100,
      pressure_to_speed_ratio = 0.4,
      flow_to_energy_ratio = 0.59,
      auto_barrel = false
      },
      {
      type = "item",
      name = "angels-plate-gunmetal",
      icon = "__angelssmelting__/graphics/icons/plate-gunmetal.png",
      icon_size=32,
      flags={"hidden"},
      subgroup = "angels-copper-casting",
      order = "yc",
      stack_size = 200
      },
      {
      type = "fluid",
      name = "liquid-molten-invar",
      icon = "__angelssmelting__/graphics/icons/molten-bronze.png",
      icon_size=32,
      default_temperature = 100,
      heat_capacity = "0KJ",
      base_color = {r = 0.1, g = 0.1, b = 0.1},
      flow_color = {r = 0.1, g = 0.1, b = 0.1},
      max_temperature = 100,
      pressure_to_speed_ratio = 0.4,
      flow_to_energy_ratio = 0.59,
      auto_barrel = false
      },
      {
      type = "item",
      name = "angels-plate-invar",
      icon = "__angelssmelting__/graphics/icons/plate-invar.png",
      icon_size=32,
      flags={"hidden"},
      subgroup = "angels-iron-casting",
      order = "ya",
      stack_size = 200
      },
      {
      type = "fluid",
      name = "liquid-molten-nitinol",
      icon = "__angelssmelting__/graphics/icons/molten-bronze.png",
      icon_size=32,
      default_temperature = 100,
      heat_capacity = "0KJ",
      base_color = {r = 0.1, g = 0.1, b = 0.1},
      flow_color = {r = 0.1, g = 0.1, b = 0.1},
      max_temperature = 100,
      pressure_to_speed_ratio = 0.4,
      flow_to_energy_ratio = 0.59,
      auto_barrel = false
      },
      {
      type = "item",
      name = "angels-plate-nitinol",
      icon = "__angelssmelting__/graphics/icons/plate-nitinol.png",
      icon_size=32,
      flags={"hidden"},
      subgroup = "angels-titanium-casting",
      order = "ya",
      stack_size = 200
      },
      {
      type = "item",
      name = "angels-plate-cobalt-steel",
      icon = "__angelssmelting__/graphics/icons/plate-cobalt-steel.png",
      icon_size=32,
      flags={"hidden"},
      subgroup = "angels-cobalt-casting",
      order = "ya",
      stack_size = 200
      },

  })
end