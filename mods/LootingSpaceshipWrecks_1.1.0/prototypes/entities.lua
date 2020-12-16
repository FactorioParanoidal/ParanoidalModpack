local salvaged_lab_inputs = table.deepcopy(data.raw["lab"]["lab"].inputs)
local salvaged_generator_animation_speed = 0.5
local salvaged_sprite_priority = "very-low"
local salvaged_assembling_machine_animation_speed = 1
local salvaged_lab_animation_speed = 0.5

local salvaged_sounds = {}

salvaged_sounds.generic_impact =
{
  {
    filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5
  }
}

salvaged_sounds.machine_open =
{
  {
    filename = "__base__/sound/machine-open.ogg", volume = 0.5
  }
}

salvaged_sounds.machine_close =
{
  {
    filename = "__base__/sound/machine-close.ogg", volume = 0.5
  }
}

data:extend(
{
  {
    type = "assembling-machine",
    name = "salvaged-assembling-machine",
    icon = "__LootingSpaceshipWrecks__/graphics/icons/crash-site-assembling-machine-1-repaired.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 2, result = "salvaged-assembling-machine"},
    map_color = {r = 0, g = 0.365, b = 0.58, a = 1},
    max_health = 50,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    collision_box = {{-1.2, -0.7}, {1.2, 0.7}},
    selection_box = {{-1.5, -1}, {1.5, 1}},
    alert_icon_shift = util.by_pixel(-3, -12),
    
    animation = salvaged_assembler_horizontal_animation(salvaged_assembling_machine_animation_speed),
    working_visualisations = salvaged_assembler_horizontal_visualisation(salvaged_assembling_machine_animation_speed),
    crafting_categories = {"crafting", "basic-crafting", "advanced-crafting"},
    crafting_speed = 0.25,
    match_animation_speed_to_activity = false,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 4
    },
    energy_usage = "90kW",
    open_sound = salvaged_sounds.machine_open,
    close_sound = salvaged_sounds.machine_close,
    vehicle_impact_sound = salvaged_sounds.generic_impact,
    working_sound =
    {
      sound =
      {
        {
          filename = "__base__/sound/assembling-machine-repaired-1.ogg",
          volume = 0.8
        },
      }
    }
  },
  {
    type = "lab",
    name = "salvaged-lab",
    icon = "__LootingSpaceshipWrecks__/graphics/icons/crash-site-lab-repaired.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 2, result = "salvaged-lab"},
    map_color = {r = 0, g = 0.365, b = 0.58, a = 1},
    max_health = 50,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-2.2, -1.2}, {2.2, 1.2}},
    selection_box = {{-2.5, -1.5}, {2.5, 1.5}},
    entity_info_icon_shift = util.by_pixel(32, 0),
    light = {intensity = 0.9, size = 12, color = {r = 1.0, g = 1.0, b = 1.0}, shift = {1.5, 0.5}},
    
    on_animation =
    {
      layers =
      {
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/crash-site-lab-repaired.png",
          priority = salvaged_sprite_priority,
          width = 244,
          height = 126,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          shift = util.by_pixel(-34, -2),
          hr_version =
          {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/hr-crash-site-lab-repaired.png",
            priority = salvaged_sprite_priority,
            width = 488,
            height = 252,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            shift = util.by_pixel(-34, -2),
            scale = 0.5
          }
        },
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/crash-site-lab-repaired-beams.png",
          priority = salvaged_sprite_priority,
          width = 68,
          height = 50,
          frame_count = 24,
          line_length = 6,
          animation_speed = salvaged_lab_animation_speed,
          shift = util.by_pixel(20, -36),
          blend_mode = "additive",
          hr_version =
          {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/hr-crash-site-lab-repaired-beams.png",
            priority = salvaged_sprite_priority,
            width = 130,
            height = 100,
            frame_count = 24,
            line_length = 6,
            animation_speed = salvaged_lab_animation_speed,
            shift = util.by_pixel(21, -36),
            blend_mode = "additive",
            scale = 0.5
          }
        },
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/crash-site-lab-repaired-shadow.png",
          priority = salvaged_sprite_priority,
          width = 350,
          height = 148,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          shift = util.by_pixel(-28, -4),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/hr-crash-site-lab-repaired-shadow.png",
            priority = salvaged_sprite_priority,
            width = 696,
            height = 302,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            shift = util.by_pixel(-27, -4),
            scale = 0.5,
            draw_as_shadow = true
          }
        }
      }
    },
    off_animation =
    {
      layers =
      {
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/crash-site-lab-repaired.png",
          priority = salvaged_sprite_priority,
          width = 244,
          height = 126,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          shift = util.by_pixel(-34, -2),
          hr_version =
          {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/hr-crash-site-lab-repaired.png",
            priority = salvaged_sprite_priority,
            width = 488,
            height = 252,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            shift = util.by_pixel(-34, -2),
            scale = 0.5
          }
        },
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/crash-site-lab-repaired-shadow.png",
          priority = salvaged_sprite_priority,
          width = 350,
          height = 148,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          shift = util.by_pixel(-28, -4),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-lab/hr-crash-site-lab-repaired-shadow.png",
            priority = salvaged_sprite_priority,
            width = 696,
            height = 302,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            shift = util.by_pixel(-27, -4),
            scale = 0.5,
            draw_as_shadow = true
          }
        }
      }
    },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/lab.ogg",
        volume = 0.7
      },
      audible_distance_modifier = 0.7,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    vehicle_impact_sound = salvaged_sounds.generic_impact,
    open_sound = salvaged_sounds.machine_open,
    close_sound = salvaged_sounds.machine_close,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "650kW",
    researching_speed = 0.15,
    inputs = salvaged_lab_inputs
  },
  {
    type = "electric-energy-interface",
    name = "salvaged-generator",
    icon = "__LootingSpaceshipWrecks__/graphics/icons/crash-site-generator.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {mining_time = 2, result = "salvaged-generator"},
    map_color = {r = 0, g = 0.365, b = 0.58, a = 1},
    max_health = 150,
    corpse = "medium-remnants",
    --subgroup = "other",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1, -1}, {1, 1}},
    allow_copy_paste = false,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "15MJ",
      usage_priority = "tertiary",
      input_flow_limit = "0kW",
      output_flow_limit = "1.5MW"
    },

    energy_production = "750kW",
    energy_usage = "0kW",
    light = {intensity = 0.75, size = 6, color = {r = 1.0, g = 1.0, b = 1.0}, shift = {64/64, -140/64}},
    continuous_animation = true,
    
    animation =
    {
      layers =
      {
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-generator/crash-site-generator.png",
          priority = salvaged_sprite_priority,
          width = 142,
          height= 128,
          frame_count = 5,
          line_length = 5,
          repeat_count = 16,
          shift = util.by_pixel(-10, -24),
          animation_speed = salvaged_generator_animation_speed,
          hr_version = {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-generator/hr-crash-site-generator.png",
            priority = salvaged_sprite_priority,
            width = 286,
            height= 252,
            frame_count = 5,
            line_length = 5,
            repeat_count = 16,
            animation_speed = salvaged_generator_animation_speed,
            shift = util.by_pixel(-11, -23),
            scale = 0.5
          }
        },
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-generator/crash-site-generator-beams.png",
          priority = salvaged_sprite_priority,
          width = 48,
          height= 116,
          frame_count = 16,
          line_length = 4,
          repeat_count = 5,
          shift = util.by_pixel(24, -30),
          animation_speed = salvaged_generator_animation_speed,
          hr_version = {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-generator/hr-crash-site-generator-beams.png",
            priority = salvaged_sprite_priority,
            width = 224,
            height= 232,
            frame_count = 16,
            line_length = 4,
            repeat_count = 5,
            animation_speed = salvaged_generator_animation_speed,
            shift = util.by_pixel(-8, -30),
            scale = 0.5
          }
        },
        {
          filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-generator/crash-site-generator-shadow.png",
          priority = salvaged_sprite_priority,
          width = 236,
          height= 78,
          frame_count = 1,
          line_length = 1,
          repeat_count = 80,
          shift = util.by_pixel(26, 4),
          draw_as_shadow = true,
          animation_speed = salvaged_generator_animation_speed,
          hr_version =
          {
            filename = "__LootingSpaceshipWrecks__/graphics/entity/crash-site-generator/hr-crash-site-generator-shadow.png",
            priority = salvaged_sprite_priority,
            width = 474,
            height= 152,
            frame_count = 1,
            line_length = 1,
            repeat_count = 80,
            draw_as_shadow = true,
            shift = util.by_pixel(25, 5),
            animation_speed = salvaged_generator_animation_speed,
            scale = 0.5
          }
        },
      }
    },
    vehicle_impact_sound = salvaged_sounds.generic_impact
  }
})