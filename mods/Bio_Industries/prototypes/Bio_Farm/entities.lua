--###############################################################################################
-- Add images
local seedling_pictures_diverse = {}

local function make_entry(img, shift)
  seedling_pictures_diverse[#seedling_pictures_diverse + 1] = {
    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/mips/seedling_" .. img .. ".png",
    priority = "extra-high",
    width = 64,
    height = 64,
    scale = 0.5,
    shift = shift or {0, -0.3},
  }
end

-- Construct the layers for seedlings
-- The first 9 layers all have the same shift value
for i = 1, 9 do
  make_entry(i)
end

-- The next 9 layers use different shift values
local image_shift = {
  { 0.4, -0.4}, -- 1
  {-0.4, -0.5}, -- 2
  { 0.3,  0.0}, -- 3
  {-0.3, -0.7}, -- 4
  { 0.2, -0.1}, -- 5
  { 0.2, -0.2}, -- 6
  {-0.2, -0.7}, -- 7
  {-0.2, -0.6}, -- 8
  { 0.3,  0.0}, -- 9
}
for i = 1, 9 do
  make_entry(i, image_shift[i])
end
--###############################################################################################
local biofarmpipepictures = {
    north = {
      filename = "__core__/graphics/empty.png",
      priority = "low",
      width = 1,
      height = 1,
    },
    east =
    {
      filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/bio_farm-pipe-E.png",
      priority = "extra-high",
      width = 20,
      height = 38,
      shift = util.by_pixel(-25, 1),
      hr_version =
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/hr_bio_farm-pipe-E.png",
        priority = "extra-high",
        width = 42,
        height = 76,
        shift = util.by_pixel(-24.5, 1),
        scale = 0.5
      }
    },
    south =
    {
      filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/bio_farm-pipe-S.png",
      priority = "extra-high",
      width = 44,
      height = 31,
      shift = util.by_pixel(0, -31.5),
      hr_version =
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/hr_bio_farm-pipe-S.png",
        priority = "extra-high",
        width = 88,
        height = 61,
        shift = util.by_pixel(0, -31.25),
        scale = 0.5
      }
    },
    west =
    {
      filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/bio_farm-pipe-W.png",
      priority = "extra-high",
      width = 19,
      height = 37,
      shift = util.by_pixel(25.5, 1.5),
      hr_version =
      {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/hr_bio_farm-pipe-W.png",
        priority = "extra-high",
        width = 39,
        height = 73,
        shift = util.by_pixel(25.75, 1.25),
        scale = 0.5
      }
    }
}
--###############################################################################################
data:extend({
-- Seedling
  {
    type = "simple-entity-with-force",
    name = "seedling",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/seedling.png",
    icon_size = 64,  icon_mipmaps = 4,
    order = "x[bi]-a[bi-seedling]",
    flags = {"placeable-neutral", "placeable-player", "player-creation", "breaths-air"},
    create_ghost_on_death = false,
    minable = {
      mining_particle = "wooden-particle",
      mining_time = 0.25,
      result = "seedling",
      count = 1
    },
    corpse = nil,
    remains_when_mined = nil,
    emissions_per_second = -0.0006,
    max_health = 5,
    collision_box = {{-0.03, -0.03}, {0.1, 0.03}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    subgroup = "trees",
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    pictures = seedling_pictures_diverse,
    map_color = util.color("70b94c55"),
},
-------------------------------------------------------------------------------------------------
{
    type = "simple-entity-with-force",
    name = "seedling-2",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/seedling.png",
    icon_size = 64,  icon_mipmaps = 4,
    order = "x[bi]-a[bi-seedling]",
    flags = {"placeable-neutral", "placeable-player", "player-creation", "breaths-air"},
    create_ghost_on_death = false,
    minable = {
      mining_particle = "wooden-particle",
      mining_time = 0.25,
      result = "seedling",
      count = 1
    },
    corpse = nil,
    remains_when_mined = nil,
    emissions_per_second = -0.0006,
    max_health = 5,
    collision_box = {{-0.03, -0.03}, {0.03, 0.03}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    subgroup = "trees",
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    pictures = seedling_pictures_diverse,
    map_color = util.color("70b94c55"),
},
-------------------------------------------------------------------------------------------------
{
    type = "simple-entity-with-force",
    name = "seedling-3",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/seedling.png",
    icon_size = 64,  icon_mipmaps = 4,
    order = "x[bi]-a[bi-seedling]",
    flags = {"placeable-neutral", "placeable-player", "player-creation", "breaths-air"},
    create_ghost_on_death = false,
    minable = {
      mining_particle = "wooden-particle",
      mining_time = 0.25,
      result = "seedling",
      count = 1
    },
    corpse = nil,
    remains_when_mined = nil,
    emissions_per_second = -0.0006,
    max_health = 5,
    collision_box = {{-0.03, -0.03}, {0.03, 0.03}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    subgroup = "trees",
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    pictures = seedling_pictures_diverse,
    map_color = util.color("70b94c55"),
},
--###############################################################################################
-- Bio Farm
{
    type = "assembling-machine",
    name = "bi-bio-farm",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/biofarm.png",
    icon_size = 64,  icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-bio-farm"},
    max_health = 250,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 70}},
    fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = biofarmpipepictures,
        pipe_covers = pipecoverspictures(),
        base_area = 1,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {-1, -5} }}
      },
      {
        production_type = "input",
        pipe_picture = biofarmpipepictures,
        pipe_covers = pipecoverspictures(),
        base_area = 1,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {1, -5} }}
      },
      off_when_no_fluid_recipe = true
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    scale_entity_info_icon = true,
    animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm.png",
          priority = "high",
          width = 304,
          height = 400,
          shift = {0, -1.5},
          scale = 1,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm.png",
            priority = "high",
            width = 608,
            height = 800,
            shift = {0, -1.5},
            scale = 0.5,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm_shadow.png",
          priority = "high",
          width = 400,
          height = 400,
          shift = {1.5, -1.5},
          scale = 1,
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm_shadow.png",
            priority = "high",
            width = 800,
            height = 800,
            shift = {1.5, -1.5},
            scale = 0.5,
            draw_as_shadow = true,
          }
        },
      }
    },
    working_visualisations = {
      {
        draw_as_light = true,
        effect = "flicker",
        apply_recipe_tint = "primary",
        animation = {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm_light.png",
              width = 400,
              height = 400,
              scale = 1,
              shift = {0, -1.5},
              blend_mode = "additive",
              hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm_light.png",
                width = 800,
                height = 800,
                scale = 0.5,
                shift = {0, -1.5},
                blend_mode = "additive",
              }
            },
          },
        },
      },
    },
    crafting_categories = {"biofarm-mod-farm"},
    crafting_speed = 1,
    energy_source = {type = "electric", usage_priority = "primary-input", drain = "50kW", emissions_per_minute = -9,},
    energy_usage = "100kW",
    ingredient_count = 3,
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    module_specification = {module_slots = 3},
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
},
--###############################################################################################
-- Greenhouse
{
    type = "assembling-machine",
    name = "bi-bio-greenhouse",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/greenhouse.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.25, result = "bi-bio-greenhouse"},
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    max_health = 250,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    crafting_categories = {"biofarm-mod-greenhouse"},
    crafting_speed = 1,
    energy_source = {type = "electric", usage_priority = "primary-input", drain = "15kW", emissions_per_minute = -6},
    energy_usage = "50kW",
    ingredient_count = 3,
    resistances = {{type = "fire", percent = 70}},
    fluid_boxes = {
      {
        production_type = "input",
        pipe_picture = {
          north =
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-N.png",
            priority = "extra-high",
            width = 35,
            height = 18,
            shift = util.by_pixel(2.5, 14),
            hr_version =
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-N-exp.png",
              priority = "extra-high",
              width = 171,
              height = 152,
              shift = util.by_pixel(2.25, 13.5),
              scale = 0.5
            }
          },
          east =
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-E.png",
            priority = "extra-high",
            width = 20,
            height = 38,
            shift = util.by_pixel(-25, 1),
            hr_version =
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-E.png",
              priority = "extra-high",
              width = 42,
              height = 76,
              shift = util.by_pixel(-24.5, 1),
              scale = 0.5
            }
          },
          south =
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-S.png",
            priority = "extra-high",
            width = 44,
            height = 31,
            shift = util.by_pixel(0, -31.5),
            hr_version =
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-S.png",
              priority = "extra-high",
              width = 88,
              height = 61,
              shift = util.by_pixel(0, -31.25),
              scale = 0.5
            }
          },
          west =
          {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-W.png",
            priority = "extra-high",
            width = 19,
            height = 37,
            shift = util.by_pixel(25.5, 1.5),
            hr_version =
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-W.png",
              priority = "extra-high",
              width = 39,
              height = 73,
              shift = util.by_pixel(25.75, 1.25),
              scale = 0.5
            }
          },
        },
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type = "input", position = {0, -2}}}
      },
    },
    module_specification = {module_slots = 2},
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse.png",
          width = 96,
          height = 128,
          frame_count = 1,
          line_length = 1,
          repeat_count = 10,
          animation_speed = 0.05,
          scale = 1,
          shift = {0, -0.5},
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse.png",
            width = 192,
            height = 256,
            frame_count = 1,
            line_length = 1,
            repeat_count = 10,
            animation_speed = 0.05,
            scale = 0.5,
            shift = {0, -0.5},
          }
        },
  
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse_shadow.png",
          width = 128,
          height = 64,
          frame_count = 1,
          line_length = 1,
          repeat_count = 10,
          animation_speed = 0.05,
          scale = 1,
          shift = {0.5, 0.5},
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse_shadow.png",
            width = 256,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 10,
            animation_speed = 0.05,
            scale = 0.5,
            shift = {0.5, 0.5},
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
        animation = {
          layers = {
            {
              filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse_light_anim.png",
              width = 96,
              height = 128,
              frame_count = 10,
              line_length = 10,
              repeat_count = 1,
              animation_speed = 0.08,
              scale = 1,
              shift = {0, -0.5},
              hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse_light_anim.png",
                width = 192,
                height = 256,
                frame_count = 10,
                line_length = 10,
                repeat_count = 1,
                animation_speed = 0.08,
                scale = 0.5,
                shift = {0, -0.5},
              }
            },
          },
        },
      },
    },
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.65},
      {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.65},
    },  
},
--###############################################################################################
-- COKERY
  {
    type = "assembling-machine",
    name = "bi-cokery",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/cokery.png",
    icon_size = 64, icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    order = "a[cokery]",
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-cokery"},
    max_health = 200,
    corpse = "medium-remnants",
    resistances = {{type = "fire", percent = 95}},
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    module_specification = {module_slots = 2},
    allowed_effects = {"consumption", "speed", "pollution"},
    animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/cokery_anim.png",
          frame_count = 16,
          line_length = 8,
          width = 128,
          height = 128,
          scale = 1,
          shift = {0.5, -0.5},
          animation_speed = 0.2,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/hr_cokery_anim.png",
            frame_count = 16,
            line_length = 8,
            width = 256,
            height = 256,
            scale = 0.5,
            shift = {0.5, -0.5},
            animation_speed = 0.2,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/cokery_shadow.png",
          priority = "extra-high",
          width = 167,
          height = 64,
          frame_count = 1,
          line_length = 1,
          repeat_count = 16,
          shift = {0.5, 0.5},
          scale = 1,
          animation_speed = 0.2,
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/hr_cokery_shadow.png",
            priority = "extra-high",
            width = 334,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 16,
            shift = {0.5, 0.5},
            scale = 0.5,
            animation_speed = 0.2,
            draw_as_shadow = true,
          }
        },
      },
    },
    idle_animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/cokery_idle.png",
          frame_count = 1,
          line_length = 1,
          width = 128,
          height = 128,
          scale = 1,
          shift = {0.5, -0.5},
          animation_speed = 0.2,
          repeat_count = 16,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/hr_cokery_idle.png",
            frame_count = 1,
            line_length = 1,
            width = 256,
            height = 256,
            scale = 0.5,
            shift = {0.5, -0.5},
            animation_speed = 0.2,
            repeat_count = 16,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/cokery_shadow.png",
          priority = "extra-high",
          width = 167,
          height = 64,
          frame_count = 1,
          line_length = 1,
          shift = {0.5, 0.5},
          scale = 1,
          animation_speed = 0.2,
          draw_as_shadow = true,
          repeat_count = 16,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/cokery/hr_cokery_shadow.png",
            priority = "extra-high",
            width = 334,
            height = 128,
            frame_count = 1,
            line_length = 1,
            shift = {0.5, 0.5},
            scale = 0.5,
            animation_speed = 0.2,
            draw_as_shadow = true,
            repeat_count = 16,
          }
        },
      },
    },
    crafting_categories = {"biofarm-mod-smelting"},
    energy_source = {
      type = "electric",
      input_priority = "secondary",
      usage_priority = "secondary-input",
      emissions_per_minute = 2.5,
    },
    energy_usage = "180kW",
    crafting_speed = 2,
    ingredient_count = 1
  },
--###############################################################################################
  -- STONECRUSHER
  {
    type = "furnace",
    name = "bi-stone-crusher",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/stone_crusher.png",
    icon_size = 64, icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "bi-stone-crusher"},
    max_health = 100,
    corpse = "medium-remnants",
    resistances = {{type = "fire", percent = 70}},
    working_sound = {
      sound = {filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/sound/BI_stonecrusher.ogg", volume = 0.8},
      apparent_volume = 1
    },
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/stone_crusher_anim.png",
          priority = "high",
          width = 65,
          height = 78,
          line_length = 10,
          frame_count = 20,
          animation_speed = 0.5,
          scale = 1,
          repeat_count = 1,
          shift = {0, -0.2},
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/hr_stone_crusher_anim.png",
            priority = "high",
            width = 130,
            height = 156,
            line_length = 10,
            frame_count = 20,
            animation_speed = 0.5,
            scale = 0.5,
            repeat_count = 1,
            shift = {0, -0.2},
          },
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/stone_crusher_shadow.png",
          priority = "high",
          width = 98,
          height = 78,
          line_length = 1,
          frame_count = 1,
          animation_speed = 0.5,
          scale = 1,
          repeat_count = 20,
          shift = {0.5, -0.2},
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/hr_stone_crusher_shadow.png",
            priority = "high",
            width = 196,
            height = 156,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            scale = 0.5,
            repeat_count = 20,
            shift = {0.5, -0.2},
            draw_as_shadow = true,
          },
        },
      }
    },
    idle_animation = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/stone_crusher_off.png",
          priority = "high",
          width = 65,
          height = 78,
          line_length = 1,
          frame_count = 1,
          repeat_count = 20,
          animation_speed = 0.5,
          scale = 1,
          shift = {0, -0.2},
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/hr_stone_crusher_off.png",
            priority = "high",
            width = 130,
            height = 156,
            line_length = 1,
            frame_count = 1,
            repeat_count = 20,
            animation_speed = 0.5,
            scale = 0.5,
            shift = {0, -0.2},
          },
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/stone_crusher_shadow.png",
          priority = "high",
          width = 98,
          height = 78,
          line_length = 1,
          frame_count = 1,
          animation_speed = 0.5,
          scale = 1,
          repeat_count = 20,
          shift = {0.5, -0.2},
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/stone-crusher/hr_stone_crusher_shadow.png",
            priority = "high",
            width = 196,
            height = 156,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            scale = 0.5,
            repeat_count = 20,
            shift = {0.5, -0.2},
            draw_as_shadow = true,
          },
        },
      }
    },
    crafting_categories = {"biofarm-mod-crushing"},
    result_inventory_size = 1,
    source_inventory_size = 1,
    crafting_speed = 1,
    energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = 0.25,},
    energy_usage = "50kW",
    module_specification = {module_slots = 2},
    allowed_effects = {"consumption", "speed", "pollution"},
  },
--###############################################################################################
})