local assembler2pipepicturesBioreactor =
{
    north = {
      filename = "__Bio_Industries__/graphics/icons/empty.png",
      priority = "extra-high",
      width = 1,
      height = 1,
      shift = util.by_pixel(2.5, 14),
      hr_version = {
        filename = "__Bio_Industries__/graphics/icons/empty.png",
        priority = "extra-high",
        width = 1,
        height = 1,
        shift = util.by_pixel(2.25, 13.5),
        scale = 0.5,
      }
    },
    east = {
      filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-E.png",
      priority = "extra-high",
      width = 20,
      height = 38,
      shift = util.by_pixel(-25, 1),
      hr_version = {
        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-E.png",
        priority = "extra-high",
        width = 42,
        height = 76,
        shift = util.by_pixel(-24.5, 1),
        scale = 0.5,
      }
    },
    south = {
      filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-S.png",
      priority = "extra-high",
      width = 44,
      height = 31,
      shift = util.by_pixel(0, -31.5),
      hr_version = {
        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-S.png",
        priority = "extra-high",
        width = 88,
        height = 61,
        shift = util.by_pixel(0, -31.25),
        scale = 0.5,
      }
    },
    west = {
      filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-W.png",
      priority = "extra-high",
      width = 19,
      height = 37,
      shift = util.by_pixel(25.5, 1.5),
      hr_version = {
        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-W.png",
        priority = "extra-high",
        width = 39,
        height = 73,
        shift = util.by_pixel(25.75, 1.25),
        scale = 0.5,
      }
    }
}
--###############################################################################################
-- BIOREACTOR
data:extend({
  {
    type = "assembling-machine",
    name = "bi-bio-reactor",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/bioreactor.png",
    icon_size = 64,  icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-reactor"},
    max_health = 100,
    corpse = "big-remnants",
    fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = assembler2pipepicturesBioreactor,
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {0, -2} }},
        render_layer = "higher-object-under",
      },
      {
        production_type = "input",
        pipe_picture = assembler2pipepicturesBioreactor,
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {2, 0} }},
        render_layer = "higher-object-under",
      },
      {
        production_type = "input",
        pipe_picture = assembler2pipepicturesBioreactor,
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {0, 2} }},
        render_layer = "higher-object-under",
      },
      {
        production_type = "output",
        pipe_picture = assembler2pipepicturesBioreactor,
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = 1,
        pipe_connections = {{ type = "output", position = {-2, -1} }},
        render_layer = "higher-object-under",
      },
      {
        production_type = "output",
        pipe_picture = assembler2pipepicturesBioreactor,
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = 1,
        pipe_connections = {{ type = "output", position = {-2, 1} }},
        render_layer = "higher-object-under",
      },
      off_when_no_fluid_recipe = true,
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_idle.png",
          priority = "high",
          width = 91,
          height = 128,
          frame_count = 1,
          line_length = 1,
          repeat_count = 18,
          animation_speed = 0.2,
          scale = 1,
          shift = {0, -0.5},
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_idle.png",
            priority = "high",
            width = 182,
            height = 256,
            frame_count = 1,
            line_length = 1,
            repeat_count = 18,
            animation_speed = 0.2,
            scale = 0.5,
            shift = {0, -0.5},
          }
  
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_shadow.png",
          priority = "high",
          width = 135,
          height = 128,
          frame_count = 1,
          line_length = 1,
          repeat_count = 18,
          animation_speed = 0.2,
          scale = 1,
          shift = {0.5, -0.5},
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_shadow.png",
            priority = "high",
            width = 270,
            height = 256,
            frame_count = 1,
            line_length = 1,
            repeat_count = 18,
            animation_speed = 0.2,
            scale = 0.5,
            shift = {0.5, -0.5},
            draw_as_shadow = true,
          }
        }
      },
    },
    working_visualisations = {
      {
        effect = "none",
        render_layer = "object",
        animation = {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_anim.png",
              priority = "low",
              width = 91,
              height = 128,
              frame_count = 18,
              line_length = 6,
              repeat_count = 1,
              animation_speed = 0.2,
              scale = 1,
              shift = {0, -0.5},
              hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_anim.png",
                priority = "low",
                width = 182,
                height = 256,
                frame_count = 18,
                line_length = 6,
                repeat_count = 1,
                animation_speed = 0.2,
                scale = 0.5,
                shift = {0, -0.5},
              }
            },
          },
        },
      },
      {
        effect = "none",
        apply_recipe_tint = "primary",
        fadeout = true,
        render_layer = "object",
        animation = {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_anim_mask.png",
              priority = "low",
              width = 91,
              height = 128,
              frame_count = 18,
              line_length = 6,
              repeat_count = 1,
              animation_speed = 0.2,
              scale = 1,
              shift = {0, -0.5},
              hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_anim_mask.png",
                priority = "low",
                width = 182,
                height = 256,
                frame_count = 18,
                line_length = 6,
                repeat_count = 1,
                animation_speed = 0.2,
                scale = 0.5,
                shift = {0, -0.5},
              }
            },
          },
        },
      },
    },
    energy_source = {type = "electric", usage_priority = "secondary-input"},
    crafting_categories = {"biofarm-mod-bioreactor"},
    ingredient_count = 3,
    crafting_speed = 1,
    energy_usage = "10kW",
    module_specification = {module_slots = 3},
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
}
})
--###############################################################################################
-- Bio Boiler
if BI.Settings.BI_Bio_Fuel then
  data:extend({
    {
      type = "boiler",
      name = "bi-bio-boiler",
      icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/bio_boiler.png",
      icon_size = 64,  icon_mipmaps = 4,
      se_allow_in_space = true,
      flags = {"placeable-neutral", "player-creation"},
      minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-boiler"},
      max_health = 300,
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
        {type = "explosion", percent = 100},
        {type = "impact", percent = 35}
      },
      collision_box = {{-1.29, -0.79}, {1.29, 0.79}},
      selection_box = {{-1.5, -1}, {1.5, 1}},
      target_temperature = 165,
      fluid_box = {
        base_area = 1,
        height = 2,
        base_level = -1,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {
          {type = "input-output", position = {-2, 0.5}},
          {type = "input-output", position = {2, 0.5}}
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
          {type = "output", position = {0, -1.5}}
        },
        production_type = "output",
        filter = "steam"
      },
      energy_consumption = "3.6MW",
      energy_source = {
        type = "burner",
        fuel_category = "chemical",
        effectivity = 0.75, --drd 1
        fuel_inventory_size = 2,
        emissions_per_minute = 15,
        smoke = {
          {
            name = "smoke",
            north_position = util.by_pixel(-38, -47.5),
            south_position = util.by_pixel(38.5, -32),
            east_position = util.by_pixel(20, -70),
            west_position = util.by_pixel(-19, -8.5),
            frequency = 20,
            starting_vertical_speed = 0.0,
            starting_frame_deviation = 60
          }
        }
      },
      working_sound = {
        sound = {filename = "__base__/sound/boiler.ogg", volume = 0.8},
        max_sounds_per_type = 3
      },
      structure = {
        north = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/boiler-N-idle.png",
            priority = "extra-high",
            width = 131,
            height = 108,
            shift = util.by_pixel(-0.5, 4),
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/hr-boiler-N-idle.png",
              priority = "extra-high",
              width = 269,
              height = 221,
              shift = util.by_pixel(-1.25, 5.25),
              scale = 0.5,
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
            priority = "extra-high",
            width = 137,
            height = 82,
            shift = util.by_pixel(20.5, 9),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-N-shadow.png",
              priority = "extra-high",
              width = 274,
              height = 164,
              scale = 0.5,
              shift = util.by_pixel(20.5, 9),
              draw_as_shadow = true,
            }
          }
        }
      },
      east = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/boiler-E-idle.png",
            priority = "extra-high",
            width = 105,
            height = 147,
            shift = util.by_pixel(-3.5, -0.5),
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/hr-boiler-E-idle.png",
              priority = "extra-high",
              width = 216,
              height = 301,
              shift = util.by_pixel(-3, 1.25),
              scale = 0.5,
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
            priority = "extra-high",
            width = 92,
            height = 97,
            shift = util.by_pixel(30, 9.5),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-E-shadow.png",
              priority = "extra-high",
              width = 184,
              height = 194,
              scale = 0.5,
              shift = util.by_pixel(30, 9.5),
              draw_as_shadow = true,
            }
          }
        }
      },
      south = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/boiler-S-idle.png",
            priority = "extra-high",
            width = 128,
            height = 95,
            shift = util.by_pixel(3, 12.5),
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/hr-boiler-S-idle.png",
              priority = "extra-high",
              width = 260,
              height = 192,
              shift = util.by_pixel(4, 13),
              scale = 0.5,
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
            priority = "extra-high",
            width = 156,
            height = 66,
            shift = util.by_pixel(30, 16),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-S-shadow.png",
              priority = "extra-high",
              width = 311,
              height = 131,
              scale = 0.5,
              shift = util.by_pixel(29.75, 15.75),
              draw_as_shadow = true,
            }
          }
        }
      },
      west = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/boiler-W-idle.png",
            priority = "extra-high",
            width = 96,
            height = 132,
            shift = util.by_pixel(1, 5),
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_boiler/hr-boiler-W-idle.png",
              priority = "extra-high",
              width = 196,
              height = 273,
              shift = util.by_pixel(1.5, 7.75),
              scale = 0.5,
            }
          },
          {
            filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
            priority = "extra-high",
            width = 103,
            height = 109,
            shift = util.by_pixel(19.5, 6.5),
            draw_as_shadow = true,
            hr_version = {
              filename = "__base__/graphics/entity/boiler/hr-boiler-W-shadow.png",
              priority = "extra-high",
              width = 206,
              height = 218,
              scale = 0.5,
              shift = util.by_pixel(19.5, 6.5),
              draw_as_shadow = true,
            }
          }
        }
      }
    },
    patch = {
      east = {
        filename = "__base__/graphics/entity/boiler/boiler-E-patch.png",
        priority = "extra-high",
        width = 3,
        height = 17,
        tint = {r = 0.5, g = 0.5, b = 0.1, a = 0.7},
        shift = util.by_pixel(33.5, -13.5),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-E-patch.png",
          width = 6,
          height = 36,
          shift = util.by_pixel(33.5, -13.5),
          scale = 0.5,
          tint = {r = 0.5, g = 0.5, b = 0.1, a = 0.7},
        }
      },
    },
    fire_flicker_enabled = true,
    fire = {
      north = {
        filename = "__base__/graphics/entity/boiler/boiler-N-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 12,
        height = 13,
        animation_speed = 0.5,
        shift = util.by_pixel(0, -8.5),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-N-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 26,
          height = 26,
          animation_speed = 0.5,
          shift = util.by_pixel(0, -8.5),
          scale = 0.5
        }
      },
      east = {
        filename = "__base__/graphics/entity/boiler/boiler-E-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 14,
        height = 14,
        animation_speed = 0.5,
        shift = util.by_pixel(-10, -22),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-E-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 28,
          height = 28,
          animation_speed = 0.5,
          shift = util.by_pixel(-9.5, -22),
          scale = 0.5
        }
      },
      south = {
        filename = "__base__/graphics/entity/boiler/boiler-S-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 12,
        height = 9,
        animation_speed = 0.5,
        shift = util.by_pixel(-1, -26.5),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-S-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 26,
          height = 16,
          animation_speed = 0.5,
          shift = util.by_pixel(-1, -26.5),
          scale = 0.5
        }
      },
      west = {
        filename = "__base__/graphics/entity/boiler/boiler-W-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 14,
        height = 14,
        animation_speed = 0.5,
        shift = util.by_pixel(13, -23),
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-W-fire.png",
          priority = "extra-high",
          frame_count = 64,
          line_length = 8,
          width = 30,
          height = 29,
          animation_speed = 0.5,
          shift = util.by_pixel(13, -23.25),
          scale = 0.5
        }
      }
    },
    fire_glow_flicker_enabled = true,
    fire_glow = {
      north = {
        filename = "__base__/graphics/entity/boiler/boiler-N-light.png",
        priority = "extra-high",
        frame_count = 1,
        width = 100,
        height = 87,
        shift = util.by_pixel(-1, -6.5),
        blend_mode = "additive",
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-N-light.png",
          priority = "extra-high",
          frame_count = 1,
          width = 200,
          height = 173,
          shift = util.by_pixel(-1, -6.75),
          blend_mode = "additive",
          scale = 0.5
        }
      },
      east = {
        filename = "__base__/graphics/entity/boiler/boiler-E-light.png",
        priority = "extra-high",
        frame_count = 1,
        width = 70,
        height = 122,
        shift = util.by_pixel(0, -13),
        blend_mode = "additive",
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-E-light.png",
          priority = "extra-high",
          frame_count = 1,
          width = 139,
          height = 244,
          shift = util.by_pixel(0.25, -13),
          blend_mode = "additive",
          scale = 0.5
        }
      },
      south = {
        filename = "__base__/graphics/entity/boiler/boiler-S-light.png",
        priority = "extra-high",
        frame_count = 1,
        width = 100,
        height = 81,
        shift = util.by_pixel(1, 5.5),
        blend_mode = "additive",
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-S-light.png",
          priority = "extra-high",
          frame_count = 1,
          width = 200,
          height = 162,
          shift = util.by_pixel(1, 5.5),
          blend_mode = "additive",
          scale = 0.5
        }
      },
      west = {
        filename = "__base__/graphics/entity/boiler/boiler-W-light.png",
        priority = "extra-high",
        frame_count = 1,
        width = 68,
        height = 109,
        shift = util.by_pixel(2, -6.5),
        blend_mode = "additive",
        hr_version = {
          filename = "__base__/graphics/entity/boiler/hr-boiler-W-light.png",
          priority = "extra-high",
          frame_count = 1,
          width = 136,
          height = 217,
          shift = util.by_pixel(2, -6.25),
          blend_mode = "additive",
          scale = 0.5
        }
      }
    },
    burning_cooldown = 20
    },
})
end