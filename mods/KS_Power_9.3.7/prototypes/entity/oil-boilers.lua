data:extend({
  {
    type = "item",
    name = "oil-steam-boiler",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler-1.png",
    icon_size = 64,
    flags = {},
    subgroup = "energy",
    order = "f[oil-steam-boiler-1]",
    place_result = "oil-steam-boiler",
    stack_size = 10
  },
  {
    type = "boiler",
    name = "oil-steam-boiler",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler.png",
    icon_size = 64,
	fast_replaceable_group = "oil-steam-boiler",
	next_upgrade = "oil-steam-boiler-2",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "oil-steam-boiler"},
    max_health = 150,
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
	energy_consumption = "2.7MW",
	effectivity= 0.5,
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
	energy_source =
    {
      type = "fluid",
      emissions_per_minute = 24,
	  fluid_box =
      {
      base_area = 1,
      height = 2,
      base_level = -1,
		pipe_connections = {{ type="input", position = {1, -2} }},
        production_type = "input",
        --pipe_covers = pipecoverspictures(),
        --pipe_picture = assembler2pipepictures(),
      },
	  burns_fluid = true,
      scale_fluid_usage = true,
      smoke =
      {
        {
          name = "smoke",
          north_position = util.by_pixel(-38, -47.5),
          south_position = util.by_pixel(38.5, -32),
          east_position = util.by_pixel(20, -70),
          west_position = util.by_pixel(-19, -8.5),
          frequency = 15,
          starting_vertical_speed = 0.0,
          starting_frame_deviation = 60
        }
      }
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
	  layers ={
    {
        --priority = "extra-high",
        width = 256,
        height = 223,
        line_length = 8,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet.png",
        frame_count = 8,
        animation_speed = 0.2,
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
		frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
      },},
      east =
    {
	  layers ={
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
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      south =
	{
	  layers ={
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
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      west =
	{
	  layers ={
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
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
},
    fire = {},
    fire_glow = {},
    burning_cooldown = 20
  },
--------------2
  {
    type = "boiler",
    name = "oil-steam-boiler-2",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler-2.png",
    icon_size = 64,
	fast_replaceable_group = "oil-steam-boiler",
	next_upgrade = "oil-steam-boiler-3",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "oil-steam-boiler-2"},
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
	target_temperature = 315,
    energy_consumption = "5.4MW",
	effectivity= 0.67,
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
    energy_source =
    {
      type = "fluid",
      emissions_per_minute = 20,
	  fluid_box =
      {
      base_area = 1,
      height = 2,
      base_level = -1,
		pipe_connections = {{ type="input", position = {1, -2} }},
        production_type = "input",
        --pipe_covers = pipecoverspictures(),
        --pipe_picture = assembler2pipepictures(),
      },
	  burns_fluid = true,
      scale_fluid_usage = true,
      smoke =
      {
        {
          name = "smoke",
          north_position = util.by_pixel(-38, -47.5),
          south_position = util.by_pixel(38.5, -32),
          east_position = util.by_pixel(20, -70),
          west_position = util.by_pixel(-19, -8.5),
          frequency = 15,
          starting_vertical_speed = 0.0,
          starting_frame_deviation = 60
        }
      }
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
	  layers ={
    {
        --priority = "extra-high",
        width = 256,
        height = 223,
        line_length = 8,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet.png",
        frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
	{
        --priority = "extra-high",
        width = 256,
        height = 223,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet-2.png",
        scale = 0.5,
		frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
      },},
      east =
    {
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_w_sheet-2.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      south =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_s_sheet-2.png",
        scale = 0.5,
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      west =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_e_sheet-2.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},},
	},
},
    fire = {},
    fire_glow = {},
    burning_cooldown = 20
  },
  -------------3
  {
    type = "boiler",
    name = "oil-steam-boiler-3",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler-3.png",
    icon_size = 64,
	fast_replaceable_group = "oil-steam-boiler",
	next_upgrade = "oil-steam-boiler-4",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "oil-steam-boiler-3"},
    max_health = 300,
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
    target_temperature = 465,
    energy_consumption = "8.1MW",
	effectivity= 0.8,
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
	energy_source =
    {
      type = "fluid",
      emissions_per_minute = 18,
	  fluid_box =
      {
      base_area = 1,
      height = 2,
      base_level = -1,
		pipe_connections = {{ type="input", position = {1, -2} }},
        production_type = "input",
        --pipe_covers = pipecoverspictures(),
        --pipe_picture = assembler2pipepictures(),
      },
	  burns_fluid = true,
      scale_fluid_usage = true,
      smoke =
      {
        {
          name = "smoke",
          north_position = util.by_pixel(-38, -47.5),
          south_position = util.by_pixel(38.5, -32),
          east_position = util.by_pixel(20, -70),
          west_position = util.by_pixel(-19, -8.5),
          frequency = 15,
          starting_vertical_speed = 0.0,
          starting_frame_deviation = 60
        }
      }
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
	  layers ={
    {
        --priority = "extra-high",
        width = 256,
        height = 223,
        line_length = 8,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet.png",
        frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
	{
        --priority = "extra-high",
        width = 256,
        height = 223,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet-3.png",
        scale = 0.5,
		frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
      },},
      east =
    {
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_w_sheet-3.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      south =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_s_sheet-3.png",
        scale = 0.5,
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      west =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_e_sheet-3.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},},
	},
},
    fire = {},
    fire_glow = {},
    burning_cooldown = 20
  },
-------------------4
  {
    type = "boiler",
    name = "oil-steam-boiler-4",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler-4.png",
    icon_size = 64,
	fast_replaceable_group = "oil-steam-boiler",
	next_upgrade = "oil-steam-boiler-5",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "oil-steam-boiler-4"},
    max_health = 400,
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
    target_temperature = 615,
    energy_consumption = "10.8MW",
	effectivity= 0.9,
    energy_source =
    {
      type = "fluid",
      emissions_per_minute = 12,
	  fluid_box =
      {
      base_area = 1,
      height = 2,
      base_level = -1,
		pipe_connections = {{ type="input", position = {1, -2} }},
        production_type = "input",
        --pipe_covers = pipecoverspictures(),
        --pipe_picture = assembler2pipepictures(),
      },
	  burns_fluid = true,
      scale_fluid_usage = true,
      smoke =
      {
        {
          name = "smoke",
          north_position = util.by_pixel(-38, -47.5),
          south_position = util.by_pixel(38.5, -32),
          east_position = util.by_pixel(20, -70),
          west_position = util.by_pixel(-19, -8.5),
          frequency = 15,
          starting_vertical_speed = 0.0,
          starting_frame_deviation = 60
        }
      }
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
	  layers ={
    {
        --priority = "extra-high",
        width = 256,
        height = 223,
        line_length = 8,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet.png",
        frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
	{
        --priority = "extra-high",
        width = 256,
        height = 223,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet-4.png",
        scale = 0.5,
		frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
      },},
      east =
    {
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_w_sheet-4.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      south =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_s_sheet-4.png",
        scale = 0.5,
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      west =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_e_sheet-4.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},},
	},
},
    fire = {},
    fire_glow = {},
    burning_cooldown = 20
  },
-------------------5
  {
    type = "boiler",
    name = "oil-steam-boiler-5",
    icon = "__KS_Power__/graphics/icons/oil-steam-boiler-5.png",
    icon_size = 64,
	fast_replaceable_group = "oil-steam-boiler",
	next_upgrade = nil,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "oil-steam-boiler-5"},
    max_health = 500,
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
    target_temperature = 765,
    energy_consumption = "13.5MW",
	effectivity= 0.98,
    energy_source =
    {
      type = "fluid",
      emissions_per_minute = 6,
	  fluid_box =
      {
      base_area = 1,
      height = 2,
      base_level = -1,
		pipe_connections = {{ type="input", position = {1, -2} }},
        production_type = "input",
        --pipe_covers = pipecoverspictures(),
        --pipe_picture = assembler2pipepictures(),
      },
	  burns_fluid = true,
      scale_fluid_usage = true,
      smoke =
      {
        {
          name = "smoke",
          north_position = util.by_pixel(-38, -47.5),
          south_position = util.by_pixel(38.5, -32),
          east_position = util.by_pixel(20, -70),
          west_position = util.by_pixel(-19, -8.5),
          frequency = 15,
          starting_vertical_speed = 0.0,
          starting_frame_deviation = 60
        }
      }
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
	  layers ={
    {
        --priority = "extra-high",
        width = 256,
        height = 223,
        line_length = 8,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet.png",
        frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
	{
        --priority = "extra-high",
        width = 256,
        height = 223,
        shift = {0.5, 0},
        filename = "__KS_Power__/graphics/ob_n_sheet-5.png",
        scale = 0.5,frame_count = 8,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
	},
      },},
      east =
    {
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_w_sheet-5.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      south =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_s_sheet-5.png",
        scale = 0.5,
        frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},
	},},
      west =
	{
	  layers ={
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
        filename = "__KS_Power__/graphics/ob_e_sheet-5.png",
        scale = 0.5,
		frame_count = 4,
        animation_speed = 0.2,
        scale = 0.5,
        run_mode = "forward",
		},},
	},
},
    fire = {},
    fire_glow = {},
    burning_cooldown = 20
}
})