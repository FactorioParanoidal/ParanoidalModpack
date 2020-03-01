--entity_helper.lua
--Templates and constants for the entity prototypes

require("copy_prototype")

--==============================================================================
-- Constants

local empty_circuit_connector = {
	led_red = { filename = graphics .. "empty.png", width = 1, height = 1 },
	led_green = { filename = graphics .. "empty.png", width = 1, height = 1 },
	led_blue = { filename = graphics .. "empty.png", width = 1, height = 1 },
	led_light = { type = "basic", intensity = 0, size = 0 }
}

empty_circuit_connector_array = {
	empty_circuit_connector, empty_circuit_connector, empty_circuit_connector,
	empty_circuit_connector, empty_circuit_connector, empty_circuit_connector,
	empty_circuit_connector, empty_circuit_connector
}

pole_circuit_connections = {
	{   -- north
		wire =   { red = {  0.5,  -2.25 }, green = {  0.6,  -2.25 } },
		shadow = { red = {  2.6,   0.0  }, green = {  2.7,   0.0  } }
	},
	{   -- northeast
		wire =   { red = {  0.35, -2.05 }, green = {  0.45, -2.0  } },
		shadow = { red = {  2.45,  0.3  }, green = {  2.55,  0.35 } }
	},
	{   -- east
		wire =   { red = {  0.0,  -1.89 }, green = {  0.0,  -1.82 } },
		shadow = { red = {  2.1,   0.46 }, green = {  2.1,   0.53 } }
	},
	{   -- southeast
		wire =   { red = { -0.35, -2.05 }, green = { -0.45, -2.0  } },
		shadow = { red = {  1.75,  0.3  }, green = {  1.65,  0.35 } }
	},
	{   -- south
		wire =   { red = { -0.5,  -2.25 }, green = { -0.6,  -2.25 } },
		shadow = { red = {  1.6,   0.0  }, green = {  1.5,   0.0  } }
	},
	{   -- southwest
		wire =   { red = { -0.35, -2.5  }, green = { -0.45, -2.55  } },
		shadow = { red = {  1.75, -0.15 }, green = {  1.65, -0.15 } }
	},
	{   -- west
		wire =   { red = {  0.0,  -2.61 }, green = {  0.0,  -2.68 } },
		shadow = { red = {  2.1,  -0.27 }, green = {  2.1,  -0.34 } }
	},
	{   -- northwest
		wire =   { red = {  0.35, -2.5  }, green = {  0.45, -2.55 } },
		shadow = { red = {  2.45, -0.15 }, green = {  2.55, -0.15 } }
	}
}

pole_circuit_connections_straight = {
	pole_circuit_connections[1], pole_circuit_connections[3], 
	pole_circuit_connections[5], pole_circuit_connections[7]
}

pole_circuit_connections_diagonal = {
	pole_circuit_connections[2], pole_circuit_connections[4], 
	pole_circuit_connections[6], pole_circuit_connections[8]
}

dummy_energy_source = {
	type = "electric",
	buffer_capacity = "0J",
	usage_priority = "secondary-output",
	render_no_power_icon = false,
	render_no_network_icon = false
}

--==============================================================================
-- Templates

function make_pole_placer(name, icon)
	return {
		type = "rail-signal",
		name = name,
		icon = graphics .. icon,
		icon_size = 32,
		animation = {
			filename = graphics .. "entities/pole-placer.png",
			width = 160, height = 160,
			frame_count = 1, direction_count = 8,
			shift = util.by_pixel(0, -55)
		},
		flags = {"placeable-neutral", "player-creation", "building-direction-8-way", 
		         "filter-directions", "fast-replaceable-no-build-while-moving" },
		collision_mask = {"object-layer"},
		fast_replaceable_group = "rail-signal",
		max_health = 100,
		corpse = "small-remnants",
		collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		drawing_box = {{-2.5, -6.0}, {2.5, 1.0}},
		circuit_wire_max_distance = config.pole_max_wire_distance,
		circuit_wire_connection_points = pole_circuit_connections,
		circuit_connector_sprites = empty_circuit_connector_array
	}
end	

function make_pole_base(type, name, placer, icon, circuit_connectors)
	return {
		type = type,
		name = name,
		icon = graphics .. icon,
		icon_size = 32,
		flags = { "player-creation" },
		fast_replaceable_group = "rail-signal",
		max_health = 100,
		corpse = "small-remnants",
		minable = { hardness = 0.2, mining_time = 0.5, result = placer },
		placeable_by = { item = placer, count = 1 },
		collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		collision_mask = {"object-layer"},
		circuit_wire_max_distance = config.pole_max_wire_distance,
		circuit_wire_connection_points = circuit_connectors
	}
end

pole_child_template = {
	type = "electric-energy-interface",
	icon = graphics .. "items/pole-wire.png",
	icon_size = 32,
	flags = { "placeable-off-grid", "not-deconstructable" },
	collision_mask = {},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selection_priority = 25,
}

function make_particle(name, picture)
	return {
		type = "particle",
		name = name,
		flags = { "not-on-map", "placeable-off-grid" },
		pictures = {{
			filename = graphics .. picture,
			width = 32, height = 32, frame_count = 1
		}},
		life_time = 180
	}
end
