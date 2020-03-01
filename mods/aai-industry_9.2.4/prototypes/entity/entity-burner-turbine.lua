local blank = {
  filename = "__aai-industry__/graphics/blank.png",
  priority = "high",
  width = 1,
  height = 1,
  frame_count = 1
}
local burner_turbine = {
  type = "boiler",
  name = "burner-turbine",
  icon = "__aai-industry__/graphics/icons/burner-turbine.png",
  icon_size = 32,
  flags = {"placeable-neutral", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "burner-turbine"},
  max_health = 250,
  corpse = "small-remnants",
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  mode = "output-to-separate-pipe",
  resistances =
  {
    { type = "fire", percent = 100 },
    { type = "explosion", percent = 30 },
    { type = "impact", percent = 50 }
  },
  selection_box = {{-2,-2}, {2,2}},
  collision_box = {{-1.6, -1.6}, {1.6, 1.6}},
  target_temperature = 165,
  fluid_input = { name = "water", amount = 0.0 },
  fluid_output = { name = "steam", amount = 10.0 },
  fluid_box =
  {
    base_area = 0.5,
    height = 2,
    base_level = -1,
    production_type = "input-output",
    pipe_connections = {},
    filter = "water"
  },
  output_fluid_box =
  {
    base_area = 0.5,
    height = 2,
    production_type = "output",
    pipe_connections = {},
    filter = "steam"
  },
  energy_consumption = "1MW",
  energy_source =
  {
    type = "burner",
    fuel_category = "chemical",
    effectivity = 0.25, --0.35
    fuel_inventory_size = 4,
    emissions_per_second_per_watt = 6 * 1e-05, -- emissions = 0.5 / 3,
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
  working_sound =
  {
    sound =
    {
      filename = "__base__/sound/furnace.ogg",
      volume = 1.6
    },
    max_sounds_per_type = 3
  },
  fire_flicker_enabled = true,
  fire_glow_flicker_enabled = false,
  burning_cooldown = 20
}

local layers = {
  layers =
  {
    {
      filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine.png",
      priority = "extra-high",
      line_length = 4,
      frame_count = 8,
      animation_speed = 0.5,
      width = 540/4,
      height = 300/2,
      shift = util.by_pixel(0, -10),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine.png",
        priority = "extra-high",
        line_length = 4,
        frame_count = 8,
        animation_speed = 0.5,
        width = 540/2,
        height = 300,
        shift = util.by_pixel(0, -10),
        scale = 0.5
      }
    }
	--[[,
    {
      filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine-shadow.png",
      priority = "extra-high",
      width = 165,
      height = 75,
      shift = util.by_pixel(30, 42),
      draw_as_shadow = true,
      hr_version = {
        filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine-shadow.png",
        priority = "extra-high",
        width = 165*2,
        height = 75*2,
        scale = 0.5,
        shift = util.by_pixel(30, 42),
        draw_as_shadow = true,
      }
    }
	
	]]
	
  }
}
burner_turbine.structure = {}
burner_turbine.structure.north = layers
burner_turbine.structure.south = layers
burner_turbine.structure.east = layers
burner_turbine.structure.west = layers
local fire = {
  filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine-glow.png",
  priority = "extra-high",
  line_length = 4,
  frame_count = 8,
  animation_speed = 0.5,
  width = 540/4,
  height = 300/2,
  shift = util.by_pixel(0, -10),
  blend_mode = "additive",
  hr_version = {
    filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine-glow.png",
    priority = "extra-high",
    line_length = 4,
    frame_count = 8,
    animation_speed = 0.5,
    width = 540/2,
    height = 300,
    shift = util.by_pixel(0, -10),
    scale = 0.5,
    blend_mode = "additive",
  }
}
burner_turbine.fire = {}
burner_turbine.fire.north = fire
burner_turbine.fire.south = fire
burner_turbine.fire.east = fire
burner_turbine.fire.west = fire

local fire_glow = {
  filename = "__aai-industry__/graphics/entity/burner-turbine/burner-turbine.png",
  priority = "extra-high",
  line_length = 4,
  frame_count = 8,
  animation_speed = 0.5,
  width = 540/4,
  height = 300/2,
  shift = util.by_pixel(0, -10),
  hr_version = {
    filename = "__aai-industry__/graphics/entity/burner-turbine/hr-burner-turbine.png",
    priority = "extra-high",
    line_length = 4,
    frame_count = 8,
    animation_speed = 0.5,
    width = 540/2,
    height = 300,
    shift = util.by_pixel(0, -10),
    scale = 0.5
  }
}
burner_turbine.fire_glow = {}
burner_turbine.fire_glow.north = fire_glow
burner_turbine.fire_glow.south = fire_glow
burner_turbine.fire_glow.east = fire_glow
burner_turbine.fire_glow.west = fire_glow

data:extend({burner_turbine})

local burner_turbine_generator = {
  type = "generator",
  name = "burner-turbine-generator",
  icon = "__aai-industry__/graphics/icons/burner-turbine.png",
  icon_size = 32,
  flags = {"placeable-neutral","player-creation", "placeable-off-grid", "not-blueprintable", "not-deconstructable"},
  max_health = 10000,
  healing_per_tick = 10000,
  corpse = "big-remnants",
  dying_explosion = "medium-explosion",
  effectivity = 1, -- fix for exactly 1 fluid per tick
  order="z",
  fluid_usage_per_tick = 1,
  maximum_temperature = 165,
  --selectable_in_game = false,
  selection_box = {{-2,-2}, {2,2}},
  collision_box = {{-1.6, -1.6}, {1.6, 1.6}},
  collision_mask = {"not-colliding-with-itself"},
  fluid_box =
  {
    base_area = 0.5,
    height = 2,
    base_level = -1,
    production_type = "input-output",
    pipe_connections = {},
    filter = "steam"
  },
  fluid_input = { name = "steam", amount = 10.0, minimum_temperature = 100.0 },
  energy_source = {
    type = "electric",
    --usage_priority = "terciary", -- bugs when accumilators are linked
    usage_priority = "secondary-output",
    render_no_network_icon = false,
	emissions_per_second_per_watt = 0,
  },
  horizontal_animation = { layers = { blank }, },
  vertical_animation = { layers = { blank }, },
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  min_perceived_performance = 0.25,
  performance_to_sound_speedup = 0.5,
  working_sound =
  {
    sound =
    {
      filename = "__base__/sound/boiler.ogg",
      volume = 0.8
    },
    max_sounds_per_type = 3
  },
}
data:extend({burner_turbine_generator})
