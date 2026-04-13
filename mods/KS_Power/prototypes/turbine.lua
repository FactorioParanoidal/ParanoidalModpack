data:extend({
	{
		type = "item",
		name = "wind-turbine-2",
		icon = "__KS_Power__/graphics/icons/wind_turbine_icon.png",
    icon_size = 64,
		flags = {},
		subgroup = "energy",
		order = "b[steam-power]-c[wind-turbine]",
		place_result = "wind-turbine-2",
		stack_size = 20,
	},

	{
    type = "recipe",
    name = "wind-turbine-2",
    energy_required = 4,
    enabled = true,
    ingredients =
    {
      {type = "item", name = "iron-plate", amount = 8},
      {type = "item", name = "iron-gear-wheel", amount = 4},
      {type = "item", name = "copper-cable", amount = 8}
    },
    results = {{type = "item", name = "wind-turbine-2", amount = 1}},
  },

  {
    type = "electric-energy-interface",
    name = "wind-turbine-2",
    icon = "__KS_Power__/graphics/icons/wind_turbine_icon.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "not-rotatable"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "wind-turbine-2"},
    max_health = 50,
    corpse = "medium-remnants",
    collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
		selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
		drawing_box = {{-0.5, -3}, {3.2, 0.5}},
    energy_source =
    {
      type = "electric",
      buffer_capacity = "15kJ",
      usage_priority = "primary-output",
      input_flow_limit = "0kW",
      output_flow_limit = "30kW",
      render_no_power_icon = false
    },
    continuous_animation = true,
    energy_production = "15kW",
    energy_usage = "0kW",
    animation = {
      layers = {
        {
          filename = "__KS_Power__/graphics/entity/wind-turbine-2/hr-wind-turbine-2-anim.png",
          width = 350,
          height = 350,
          scale = 0.5,
          frame_count = 20,
          line_length = 5,
          shift = {1.7,-1.4},
          animation_speed = 1,
        },
        {
          filename = "__KS_Power__/graphics/entity/wind-turbine-2/hr-wind-turbine-2-anim-shadow.png",
          width = 350,
          height = 350,
          scale = 0.5,
          frame_count = 20,
          line_length = 5,
          shift = {1.7,-1.4},
          animation_speed = 1,
          draw_as_shadow = true,
        },
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/train-wheels.ogg",
        volume = 0.4
      },
      idle_sound =
      {
        filename = "__base__/sound/train-wheels.ogg",
        volume = 0.4
      },
      max_sounds_per_type = 3
    },
  },

})