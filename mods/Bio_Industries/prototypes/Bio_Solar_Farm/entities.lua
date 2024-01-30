if BI.Settings.BI_Solar_Additions then

local solarboilerstructurelayer = 
{
    layers = {
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_boiler/Bio_Solar_Boiler.png",
        priority = "low",
        width = 288,
        height = 288,
        scale = 1,
        hr_version = {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_boiler/hr_Bio_Solar_Boiler.png",
          priority = "low",
          width = 576,
          height = 576,
          scale = 0.5,
        }
      },
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_boiler/Bio_Solar_Boiler_shadow.png",
        priority = "high",
        width = 288,
        height = 288,
        scale = 1,
        draw_as_shadow = true,
        hr_version = {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_boiler/hr_Bio_Solar_Boiler_shadow.png",
          priority = "high",
          width = 576,
          height = 576,
          scale = 0.5,
          draw_as_shadow = true,
        },
      },
    },
}

local solarboilerfireglow = 
{
    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_boiler/Bio_Solar_Boiler_light.png",
    priority = "extra-high",
    frame_count = 1,
    width = 288,
    height = 288,
    scale = 1,
    draw_as_glow = true,
    blend_mode = "additive",
    hr_version = {
      filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_boiler/hr_Bio_Solar_Boiler_light.png",
      priority = "extra-high",
      frame_count = 1,
      width = 576,
      height = 576,
      scale = 0.5,
      draw_as_glow = true,
      blend_mode = "additive",
    }
}
--###############################################################################################
data:extend({

-- Solar Farm
{
    type = "solar-panel",
    name = "bi-bio-solar-farm",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/solar-panel-large.png",
    icon_size = 64, icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.25, mining_time = 0.5, result = "bi-bio-solar-farm"},
    max_health = 600,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 80}},
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    energy_source = {type = "electric", usage_priority = "solar"},
    picture = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_farm/Bio_Solar_Farm.png",
          width = 312,
          height = 289,
          frame_count = 1,
          direction_count = 1,
          scale = 1,
          shift = util.by_pixel(10, 0),
            hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_farm/hr_Bio_Solar_Farm.png",
            width = 624,
            height = 578,
            scale = 0.5,
            frame_count = 1,
            direction_count = 1,
            shift = util.by_pixel(10, 0),
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_farm/Bio_Solar_Farm_shadow.png",
          width = 312,
          height = 289,
          frame_count = 1,
          direction_count = 1,
          scale = 1,
          shift = {0.3, 0},
          draw_as_shadow = true,
            hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_solar_farm/hr_Bio_Solar_Farm_shadow.png",
            width = 624,
            height = 578,
            scale = 0.5,
            frame_count = 1,
            direction_count = 1,
            shift = {0.3, 0},
            draw_as_shadow = true,
          }
        }
      }
    },
    production = "3600kW"
},
--###############################################################################################
-- BI Accumulator
{
    type = "accumulator",
    name = "bi-bio-accumulator",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/accumulator_large.png",
    icon_size = 64, icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-accumulator"},
    max_health = 500,
    corpse = "big-remnants",
    collision_box = {{-1.75, -1.75}, {1.75, 1.75}},
    selection_box = {{-2, -2}, {2, 2}},
    energy_source = 
    {
      type = "electric",
      buffer_capacity = "300MJ",
      usage_priority = "tertiary",
      input_flow_limit = "400kW", --DrD 20MW
      output_flow_limit = "1MW" --DrD 20MW
    },
    picture = 
    {
      layers = 
      {
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator.png",
        priority = "extra-high",
        width = 154,
        height = 181,
        scale = 1,
        shift = {0, -0.6},
        hr_version = 
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator.png",
          priority = "extra-high",
          width = 307,
          height = 362,
          scale = 0.5,
          shift = {0, -0.6},
        }
      },
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator_shadow.png",
        priority = "extra-high",
        width = 192,
        height = 136,
        frame_count = 1,
        line_length = 1,
        repeat_count = 24,
        shift = {1, 0},
        scale = 1,
        draw_as_shadow = true,
        hr_version = 
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator_shadow.png",
          priority = "extra-high",
          width = 384,
          height = 272,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          shift = {1, 0},
          scale = 0.5,
          draw_as_shadow = true,
        }
      },
      },
    },
    charge_animation = 
    {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator.png",
          priority = "high",
          width = 154,
          height = 181,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          animation_speed = 0.4,
          shift = {0, -0.6},
          scale = 1,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator.png",
            priority = "high",
            width = 307,
            height = 362,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            scale = 0.5,
            animation_speed = 0.4,
            shift = {0, -0.6},
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator_anim_charge.png",
          priority = "extra-high",
          width = 154,
          height = 181,
          line_length = 6,
          frame_count = 12,
          repeat_count = 2,
          draw_as_glow = true,
          shift = {0, -0.6},
          scale = 1,
          animation_speed = 0.3,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator_anim_charge.png",
            priority = "extra-high",
            width = 307,
            height = 362,
            line_length = 6,
            frame_count = 12,
            repeat_count = 2,
            draw_as_glow = true,
            shift = {0, -0.6},
            scale = 0.5,
            animation_speed = 0.3,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator_shadow.png",
          priority = "extra-high",
          width = 192,
          height = 136,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          shift = {1, 0},
          scale = 1,
          animation_speed = 0.3,
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator_shadow.png",
            priority = "extra-high",
            width = 384,
            height = 272,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            shift = {1, 0},
            scale = 0.5,
            animation_speed = 0.3,
            draw_as_shadow = true,
          }
        },
      },
    },
    charge_cooldown = 30,
    charge_light = {intensity = 0.3, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    discharge_animation = 
    {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator.png",
          priority = "high",
          width = 154,
          height = 181,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          animation_speed = 0.4,
          scale = 1,
          shift = {0, -0.6},
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator.png",
            priority = "high",
            width = 307,
            height = 362,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            animation_speed = 0.4,
            scale = 0.5,
            shift = {0, -0.6},
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator_anim_discharge.png",
          priority = "extra-high",
          width = 154,
          height = 181,
          line_length = 6,
          frame_count = 24,
          draw_as_glow = true,
          shift = {0, -0.6},
          scale = 1,
          animation_speed = 0.4,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator_anim_discharge.png",
            priority = "extra-high",
            width = 307,
            height = 362,
            line_length = 6,
            frame_count = 24,
            draw_as_glow = true,
            shift = {0, -0.6},
            scale = 0.5,
            animation_speed = 0.4,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/bi_large_accumulator_shadow.png",
          priority = "extra-high",
          width = 192,
          height = 136,
          frame_count = 1,
          line_length = 1,
          repeat_count = 24,
          animation_speed = 0.4,
          shift = {1, 0},
          scale = 1,
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/large_accumulator/hr_bi_large_accumulator_shadow.png",
            priority = "extra-high",
            width = 384,
            height = 272,
            frame_count = 1,
            line_length = 1,
            repeat_count = 24,
            animation_speed = 0.4,
            shift = {1, 0},
            scale = 0.5,
            draw_as_shadow = true,
          }
        },
      },
    },
    discharge_cooldown = 60,
    discharge_light = {intensity = 0.7, size = 7, color = {r = 1.0, g = 1.0, b = 1.0}},
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.65},
    },  
    working_sound = {
    sound = {filename = "__base__/sound/accumulator-working.ogg", volume = 1},
    idle_sound = {filename = "__base__/sound/accumulator-idle.ogg", volume = 0.4},
    max_sounds_per_type = 5
    },
    circuit_wire_connection_point = {
      shadow = {red = {0.984375, 1.10938}, green = {0.890625, 1.10938}},
      wire = {red = {0.6875, 0.59375}, green = {0.6875, 0.71875}}
    },
    circuit_wire_max_distance = 9,
    default_output_signal = {type = "virtual", name = "signal-A"}
  },
--###############################################################################################
-- Large Substation
{
    type = "electric-pole",
    name = "bi-large-substation",
    localised_name = {"entity-name.bi-large-substation"},
    localised_description = {"entity-description.bi-large-substation"},
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/substation_large.png",
    icon_size = 64, icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-large-substation"},
    max_health = 600,
    corpse = "big-remnants",
    dying_explosion = "big-explosion",
    track_coverage_during_build_by_moving = true,
    resistances = {{type = "fire", percent = 90}},
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    drawing_box = {{-2.5, -5}, {2.5, 2.5}},
    maximum_wire_distance = 25,
    supply_area_distance = 50.5,
    pictures = 
    {
      layers = 
      {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/huge_substation/huge_substation.png",
            priority = "high",
            width = 192,
            height = 192,
            direction_count = 1,
            scale = 1,
            hr_version = 
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/huge_substation/hr_huge_substation.png",
              priority = "high",
              width = 384,
              height = 384,
              direction_count = 1,
              scale = 0.5,
            }
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/huge_substation/huge_substation_shadow.png",
            priority = "high",
            width = 192,
            height = 192,
            direction_count = 1,
            scale = 1,
            draw_as_shadow = true,
            hr_version = 
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/huge_substation/hr_huge_substation_shadow.png",
              priority = "high",
              width = 384,
              height = 384,
              direction_count = 1,
              scale = 0.5,
              draw_as_shadow = true,
            }
          }
      }
    },
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.65},
    },  
    working_sound = {
      sound = {filename = "__base__/sound/substation.ogg"}, 
      apparent_volume = 1.1,
      audible_distance_modifier = 0.5,
      probability = 1 / (6 * 60) -- average pause between the sound is 6 seconds
    },
    connection_points = {{      
        shadow = {copper = util.by_pixel(29, -24), green = util.by_pixel(42, -26), red = util.by_pixel(16, -5)},
        wire = {copper = util.by_pixel(-3, -54), green = util.by_pixel(11, -57), red = util.by_pixel(-15, -37)}
    }},
    radius_visualisation_picture = {
      filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12, height = 12, priority = "extra-high-no-scale"
    }
},
--###############################################################################################
-- Solar plant + boiler
{
    type = "boiler",
    name = "bi-solar-boiler",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/solar-boiler.png",
    icon_size = 64, icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 1, result = "bi-solar-boiler"},
    max_health = 400,
    corpse = "small-remnants",
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.65},
    },  
    mode = "output-to-separate-pipe",
    resistances = {
      {type = "fire", percent = 100},
      {type = "explosion", percent = 30},
      {type = "impact", percent = 30}
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    target_temperature = 165, --drd from 235
    fluid_box = {
      base_area = 1,
      height = 2,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections = {
        {type = "input-output", position = {5, 0}},
        {type = "input-output", position = {-5, 0}},
      },
      production_type = "input-output",
      filter = "water"
    },
    output_fluid_box = {
      base_area = 1,
      height = 2,
      base_level = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections = {
        {type = "input-output", position = {0, 5}},
        {type = "input-output", position = {0, -5}},
      },
      production_type = "output",
      filter = "steam"
    },
    energy_consumption = "950KW", -- drd from 1799
    energy_source = {type = "electric", input_priority = "primary", usage_priority = "primary-input",},
    working_sound = {sound = {filename = "__base__/sound/boiler.ogg", volume = 0.9}, max_sounds_per_type = 3},
    structure = 
    {
      north = solarboilerstructurelayer,
      east = solarboilerstructurelayer,
      south = solarboilerstructurelayer,
      west = solarboilerstructurelayer,
    },
    fire_flicker_enabled = false,
    fire = {},
    fire_glow_flicker_enabled = false,
    fire_glow = 
    {
      north = solarboilerfireglow,
      east = solarboilerfireglow,
      south = solarboilerfireglow,
      west = solarboilerfireglow,
    },
    burning_cooldown = 20
  }

})
end