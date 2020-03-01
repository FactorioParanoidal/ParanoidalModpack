if settings.startup["bobmods-power-fluidgenerator"].value == true then

function bobmods.power.fluid_generator_structure()
  return {
    filename = "__bobpower__/graphics/fluid-generator/hr-fluid-generator.png",
    priority = "extra-high",
    width = 269,
    height = 284,
    frame_count = 1,
    shift = util.by_pixel(-1.25, 5.25),
    scale = 0.5
  }
end




function bobmods.power.fluid_generator_fire_glow()
  return {
    filename = "__bobpower__/graphics/fluid-generator/hr-fluid-generator-light.png",
    priority = "extra-high",
    frame_count = 1,
    width = 200,
    height = 257,
    shift = util.by_pixel(-1, -6.75 -10),
    blend_mode = "additive",
    scale = 0.5
  }
end


function bobmods.power.fluid_generator_fire()
  return {
    layers = 
    { 
      {
        filename = "__bobpower__/graphics/fluid-generator/hr-boiler-N-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 26,
        height = 26,
        animation_speed = 0.5,
        shift = util.by_pixel(0, -8.5 -32),
        scale = 0.5
      },
      {
        filename = "__bobpower__/graphics/fluid-generator/hr-boiler-S-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 26,
        height = 16,
        animation_speed = 0.5,
        shift = util.by_pixel(-1, -26.5 +32),
        scale = 0.5
      },
      bobmods.power.fluid_generator_fire_glow()
    }
  }
end

function bobmods.power.fluid_generator_working_visualisations()
  return
  {
    {
      north_position = {0.0, 0.0},
      east_position = {0.0, 0.0},
      south_position = {0.0, 0.0},
      west_position = {0.0, 0.0},
      {
        filename = "__bobpower__/graphics/fluid-generator/hr-fluid-generator-light.png",
        priority = "extra-high",
        frame_count = 1,
        width = 200,
        height = 257,
        shift = util.by_pixel(-1, -6.75 -10),
        blend_mode = "additive",
        scale = 0.5
      }
    },
    {
      north_position = {0.0, 0.0},
      east_position = {0.0, 0.0},
      south_position = {0.0, 0.0},
      west_position = {0.0, 0.0},
      {
        filename = "__bobpower__/graphics/fluid-generator/hr-boiler-N-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 26,
        height = 26,
        animation_speed = 0.5,
        shift = util.by_pixel(0, -8.5 -32),
        scale = 0.5
      },
    },
    {
      north_position = {0.0, 0.0},
      east_position = {0.0, 0.0},
      south_position = {0.0, 0.0},
      west_position = {0.0, 0.0},
      {
        filename = "__bobpower__/graphics/fluid-generator/hr-boiler-S-fire.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        width = 26,
        height = 16,
        animation_speed = 0.5,
        shift = util.by_pixel(-1, -26.5 +32),
        scale = 0.5
      },
    },
  }
end


data:extend(
{
  {
    type = "generator",
    name = "fluid-generator",
    icon = "__bobpower__/graphics/icons/fluid-generator.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "fluid-generator"},
    max_health = 500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    effectivity = 0.6,
    fluid_usage_per_tick = (6/60),
    maximum_temperature = 275,
    burns_fluid = true,
    scale_fluid_usage = true,
    max_power_output = "2MW",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      },
      {
        type = "impact",
        percent = 30
      }
    },
    fast_replaceable_group = "fluid-generator",
    collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_box =
    {
      base_area = 1,
      height = 2,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { type = "input-output", position = {0, 2} },
        { type = "input-output", position = {0, -2} },
        { type = "input-output", position = {2, 0} },
        { type = "input-output", position = {-2, 0} },
      },
      production_type = "input-output",
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output",
      emissions_per_minute = 8,
    },
    horizontal_animation = bobmods.power.fluid_generator_structure(),
    vertical_animation = bobmods.power.fluid_generator_structure(),
    working_visualisations = bobmods.power.fluid_generator_working_visualisations(),
    smoke =
    {
      {
        name = "smoke",
        position = util.by_pixel(38.5, -16),
        frequency = 0.205,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60
      },
      {
        name = "smoke",
        position = util.by_pixel(-38, -63.5),
        frequency = 0.195,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5
  },

  {
    type = "generator",
    name = "fluid-generator-2",
    icon = "__bobpower__/graphics/icons/fluid-generator.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "fluid-generator-2"},
    max_health = 650,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    effectivity = 0.8,
    fluid_usage_per_tick = (6/60),
    maximum_temperature = 275,
    burns_fluid = true,
    scale_fluid_usage = true,
    max_power_output = "2.75MW",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      },
      {
        type = "impact",
        percent = 30
      }
    },
    fast_replaceable_group = "fluid-generator",
    collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_box =
    {
      base_area = 1,
      height = 2,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { type = "input-output", position = {0, 2} },
        { type = "input-output", position = {0, -2} },
        { type = "input-output", position = {2, 0} },
        { type = "input-output", position = {-2, 0} },
      },
      production_type = "input-output",
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output",
      emissions_per_minute = 6,
    },
    horizontal_animation = bobmods.power.fluid_generator_structure(),
    vertical_animation = bobmods.power.fluid_generator_structure(),
    working_visualisations = bobmods.power.fluid_generator_working_visualisations(),
    smoke =
    {
      {
        name = "smoke",
        position = util.by_pixel(38.5, -16),
        frequency = 0.28,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60
      },
      {
        name = "smoke",
        position = util.by_pixel(-38, -63.5),
        frequency = 0.27,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5
  },

  {
    type = "generator",
    name = "fluid-generator-3",
    icon = "__bobpower__/graphics/icons/fluid-generator.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "fluid-generator-3"},
    max_health = 800,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    effectivity = 1,
    fluid_usage_per_tick = (6/60),
    maximum_temperature = 275,
    burns_fluid = true,
    scale_fluid_usage = true,
    max_power_output = "3.5MW",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      },
      {
        type = "impact",
        percent = 30
      }
    },
    fast_replaceable_group = "fluid-generator",
    collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_box =
    {
      base_area = 1,
      height = 2,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { type = "input-output", position = {0, 2} },
        { type = "input-output", position = {0, -2} },
        { type = "input-output", position = {2, 0} },
        { type = "input-output", position = {-2, 0} },
      },
      production_type = "input-output",
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output",
      emissions_per_minute = 4,
    },
    horizontal_animation = bobmods.power.fluid_generator_structure(),
    vertical_animation = bobmods.power.fluid_generator_structure(),
    working_visualisations = bobmods.power.fluid_generator_working_visualisations(),
    smoke =
    {
      {
        name = "smoke",
        position = util.by_pixel(38.5, -16),
        frequency = 0.355,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60
      },
      {
        name = "smoke",
        position = util.by_pixel(-38, -63.5),
        frequency = 0.345,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5
  },
}
)

if mods["bobrevamp"] and data.raw.fluid.hydrogen and data.raw.fluid.oxygen and data.raw.fluid.nitrogen then

data:extend(
{
  {
    type = "generator",
    name = "hydrazine-generator",
    icon = "__bobpower__/graphics/icons/fluid-generator.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "hydrazine-generator"},
    max_health = 750,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    effectivity = 1,
    fluid_usage_per_tick = (12/60),
    maximum_temperature = 275,
    burns_fluid = true,
    resistances =
    {
      {
        type = "fire",
        percent = 70
      },
      {
        type = "impact",
        percent = 30
      }
    },
    fast_replaceable_group = "fluid-generator",
    collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_box =
    {
      base_area = 1,
      height = 2,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { type = "input-output", position = {0, 2} },
        { type = "input-output", position = {0, -2} },
        { type = "input-output", position = {2, 0} },
        { type = "input-output", position = {-2, 0} },
      },
      production_type = "input-output",
      filter = "hydrazine",
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output",
      emissions_per_minute = 1,
    },
    horizontal_animation = bobmods.power.fluid_generator_structure(),
    vertical_animation = bobmods.power.fluid_generator_structure(),
    working_visualisations = bobmods.power.fluid_generator_working_visualisations(),
    smoke =
    {
      {
        name = "light-smoke",
        position = util.by_pixel(38.5, -16),
        frequency = 0.105,
        starting_vertical_speed = 0.08,
        slow_down_factor = 1,
        starting_frame_deviation = 60
      },
      {
        name = "light-smoke",
        position = util.by_pixel(-38, -63.5),
        frequency = 0.095,
        starting_vertical_speed = 0.08,
        slow_down_factor = 1,
        starting_frame_deviation = 60
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5
  },
}
)

end

end
