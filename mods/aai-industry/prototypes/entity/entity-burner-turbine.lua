local blank = {
  filename = "__aai-industry__/graphics/blank.png",
  priority = "high",
  width = 1,
  height = 1,
  frame_count = 1
}
local effectivity = settings.startup["aai-burner-turbine-efficiency"].value / 100
local layers = {
  layers =
  {
    {
      filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine.png",
      priority = "extra-high",
      line_length = 4,
      frame_count = 8,
      animation_speed = 0.6,
      width = 540/4,
      height = 300/2,
      shift = util.by_pixel(0, -10),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine.png",
        priority = "extra-high",
        line_length = 4,
        frame_count = 8,
        animation_speed = 0.6,
        width = 540/2,
        height = 300,
        shift = util.by_pixel(0, -10),
        scale = 0.5
      }
    },
    {
      filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine-shadow.png",
      priority = "extra-high",
      width = 165,
      height = 75,
      shift = util.by_pixel(30, 42),
      draw_as_shadow = true,
      repeat_count = 8,
      hr_version = {
        filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine-shadow.png",
        priority = "extra-high",
        width = 165*2,
        height = 75*2,
        scale = 0.5,
        shift = util.by_pixel(30, 42),
        draw_as_shadow = true,
        repeat_count = 8,
      }
    }
  }
}
local fire_glow = {
  filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine-glow.png",
  priority = "extra-high",
  line_length = 4,
  frame_count = 8,
  animation_speed = 0.6,
  width = 540/4,
  height = 300/2,
  shift = util.by_pixel(0, -10),
  blend_mode = "additive",
  draw_as_glow = true,
  hr_version = {
    filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine-glow.png",
    priority = "extra-high",
    line_length = 4,
    frame_count = 8,
    animation_speed = 0.6,
    width = 540/2,
    height = 300,
    shift = util.by_pixel(0, -10),
    scale = 0.5,
    blend_mode = "additive",
    draw_as_glow = true,
  }
}
local fire_light = {
  filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine-light.png",
  priority = "extra-high",
  line_length = 4,
  frame_count = 8,
  animation_speed = 0.6,
  width = 540/4,
  height = 300/2,
  shift = util.by_pixel(0, -10),
  blend_mode = "additive",
  draw_as_light = true,
  hr_version = {
    filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine-light.png",
    priority = "extra-high",
    line_length = 4,
    frame_count = 8,
    animation_speed = 0.6,
    width = 540/2,
    height = 300,
    shift = util.by_pixel(0, -10),
    scale = 0.5,
    blend_mode = "additive",
    draw_as_light = true,
  }
}
local fire_and_glow = {
  layers = {
    fire_glow,
    fire_light
  }
}
local burner_generator = {
  type = "burner-generator",
  name = "burner-turbine",
  icon = "__aai-industry__/graphics/icons/burner-turbine.png",
  icon_size = 64, icon_mipmaps = 1,
  flags = {"placeable-neutral", "player-creation", "not-rotatable"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "burner-turbine"},
  max_health = 250,
  corpse = "small-remnants",
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  resistances =
  {
    { type = "fire", percent = 100 },
    { type = "explosion", percent = 30 },
    { type = "impact", percent = 50 }
  },
  selection_box = {{-2,-2}, {2,2}},
  collision_box = {{-1.6, -1.6}, {1.6, 1.6}},
  max_power_output = "2MW",
  burner =
  {
    type = "burner",
    fuel_category = "chemical",
    effectivity = effectivity,
    fuel_inventory_size = 4,
    emissions_per_minute = 34,
    light_flicker =
    {
      minimum_light_size = 1,
      light_intensity_to_size_coefficient = 0.25,
      color = {1,0.6,0},
      minimum_intensity = 0.05,
      maximum_intensity = 0.3
    },
    smoke =
    {
      {
        name = "smoke",
        north_position = util.by_pixel(20, -85),
        south_position = util.by_pixel(20, -85),
        east_position = util.by_pixel(20, -85),
        west_position = util.by_pixel(20, -85),
        frequency = 30,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60,
        deviation = {-1, 1},
      }
    }
  },
  energy_source = {
    type = "electric",
    usage_priority = "primary-output",
  },
  working_sound =
  {
    sound =
    {
      filename = "__base__/sound/furnace.ogg",
      volume = 1.6
    },
    max_sounds_per_type = 3
  },
  min_perceived_performance = 0.25,
  performance_to_sound_speedup = 0.5,
  idle_animation = {
    north = layers,
    south = layers,
    east = layers,
    west = layers,
  },
  always_draw_idle_animation = true,
  animation = {
    north = fire_and_glow,
    south = fire_and_glow,
    east = fire_and_glow,
    west = fire_and_glow,
  }
}
data:extend({burner_generator})
