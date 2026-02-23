if my_light_bright then
	filename_lamp = "__AfraidOfTheDark__/graphics/balloon-light-on.png"
	filename_short_lamp = "__AfraidOfTheDark__/graphics/short-balloon-light-on.png"
else
	filename_lamp = "__AfraidOfTheDark__/graphics/balloon-light-on-soft.png"
	filename_short_lamp = "__AfraidOfTheDark__/graphics/short-balloon-light-on-soft.png"
end


data:extend(
{
	----------------------------------------------------------------------------------
	{
		type = "lamp",
		name = "balloon-light",
		icon = "__AfraidOfTheDark__/graphics/balloon-light-icon.png",
		icon_size = 32,
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "balloon-light"},
		max_health = 90,
		corpse = "small-remnants",
		collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage_per_tick = "30kW",
		light = {intensity = 0.95, size = 120},
		picture_off =
		{
			filename = "__AfraidOfTheDark__/graphics/balloon-light-off.png",
			priority = "high",
			width = 96,
			height = 128,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, -1.35},
		},
		picture_on =
		{
			filename = filename_lamp,
			priority = "high",
			width = 96,
			height = 128,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, -1.35},
		},

		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {0.759375, -0.096875},
				green = {0.759375, -0.096875},
			},
			wire =
			{
				red = {0.30625, -0.39375},
				green = {0.30625, -0.39375},
			}
		},

		circuit_wire_max_distance = 7.5
	},
	----------------------------------------------------------------------------------
	{
		type = "lamp",
		name = "short-balloon-light",
		icon = "__AfraidOfTheDark__/graphics/short-balloon-light-icon.png",
		icon_size = 32,
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "short-balloon-light"},
		max_health = 90,
		corpse = "small-remnants",
		collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage_per_tick = "30kW",
		light = {intensity = 0.95, size = 120},
		picture_off =
		{
			filename = "__AfraidOfTheDark__/graphics/short-balloon-light-off.png",
			priority = "high",
			width = 96,
			height = 128,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, -0.0},
		},
		picture_on =
		{
			filename = filename_short_lamp,
			priority = "high",
			width = 96,
			height = 128,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0, -0.0},
		},

		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {0.759375, -0.096875},
				green = {0.759375, -0.096875},
			},
			wire =
			{
				red = {0.30625, -0.39375},
				green = {0.30625, -0.39375},
			}
		},

		circuit_wire_max_distance = 7.5
	},
	----------------------------------------------------------------------------------
	{
		type = "night-vision-equipment",
		name = "perfect-night-glasses",
		sprite =
		{
			filename = "__AfraidOfTheDark__/graphics/perfect-night-glasses.png",
			width = 64,
			height = 64,
			priority = "medium"
		},
		shape =
		{
			width = 2,
			height = 2,
			type = "full"
		},
		energy_source =
		{
			type = "electric",
			buffer_capacity = "24kJ",
			input_flow_limit = "24kW",
			usage_priority = "primary-input"
		},
		energy_input = "1kW",
		tint = {r = 0, g = 0, b = 0, a = 0},
		desaturation_params = 
		{ 
		  smoothstep_min = 0.1,
		  smoothstep_max = 0.7,
		  minimum = 0.3,
		  maximum = 1.0
		},
		light_params = 
		{ 
		  smoothstep_min = 0.1,
		  smoothstep_max = 0.7,
		  minimum = 0.666,
		  maximum = 1.0,
		},
		categories = {"armor"},
		color_lookup = {{0, "__core__/graphics/color_luts/lut-sunset.png"}}
	},

}
)

