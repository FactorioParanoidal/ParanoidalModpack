local burner_picture =
{
  layers =
  {
    {
      filename = "__KS_Power__/graphics/entity/big-burner-generator/hr-big-burner-generator.png",
      width = 640,
      height = 640,
      scale = 0.5,
      shift = { -0.03125 *2, -0.1875 *2 }
    },
    {
      filename = "__KS_Power__/graphics/entity/big-burner-generator/hr-big-burner-generator-shadow.png",
      width = 525*2,
      height = 323*2,
      scale = 0.5,
      shift = { 1.625 * 2, 0 },
      draw_as_shadow = true
    }
  }
}

data:extend({
  {
    type = "item",
    name = "big-burner-generator",
    icon = "__KS_Power__/graphics/icons/big-burner-generator-icon.png",
    icon_size = 64,
    flags = {},
    subgroup = "energy",
    order = "b[steam-power]-d[big-burner-generator]",
    place_result = "big-burner-generator",
    stack_size = 10
  },

  {
    type = "recipe",
    name = "big-burner-generator",
    enabled = false,
    ingredients =
    {
      {type = "item", name = "heat-exchanger", amount = 4},
      {type = "item", name = "steel-plate", amount = 50},
      {type = "item", name = "concrete", amount = 100},
      {type = "item", name = "pump", amount = 10}
    },
    results = {{type = "item", name = "big-burner-generator", amount = 1}}
  },
  {
    type = "burner-generator",
    name = "big-burner-generator",
    icon = "__KS_Power__/graphics/icons/big-burner-generator-icon.png",
    icon_size = 64,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 1, result = "big-burner-generator"},
    max_health = 3000,
    corpse = "small-remnants",
    effectivity = 1,
    resistances =
    {
      {
        type = "fire",
        percent = 70
      }
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output"
    },
    burner =
    {
      type = "burner",
      fuel_inventory_size = 5,
      effectivity = 0.5,
      emissions_per_minute = {pollution = 1000},
      light_flicker = {intensity = 0.2, minimum_light_size = 1, color = {r=1.0, g=0.7, b=0.7, a=0.2}},
      smoke =
      {
        {
          name = "smoke",
          frequency = 25,
          north_position = {-2.5, -1.4},
          south_position = {-2.5, -1.4},
          east_position = {-2.5, -1.4},
          west_position = {-2.5, -1.4},
          deviation = {0.2, 0.2},
          starting_vertical_speed = 0.02,
          starting_vertical_speed_deviation = 0.03,
          starting_frame_deviation = 3,
          slow_down_factor = 0.1
        },
        {
          name = "big-burner-generator-smoke",
          frequency = 25,
          north_position = {-2.5, -1.4},
          south_position = {-2.5, -1.4},
          east_position = {-2.5, -1.4},
          west_position = {-2.5, -1.4},
          deviation = {0.1, 0.1},
          starting_vertical_speed = 0.01,
          starting_vertical_speed_deviation = 0.01,
          starting_frame_deviation = 3,
          slow_down_factor = 0.1
        },
      }
    },
    animation = burner_picture,
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
    max_power_output = "50MW",
  },

  {
    type = "technology",
    name = "big-burner-generator",
    icon = "__KS_Power__/graphics/technology/big-burner-generator-technology.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "big-burner-generator"
      }
    },
    prerequisites = {"flammables", "chemical-science-pack"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "f-b-d",
  },
  {
    type = "trivial-smoke",
    name = "big-burner-generator-smoke",
    flags = {"not-on-map"},
    duration = 170,
    fade_in_duration = 20,
    fade_away_duration = 100,
    spread_duration = 200,
    slow_down_factor = 0.5,
    start_scale = 1,
    end_scale = 0,
    color = {r = 1, g = 0.4, b = 0.4, a = 0.1},
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
      scale = 0.5,
      animation_speed = 32 / 100,
      blend_mode = "additive",
      draw_as_glow = true,
    },
  },
})