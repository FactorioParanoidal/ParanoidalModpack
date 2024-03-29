data:extend({
  {
    type = "item",
    name = "crop-farm",
    icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png",
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "a",
    place_result = "crop-farm",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "crop-farm",
    icon = "__angelsbioprocessing__/graphics/icons/basic-farm.png",
    icon_size = 32,
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 1, result = "crop-farm" },
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = { { -2.4, -2.4 }, { 2.4, 2.4 } },
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    fast_replaceable_group = "crop-farm",
    module_specification = {
      module_slots = 2,
    },
    allowed_effects = { "consumption", "speed", "productivity", "pollution" },
    crafting_categories = { "temperate-farming", "desert-farming", "swamp-farming", "basic-farming" },
    crafting_speed = 1,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -40,
    },
    energy_usage = "100kW",
    --ingredient_count = 4,
    animation = {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-basic.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
      },
    },
    working_visualisations = {
      {
        apply_recipe_tint = "primary",
        animation = {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-1.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = { 0, 0 },
          animation_speed = 0.005,
        },
      },
    },
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound = {
      sound = { filename = "__base__/sound/chemical-plant.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = { { type = "input", position = { 0, -3 } } },
      },
    },
  },
  {
    type = "item",
    name = "temperate-farm",
    icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png",
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "ba",
    place_result = "temperate-farm",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "temperate-farm",
    icon = "__angelsbioprocessing__/graphics/icons/temperate-farm.png",
    icon_size = 32,
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 1, result = "temperate-farm" },
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = { { -2.4, -2.4 }, { 2.4, 2.4 } },
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    fast_replaceable_group = "crop-farm",
    module_specification = {
      module_slots = 2,
    },
    allowed_effects = { "consumption", "speed", "productivity", "pollution" },
    crafting_categories = { "temperate-farming", "advanced-temperate-farming" },
    crafting_speed = 2,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -80,
    },
    energy_usage = "125kW",
    --ingredient_count = 4,
    animation = {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-temperate.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
      },
    },
    working_visualisations = {
      {
        apply_recipe_tint = "primary",
        animation = {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-2.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = { 0, 0 },
          animation_speed = 0.01,
        },
      },
    },
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound = {
      sound = { filename = "__base__/sound/chemical-plant.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = { { type = "input", position = { 0, -3 } } },
      },
    },
  },
  {
    type = "item",
    name = "desert-farm",
    icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png",
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "bc",
    place_result = "desert-farm",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "desert-farm",
    icon = "__angelsbioprocessing__/graphics/icons/desert-farm.png",
    icon_size = 32,
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 1, result = "desert-farm" },
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = { { -2.4, -2.4 }, { 2.4, 2.4 } },
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    fast_replaceable_group = "crop-farm",
    module_specification = {
      module_slots = 2,
    },
    allowed_effects = { "consumption", "speed", "productivity", "pollution" },
    crafting_categories = { "desert-farming", "advanced-desert-farming" },
    crafting_speed = 2,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -80,
    },
    energy_usage = "125kW",
    --ingredient_count = 4,
    animation = {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-desert.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
      },
    },
    working_visualisations = {
      {
        apply_recipe_tint = "primary",
        animation = {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-3.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = { 0, 0 },
          animation_speed = 0.01,
        },
      },
    },
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound = {
      sound = { filename = "__base__/sound/chemical-plant.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = { { type = "input", position = { 0, -3 } } },
      },
    },
  },
  {
    type = "item",
    name = "swamp-farm",
    icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png",
    icon_size = 32,
    subgroup = "bio-processing-buildings-vegetabilis-a",
    order = "bb",
    place_result = "swamp-farm",
    stack_size = 10,
  },
  {
    type = "assembling-machine",
    name = "swamp-farm",
    icon = "__angelsbioprocessing__/graphics/icons/swamp-farm.png",
    icon_size = 32,
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 1, result = "swamp-farm" },
    max_health = 300,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = { { -2.4, -2.4 }, { 2.4, 2.4 } },
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    fast_replaceable_group = "crop-farm",
    module_specification = {
      module_slots = 2,
    },
    allowed_effects = { "consumption", "speed", "productivity", "pollution" },
    crafting_categories = { "swamp-farming", "advanced-swamp-farming" },
    crafting_speed = 2,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = -80,
    },
    energy_usage = "125kW",
    --ingredient_count = 4,
    animation = {
      layers = {
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/farm-base.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
        {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-water.png",
          width = 224,
          height = 224,
          line_length = 1,
          frame_count = 1,
          shift = { 0, 0 },
        },
      },
    },
    working_visualisations = {
      {
        apply_recipe_tint = "primary",
        animation = {
          filename = "__angelsbioprocessing__/graphics/entity/crop-farm/field-animation-4.png",
          line_length = 6,
          frame_count = 36,
          width = 224,
          height = 224,
          shift = { 0, 0 },
          animation_speed = 0.01,
        },
      },
    },
    vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound = {
      sound = { filename = "__base__/sound/chemical-plant.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
    fluid_boxes = {
      {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = { { type = "input", position = { 0, -3 } } },
      },
    },
  },
})
