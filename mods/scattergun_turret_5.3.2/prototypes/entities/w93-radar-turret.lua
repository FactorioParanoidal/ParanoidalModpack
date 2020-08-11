require "util"

data:extend({
{
	type = "radar",
	name = "w93-radar-turret",

	icon = "__scattergun_turret__/graphics/icons/radar-turret.png",
	icon_size = 64,
	flags = {"placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "w93-radar-turret"},
	max_health = 600,
	corpse = "medium-remnants",

	resistances =
	{
		{
			type = "acid",
			decrease = 0,
			percent = 60,
		},
		{
			type = "fire",
			decrease = 0,
			percent = 60,
		}
	},
	collision_box = {{-1.2, -1.2 }, {1.2, 1.2}},
	selection_box = {{-1.3, -1.3 }, {1.3, 1.3}},

	energy_per_sector = "10J",

	max_distance_of_sector_revealed = 0,
	max_distance_of_nearby_sector_revealed = 9,

	energy_per_nearby_scan = "10kJ",
	energy_source =

	{

		type = "electric",

		usage_priority = "secondary-input"
	},

	energy_usage = "1.2MW",
	pictures =
	{

		layers =
		{

			{
				width = 80,
				height = 60,
				priority = "very-low",

				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.0, 0.0},
				line_length = 1,
				lines_per_file = 18,
				filenames =
				{
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret-1.png",
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret-2.png",
				},
			},
			{
				width = 80,
				height = 60,
				priority = "very-low",

				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.2, 0.0},
				line_length = 1,
				lines_per_file = 18,
				draw_as_shadow = true,
				flags = { "shadow" },
				filenames =
				{
					"__scattergun_turret__/graphics/entity/modular-turret2-shadow.png",
					"__scattergun_turret__/graphics/entity/modular-turret2-shadow.png",
				},
			},
		},
	},
	vehicle_impact_sound =
	{
		filename = "__base__/sound/car-metal-impact.ogg",
		volume = 0.65
	},

	working_sound =
	{

		sound =

		{

			{
 filename = "__base__/sound/radar.ogg"
 }
		},

		apparent_volume = 2

	},
	radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.235, a = 0.275 }

},
{
	type = "radar",
	name = "w93-radar-turret2",

	icon = "__scattergun_turret__/graphics/icons/radar-turret2.png",
	icon_size = 64,
	flags = {"placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "w93-radar-turret2"},
	max_health = 600,
	corpse = "medium-remnants",

	resistances =
	{
		{
			type = "acid",
			decrease = 0,
			percent = 60,
		},
		{
			type = "fire",
			decrease = 0,
			percent = 60,
		}
	},
	collision_box = {{-1.2, -1.2 }, {1.2, 1.2}},
	selection_box = {{-1.3, -1.3 }, {1.3, 1.3}},

	energy_per_sector = "18MJ",

	max_distance_of_sector_revealed = 25,
	max_distance_of_nearby_sector_revealed = 1,

	energy_per_nearby_scan = "250kJ",
	energy_source =

	{

		type = "electric",

		usage_priority = "secondary-input"
	},

	energy_usage = "12MW",
	pictures =
	{

		layers =
		{

			{
				width = 80,
				height = 60,
				priority = "very-low",

				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.0, 0.0},
				line_length = 1,
				lines_per_file = 18,
				filenames =
				{
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret2-base.png",
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret2-base.png",
				},
			},
			{
				width = 80,
				height = 60,
				priority = "very-low",

				direction_count = 36,
				axially_symmetrical = false,
				shift = util.by_pixel(0, -12),
				line_length = 1,
				lines_per_file = 18,
				filenames =
				{
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret2-1.png",
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret2-2.png",
				},
			},
			{
				width = 80,
				height = 60,
				priority = "very-low",

				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.2, 0.0},
				line_length = 1,
				lines_per_file = 18,
				draw_as_shadow = true,
				flags = { "shadow" },
				filenames =
				{
					"__scattergun_turret__/graphics/entity/modular-turret2-shadow.png",
					"__scattergun_turret__/graphics/entity/modular-turret2-shadow.png",
				},
			},
			{
				width = 80,
				height = 60,
				priority = "very-low",

				direction_count = 36,
				axially_symmetrical = false,
				shift = util.by_pixel(20, -12),
				line_length = 1,
				lines_per_file = 18,
				draw_as_shadow = true,
				flags = { "shadow" },
				filenames =
				{
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret2-shadow-1.png",
					"__scattergun_turret__/graphics/entity/radar-turret/radar-turret2-shadow-2.png",
				},
			},
		},
	},
	vehicle_impact_sound =
	{
		filename = "__base__/sound/car-metal-impact.ogg",
		volume = 0.65
	},

	working_sound =
	{

		sound =

		{

			{
 filename = "__base__/sound/radar.ogg"
 }
		},

		apparent_volume = 2

	},
	radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.235, a = 0.275 }

}})