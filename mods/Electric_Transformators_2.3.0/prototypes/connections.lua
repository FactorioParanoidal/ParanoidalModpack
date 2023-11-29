

local TRAFOS_CON_COPPERWIRE_PICTURE = {
	filename = "__base__/graphics/entity/small-electric-pole/copper-wire.png",
	priority = "extra-high-no-scale",
	width = 224, height = 46,
}


local TRAFOS_CON_GREEN_WIRE_PICTURE = {
	filename = "__base__/graphics/entity/small-electric-pole/green-wire.png",
	priority = "extra-high-no-scale",
	width = 224, height = 46,
}


local TRAFOS_CON_RED_WIRE_PICTURE = {
	filename = "__base__/graphics/entity/small-electric-pole/red-wire.png",
	priority = "extra-high-no-scale",
	width = 224, height = 46,
}


local TRAFOS_CON_WIRE_SHADOW_PICTURE = {
	filename = "__base__/graphics/entity/small-electric-pole/wire-shadow.png",
	priority = "extra-high-no-scale",
	width = 224, height = 46,
}


local TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE = {
	filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
	width = 12, height = 12,
}


local TRAFOS_POLE_CONNECTION = {
	source = {
		north = { wire = {  0.0,  -2.8}, shadow = {2.5, -0.3}  },
		east  = { wire = {  0.6,  -1.6}, shadow = {1.3,  0.2}  },
		south = { wire = {  0.0,  -0.2}, shadow = {2.5,  1.75} },
		west  = { wire = {-0.75, -1.75}, shadow = {2.0,  0.6}  },
	},
	target = {
		north = { wire = { 0.0, -0.75}, shadow = {3.0,  1.5} },
		east  = { wire = {-0.7, -2.1},  shadow = {3.0,  0.5} },
		south = { wire = { 0.0, -3.0},  shadow = {3.0, -0.2} },
		west  = { wire = { 0.6, -2.0},  shadow = {1.8,  0.2} },
	},
}

local function trafos_wireconnections(prec, dir)
	local template = { shadow = {}, wire = {} }
	local wiretypes = {"red", "green", "copper"}

	for _, type in ipairs(wiretypes) do
		template["shadow"][type] = TRAFOS_POLE_CONNECTION[prec][dir]["shadow"]
		template["wire"][type] = TRAFOS_POLE_CONNECTION[prec][dir]["wire"]
	end

	return {template}
end


data:extend({
	------------power poles---------------------------------------------------------------------------
	{
		type = "electric-pole",
		name = "trafo-connection_src_0",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		icon_size = 32,
		order = "z",
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("source", "north"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	},
	{
		type = "electric-pole",
		name = "trafo-connection_src_2",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		order = "z",
		icon_size = 32,
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("source", "east"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	},
	{
		type = "electric-pole",
		name = "trafo-connection_src_4",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		order = "z",
		icon_size = 32,
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("source", "south"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	},
	{
		type = "electric-pole",
		name = "trafo-connection_src_6",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		order = "z",
		icon_size = 32,
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("source", "west"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	},
	{
		type = "electric-pole",
		name = "trafo-connection_tar_0",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		order = "z",
		icon_size = 32,
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("target", "north"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	},
	{
		type = "electric-pole",
		name = "trafo-connection_tar_2",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		order = "z",
		icon_size = 32,
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("target", "east"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	},
	{
		type = "electric-pole",
		name = "trafo-connection_tar_4",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		order = "z",
		icon_size = 32,
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("target", "south"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	},
	{
		type = "electric-pole",
		name = "trafo-connection_tar_6",
		icon = "__base__/graphics/icons/substation.png",
		flags = TRAFOS_POLE_FLAGS,
		collision_mask = {"ghost-layer"},
		collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
		selection_box = {{-1, -1}, {1, 1}},
		drawing_box = {{-1, -1.5}, {1, 1}},
		maximum_wire_distance = 5,
		supply_area_distance = 1,
		order = "z",
		icon_size = 32,
		pictures = TRAFOS_INVISIBLE,
		connection_points = trafos_wireconnections("target", "west"),
		copper_wire_picture = TRAFOS_CON_COPPERWIRE_PICTURE,
		green_wire_picture = TRAFOS_CON_GREEN_WIRE_PICTURE,
		radius_visualisation_picture = TRAFOS_CON_RADIUS_VISUALIZATION_PICTURE,
		red_wire_picture = TRAFOS_CON_RED_WIRE_PICTURE,
		wire_shadow_picture = TRAFOS_CON_WIRE_SHADOW_PICTURE
	}
})

