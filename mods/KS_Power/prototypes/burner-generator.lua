require "util"

local north_animation =
{
  layers =
  {
    {
      filename = "__KS_Power__/graphics/entity/burner-generator/hr-burner-generator-h.png",
      priority = "extra-high",
      width = 241,
      height = 160,
      scale = 0.5,
      shift = util.by_pixel(0, 4),
      frame_count = 1,
    },
    {
      filename = "__KS_Power__/graphics/entity/burner-generator/hr-burner-generator-h-shadow.png",
      priority = "extra-high",
      width = 241,
      height = 160,
      scale = 0.5,
      shift = util.by_pixel(20, 4),
      frame_count = 1,
      draw_as_shadow = true,
    },
  }
}

local east_animation =
{
  layers =
  {
    {
      filename = "__KS_Power__/graphics/entity/burner-generator/hr-burner-generator-v.png",
      priority = "extra-high",
      width = 186,
      height = 224,
      scale = 0.5,
      shift = util.by_pixel(0, -0.5),
      frame_count = 1,
    },
    {
      filename = "__KS_Power__/graphics/entity/burner-generator/hr-burner-generator-v-shadow.png",
      priority = "extra-high",
      width = 186,
      height = 224,
      scale = 0.5,
      shift = util.by_pixel(12, -0.5),
      frame_count = 1,
      draw_as_shadow = true,
    },
  }
}

local north_smoke = {-0.05, 0.8}
local east_smoke = {-0.1, 0.7}
data:extend({
  {
    type = "item",
    name = "burner-generator",
    icon = "__KS_Power__/graphics/icons/burner-generator-icon.png",
    icon_size = 64,
    flags = {},
    subgroup = "energy",
    order = "b[steam-power]-c[burner-generator]",
    place_result = "burner-generator",
    stack_size = 10
  },

  {
    type = "recipe",
    name = "burner-generator",
    enabled = true,
    ingredients =
    {
      {type = "item", name = "boiler", amount = 1},
      {type = "item", name = "iron-plate", amount = 4},
      {type = "item", name = "iron-gear-wheel", amount = 5},
      {type = "item", name = "pipe", amount = 4}
    },
    results = {{type = "item", name = "burner-generator", amount = 1}}
  },
  {
    type = "burner-generator",
    name = "burner-generator",
    icon = "__KS_Power__/graphics/icons/burner-generator-icon.png",
    icon_size = 64,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "burner-generator"},
    max_health = 300,
    corpse = "small-remnants",
    effectivity = 0.25,
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    collision_box = {{-1.2, -0.8}, {1.2, 0.8}},
    selection_box = {{-1.5, -1}, {1.5, 1}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output"
    },
    burner =
    {
      type = "burner",
      fuel_inventory_size = 2,
      effectivity = 0.25,
      emissions_per_minute = {pollution = 30},
      light_flicker = {color = {0,0,0}},
      smoke =
      {
        {
          name = "smoke",
          frequency = 10,
          north_position = north_smoke,
          south_position = north_smoke,
          east_position = east_smoke,
          west_position = east_smoke,
          starting_vertical_speed = 0.03,
        },
        {
          name = "burner-generator-smoke",
          frequency = 30,
          north_position = north_smoke,
          south_position = north_smoke,
          east_position = east_smoke,
          west_position = east_smoke,
          starting_vertical_speed = 0.01,
          starting_vertical_speed_deviation = 0.01,
          deviation = {0.1, 0.1}
        },
      }
    },
    animation =
    {
      north = north_animation,
      south = north_animation,
      east = east_animation,
      west = east_animation
    },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.5
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5,
    max_power_output = "0.5MW",
  },

  {
    type = "trivial-smoke",
    name = "burner-generator-smoke",
    flags = {"not-on-map"},
    duration = 50,
    fade_in_duration = 5,
    fade_away_duration = 30,
    spread_duration = 200,
    slow_down_factor = 0.5,
    start_scale = 1,
    end_scale = 0,
    color = {r = 1, g = 0.5, b = 0.5, a = 0.1},
    cyclic = false,
    affected_by_wind = false,
    animation =
    {
      filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png",
      priority = "extra-high",
      line_length = 6,
      width = 124,
      height = 108,
      frame_count = 36,
      scale = 0.20,
      animation_speed = 32 / 200,
      blend_mode = "additive",
      draw_as_glow = true,
    },
  },
})