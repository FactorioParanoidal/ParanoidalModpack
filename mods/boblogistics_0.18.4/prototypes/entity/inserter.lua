data:extend(
{
  {
    type = "inserter",
    name = "express-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/cyan-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = "express-inserter"},
    max_health = 200,
    corpse = "small-remnants",
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
    energy_per_movement = "10kJ",
    energy_per_rotation = "10kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "0.7kW"
    },
    extension_speed = 0.25,
    rotation_speed = 0.1,
    pickup_position = {0, -1},
    insert_position = {0, 1.2},
    fast_replaceable_group = "inserter",
    hand_base_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/cyan-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-cyan-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/cyan-inserter-hand-closed.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-cyan-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/cyan-inserter-hand-open.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-cyan-inserter-hand-open.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_base_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 8,
      height = 33,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-base-shadow.png",
        priority = "extra-high",
        width = 32,
        height = 132,
        scale = 0.25
      }
    },
    hand_closed_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-closed-shadow.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-open-shadow.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    platform_picture =
    {
      sheet=
      {
        filename = "__boblogistics__/graphics/entity/inserter/cyan-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-cyan-inserter-platform.png",
          priority = "extra-high",
          width = 105,
          height = 79,
          shift = util.by_pixel(1.5, 7.5-1),
          scale = 0.5
        }
      }
    },
    circuit_wire_connection_points = circuit_connector_definitions["inserter"].points,
    circuit_connector_sprites = circuit_connector_definitions["inserter"].sprites,
    default_stack_control_input_signal = inserter_default_stack_control_input_signal,
    circuit_wire_max_distance = inserter_circuit_wire_max_distance
  },

  {
    type = "inserter",
    name = "express-filter-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/magenta-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = "express-filter-inserter"},
    max_health = 200,
    corpse = "small-remnants",
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
    energy_per_movement = "10kJ",
    energy_per_rotation = "10kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "0.7kW"
    },
    extension_speed = 0.25,
    rotation_speed = 0.1,
    fast_replaceable_group = "inserter",
    filter_count = 5,
    hand_base_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/magenta-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-magenta-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/magenta-inserter-hand-closed.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-magenta-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/magenta-inserter-hand-open.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-magenta-inserter-hand-open.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_base_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 8,
      height = 33,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-base-shadow.png",
        priority = "extra-high",
        width = 32,
        height = 132,
        scale = 0.25
      }
    },
    hand_closed_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-closed-shadow.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-open-shadow.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    platform_picture =
    {
      sheet=
      {
        filename = "__boblogistics__/graphics/entity/inserter/magenta-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-magenta-inserter-platform.png",
          priority = "extra-high",
          width = 105,
          height = 79,
          shift = util.by_pixel(1.5, 7.5-1),
          scale = 0.5
        }
      }
    },
    circuit_wire_connection_points = circuit_connector_definitions["inserter"].points,
    circuit_connector_sprites = circuit_connector_definitions["inserter"].sprites,
    default_stack_control_input_signal = inserter_default_stack_control_input_signal,
    circuit_wire_max_distance = inserter_circuit_wire_max_distance
  },

  {
    type = "inserter",
    name = "express-stack-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/dark-green-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    stack = true,
    minable =
    {
      mining_time = 0.1,
      result = "express-stack-inserter"
    },
    max_health = 200,
    corpse = "small-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
    pickup_position = {0, -1},
    insert_position = {0, 1.2},
    energy_per_movement = "25kJ",
    energy_per_rotation = "25kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "1.5kW"
    },
    extension_speed = 0.25,
    rotation_speed = 0.1,
    fast_replaceable_group = "inserter",
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
    hand_base_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/dark-green-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-dark-green-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/dark-green-big-inserter-hand-closed.png",
      priority = "extra-high",
      width = 24,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-dark-green-big-inserter-hand-closed.png",
        priority = "extra-high",
        width = 100,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/dark-green-big-inserter-hand-open.png",
      priority = "extra-high",
      width = 32,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-dark-green-big-inserter-hand-open.png",
        priority = "extra-high",
        width = 130,
        height = 164,
        scale = 0.25
      }
    },
    hand_base_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 8,
      height = 33,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-base-shadow.png",
        priority = "extra-high",
        width = 32,
        height = 132,
        scale = 0.25
      }
    },
    hand_closed_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/stack-inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 24,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-stack-inserter-hand-closed-shadow.png",
        priority = "extra-high",
        width = 100,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/stack-inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 32,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-stack-inserter-hand-open-shadow.png",
        priority = "extra-high",
        width = 130,
        height = 164,
        scale = 0.25
      }
    },
    platform_picture =
    {
      sheet =
      {
        filename = "__boblogistics__/graphics/entity/inserter/dark-green-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-dark-green-inserter-platform.png",
          priority = "extra-high",
          width = 105,
          height = 79,
          shift = util.by_pixel(1.5, 7.5-1),
          scale = 0.5
        }
      }
    },
    circuit_wire_connection_points = circuit_connector_definitions["inserter"].points,
    circuit_connector_sprites = circuit_connector_definitions["inserter"].sprites,
    default_stack_control_input_signal = inserter_default_stack_control_input_signal,
    circuit_wire_max_distance = inserter_circuit_wire_max_distance
  },

  {
    type = "inserter",
    name = "express-stack-filter-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/stripe-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    stack = true,
    filter_count = 2,
    minable =
    {
      mining_time = 0.1,
      result = "express-stack-filter-inserter"
    },
    max_health = 200,
    corpse = "small-remnants",
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
    pickup_position = {0, -1},
    insert_position = {0, 1.2},
    energy_per_movement = "25kJ",
    energy_per_rotation = "25kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "1.5kW"
    },
    extension_speed = 0.25,
    rotation_speed = 0.1,
    fast_replaceable_group = "inserter",
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
    hand_base_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/stripe-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-stripe-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/stripe-inserter-hand-closed.png",
      priority = "extra-high",
      width = 24,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-stripe-inserter-hand-closed.png",
        priority = "extra-high",
        width = 100,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/stripe-inserter-hand-open.png",
      priority = "extra-high",
      width = 32,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-stripe-inserter-hand-open.png",
        priority = "extra-high",
        width = 130,
        height = 164,
        scale = 0.25
      }
    },
    hand_base_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 8,
      height = 33,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-inserter-hand-base-shadow.png",
        priority = "extra-high",
        width = 32,
        height = 132,
        scale = 0.25
      }
    },
    hand_closed_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/stack-inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 24,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-stack-inserter-hand-closed-shadow.png",
        priority = "extra-high",
        width = 100,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_shadow =
    {
      filename = "__boblogistics__/graphics/entity/inserter/stack-inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 32,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-stack-inserter-hand-open-shadow.png",
        priority = "extra-high",
        width = 130,
        height = 164,
        scale = 0.25
      }
    },
    platform_picture =
    {
      sheet =
      {
        filename = "__boblogistics__/graphics/entity/inserter/stripe-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-stripe-inserter-platform.png",
          priority = "extra-high",
          width = 105,
          height = 79,
          shift = util.by_pixel(1.5, 7.5-1),
          scale = 0.5
        }
      }
    },
    circuit_wire_connection_points = circuit_connector_definitions["inserter"].points,
    circuit_connector_sprites = circuit_connector_definitions["inserter"].sprites,
    default_stack_control_input_signal = inserter_default_stack_control_input_signal,
    circuit_wire_max_distance = inserter_circuit_wire_max_distance
  },
}
)

data.raw.inserter["fast-inserter"].next_upgrade = "express-inserter"
data.raw.inserter["filter-inserter"].next_upgrade = "express-filter-inserter"
data.raw.inserter["stack-inserter"].next_upgrade = "express-stack-inserter"
data.raw.inserter["stack-filter-inserter"].next_upgrade = "express-stack-filter-inserter"



local inserter =
{
  graphics = require("prototypes.entity.inserter-graphics"),
  stats = 
  {
    yellow =
    {
      health = 125,
      rotation_speed = 0.02,
      extension_speed = 0.05,
      energy_per_movement = "5kJ",
      energy_per_rotation = "5kJ",
      drain = "0.4kW"
    },
    red =
    {
      health = 150,
      rotation_speed = 0.04,
      extension_speed = 0.1,
      energy_per_movement = "6.25kJ",
      energy_per_rotation = "6.25kJ",
      drain = "0.5kW",
      stack =
      {
        energy_per_movement = "17.5kJ",
        energy_per_rotation = "17.5kJ",
        drain = "1kW"
      }
    },
    blue =
    {
      health = 175,
      rotation_speed = 0.06,
      extension_speed = 0.15,
      energy_per_movement = "7.5kJ",
      energy_per_rotation = "7.5kJ",
      drain = "0.6kW",
      stack =
      {
        energy_per_movement = "20kJ",
        energy_per_rotation = "20kJ",
        drain = "1.2kW"
      }
    },
    purple =
    {
      health = 200,
      rotation_speed = 0.08,
      extension_speed = 0.2,
      energy_per_movement = "8.75kJ",
      energy_per_rotation = "8.75kJ",
      drain = "0.7kW",
      stack =
      {
        energy_per_movement = "22.5kJ",
        energy_per_rotation = "22.5kJ",
        drain = "1.4kW"
      }
    },
    green =
    {
      health = 225,
      rotation_speed = 0.1,
      extension_speed = 0.25,
      energy_per_movement = "10kJ",
      energy_per_rotation = "10kJ",
      drain = "0.8kW",
      stack =
      {
        energy_per_movement = "25kJ",
        energy_per_rotation = "25kJ",
        drain = "1.6kW"
      }
    }
  }
}

if settings.startup["bobmods-logistics-inserteroverhaul"].value == true then
  data.raw.inserter["inserter"].next_upgrade = "red-inserter"
  data.raw.inserter["inserter"].max_health = inserter.stats.yellow.health
  data.raw.inserter["inserter"].extension_speed = inserter.stats.yellow.extension_speed
  data.raw.inserter["inserter"].rotation_speed = inserter.stats.yellow.rotation_speed
  data.raw.inserter["inserter"].energy_per_movement = inserter.stats.yellow.energy_per_movement
  data.raw.inserter["inserter"].energy_per_rotation = inserter.stats.yellow.energy_per_rotation
  data.raw.inserter["inserter"].energy_source.drain = inserter.stats.yellow.drain


  data:extend(
  {
    util.merge{
      data.raw.inserter["filter-inserter"],
      {
        name = "yellow-filter-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/yellow-filter-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "yellow-filter-inserter"},
        next_upgrade = "red-filter-inserter",
        max_health = inserter.stats.yellow.health,
        extension_speed = inserter.stats.yellow.extension_speed,
        rotation_speed = inserter.stats.yellow.rotation_speed,
        energy_per_movement = inserter.stats.yellow.energy_per_movement,
        energy_per_rotation = inserter.stats.yellow.energy_per_rotation,
        energy_source = { drain = inserter.stats.yellow.drain },
      }
    }
  }
  )
  data.raw.inserter["yellow-filter-inserter"].hand_base_picture = inserter.graphics.yellow.hand_base_picture()
  data.raw.inserter["yellow-filter-inserter"].hand_closed_picture = inserter.graphics.yellow.hand_closed_picture()
  data.raw.inserter["yellow-filter-inserter"].hand_open_picture = inserter.graphics.yellow.hand_open_picture()
  data.raw.inserter["yellow-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()


  data.raw.inserter["long-handed-inserter"].order = "[inserter]-c[fast]"
  data.raw.inserter["long-handed-inserter"].fast_replaceable_group = "inserter"
  data.raw.inserter["long-handed-inserter"].max_health = inserter.stats.red.health
  data.raw.inserter["long-handed-inserter"].extension_speed = inserter.stats.red.extension_speed
  data.raw.inserter["long-handed-inserter"].rotation_speed = inserter.stats.red.rotation_speed
  data.raw.inserter["long-handed-inserter"].energy_per_movement = inserter.stats.red.energy_per_movement
  data.raw.inserter["long-handed-inserter"].energy_per_rotation = inserter.stats.red.energy_per_rotation
  data.raw.inserter["long-handed-inserter"].energy_source.drain = inserter.stats.red.drain
  data:extend(
  {
    util.merge{
      data.raw.inserter["long-handed-inserter"],
      {
        name = "red-inserter",
        next_upgrade = "fast-inserter",
        pickup_position = {0, -1},
        insert_position = {0, 1.2},
      }
    }
  }
  )
  data.raw.inserter["long-handed-inserter"].placeable_by = {item = "long-handed-inserter", count = 1}

  data:extend(
  {
    util.merge{
      data.raw.inserter["filter-inserter"],
      {
        name = "red-filter-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/red-filter-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "red-filter-inserter"},
        next_upgrade = "filter-inserter",
        max_health = inserter.stats.red.health,
        extension_speed = inserter.stats.red.extension_speed,
        rotation_speed = inserter.stats.red.rotation_speed,
        energy_per_movement = inserter.stats.red.energy_per_movement,
        energy_per_rotation = inserter.stats.red.energy_per_rotation,
        energy_source = { drain = inserter.stats.red.drain },
      }
    }
  }
  )
  data.raw.inserter["red-filter-inserter"].working_sound = util.table.deepcopy(data.raw.inserter["long-handed-inserter"].working_sound)
  data.raw.inserter["red-filter-inserter"].hand_base_picture = inserter.graphics.red.hand_base_picture()
  data.raw.inserter["red-filter-inserter"].hand_closed_picture = inserter.graphics.red.hand_closed_picture()
  data.raw.inserter["red-filter-inserter"].hand_open_picture = inserter.graphics.red.hand_open_picture()
  data.raw.inserter["red-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()

  data:extend(
  {
    util.merge{
      data.raw.inserter["stack-inserter"],
      {
        name = "red-stack-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/red-stack-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "red-stack-inserter"},
        next_upgrade = "stack-inserter",
        max_health = inserter.stats.red.health,
        extension_speed = inserter.stats.red.extension_speed,
        rotation_speed = inserter.stats.red.rotation_speed,
        energy_per_movement = inserter.stats.red.stack.energy_per_movement,
        energy_per_rotation = inserter.stats.red.stack.energy_per_rotation,
        energy_source = { drain = inserter.stats.red.stack.drain },
      }
    }
  }
  )
  data.raw.inserter["red-stack-inserter"].working_sound = util.table.deepcopy(data.raw.inserter["long-handed-inserter"].working_sound)
  data.raw.inserter["red-stack-inserter"].hand_base_picture = inserter.graphics.red.hand_base_picture()
  data.raw.inserter["red-stack-inserter"].hand_closed_picture = inserter.graphics.red.stack.hand_closed_picture()
  data.raw.inserter["red-stack-inserter"].hand_open_picture = inserter.graphics.red.stack.hand_open_picture()
  data.raw.inserter["red-stack-inserter"].platform_picture = inserter.graphics.red.platform_picture()

  data:extend(
  {
    util.merge{
      data.raw.inserter["stack-filter-inserter"],
      {
        name = "red-stack-filter-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/red-stack-filter-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "red-stack-filter-inserter"},
        next_upgrade = "stack-filter-inserter",
        max_health = inserter.stats.red.health,
        extension_speed = inserter.stats.red.extension_speed,
        rotation_speed = inserter.stats.red.rotation_speed,
        energy_per_movement = inserter.stats.red.stack.energy_per_movement,
        energy_per_rotation = inserter.stats.red.stack.energy_per_rotation,
        energy_source = { drain = inserter.stats.red.stack.drain },
      }
    }
  }
  )
  data.raw.inserter["red-stack-filter-inserter"].working_sound = util.table.deepcopy(data.raw.inserter["long-handed-inserter"].working_sound)
  data.raw.inserter["red-stack-filter-inserter"].hand_base_picture = inserter.graphics.red.hand_base_picture()
  data.raw.inserter["red-stack-filter-inserter"].hand_closed_picture = inserter.graphics.red.stack.hand_closed_picture()
  data.raw.inserter["red-stack-filter-inserter"].hand_open_picture = inserter.graphics.red.stack.hand_open_picture()
  data.raw.inserter["red-stack-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()


  data.raw.inserter["fast-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-inserter.png"
  data.raw.inserter["fast-inserter"].icon_size = 32
  data.raw.inserter["fast-inserter"].order = "[inserter]-d[express]"
  data.raw.inserter["fast-inserter"].next_upgrade = "turbo-inserter"
  data.raw.inserter["fast-inserter"].max_health = inserter.stats.blue.health
  data.raw.inserter["fast-inserter"].extension_speed = inserter.stats.blue.extension_speed
  data.raw.inserter["fast-inserter"].rotation_speed = inserter.stats.blue.rotation_speed
  data.raw.inserter["fast-inserter"].energy_per_movement = inserter.stats.blue.energy_per_movement
  data.raw.inserter["fast-inserter"].energy_per_rotation = inserter.stats.blue.energy_per_rotation
  data.raw.inserter["fast-inserter"].energy_source.drain = inserter.stats.blue.drain

  data.raw.inserter["filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-filter-inserter.png"
  data.raw.inserter["filter-inserter"].icon_size = 32
  data.raw.inserter["filter-inserter"].order = "[inserter]-d[express]-b[filter]"
  data.raw.inserter["filter-inserter"].next_upgrade = "turbo-filter-inserter"
  data.raw.inserter["filter-inserter"].max_health = inserter.stats.blue.health
  data.raw.inserter["filter-inserter"].extension_speed = inserter.stats.blue.extension_speed
  data.raw.inserter["filter-inserter"].rotation_speed = inserter.stats.blue.rotation_speed
  data.raw.inserter["filter-inserter"].energy_per_movement = inserter.stats.blue.energy_per_movement
  data.raw.inserter["filter-inserter"].energy_per_rotation = inserter.stats.blue.energy_per_rotation
  data.raw.inserter["filter-inserter"].energy_source.drain = inserter.stats.blue.drain
  data.raw.inserter["filter-inserter"].hand_base_picture = inserter.graphics.blue.hand_base_picture()
  data.raw.inserter["filter-inserter"].hand_closed_picture = inserter.graphics.blue.hand_closed_picture()
  data.raw.inserter["filter-inserter"].hand_open_picture = inserter.graphics.blue.hand_open_picture()
  data.raw.inserter["filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()

  data.raw.inserter["stack-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-stack-inserter.png"
  data.raw.inserter["stack-inserter"].icon_size = 32
  data.raw.inserter["stack-inserter"].order = "[inserter]-d[express]-c[stack]"
  data.raw.inserter["stack-inserter"].next_upgrade = "turbo-stack-inserter"
  data.raw.inserter["stack-inserter"].max_health = inserter.stats.blue.health
  data.raw.inserter["stack-inserter"].extension_speed = inserter.stats.blue.extension_speed
  data.raw.inserter["stack-inserter"].rotation_speed = inserter.stats.blue.rotation_speed
  data.raw.inserter["stack-inserter"].energy_per_movement = inserter.stats.blue.stack.energy_per_movement
  data.raw.inserter["stack-inserter"].energy_per_rotation = inserter.stats.blue.stack.energy_per_rotation
  data.raw.inserter["stack-inserter"].energy_source.drain = inserter.stats.blue.stack.drain
  data.raw.inserter["stack-inserter"].hand_base_picture = inserter.graphics.blue.hand_base_picture()
  data.raw.inserter["stack-inserter"].hand_closed_picture = inserter.graphics.blue.stack.hand_closed_picture()
  data.raw.inserter["stack-inserter"].hand_open_picture = inserter.graphics.blue.stack.hand_open_picture()
  data.raw.inserter["stack-inserter"].platform_picture = inserter.graphics.blue.platform_picture()

  data.raw.inserter["stack-filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-stack-filter-inserter.png"
  data.raw.inserter["stack-filter-inserter"].icon_size = 32
  data.raw.inserter["stack-filter-inserter"].order = "[inserter]-d[express]-d[stack-filter]"
  data.raw.inserter["stack-filter-inserter"].next_upgrade = "turbo-stack-filter-inserter"
  data.raw.inserter["stack-filter-inserter"].max_health = inserter.stats.blue.health
  data.raw.inserter["stack-filter-inserter"].extension_speed = inserter.stats.blue.extension_speed
  data.raw.inserter["stack-filter-inserter"].rotation_speed = inserter.stats.blue.rotation_speed
  data.raw.inserter["stack-filter-inserter"].energy_per_movement = inserter.stats.blue.stack.energy_per_movement
  data.raw.inserter["stack-filter-inserter"].energy_per_rotation = inserter.stats.blue.stack.energy_per_rotation
  data.raw.inserter["stack-filter-inserter"].energy_source.drain = inserter.stats.blue.stack.drain
  data.raw.inserter["stack-filter-inserter"].hand_base_picture = inserter.graphics.blue.hand_base_picture()
  data.raw.inserter["stack-filter-inserter"].hand_closed_picture = inserter.graphics.blue.stack.hand_closed_picture()
  data.raw.inserter["stack-filter-inserter"].hand_open_picture = inserter.graphics.blue.stack.hand_open_picture()
  data.raw.inserter["stack-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()


  data:extend(
  {
    util.merge{
      data.raw.inserter["fast-inserter"],
      {
        name = "turbo-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/purple-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "turbo-inserter"},
        next_upgrade = "express-inserter",
        max_health = inserter.stats.purple.health,
        extension_speed = inserter.stats.purple.extension_speed,
        rotation_speed = inserter.stats.purple.rotation_speed,
        energy_per_movement = inserter.stats.purple.energy_per_movement,
        energy_per_rotation = inserter.stats.purple.energy_per_rotation,
        energy_source = { drain = inserter.stats.purple.drain },
      }
    }
  }
  )
  data.raw.inserter["turbo-inserter"].hand_base_picture = inserter.graphics.purple.hand_base_picture()
  data.raw.inserter["turbo-inserter"].hand_closed_picture = inserter.graphics.purple.hand_closed_picture()
  data.raw.inserter["turbo-inserter"].hand_open_picture = inserter.graphics.purple.hand_open_picture()
  data.raw.inserter["turbo-inserter"].platform_picture = inserter.graphics.purple.platform_picture()


  data:extend(
  {
    util.merge{
      data.raw.inserter["filter-inserter"],
      {
        name = "turbo-filter-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/purple-filter-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "turbo-filter-inserter"},
        next_upgrade = "express-filter-inserter",
        max_health = inserter.stats.purple.health,
        extension_speed = inserter.stats.purple.extension_speed,
        rotation_speed = inserter.stats.purple.rotation_speed,
        energy_per_movement = inserter.stats.purple.energy_per_movement,
        energy_per_rotation = inserter.stats.purple.energy_per_rotation,
        energy_source = { drain = inserter.stats.purple.drain },
      }
    }
  }
  )
  data.raw.inserter["turbo-filter-inserter"].hand_base_picture = inserter.graphics.purple.hand_base_picture()
  data.raw.inserter["turbo-filter-inserter"].hand_closed_picture = inserter.graphics.purple.hand_closed_picture()
  data.raw.inserter["turbo-filter-inserter"].hand_open_picture = inserter.graphics.purple.hand_open_picture()
  data.raw.inserter["turbo-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()

  data:extend(
  {
    util.merge{
      data.raw.inserter["stack-inserter"],
      {
        name = "turbo-stack-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/purple-stack-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "turbo-stack-inserter"},
        next_upgrade = "express-stack-inserter",
        max_health = inserter.stats.purple.health,
        extension_speed = inserter.stats.purple.extension_speed,
        rotation_speed = inserter.stats.purple.rotation_speed,
        energy_per_movement = inserter.stats.purple.stack.energy_per_movement,
        energy_per_rotation = inserter.stats.purple.stack.energy_per_rotation,
        energy_source = { drain = inserter.stats.purple.stack.drain },
      }
    }
  }
  )
  data.raw.inserter["turbo-stack-inserter"].hand_base_picture = inserter.graphics.purple.hand_base_picture()
  data.raw.inserter["turbo-stack-inserter"].hand_closed_picture = inserter.graphics.purple.stack.hand_closed_picture()
  data.raw.inserter["turbo-stack-inserter"].hand_open_picture = inserter.graphics.purple.stack.hand_open_picture()
  data.raw.inserter["turbo-stack-inserter"].platform_picture = inserter.graphics.purple.platform_picture()

  data:extend(
  {
    util.merge{
      data.raw.inserter["stack-filter-inserter"],
      {
        name = "turbo-stack-filter-inserter",
        icon = "__boblogistics__/graphics/icons/inserter/purple-stack-filter-inserter.png",
        icon_size = 32,
        minable = {mining_time = 0.1, result = "turbo-stack-filter-inserter"},
        filter_count = 2,
        next_upgrade = "express-stack-filter-inserter",
        max_health = inserter.stats.purple.health,
        extension_speed = inserter.stats.purple.extension_speed,
        rotation_speed = inserter.stats.purple.rotation_speed,
        energy_per_movement = inserter.stats.purple.stack.energy_per_movement,
        energy_per_rotation = inserter.stats.purple.stack.energy_per_rotation,
        energy_source = { drain = inserter.stats.purple.stack.drain },
      }
    }
  }
  )
  data.raw.inserter["turbo-stack-filter-inserter"].hand_base_picture = inserter.graphics.purple.hand_base_picture()
  data.raw.inserter["turbo-stack-filter-inserter"].hand_closed_picture = inserter.graphics.purple.stack.hand_closed_picture()
  data.raw.inserter["turbo-stack-filter-inserter"].hand_open_picture = inserter.graphics.purple.stack.hand_open_picture()
  data.raw.inserter["turbo-stack-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()


--these must be after turbo to prevent them being copied onto the turbo inserters.

  data.raw.inserter["fast-inserter"].localised_name = {"entity-name.express-inserter"}
  data.raw.inserter["filter-inserter"].localised_name = {"entity-name.express-filter-inserter"}
  data.raw.inserter["stack-inserter"].localised_name = {"entity-name.express-stack-inserter"}
  data.raw.inserter["stack-filter-inserter"].localised_name = {"entity-name.express-stack-filter-inserter"}


  data.raw.inserter["express-inserter"].localised_name = {"entity-name.ultimate-inserter"}
  data.raw.inserter["express-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-inserter.png"
  data.raw.inserter["express-inserter"].icon_size = 32
  data.raw.inserter["express-inserter"].max_health = inserter.stats.green.health
  data.raw.inserter["express-inserter"].extension_speed = inserter.stats.green.extension_speed
  data.raw.inserter["express-inserter"].rotation_speed = inserter.stats.green.rotation_speed
  data.raw.inserter["express-inserter"].energy_per_movement = inserter.stats.green.energy_per_movement
  data.raw.inserter["express-inserter"].energy_per_rotation = inserter.stats.green.energy_per_rotation
  data.raw.inserter["express-inserter"].energy_source.drain = inserter.stats.green.drain
  data.raw.inserter["express-inserter"].hand_base_picture = inserter.graphics.green.hand_base_picture()
  data.raw.inserter["express-inserter"].hand_closed_picture = inserter.graphics.green.hand_closed_picture()
  data.raw.inserter["express-inserter"].hand_open_picture = inserter.graphics.green.hand_open_picture()
  data.raw.inserter["express-inserter"].platform_picture = inserter.graphics.green.platform_picture()

  data.raw.inserter["express-filter-inserter"].localised_name = {"entity-name.ultimate-filter-inserter"}
  data.raw.inserter["express-filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-filter-inserter.png"
  data.raw.inserter["express-filter-inserter"].icon_size = 32
  data.raw.inserter["express-filter-inserter"].max_health = inserter.stats.green.health
  data.raw.inserter["express-filter-inserter"].extension_speed = inserter.stats.green.extension_speed
  data.raw.inserter["express-filter-inserter"].rotation_speed = inserter.stats.green.rotation_speed
  data.raw.inserter["express-filter-inserter"].energy_per_movement = inserter.stats.green.energy_per_movement
  data.raw.inserter["express-filter-inserter"].energy_per_rotation = inserter.stats.green.energy_per_rotation
  data.raw.inserter["express-filter-inserter"].energy_source.drain = inserter.stats.green.drain
  data.raw.inserter["express-filter-inserter"].hand_base_picture = inserter.graphics.green.hand_base_picture()
  data.raw.inserter["express-filter-inserter"].hand_closed_picture = inserter.graphics.green.hand_closed_picture()
  data.raw.inserter["express-filter-inserter"].hand_open_picture = inserter.graphics.green.hand_open_picture()
  data.raw.inserter["express-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()

  data.raw.inserter["express-stack-inserter"].localised_name = {"entity-name.ultimate-stack-inserter"}
  data.raw.inserter["express-stack-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-stack-inserter.png"
  data.raw.inserter["express-stack-inserter"].icon_size = 32
  data.raw.inserter["express-stack-inserter"].max_health = inserter.stats.green.health
  data.raw.inserter["express-stack-inserter"].extension_speed = inserter.stats.green.extension_speed
  data.raw.inserter["express-stack-inserter"].rotation_speed = inserter.stats.green.rotation_speed
  data.raw.inserter["express-stack-inserter"].energy_per_movement = inserter.stats.green.stack.energy_per_movement
  data.raw.inserter["express-stack-inserter"].energy_per_rotation = inserter.stats.green.stack.energy_per_rotation
  data.raw.inserter["express-stack-inserter"].energy_source.drain = inserter.stats.green.stack.drain
  data.raw.inserter["express-stack-inserter"].hand_base_picture = inserter.graphics.green.hand_base_picture()
  data.raw.inserter["express-stack-inserter"].hand_closed_picture = inserter.graphics.green.stack.hand_closed_picture()
  data.raw.inserter["express-stack-inserter"].hand_open_picture = inserter.graphics.green.stack.hand_open_picture()
  data.raw.inserter["express-stack-inserter"].platform_picture = inserter.graphics.green.platform_picture()

  data.raw.inserter["express-stack-filter-inserter"].localised_name = {"entity-name.ultimate-stack-filter-inserter"}
  data.raw.inserter["express-stack-filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-stack-filter-inserter.png"
  data.raw.inserter["express-stack-filter-inserter"].icon_size = 32
  data.raw.inserter["express-stack-filter-inserter"].max_health = inserter.stats.green.health
  data.raw.inserter["express-stack-filter-inserter"].extension_speed = inserter.stats.green.extension_speed
  data.raw.inserter["express-stack-filter-inserter"].rotation_speed = inserter.stats.green.rotation_speed
  data.raw.inserter["express-stack-filter-inserter"].energy_per_movement = inserter.stats.green.stack.energy_per_movement
  data.raw.inserter["express-stack-filter-inserter"].energy_per_rotation = inserter.stats.green.stack.energy_per_rotation
  data.raw.inserter["express-stack-filter-inserter"].energy_source.drain = inserter.stats.green.stack.drain
  data.raw.inserter["express-stack-filter-inserter"].hand_base_picture = inserter.graphics.green.hand_base_picture()
  data.raw.inserter["express-stack-filter-inserter"].hand_closed_picture = inserter.graphics.green.stack.hand_closed_picture()
  data.raw.inserter["express-stack-filter-inserter"].hand_open_picture = inserter.graphics.green.stack.hand_open_picture()
  data.raw.inserter["express-stack-filter-inserter"].platform_picture = inserter.graphics.filter.platform_picture()

end
