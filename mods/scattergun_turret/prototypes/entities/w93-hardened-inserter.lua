local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require("__base__.prototypes.entity.hit-effects")

data:extend({
{
	type = "inserter",

	name = "w93-hardened-inserter",

	icon = "__scattergun_turret__/graphics/icons/hardened-inserter.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {"placeable-neutral", "placeable-player", "player-creation"},
	stack = false,
	minable =

	{
		hardness = 0.2,

		mining_time = 0.5,

		result = "w93-hardened-inserter"

	},
	max_health = 450,

	corpse = "small-remnants",
	resistances =
	{
		{
			type = "physical",
			decrease = 5,
			percent = 15
		},
		{
			type = "explosion",
			decrease = 80,
			percent = 50,
		},
		{
			type = "acid",
			decrease = 0,
			percent = 35,
		},
		{
			type = "fire",
			decrease = 0,
			percent = 90,
		}
	},
	collision_box = {{-0.15, -0.15}, {0.15, 0.15}},

	selection_box = {{-0.4, -0.35}, {0.4, 0.45}},

	damaged_trigger_effect = hit_effects.entity(),
	pickup_position = {0, -1},
	insert_position = {0, 2.2},
	energy_per_movement = "8kJ",
	energy_per_rotation = "8kJ",
	energy_source =

	{
		type = "electric",
		usage_priority = "secondary-input",
		drain = "400W"
	},

	extension_speed = 0.0457,

	rotation_speed = 0.02,
	filter_count = 5,
	icon_draw_specification = {scale = 0.5},
	impact_category = "metal",
	hand_size = 1.5,
	open_sound = sounds.inserter_open,
	close_sound = sounds.inserter_close,
	working_sound = sounds.inserter_basic,
	hand_base_picture =

	{
		filename = "__scattergun_turret__/graphics/entity/hardened-inserter/hr-hardened-inserter-hand-base.png",

		priority = "extra-high",

		width = 32,
		height = 136,
		scale = 0.25

	},
	hand_closed_picture =
	{
		filename = "__scattergun_turret__/graphics/entity/hardened-inserter/hr-hardened-inserter-hand-closed.png",

		priority = "extra-high",

		width = 72,
		height = 164,
		scale = 0.25
	},
	hand_open_picture =
	{
		filename = "__scattergun_turret__/graphics/entity/hardened-inserter/hr-hardened-inserter-hand-open.png",
		priority = "extra-high",
		width = 72,
		height = 164,
		scale = 0.25
	},
	hand_base_shadow =

	{

		filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",

		priority = "extra-high",
		width = 32,

		height = 132,
		scale = 0.25
	},

	hand_closed_shadow =

	{

		filename = "__base__/graphics/entity/bulk-inserter/bulk-inserter-hand-closed-shadow.png",
		priority = "extra-high",
		width = 100,

		height = 164,
		scale = 0.25
	},

	hand_open_shadow =

	{

		filename = "__base__/graphics/entity/bulk-inserter/bulk-inserter-hand-open-shadow.png",
		priority = "extra-high",
		width = 130,

		height = 164,

		scale = 0.25

	},

	platform_picture =
	{
		sheet =

		{
			filename = "__scattergun_turret__/graphics/entity/hardened-inserter/hr-hardened-inserter-platform.png",

			priority = "extra-high",
 
			width = 105,
			height = 79,

			shift = util.by_pixel(1.5, 7.5-1),
			scale = 0.5
		}

	},

	circuit_connector = circuit_connector_definitions["inserter"],
	circuit_wire_max_distance = inserter_circuit_wire_max_distance,
	default_stack_control_input_signal = inserter_default_stack_control_input_signal
}})