data:extend({
	{
		type = "item",
		name = "wind-turbine-2",
		icon = "__KS_Power__/graphics/wind_turbine_icon.png",
    icon_size = 32,
		--flags = {},
		subgroup = "energy",	
		order = "b[steam-power]-c[wind-turbine]",		
		place_result = "wind-turbine-2",
		stack_size = 20,
	},

	{
    type = "recipe",
    name = "wind-turbine-2",
    energy_required = 4,
    enabled = "true",
    ingredients =
    {
      {"iron-plate", 8},
      {"iron-gear-wheel", 4},
      {"copper-cable", 8},
      {"iron-stick", 5}
    },
    result = "wind-turbine-2"
  },

  {
    type = "electric-energy-interface",
    name = "wind-turbine-2",
    icon = "__KS_Power__/graphics/wind_turbine_icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "wind-turbine-2"},
    max_health = 50,
    corpse = "medium-remnants",
    collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
		selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
		drawing_box = {{-0.5, -3}, {3.2, 0.5}},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "1kJ",
      usage_priority = "primary-output",
      input_flow_limit = "0kW",
      output_flow_limit = "30kW",
      render_no_power_icon = false
    },
    energy_production = "0kW",
    energy_usage = "0kW",
    animation =
    {
			filename = "__KS_Power__/graphics/wind_turbine_sheet_4.png",
			width = 175,
			height = 175,
			frame_count = 20,
			line_length = 5,
			shift = {1.7,-1.4},
      animation_speed = 0.005
		},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/train-wheels.ogg",
        volume = 0.6
      },
      idle_sound =
      {
        filename = "__base__/sound/train-wheels.ogg",
        volume = 0.0
      },
      max_sounds_per_type = 5
    },
  },

})