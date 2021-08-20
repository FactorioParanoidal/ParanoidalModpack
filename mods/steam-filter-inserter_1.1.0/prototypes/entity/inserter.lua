-- прямой фильтрующий паровой манипулятор
data:extend({

  {
    type = "inserter",
    name = "steam-filter-inserter",
    icon = "__steam-filter-inserter__/graphics/icons/straight-steam-filter-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "steam-filter-inserter"},
    max_health = 100,
    corpse = "small-remnants",
    light_flicker = nil,
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      match_progress_to_activity = true,
      sound =
      {
        {
          filename = "__base__/sound/inserter-fast-1.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-fast-2.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-fast-3.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-fast-4.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-fast-5.ogg",
          volume = 0.75
        }
      }
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
    pickup_position = {0, -1},
    insert_position = {0, 1.2},
    energy_per_movement = "10KJ",
    energy_per_rotation = "10KJ",

    energy_source =
    {
      type = "fluid",
      effectivity = 1,
      fluid_box =
      {
        base_area = 0.1,
        height = 0.2,
        base_level = 0,
        pipe_connections =
        {
          {type = "input-output", position = {1, 0}},
          {type = "input-output", position = {-1, 0}},
          --{type = "input-output", position = {0, 1}},
          --{type = "input-output", position = {0, -1}}
        },
        pipe_covers = pipecoverspictures(),
        pipe_picture = assembler3pipepictures(),
        production_type = "input-output",
        filter = "steam"
      },
      burns_fluid = false,
      scale_fluid_usage = false,
      fluid_usage_per_tick = (0.7/60),
      maximum_temperature = 765,
      smoke =
      {
        {
          name = "light-smoke",
          frequency = 10 / 32,
          starting_vertical_speed = 0.08,
          slow_down_factor = 1,
          starting_frame_deviation = 60
        }
      }
    },
    
    extension_speed = 0.125,
    rotation_speed = 0.05,

    fast_replaceable_group = "inserter",
    filter_count = 1,
    hand_base_picture =
    {
      filename = "__base__/graphics/entity/filter-inserter/filter-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__base__/graphics/entity/filter-inserter/hr-filter-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__base__/graphics/entity/filter-inserter/filter-inserter-hand-closed.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__base__/graphics/entity/filter-inserter/hr-filter-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__base__/graphics/entity/filter-inserter/filter-inserter-hand-open.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__base__/graphics/entity/filter-inserter/hr-filter-inserter-hand-open.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_base_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 8,
      height = 33,
      hr_version = {
        filename = "__base__/graphics/entity/burner-inserter/hr-burner-inserter-hand-base-shadow.png",
        priority = "extra-high",
        width = 32,
        height = 132,
        scale = 0.25
      }
    },
    hand_closed_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__base__/graphics/entity/burner-inserter/hr-burner-inserter-hand-closed-shadow.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__base__/graphics/entity/burner-inserter/hr-burner-inserter-hand-open-shadow.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    platform_picture =
    {
      sheet =
      {
        filename = "__base__/graphics/entity/burner-inserter/burner-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__base__/graphics/entity/burner-inserter/hr-burner-inserter-platform.png",
          priority = "extra-high",
          width = 105,
          height = 79,
          shift = util.by_pixel(1.5, 7.5-1),
          scale = 0.5
        }
      }
    },
    uses_arm_movement = "basic-inserter",
  },
})

-- угловой фильтрующий паровой манипулятор
data:extend({
util.merge{data.raw.inserter["steam-filter-inserter"],{
    name = "corner-steam-filter-inserter",
    icon = "__steam-filter-inserter__/graphics/icons/corner-steam-filter-inserter.png",
    minable = {result = "corner-steam-filter-inserter"},
  }}
})
data.raw.inserter["corner-steam-filter-inserter"].energy_source.fluid_box.pipe_connections =
{
  {type = "input-output", position = {-1, 0}},
  {type = "input-output", position = {0, 1}}
}

