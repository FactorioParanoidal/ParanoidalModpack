 data:extend({
  {
    type = "item",
    name = "oil-steam-boiler",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 32,
    flags = {},
    subgroup = "energy",
    order = "f[oil-steam-boiler]",
    place_result = "oil-steam-boiler",
    stack_size = 10
  },
  {
    type = "recipe",
    name = "oil-steam-boiler",
    enabled = false,
    energy_required = 15,
    ingredients =
    {
      {"boiler", 1},
      {"steel-plate", 12},
	  {"basic-circuit-board", 5},
      {"pipe", 10},
      {"concrete", 6},
    },
    result = "oil-steam-boiler"
  },
  {
    type = "boiler",
    name = "oil-steam-boiler",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "oil-steam-boiler"},
    max_health = 200,
    corpse = "big-remnants",
    dying_explosion = "big-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    mode = "output-to-separate-pipe",
    resistances =
    {
      {
        type = "fire",
        percent = 90
      },
      {
        type = "explosion",
        percent = 30
      },
      {
        type = "impact",
        percent = 30
      }
    },
    target_temperature = 165,
    fluid_box =
    {
      base_area = 1,
      height = 2,
      base_level = -1,
      --pipe_covers = pipecoverspictures(),
      pipe_connections = {{ type="input", position = {-1, -2} }},
      production_type = "input",
      filter = "water"
    },
    output_fluid_box =
    {
      base_area = 1,
      height = 2,
      base_level = 1,
      --pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        {type = "output", position = {0, 2}}
      },
      production_type = "output",
      filter = "steam"
    },
    energy_consumption = "2.7MW",
    energy_source =
    {
      type = "fluid",
      emissions = 0.01,
      burns_fluid = true,
      fluid_usage_per_tick = 0,
      scale_fluid_usage = true,
      fluid_box =
      {
        base_area = 1,
        height = 2,
        base_level = -1,
        --pipe_covers = pipecoverspictures(),
        pipe_connections = {{ type="input", position = {1, -2} }},
        production_type = "input",
      },
    },
    working_sound =
    {
      sound =
      {
        filename = "__KS_Power__/sounds/oil-boiler-loop-2.ogg",
        volume = 0.35
      },
      idle_sound = { filename = "__KS_Power__/sounds/steam-offlet.ogg", volume = 0.35 },
      max_sounds_per_type = 2,
    },

    structure =
    {
      north =
      {
        priority = "extra-high",
        width = 256,
        height = 223,
        line_length = 8,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet.png",
        frame_count = 8,
        animation_speed = 0.4,
        scale = 0.5,
        run_mode = "forward-then-backward",
      },
      east =
      {
        priority = "extra-high",
        width = 256,
        height = 175,
        line_length = 4,
        shift = {0.45, 0},
        filename = "__KS_Power__/graphics/ob_w_sheet.png",
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward-then-backward",
      },
      south =
      {
        priority = "extra-high",
        width = 256,
        height = 220,
        line_length = 4,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_s_sheet.png",
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward-then-backward",
      },
      west =
      {
        priority = "extra-high",
        width = 256,
        height = 173,
        line_length = 4,
        shift = {0.45, 0},
        filename = "__KS_Power__/graphics/ob_e_sheet.png",
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward-then-backward",
      }
    },
    fire = {},
    fire_glow = {},
    burning_cooldown = 20
  }
})

data:extend({{
  type = "technology",
  name = "OilBurning",
  icon = "__KS_Power__/graphics/oil-boiler-tech2.png",
  icon_size = 128,
  effects ={
  {
    type = "unlock-recipe",
    recipe = "oil-steam-boiler"
  }},
  prerequisites = {"oil-processing","concrete"},
  unit =
  {
    count = 200,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 30
  },
  order = "f-b-c",
}})