data:extend(
  {
    {
      type = "item",
      name = "petroleum-generator",
      icon = "__KS_Power__/graphics/icons/petroleum-generator-icon.png",
      icon_size = 64,
      flags = {},
      subgroup = "energy",
      order = "b[steam-power]-d[petroleum-generator]",
      place_result = "petroleum-generator",
      stack_size = 20
    },
    {
      type = "recipe",
      name = "petroleum-generator",
      energy_required = 15,
      enabled = false,
      ingredients = {
        {type = "item", name = "steel-plate", amount = 12},
        {type = "item", name = "engine-unit", amount = 8},
        {type = "item", name = "electronic-circuit", amount = 16},
        {type = "item", name = "pipe", amount = 10}
      },
      results = {{type = "item", name = "petroleum-generator", amount = 1}}
    },
    {
      type = "generator",
      name = "petroleum-generator",
      icon = "__KS_Power__/graphics/icons/petroleum-generator-icon.png",
      icon_size = 64,
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 2, result = "petroleum-generator"},
      max_power_output = (4 / 60) .. "MJ",
      max_health = 300,
      corpse = "big-remnants",
      effectivity = 1,
      fluid_usage_per_tick = 2 / 60,
      burns_fluid = true,
      scale_fluid_usage = true,
      maximum_temperature = 1000, --not needed...
      resistances = {
        {
          type = "fire",
          percent = 70
        }
      },
      collision_box = {{-0.7, -2.7}, {0.7, 2.7}},
      selection_box = {{-1, -3}, {1, 3}},
      fluid_box = {
        volume = 100,
        pipe_covers = pipecoverspictures(),
        production_type = "input-output",
        pipe_connections =
        {
          {position = {-0.5, 0.5}, flow_direction = "input-output", direction = defines.direction.west},
          {position = {0.5, 0.5},  flow_direction = "input-output", direction = defines.direction.east}
        },
      },
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-output",
        emissions_per_minute = {pollution = 50},
      },
      vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
      horizontal_animation =
      {
        layers = {
          {
            filename = "__KS_Power__/graphics/entity/petroleum-generator/hr-petroleum-generator-horizontal-base.png",
            width = 548,
            height = 256,
            frame_count = 1,
            repeat_count = 14,
            shift = util.by_pixel(0, -13),
            animation_speed = 0.5,
            scale = 0.5,
          },
          {
            filename = "__KS_Power__/graphics/entity/petroleum-generator/hr-petroleum-generator-horizontal-base-shadow.png",
            width = 548,
            height = 256,
            frame_count = 1,
            repeat_count = 14,
            shift = {0.5, -0.4},
            animation_speed = 0.5,
            scale = 0.5,
            draw_as_shadow = true,
          },
          {
            filename = "__KS_Power__/graphics/entity/petroleum-generator/hr-petroleum-generator-horizontal-anim.png",
            width = 448,
            height = 256,
            frame_count = 8,
            line_length = 4,
            shift = util.by_pixel(0, -13),
            animation_speed = 0.5,
            scale = 0.5,
            run_mode = "forward-then-backward",
            draw_as_glow = true,
          },
        }
      },
      vertical_animation =
      {
        layers = {
          {
            filename = "__KS_Power__/graphics/entity/petroleum-generator/hr-petroleum-generator-vertical-base.png",
            width = 256,
            height = 448,
            frame_count = 1,
            repeat_count = 8,
            animation_speed = 0.5,
            scale = 0.5,
          },
          {
            filename = "__KS_Power__/graphics/entity/petroleum-generator/hr-petroleum-generator-vertical-base-shadow.png",
            width = 256,
            height = 448,
            frame_count = 1,
            repeat_count = 8,
            shift = util.by_pixel(25, 0),
            animation_speed = 0.5,
            scale = 0.5,
            draw_as_shadow = true,
          },
          {
            filename = "__KS_Power__/graphics/entity/petroleum-generator/hr-petroleum-generator-vertical-anim.png",
            width = 256,
            height = 448,
            frame_count = 8,
            line_length = 4,
            animation_speed = 0.5,
            scale = 0.5,
            draw_as_glow = true
          },
        },
      },
      smoke = {
        {
          name = "tank-smoke",
          --north_position = {0.42, -0.85},
          --east_position = {-1.15, -2.0},
          north_position = util.by_pixel(-14.5, -27),
          south_position = util.by_pixel(-14.5, -27),
          east_position = util.by_pixel(-46, -66),
          west_position = util.by_pixel(-46, -66),
          frequency = 10 / 32,
          starting_vertical_speed = 0.06,
          starting_vertical_speed_deviation = 0.1,
          slow_down_factor = 1,
          starting_frame_deviation = 60,
          starting_frame = 5,
        },
        {
          name = "tank-smoke",
          --north_position = {-0.42, -0.85},
          --east_position = {-1.15, -1.8},
          north_position = util.by_pixel(14.5, -27),
          south_position = util.by_pixel(14.5, -27),
          east_position = util.by_pixel(-46, -82),
          west_position = util.by_pixel(-46, -82),
          frequency = 10 / 32,
          starting_vertical_speed = 0.06,
          starting_vertical_speed_deviation = 0.1,
          slow_down_factor = 1,
          starting_frame_deviation = 10,
          starting_frame = 5,
          starting_frame_speed = 1,
          starting_frame_speed_deviation = 0.5
        }
      },
      working_sound = {
        sound = {
          {
            filename = "__KS_Power__/sounds/diesel-loop-1.ogg",
            volume = 0.5
          },
          {
            filename = "__KS_Power__/sounds/diesel-loop-2.ogg",
            volume = 0.5
          },
          {
            filename = "__KS_Power__/sounds/diesel-loop-3.ogg",
            volume = 0.5
          }
        },
        match_speed_to_activity = true,
        max_sounds_per_type = 2
      },
      min_perceived_performance = 0.4,
      performance_to_sound_speedup = 0.2
    },
    {
      type = "recipe",
      name = "diesel-fuel",
      category = "chemistry",
      enabled = false,
      energy_required = 5,
      ingredients = {
        {type = "fluid", name = "petroleum-gas", amount = 20},
        {type = "fluid", name = "light-oil", amount = 20}
      },
      crafting_machine_tint = {
        primary = {r = 0.5, g = 0.4, b = 0},
        secondary = {r = 0.5, g = 0.4, b = 0},
        tertiary = {r = 0.5, g = 0.4, b = 0},
        quaternary = {r = 0.5, g = 0.4, b = 0}
      },
      results = {{type = "fluid", name = "diesel-fuel", amount = 30, temperature = 25}},
      main_product = "",
      icon = "__KS_Power__/graphics/icons/diesel-fuel-recipe-icon.png",
      icon_size = 64,
      subgroup = "fluid-recipes",
      order = "b[fluid-chemistry]-i[diesel-fuel]"
    },
    {
      type = "technology",
      name = "petroleum-generator",
      icon = "__KS_Power__/graphics/technology/petroleum-generator-technology.png",
      icon_size = 256,
      effects = {
        {
          type = "unlock-recipe",
          recipe = "petroleum-generator"
        },
        {
          type = "unlock-recipe",
          recipe = "diesel-fuel"
        }
      },
      prerequisites = {"advanced-oil-processing", "engine"},
      unit = {
        count = 150,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
        time = 60
      },
      order = "f-b-d"
    },
    {
      type = "fluid",
      name = "diesel-fuel",
      default_temperature = 0,
      max_temperature = 25,
      auto_barrel = true,
      heat_capacity = "1kJ",
      base_color = {r = 0.8, g = 0.7, b = 0},
      flow_color = {r = 0.5, g = 0.4, b = 0},
      icon = "__KS_Power__/graphics/icons/diesel-fuel-icon.png",
      icon_size = 64,
      order = "a[fluid]-i[diesel-fuel]",
      pressure_to_speed_ratio = 0.4,
      flow_to_energy_ratio = 0.59
    }
  }
)
