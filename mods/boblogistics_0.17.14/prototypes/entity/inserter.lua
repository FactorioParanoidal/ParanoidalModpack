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



if settings.startup["bobmods-logistics-inserteroverhaul"].value == true then


data.raw.inserter["inserter"].max_health = 125
data.raw.inserter["inserter"].extension_speed = 0.04
data.raw.inserter["inserter"].rotation_speed = 0.02
data.raw.inserter["inserter"].next_upgrade = "red-inserter"


data.raw.inserter["long-handed-inserter"].max_health = 150
data.raw.inserter["long-handed-inserter"].order = "[inserter]-c[fast]"
data.raw.inserter["long-handed-inserter"].fast_replaceable_group = "inserter"
data.raw.inserter["long-handed-inserter"].placeable_by = {item = "long-handed-inserter", count = 1}
data.raw.inserter["long-handed-inserter"].extension_speed = 0.06
data.raw.inserter["long-handed-inserter"].rotation_speed = 0.03


data.raw.item["fast-inserter"].localised_name = {"entity-name.express-inserter"}
data.raw.inserter["fast-inserter"].localised_name = {"entity-name.express-inserter"}
data.raw.inserter["fast-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-inserter.png"
data.raw.inserter["fast-inserter"].icon_size = 32
data.raw.inserter["fast-inserter"].max_health = 175
data.raw.inserter["fast-inserter"].order = "[inserter]-d[express]"
data.raw.inserter["fast-inserter"].next_upgrade = "turbo-inserter"
data.raw.inserter["fast-inserter"].extension_speed = 0.1
data.raw.inserter["fast-inserter"].rotation_speed = 0.05

data.raw.item["filter-inserter"].localised_name = {"entity-name.express-filter-inserter"}
data.raw.inserter["filter-inserter"].localised_name = {"entity-name.express-filter-inserter"}
data.raw.inserter["filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-filter-inserter.png"
data.raw.inserter["filter-inserter"].icon_size = 32
data.raw.inserter["filter-inserter"].max_health = 175
data.raw.inserter["filter-inserter"].order = "[inserter]-d[express]-b[filter]"
data.raw.inserter["filter-inserter"].next_upgrade = "turbo-filter-inserter"
data.raw.inserter["filter-inserter"].extension_speed = 0.1
data.raw.inserter["filter-inserter"].rotation_speed = 0.05
data.raw.inserter["filter-inserter"].energy_per_movement = "7kJ"
data.raw.inserter["filter-inserter"].energy_per_rotation = "7kJ"
data.raw.inserter["filter-inserter"].hand_base_picture.filename = "__base__/graphics/entity/fast-inserter/fast-inserter-hand-base.png"
data.raw.inserter["filter-inserter"].hand_base_picture.hr_version.filename = "__base__/graphics/entity/fast-inserter/hr-fast-inserter-hand-base.png"
data.raw.inserter["filter-inserter"].hand_closed_picture.filename = "__base__/graphics/entity/fast-inserter/fast-inserter-hand-closed.png"
data.raw.inserter["filter-inserter"].hand_closed_picture.hr_version.filename = "__base__/graphics/entity/fast-inserter/hr-fast-inserter-hand-closed.png"
data.raw.inserter["filter-inserter"].hand_open_picture.filename = "__base__/graphics/entity/fast-inserter/fast-inserter-hand-open.png"
data.raw.inserter["filter-inserter"].hand_open_picture.hr_version.filename = "__base__/graphics/entity/fast-inserter/hr-fast-inserter-hand-open.png"
data.raw.inserter["filter-inserter"].platform_picture.sheet.filename = "__base__/graphics/entity/stack-filter-inserter/stack-filter-inserter-platform.png"
data.raw.inserter["filter-inserter"].platform_picture.sheet.hr_version.filename = "__base__/graphics/entity/stack-filter-inserter/hr-stack-filter-inserter-platform.png"

data.raw.item["stack-inserter"].localised_name = {"entity-name.express-stack-inserter"}
data.raw.inserter["stack-inserter"].localised_name = {"entity-name.express-stack-inserter"}
data.raw.inserter["stack-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-stack-inserter.png"
data.raw.inserter["stack-inserter"].icon_size = 32
data.raw.inserter["stack-inserter"].max_health = 175
data.raw.inserter["stack-inserter"].order = "[inserter]-d[express]-c[stack]"
data.raw.inserter["stack-inserter"].next_upgrade = "turbo-stack-inserter"
data.raw.inserter["stack-inserter"].extension_speed = 0.1
data.raw.inserter["stack-inserter"].rotation_speed = 0.05
data.raw.inserter["stack-inserter"].energy_source.drain = "0.8kW"
data.raw.inserter["stack-inserter"].hand_base_picture.filename = "__base__/graphics/entity/fast-inserter/fast-inserter-hand-base.png"
data.raw.inserter["stack-inserter"].hand_base_picture.hr_version.filename = "__base__/graphics/entity/fast-inserter/hr-fast-inserter-hand-base.png"
data.raw.inserter["stack-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/blue-stack-inserter-hand-closed.png"
data.raw.inserter["stack-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-blue-stack-inserter-hand-closed.png"
data.raw.inserter["stack-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/blue-stack-inserter-hand-open.png"
data.raw.inserter["stack-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-blue-stack-inserter-hand-open.png"
data.raw.inserter["stack-inserter"].platform_picture.sheet.filename = "__base__/graphics/entity/fast-inserter/fast-inserter-platform.png"
data.raw.inserter["stack-inserter"].platform_picture.sheet.hr_version.filename = "__base__/graphics/entity/fast-inserter/hr-fast-inserter-platform.png"

data.raw.item["stack-filter-inserter"].localised_name = {"entity-name.express-stack-filter-inserter"}
data.raw.inserter["stack-filter-inserter"].localised_name = {"entity-name.express-stack-filter-inserter"}
data.raw.inserter["stack-filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/blue-stack-filter-inserter.png"
data.raw.inserter["stack-filter-inserter"].icon_size = 32
data.raw.inserter["stack-filter-inserter"].max_health = 175
data.raw.inserter["stack-filter-inserter"].order = "[inserter]-d[express]-d[stack-filter]"
data.raw.inserter["stack-filter-inserter"].next_upgrade = "turbo-stack-filter-inserter"
data.raw.inserter["stack-filter-inserter"].extension_speed = 0.1
data.raw.inserter["stack-filter-inserter"].rotation_speed = 0.05
data.raw.inserter["stack-filter-inserter"].energy_source.drain = "0.8kW"
data.raw.inserter["stack-filter-inserter"].hand_base_picture.filename = "__base__/graphics/entity/fast-inserter/fast-inserter-hand-base.png"
data.raw.inserter["stack-filter-inserter"].hand_base_picture.hr_version.filename = "__base__/graphics/entity/fast-inserter/hr-fast-inserter-hand-base.png"
data.raw.inserter["stack-filter-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/blue-stack-inserter-hand-closed.png"
data.raw.inserter["stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-blue-stack-inserter-hand-closed.png"
data.raw.inserter["stack-filter-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/blue-stack-inserter-hand-open.png"
data.raw.inserter["stack-filter-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-blue-stack-inserter-hand-open.png"
data.raw.inserter["stack-filter-inserter"].platform_picture.sheet.filename = "__base__/graphics/entity/stack-filter-inserter/stack-filter-inserter-platform.png"
data.raw.inserter["stack-filter-inserter"].platform_picture.sheet.hr_version.filename = "__base__/graphics/entity/stack-filter-inserter/hr-stack-filter-inserter-platform.png"



data.raw.item["express-inserter"].localised_name = {"entity-name.ultimate-inserter"}
data.raw.inserter["express-inserter"].localised_name = {"entity-name.ultimate-inserter"}
data.raw.inserter["express-inserter"].max_health = 225
data.raw.inserter["express-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-inserter.png"
data.raw.inserter["express-inserter"].icon_size = 32
data.raw.inserter["express-inserter"].hand_base_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-base.png"
data.raw.inserter["express-inserter"].hand_base_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-base.png"
data.raw.inserter["express-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-closed.png"
data.raw.inserter["express-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-closed.png"
data.raw.inserter["express-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-open.png"
data.raw.inserter["express-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-open.png"
data.raw.inserter["express-inserter"].platform_picture.sheet.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-platform.png"
data.raw.inserter["express-inserter"].platform_picture.sheet.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-platform.png"

data.raw.item["express-filter-inserter"].localised_name = {"entity-name.ultimate-filter-inserter"}
data.raw.inserter["express-filter-inserter"].localised_name = {"entity-name.ultimate-filter-inserter"}
data.raw.inserter["express-filter-inserter"].max_health = 225
data.raw.inserter["express-filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-filter-inserter.png"
data.raw.inserter["express-filter-inserter"].icon_size = 32
data.raw.inserter["express-filter-inserter"].hand_base_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-base.png"
data.raw.inserter["express-filter-inserter"].hand_base_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-base.png"
data.raw.inserter["express-filter-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-closed.png"
data.raw.inserter["express-filter-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-closed.png"
data.raw.inserter["express-filter-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-open.png"
data.raw.inserter["express-filter-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-open.png"
data.raw.inserter["express-filter-inserter"].platform_picture.sheet.filename = "__boblogistics__/graphics/entity/inserter/white-inserter-platform.png"
data.raw.inserter["express-filter-inserter"].platform_picture.sheet.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-white-inserter-platform.png"

data.raw.item["express-stack-inserter"].localised_name = {"entity-name.ultimate-stack-inserter"}
data.raw.inserter["express-stack-inserter"].localised_name = {"entity-name.ultimate-stack-inserter"}
data.raw.inserter["express-stack-inserter"].max_health = 225
data.raw.inserter["express-stack-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-stack-inserter.png"
data.raw.inserter["express-stack-inserter"].icon_size = 32
data.raw.inserter["express-stack-inserter"].hand_base_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-base.png"
data.raw.inserter["express-stack-inserter"].hand_base_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-base.png"
data.raw.inserter["express-stack-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/green-stack-inserter-hand-closed.png"
data.raw.inserter["express-stack-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-stack-inserter-hand-closed.png"
data.raw.inserter["express-stack-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/green-stack-inserter-hand-open.png"
data.raw.inserter["express-stack-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-stack-inserter-hand-open.png"
data.raw.inserter["express-stack-inserter"].platform_picture.sheet.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-platform.png"
data.raw.inserter["express-stack-inserter"].platform_picture.sheet.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-platform.png"

data.raw.item["express-stack-filter-inserter"].localised_name = {"entity-name.ultimate-stack-filter-inserter"}
data.raw.inserter["express-stack-filter-inserter"].localised_name = {"entity-name.ultimate-stack-filter-inserter"}
data.raw.inserter["express-stack-filter-inserter"].max_health = 225
data.raw.inserter["express-stack-filter-inserter"].icon = "__boblogistics__/graphics/icons/inserter/green-stack-filter-inserter.png"
data.raw.inserter["express-stack-filter-inserter"].icon_size = 32
data.raw.inserter["express-stack-filter-inserter"].hand_base_picture.filename = "__boblogistics__/graphics/entity/inserter/green-inserter-hand-base.png"
data.raw.inserter["express-stack-filter-inserter"].hand_base_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-inserter-hand-base.png"
data.raw.inserter["express-stack-filter-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/green-stack-inserter-hand-closed.png"
data.raw.inserter["express-stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-stack-inserter-hand-closed.png"
data.raw.inserter["express-stack-filter-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/green-stack-inserter-hand-open.png"
data.raw.inserter["express-stack-filter-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-green-stack-inserter-hand-open.png"
data.raw.inserter["express-stack-filter-inserter"].platform_picture.sheet.filename = "__boblogistics__/graphics/entity/inserter/white-inserter-platform.png"
data.raw.inserter["express-stack-filter-inserter"].platform_picture.sheet.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-white-inserter-platform.png"


data:extend(
{
  util.merge{
    data.raw.inserter["filter-inserter"],
    {
      name = "yellow-filter-inserter",
      max_health = 125,
      icon = "__boblogistics__/graphics/icons/inserter/yellow-filter-inserter.png",
      icon_size = 32,
      minable = {mining_time = 0.1, result = "yellow-filter-inserter"},
      next_upgrade = "red-filter-inserter",
      extension_speed = 0.04,
      rotation_speed = 0.02,
      energy_per_movement = "5kJ",
      energy_per_rotation = "5kJ",
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        drain = "0.4kW"
      },
    }
  },
  util.merge{
    data.raw.inserter["long-handed-inserter"],
    {
      name = "red-inserter",
      next_upgrade = "fast-inserter",
      pickup_position = {0, -1},
      insert_position = {0, 1.2},
    }
  },
  util.merge{
    data.raw.inserter["filter-inserter"],
    {
      name = "red-filter-inserter",
      max_health = 150,
      icon = "__boblogistics__/graphics/icons/inserter/red-filter-inserter.png",
      icon_size = 32,
      minable = {mining_time = 0.1, result = "red-filter-inserter"},
      next_upgrade = "filter-inserter",
      extension_speed = 0.06,
      rotation_speed = 0.03,
      energy_per_movement = "5kJ",
      energy_per_rotation = "5kJ",
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        drain = "0.4kW"
      },
    }
  },
  util.merge{
    data.raw.inserter["stack-inserter"],
    {
      name = "red-stack-inserter",
      max_health = 150,
      icon = "__boblogistics__/graphics/icons/inserter/red-stack-inserter.png",
      icon_size = 32,
      minable = {mining_time = 0.1, result = "red-stack-inserter"},
      next_upgrade = "stack-inserter",
      extension_speed = 0.06,
      rotation_speed = 0.03,
      energy_per_movement = "17.5kJ",
      energy_per_rotation = "17.5kJ",
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        drain = "0.8kW"
      },
    }
  },
  util.merge{
    data.raw.inserter["stack-filter-inserter"],
    {
      name = "red-stack-filter-inserter",
      max_health = 150,
      icon = "__boblogistics__/graphics/icons/inserter/red-stack-filter-inserter.png",
      icon_size = 32,
      minable = {mining_time = 0.1, result = "red-stack-filter-inserter"},
      next_upgrade = "stack-filter-inserter",
      extension_speed = 0.06,
      rotation_speed = 0.03,
      energy_per_movement = "17.5kJ",
      energy_per_rotation = "17.5kJ",
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        drain = "0.8kW"
      },
    }
  },
}
)


data.raw.inserter["yellow-filter-inserter"].hand_base_picture.filename = "__base__/graphics/entity/inserter/inserter-hand-base.png"
data.raw.inserter["yellow-filter-inserter"].hand_base_picture.height = 33
data.raw.inserter["yellow-filter-inserter"].hand_base_picture.hr_version.filename = "__base__/graphics/entity/inserter/hr-inserter-hand-base.png"
data.raw.inserter["yellow-filter-inserter"].hand_closed_picture.filename = "__base__/graphics/entity/inserter/inserter-hand-closed.png"
data.raw.inserter["yellow-filter-inserter"].hand_closed_picture.hr_version.filename = "__base__/graphics/entity/inserter/hr-inserter-hand-closed.png"
data.raw.inserter["yellow-filter-inserter"].hand_open_picture.filename = "__base__/graphics/entity/inserter/inserter-hand-open.png"
data.raw.inserter["yellow-filter-inserter"].hand_open_picture.hr_version.filename = "__base__/graphics/entity/inserter/hr-inserter-hand-open.png"

data.raw.inserter["red-filter-inserter"].hand_base_picture.filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-base.png"
data.raw.inserter["red-filter-inserter"].hand_base_picture.hr_version.filename = "__base__/graphics/entity/long-handed-inserter/hr-long-handed-inserter-hand-base.png"
data.raw.inserter["red-filter-inserter"].hand_closed_picture.filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-closed.png"
data.raw.inserter["red-filter-inserter"].hand_closed_picture.hr_version.filename = "__base__/graphics/entity/long-handed-inserter/hr-long-handed-inserter-hand-closed.png"
data.raw.inserter["red-filter-inserter"].hand_open_picture.filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-open.png"
data.raw.inserter["red-filter-inserter"].hand_open_picture.hr_version.filename = "__base__/graphics/entity/long-handed-inserter/hr-long-handed-inserter-hand-open.png"

data.raw.inserter["red-stack-inserter"].hand_base_picture.filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-base.png"
data.raw.inserter["red-stack-inserter"].hand_base_picture.hr_version.filename = "__base__/graphics/entity/long-handed-inserter/hr-long-handed-inserter-hand-base.png"
data.raw.inserter["red-stack-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/red-stack-inserter-hand-closed.png"
data.raw.inserter["red-stack-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-red-stack-inserter-hand-closed.png"
data.raw.inserter["red-stack-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/red-stack-inserter-hand-open.png"
data.raw.inserter["red-stack-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-red-stack-inserter-hand-open.png"
data.raw.inserter["red-stack-inserter"].platform_picture.sheet.filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-platform.png"
data.raw.inserter["red-stack-inserter"].platform_picture.sheet.hr_version.filename = "__base__/graphics/entity/long-handed-inserter/hr-long-handed-inserter-platform.png"

data.raw.inserter["red-stack-filter-inserter"].hand_base_picture.filename = "__base__/graphics/entity/long-handed-inserter/long-handed-inserter-hand-base.png"
data.raw.inserter["red-stack-filter-inserter"].hand_base_picture.hr_version.filename = "__base__/graphics/entity/long-handed-inserter/hr-long-handed-inserter-hand-base.png"
data.raw.inserter["red-stack-filter-inserter"].hand_closed_picture.filename = "__boblogistics__/graphics/entity/inserter/red-stack-inserter-hand-closed.png"
data.raw.inserter["red-stack-filter-inserter"].hand_closed_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-red-stack-inserter-hand-closed.png"
data.raw.inserter["red-stack-filter-inserter"].hand_open_picture.filename = "__boblogistics__/graphics/entity/inserter/red-stack-inserter-hand-open.png"
data.raw.inserter["red-stack-filter-inserter"].hand_open_picture.hr_version.filename = "__boblogistics__/graphics/entity/inserter/hr-red-stack-inserter-hand-open.png"



data:extend(
{
  {
    type = "inserter",
    name = "turbo-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/purple-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = "turbo-inserter"},
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
    energy_per_movement = "8.5kJ",
    energy_per_rotation = "8.5kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "0.6kW"
    },
    extension_speed = 0.2,
    rotation_speed = 0.07,
    pickup_position = {0, -1},
    insert_position = {0, 1.2},
    fast_replaceable_group = "inserter",
    next_upgrade = "express-inserter",
    hand_base_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-closed.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-open.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-open.png",
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
        filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-platform.png",
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
    name = "turbo-filter-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/purple-filter-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.1, result = "turbo-filter-inserter"},
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
    energy_per_movement = "8.5kJ",
    energy_per_rotation = "8.5kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "0.6kW"
    },
    extension_speed = 0.2,
    rotation_speed = 0.07,
    fast_replaceable_group = "inserter",
    next_upgrade = "express-filter-inserter",
    filter_count = 5,
    hand_base_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-closed.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-closed.png",
        priority = "extra-high",
        width = 72,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-open.png",
      priority = "extra-high",
      width = 18,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-open.png",
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
        filename = "__boblogistics__/graphics/entity/inserter/white-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-white-inserter-platform.png",
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
    name = "turbo-stack-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/purple-stack-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    stack = true,
    minable =
    {
      mining_time = 0.1,
      result = "turbo-stack-inserter"
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
    energy_per_movement = "22kJ",
    energy_per_rotation = "22kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "1.2kW"
    },
    extension_speed = 0.2,
    rotation_speed = 0.07,
    fast_replaceable_group = "inserter",
    next_upgrade = "express-stack-inserter",
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
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-stack-inserter-hand-closed.png",
      priority = "extra-high",
      width = 24,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-stack-inserter-hand-closed.png",
        priority = "extra-high",
        width = 100,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-stack-inserter-hand-open.png",
      priority = "extra-high",
      width = 32,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-stack-inserter-hand-open.png",
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
        filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-platform.png",
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
    name = "turbo-stack-filter-inserter",
    icon = "__boblogistics__/graphics/icons/inserter/purple-stack-filter-inserter.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    stack = true,
    filter_count = 2,
    minable =
    {
      mining_time = 0.1,
      result = "turbo-stack-filter-inserter"
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
    energy_per_movement = "22kJ",
    energy_per_rotation = "22kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "1.2kW"
    },
    extension_speed = 0.2,
    rotation_speed = 0.07,
    fast_replaceable_group = "inserter",
    next_upgrade = "express-stack-filter-inserter",
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
      filename = "__boblogistics__/graphics/entity/inserter/purple-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 34,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-inserter-hand-base.png",
        priority = "extra-high",
        width = 32,
        height = 136,
        scale = 0.25
      }
    },
    hand_closed_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-stack-inserter-hand-closed.png",
      priority = "extra-high",
      width = 24,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-stack-inserter-hand-closed.png",
        priority = "extra-high",
        width = 100,
        height = 164,
        scale = 0.25
      }
    },
    hand_open_picture =
    {
      filename = "__boblogistics__/graphics/entity/inserter/purple-stack-inserter-hand-open.png",
      priority = "extra-high",
      width = 32,
      height = 41,
      hr_version = {
        filename = "__boblogistics__/graphics/entity/inserter/hr-purple-stack-inserter-hand-open.png",
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
        filename = "__boblogistics__/graphics/entity/inserter/white-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
        shift = {0.09375, 0},
        hr_version = {
          filename = "__boblogistics__/graphics/entity/inserter/hr-white-inserter-platform.png",
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

end

