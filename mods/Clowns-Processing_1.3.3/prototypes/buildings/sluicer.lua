data:extend(
{
	{
		type = "recipe",
		name = "sluicer",
		enabled = false,
		ingredients =
		{
			{"iron-plate", 10},
			{"pipe", 20},
			{"iron-gear-wheel", 20},
			{"stone-brick", 10},
		},
		result = "sluicer",
		energy_required = 10,
	},

	{
		type = "item",
		name = "sluicer",
		icon = "__Clowns-Processing__/graphics/icons/sluicer.png",
		icon_size = 32,
		subgroup = "washing-building",
		order = "c-a",
		place_result = "sluicer",
		stack_size = 20,
	},

	{
		type = "assembling-machine",
		name = "sluicer",
		fast_replaceable_group = "sluicer",
		icon = "__Clowns-Processing__/graphics/icons/sluicer.png",
		icon_size = 32,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {hardness = 0.8, mining_time = 0.8, result = "sluicer"},
		max_health = 500,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		resistances =
		{
			{
			type = "fire",
			percent = 70
			}
		},
		collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		animation = 
		{
			filename = "__Clowns-Processing__/graphics/entity/sluicer.png",
			priority = "high",
			width = 160,
			height = 160,
			frame_count = 30,
			line_length = 6,
			animation_speed = 1,
			shift = {0,0}
		},
		crafting_categories = {"sluicing"},
		crafting_speed = 1,
		module_specification =
		{
			module_slots = 2
		},
		allowed_effects = {"consumption", "speed", "pollution"},
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			emissions = 0.1
		},
		energy_usage = "75kW",
		ingredient_count = 2,
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		working_sound =
		{
			sound = 
			{
				{
				  filename = "__base__/sound/assembling-machine-t1-1.ogg",
				  volume = 0.8
				},
				{
				  filename = "__base__/sound/assembling-machine-t1-2.ogg",
				  volume = 0.8
				},
			},
		idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
		apparent_volume = 1.5,
		},
		fluid_boxes =
		{
			{
				production_type = "input",
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = {0, -2} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures(),
				base_level = 1,
				pipe_connections = {{ position = {0, 2} }}
			}
		}
	}
}
)