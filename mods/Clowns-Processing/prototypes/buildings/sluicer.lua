-- Everything related to the buildings: Items, Recipes, Entities(Assember)
circuit_connector_definitions["sluicer"] = circuit_connector_definitions.create_vector(universal_connector_template, {
	{ variation =  4, main_offset = util.by_pixel( 45.25,  65.25), shadow_offset = util.by_pixel( 45.25,  65.25), show_shadow = true },
	{ variation =  4, main_offset = util.by_pixel( 45.25,  65.25), shadow_offset = util.by_pixel( 45.25,  65.25), show_shadow = true },
	{ variation =  4, main_offset = util.by_pixel( 45.25,  65.25), shadow_offset = util.by_pixel( 45.25,  65.25), show_shadow = true },
	{ variation =  4, main_offset = util.by_pixel( 45.25,  65.25), shadow_offset = util.by_pixel( 45.25,  65.25), show_shadow = true },
  })
data:extend(
{
	{
		type = "recipe",
		name = "clowns-sluicer",
		enabled = false,
		ingredients =
		{
			{type = "item", name = "iron-plate", amount = 10},
			{type = "item", name = "pipe", amount = 20},
			{type = "item", name = "iron-gear-wheel", amount = 20},
			{type = "item", name = "stone-brick", amount = 10},
		},
		results = {
			{type = "item", name = "clowns-sluicer", amount = 1}
		},
		energy_required = 10,
	},
	{
		type = "item",
		name = "clowns-sluicer",
		icons = angelsmods.functions.add_number_icon_layer(
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sluicer.png",
					icon_size = 32, icon_mipmaps = 1
				}
			},	1, angelsmods.refining.number_tint),
		subgroup = "angels-washing-building",
		order = "c-a",
		place_result = "clowns-sluicer",
		stack_size = 20,
	},
	{
		type = "assembling-machine",
		name = "clowns-sluicer",
		icons = angelsmods.functions.add_number_icon_layer(
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sluicer.png",
					icon_size = 32,
				}
			}, 1, angelsmods.refining.number_tint),
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		collision_mask = angelsmods.functions.set_building_collision_mask("asm", { "elevated_rail" }),
		minable = {mining_time = 0.8, result = "clowns-sluicer"},
		fast_replaceable_group = "sluicer",
		next_upgrade = "clowns-sluicer-2",
		max_health = 500,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
		drawing_box_vertical_extension = 0.3,
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		module_slots = 2,
		allowed_effects = {"consumption", "speed", "pollution"},
		crafting_categories = {"sluicing"},
		crafting_speed = 1,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute= { pollution = 0.1 },
		},
		energy_usage = "75kW",
		circuit_connector = circuit_connector_definitions["sluicer"],
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		graphics_set = {
			animation =	{
				layers = {
					{
						filename = "__Clowns-Processing__/graphics/entity/sluicer.png",
						width = 160,
						height = 160,
						frame_count = 30,
						line_length = 6,
						animation_speed = 0.4,
						shift = {0,0},
					},
				},
			},
		},
		fluid_boxes =
		{
			{
				production_type = "input",
				pipe_covers = pipecoverspictures(),
				volume = 200,
				pipe_connections = {{ flow_direction ="input", direction = defines.direction.north, position = {0, -1} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures(),
				volume = 100,
				pipe_connections = {{ flow_direction ="output", direction = defines.direction.south, position = {0, 1} }}
			}
		},
		resistances =
		{
			{
			type = "fire",
			percent = 70
			}
		},
		impact_category = "metal",
		working_sound =	{
			sound =	{ filename = "__base__/sound/assembling-machine-t1-1.ogg", volume = 0.8 },
			idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
		},
	},
	{
		type = "recipe",
		name = "clowns-sluicer-2",
		enabled = false,
		ingredients =
		{
			{type = "item", name = "steel-plate", amount = 20},
			{type = "item", name = "clowns-sluicer", amount = 1},
			{type = "item", name = "iron-gear-wheel", amount = 20},
			{type = "item", name = "concrete", amount = 20},
		},
		results = {
			{type = "item", name = "clowns-sluicer-2", amount = 1}
		},
		energy_required = 10,
	},
	{
		type = "item",
		name = "clowns-sluicer-2",
		icons = angelsmods.functions.add_number_icon_layer(
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sluicer.png",
					icon_size = 32,
				}
			}, 2, angelsmods.refining.number_tint),
		subgroup = "angels-washing-building",
		order = "c-a",
		place_result = "clowns-sluicer-2",
		stack_size = 20,
	},
	{
		type = "assembling-machine",
		name = "clowns-sluicer-2",
		icons = angelsmods.functions.add_number_icon_layer(
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sluicer.png",
					icon_size = 32,
					tint = {r = 237/255, g = 191/255, b = 29/255}
				}
			}, 2, angelsmods.refining.number_tint),
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		collision_mask = angelsmods.functions.set_building_collision_mask("asm", { "elevated_rail" }),
		minable = {mining_time = 1.2, result = "clowns-sluicer-2"},
		fast_replaceable_group = "sluicer",
		max_health = 1000,
		corpse = "medium-remnants",
		dying_explosion = "medium-explosion",
		collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
		drawing_box_vertical_extension = 0.3,
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		module_slots = 3,
		allowed_effects = {"consumption", "speed", "pollution"},
		crafting_categories = {"sluicing"},
		crafting_speed = 1.75,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = {pollution = 0.1},
		},
		energy_usage = "150kW",
		circuit_connector = circuit_connector_definitions["sluicer"],
		circuit_wire_max_distance = default_circuit_wire_max_distance,
		graphics_set = {
			animation =	{
				layers = {
					{
						filename = "__Clowns-Processing__/graphics/entity/sluicer.png",
						width = 160,
						height = 160,
						frame_count = 30,
						line_length = 6,
						animation_speed = 0.4,
						shift = {0,0},
						tint = {r = 237/255, g = 191/255, b = 29/255}
					},
				},
			},
		},
		fluid_boxes =
		{
			{
				production_type = "input",
				pipe_covers = pipecoverspictures(),
				volume = 200,
				pipe_connections = {{ flow_direction ="input", direction = defines.direction.north, position = {0, -1} }}
			},
			{
				production_type = "output",
				pipe_covers = pipecoverspictures(),
				volume = 100,
				pipe_connections = {{ flow_direction ="output", direction = defines.direction.south, position = {0, 1} }}
			}
		},
		resistances =
		{
			{
				type = "fire",
				percent = 90
			}
		},
		impact_category = "metal",
		working_sound =	{
			sound =	{ filename = "__base__/sound/assembling-machine-t1-1.ogg", volume = 0.8 },
			idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
		},
	},
})
