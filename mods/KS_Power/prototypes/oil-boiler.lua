

 --------------------------------------------------------------
 data:extend(
 {
    type = "boiler",
    name = "oil-steam-boiler",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 64,
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
      emissions_per_minute = 24,
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
	  layers =
    {
        --priority = "extra-high",
        width = 256,
        height = 223,
        line_length = 8,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet.png",
        frame_count = 8,
        animation_speed = 0.4,
        scale = 0.5,
        run_mode = "forward",
	},
	{
        --priority = "extra-high",
        width = 256,
        height = 223,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet-1.png",
        scale = 0.5,
	},
      },
	  
      east =
    {
	  layers =
		{
        --priority = "extra-high",
        width = 256,
        height = 175,
        line_length = 4,
        shift = {0.45, 0},
        filename = "__KS_Power__/graphics/ob_w_sheet.png",
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
		{
        --priority = "extra-high",
        width = 256,
        height = 175,
        shift = {0.45, 0},
        filename = "__KS_Power__/graphics/ob_w_sheet-1.png",
        scale = 0.5,
		},
	},
      south =
	{
	  layers =
		{
        --priority = "extra-high",
        width = 256,
        height = 220,
        line_length = 4,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_s_sheet.png",
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
		{
        --priority = "extra-high",
        width = 256,
        height = 220,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_s_sheet-1.png",
        scale = 0.5,
		},
	},
      west =
	{
	  layers =
		{
        --priority = "extra-high",
        width = 256,
        height = 173,
        line_length = 4,
        shift = {0.45, 0},
        filename = "__KS_Power__/graphics/ob_e_sheet.png",
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
		{
        --priority = "extra-high",
        width = 256,
        height = 173,
        shift = {0.45, 0},
        filename = "__KS_Power__/graphics/ob_e_sheet-1.png",
        scale = 0.5,
		},
	},
    },
    fire = {},
    fire_glow = {},
    burning_cooldown = 20
})

data:extend({
util.merge{data.raw.boiler["oil-steam-boiler"],
  {
    name = "oil-steam-boiler-2",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 64,
    minable = {hardness = 0.2, mining_time = 0.5, result = "oil-steam-boiler-2"},
    max_health = 375,
    target_temperature = 315,
    energy_consumption = "5.4MW",
    next_upgrade = "oil-steam-boiler-3",
    energy_source =
    {
      emissions_per_minute = 18,
    }
  }
},

util.merge{data.raw.boiler["oil-steam-boiler"],
  {
    name = "oil-steam-boiler-3",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 64,
    minable = {hardness = 0.2, mining_time = 0.5, result = "oil-steam-boiler-3"},
    max_health = 450,
    target_temperature = 465,
    energy_consumption = "8.1MW",
    next_upgrade = "oil-boiler-4",
    energy_source =
    {
      emissions_per_minute = 15,
    }
  }
},

util.merge{data.raw.boiler["oil-steam-boiler"],
  {
    name = "oil-boiler-4",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 64,
    minable = {hardness = 0.2, mining_time = 0.5, result = "oil-boiler-4"},
    max_health = 525,
    target_temperature = 615,
    energy_consumption = "10.8MW",
	next_upgrade = "oil-boiler-5",
    energy_source =
    {
      emissions_per_minute = 12,
    }
  }
},

util.merge{data.raw.boiler["oil-steam-boiler"],
  {
    name = "oil-boiler-5",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 64,
    minable = {hardness = 0.2, mining_time = 0.5, result = "oil-boiler-5"},
    max_health = 700,
    target_temperature = 765,
    energy_consumption = "13.5MW",
    energy_source =
    {
      emissions_per_minute = 6,
    }
  }
}
})