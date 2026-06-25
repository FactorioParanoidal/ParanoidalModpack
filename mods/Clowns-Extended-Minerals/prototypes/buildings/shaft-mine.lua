data:extend(
{
	{
		type = "recipe",
		name = "shaft-mine",
		enabled = true,
		ingredients =
		{
			{"electric-mining-drill", 5},
			{"steel-plate", 25},
			{"electronic-circuit", 20},
			{"stone-brick", 100},
		},
		result = "shaft-mine",
		energy_required = 10,
	},

	{
		type = "item",
		name = "shaft-mine",
		icon = "__Clowns-Extended-Minerals__/graphics/icons/shaft-mine.png",
		icon_size = 32,
		subgroup = "extraction-machine",
		order = "a[items]-m[shaft-mine]",
		place_result = "shaft-mine",
		stack_size = 20,
	},

	{
		type = "assembling-machine",
		name = "shaft-mine",
		fast_replaceable_group = "shaft-mine",
		icon = "__Clowns-Extended-Minerals__/graphics/icons/shaft-mine.png",
		icon_size = 32,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 1.2, result = "shaft-mine"},
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
		collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
		selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
		animation = 
		{
			filename = "__Clowns-Extended-Minerals__/graphics/entity/shaft-mine.png",
			priority = "high",
			width = 288,
			height = 288,
			frame_count = 1,
			line_length = 1,
			animation_speed = 0.8,
			shift = {1,-0.5}
		},
		crafting_categories = {"shaft-mining", "angels-ore-sorting"},
		crafting_speed = 1, --* settings.startup["shaft-mine-crafting-speed"].value,
		module_specification =
		{
			module_slots = 3
		},
		allowed_effects = {"consumption", "speed", "pollution"},
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			emissions = 0.1
		},
		energy_usage = "325kW", --1.5MW for 4
		ingredient_count = 1, --?????
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
		}
	}
}
)