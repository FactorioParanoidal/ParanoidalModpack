data:extend({
-- Bio Garden
{
    type = "assembling-machine",
    name = "bi-bio-garden",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/garden_3x3.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-garden"},
    fast_replaceable_group = "bi-bio-garden",
    max_health = 150,
    corpse = "medium-remnants",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = {
          north =
          {
            filename = "__core__/graphics/empty.png",
            priority = "low",
            width = 1,
            height = 1,
          },
          east =
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/assembling-machine-3-pipe-E.png",
            priority = "extra-high",
            width = 20,
            height = 38,
            shift = util.by_pixel(-25, 1),
            hr_version =
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/hr-assembling-machine-3-pipe-E.png",
              priority = "extra-high",
              width = 42,
              height = 76,
              shift = util.by_pixel(-24.5, 1),
              scale = 0.5
            }
          },
          south =
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/assembling-machine-3-pipe-S.png",
            priority = "extra-high",
            width = 44,
            height = 31,
            shift = util.by_pixel(0, -31.5),
            hr_version =
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/hr-assembling-machine-3-pipe-S.png",
              priority = "extra-high",
              width = 88,
              height = 61,
              shift = util.by_pixel(0, -31.25),
              scale = 0.5
            }
          },
          west =
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/assembling-machine-3-pipe-W.png",
            priority = "extra-high",
            width = 19,
            height = 37,
            shift = util.by_pixel(25.5, 1.5),
            hr_version =
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/hr-assembling-machine-3-pipe-W.png",
              priority = "extra-high",
              width = 39,
              height = 73,
              shift = util.by_pixel(25.75, 1.25),
              scale = 0.5
            }
          },
        },
        pipe_covers = pipecoverspictures(),
        base_area = 1,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {0, -2} }}
      },
      off_when_no_fluid_recipe = false
    },
    animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/bio_garden_anim_trees.png",
          width = 128,
          height = 160,
          scale = 1,
          frame_count = 20,
          line_length = 5,
          repeat_count = 1,
          animation_speed = 0.15,
          shift = {0, -0.75},
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/hr_bio_garden_anim_trees.png",
            width = 256,
            height = 320,
            scale = 0.5,
            frame_count = 20,
            line_length = 5,
            repeat_count = 1,
            animation_speed = 0.15,
            shift = {0, -0.75},
          },
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/bio_garden_shadow.png",
          width = 192,
          height = 160,
          scale = 1,
          frame_count = 1,
          line_length = 1,
          repeat_count = 20,
          animation_speed = 0.431,
          shift = {1, -0.75},
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/hr_bio_garden_shadow.png",
            width = 384,
            height = 320,
            scale = 0.5,
            frame_count = 1,
            line_length = 1,
            repeat_count = 20,
            animation_speed = 0.431,
            shift = {1, -0.75},
            draw_as_shadow = true,
          },
        },
      },
    },
    working_visualisations = {
      {
        draw_as_light = true,
        effect = "flicker",
        apply_recipe_tint = "primary",
        constant_speed = true,
        fadeout = true,
        animation = {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/bio_garden_anim_light.png",
              width = 128,
              height = 160,
              scale = 1,
              frame_count = 10,
              line_length = 5,
              repeat_count = 2,
              animation_speed = 0.1,
              shift = {0, -0.75},
              hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden/hr_bio_garden_anim_light.png",
                width = 256,
                height = 320,
                scale = 0.5,
                frame_count = 10,
                line_length = 5,
                repeat_count = 2,
                animation_speed = 0.1,
                shift = {0, -0.75},
              },
            },
          },
        },
      },
    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    working_sound = {
      sound = { { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.7 } },
      idle_sound = { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.2 },
      apparent_volume = 1.5,
    },
    crafting_categories = {"clean-air"},
    source_inventory_size = 1,
    result_inventory_size = 1,
    crafting_speed = 1,
    energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = -45,},
    energy_usage = "100kW",
    ingredient_count = 1,
    map_color = util.color("81b700"),  --1b6311
  },
--###############################################################################################
--LARGE BIO GARDEN
{
  type = "assembling-machine",
  name = "bi-bio-garden-large",
  icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/garden_9x9.png",
  icon_size = 64, icon_mipmaps = 4,
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 1.6, mining_time = 4, result = "bi-bio-garden-large"},
  fast_replaceable_group = "bi-bio-garden-large",
  max_health = 1200,
  corpse = "medium-remnants",
  --corpse = "bi-bio-garden-large-remnant",
  collision_box = {{-4.3, -4.3}, {4.3, 4.3}},
  selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
  scale_entity_info_icon = true,
  fluid_boxes = {
    {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 1,
      base_level = -1,
      filter = "water",
      pipe_connections = {
        { type = "input-output", position = {0, -5} },
        { type = "input-output", position = {0, 5} },
        { type = "input-output", position = {-5, 0} },
        { type = "input-output", position = {5, 0} },
      },
    },
    off_when_no_fluid_recipe = false,
  },
  animation = {
    layers = {
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_large/bio_garden_large.png",
        width = 320,
        height = 352,
        scale = 1,
        shift = {0, -0.5},
        hr_version = {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_large/hr_bio_garden_large.png",
          width = 640,
          height = 704,
          scale = 0.5,
          shift = {0, -0.5},
        }
      },
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_large/bio_garden_large_shadow.png",
        width = 352,
        height = 320,
        scale = 1,
        shift = {0.5, 0},
        draw_as_shadow = true,
        hr_version = {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_large/hr_bio_garden_large_shadow.png",
          width = 704,
          height = 640,
          scale = 0.5,
          shift = {0.5, 0},
          draw_as_shadow = true,
        }
      },
    },
  },
  working_visualisations = {
    {
      draw_as_light = true,
      effect = "flicker",
      apply_recipe_tint = "primary",
      constant_speed = true,
      fadeout = true,
      animation = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_large/bio_garden_large_light.png",
            width = 320,
            height = 320,
            scale = 1,
            shift = {0, 0},
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_large/hr_bio_garden_large_light.png",
              width = 640,
              height = 640,
              scale = 0.5,
              shift = {0, 0},
            },
          },
        },
      },
    },
  },
  open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
  close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  working_sound = {
    sound = { { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.7 } },
    idle_sound = { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.2 },
    apparent_volume = 1.5,
  },
  crafting_categories = {"clean-air"},
  source_inventory_size = 1,
  result_inventory_size = 1,
  crafting_speed = 8,
  energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = -428,},
  energy_usage = "800kW",
  ingredient_count = 1,
  map_color = util.color("81b700"),  --1b6311
},
--###############################################################################################
--HUGE BIO GARDEN
{
  type = "assembling-machine",
  name = "bi-bio-garden-huge",
  icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/garden_27x27.png",
  icon_size = 64, icon_mipmaps = 4,
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 12.8, mining_time = 15, result = "bi-bio-garden-huge"},
  fast_replaceable_group = "bi-bio-garden-huge",
  max_health = 9000,
  corpse = "medium-remnants",
  --corpse = "bi-bio-garden-huge-remnant",
  collision_box = {{-13.3, -13.3}, {13.3, 13.3}},
  selection_box = {{-13.5, -13.5}, {13.5, 13.5}},
  scale_entity_info_icon = true,
  fluid_boxes = {
    {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      base_area = 1,
      base_level = -1,
      filter = "water",
      pipe_connections = {
        { type = "input-output", position = {0, -14} },
        { type = "input-output", position = {0, 14} },
        { type = "input-output", position = {-14, 0} },
        { type = "input-output", position = {14, 0} },
      },
    },
    off_when_no_fluid_recipe = false,
  },
  animation = {
    layers = {
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/bio_garden_huge.png",
        width = 896,
        height = 928,
        scale = 1,
        frame_count = 1,
        line_length = 1,
        repeat_count = 8,
        animation_speed = 1,
        shift = {0, -0.5},
        hr_version = {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/hr_bio_garden_huge.png",
          width = 1792,
          height = 1856,
          scale = 0.5,
          frame_count = 1,
          line_length = 1,
          repeat_count = 8,
          animation_speed = 1,
          shift = {0, -0.5},
        }
      },
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/bio_garden_huge_shadow.png",
        width = 128,
        height = 928,
        scale = 1,
        frame_count = 1,
        line_length = 1,
        repeat_count = 8,
        animation_speed = 1,
        shift = {14, -0.5},
        draw_as_shadow = true,
        hr_version = {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/hr_bio_garden_huge_shadow.png",
          width = 256,
          height = 1856,
          scale = 0.5,
          frame_count = 1,
          line_length = 1,
          repeat_count = 8,
          animation_speed = 1,
          shift = {14, -0.5},
          draw_as_shadow = true,
        }
      },
    },
  },
  working_visualisations = {
    {
      constant_speed = true,
      fadeout = true,
      animation = {
        layers = {
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/bio_garden_huge_turbine_anim.png",
            width = 64,
            height = 48,
            scale = 1,
            frame_count = 8,
            line_length = 8,
            repeat_count = 1,
            animation_speed = 1,
            shift = {-4.5, -4.5},
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/hr_bio_garden_huge_turbine_anim.png",
              width = 128,
              height = 96,
              scale = 0.5,
              frame_count = 8,
              line_length = 8,
              repeat_count = 1,
              animation_speed = 1,
              shift = {-4.5, -4.5},
            }
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/bio_garden_huge_turbine_anim.png",
            width = 64,
            height = 48,
            scale = 1,
            frame_count = 8,
            line_length = 8,
            repeat_count = 1,
            animation_speed = 1,
            shift = {4.5, 4.5},
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/hr_bio_garden_huge_turbine_anim.png",
              width = 128,
              height = 96,
              scale = 0.5,
              frame_count = 8,
              line_length = 8,
              repeat_count = 1,
              animation_speed = 1,
              shift = {4.5, 4.5},
            }
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/bio_garden_huge_turbine_anim.png",
            width = 64,
            height = 48,
            scale = 1,
            frame_count = 8,
            line_length = 8,
            repeat_count = 1,
            animation_speed = 1,
            shift = {4.5, -4.5},
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/hr_bio_garden_huge_turbine_anim.png",
              width = 128,
              height = 96,
              scale = 0.5,
              frame_count = 8,
              line_length = 8,
              repeat_count = 1,
              animation_speed = 1,
              shift = {4.5, -4.5},
            }
          },
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/bio_garden_huge_turbine_anim.png",
            width = 64,
            height = 48,
            scale = 1,
            frame_count = 8,
            line_length = 8,
            repeat_count = 1,
            animation_speed = 1,
            shift = {-4.5, 4.5},
            hr_version = {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biogarden_huge/hr_bio_garden_huge_turbine_anim.png",
              width = 128,
              height = 96,
              scale = 0.5,
              frame_count = 8,
              line_length = 8,
              repeat_count = 1,
              animation_speed = 1,
              shift = {-4.5, 4.5},
            }
          },
        },
      },
    },
  },

  open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
  close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
  working_sound = 
  {
    sound = { { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.7 } },
    --sound = { { filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/sound/BI_garden_fan.ogg", volume = 0.9, max_sounds_per_type = 3} },
    idle_sound = { filename = "__Bio_Industries__/sound/rainforest_ambience.ogg", volume = 0.2 },
    apparent_volume = 1.5,
  },
  crafting_categories = {"clean-air"},
  source_inventory_size = 1,
  result_inventory_size = 1,
  crafting_speed = 64,
  energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = -4065,},
  energy_usage = "6400kW",
  ingredient_count = 1,
  map_color = util.color("81b700"),  --1b6311
}

})