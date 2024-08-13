local Setting = require "scripts.setting"
local util = require "__core__.lualib.util"

local debug_core = false

local REACTOR_GLOW_COLOR = {r = 0, g = 1, b = 0.94}
local BREEDER_GLOW_COLOR = {r = 0.94, g = 1, b = 0}

local REACTOR_LIGHT = {intensity = 0.9, size = 3, color = REACTOR_GLOW_COLOR}
local BREEDER_LIGHT = {intensity = 0.9, size = 3, color = BREEDER_GLOW_COLOR}

if Setting.startup("disable-reactor-light") then
	REACTOR_LIGHT = nil
	BREEDER_LIGHT = nil
end

local REACTOR_DEFAULT_PICTURE_ATTRS = {
	width = 288, height = 348,
	scale = 0.3542,
	shift = util.by_pixel(1,-12),
}

local REACTOR_LIGHT_FLICKER_ATTRS = {
        color = {0,0,0},
        minimum_intensity = 0.7,
        maximum_intensity = 0.95,
}

local REACTOR_RESISTANCES_ATTRS = {
	{ type = "physical",  percent = 80,  },
	{ type = "impact",    percent = 80,  },
	{ type = "fire",      percent = 80,  },
	{ type = "acid",      percent = 80,  },
	{ type = "poison",    percent = 80,  },
	{ type = "explosion", percent = 70,  },
	{ type = "laser",     percent = 70,  },
}

-- https://wiki.factorio.com/Types/EntityPrototypeFlags
local REACTOR_TEMPLATE_ENTITY_FLAGS = {
	"not-rotatable",
	"placeable-player",
--	"placeable-neutral",
--	"placeable-enemy",
	"placeable-off-grid",
	"player-creation",
--	"building-direction-8-way",
--	"filter-directions",
--	"fast-replaceable-no-build-while-moving",
--	"breaths-air",
--	"not-repairable",
	"not-on-map",
	"not-blueprintable",
--	"not-deconstructable", -- added where needed
	"hidden",
	"hide-alt-info",
--	"fast-replaceable-no-cross-type-while-moving",
--	"no-gap-fill-while-building",
	"not-flammable",
--	"no-automated-item-removal",
--	"no-automated-item-insertion",
	"no-copy-paste",
--	"not-selectable-in-game",
	"not-upgradable",
	"not-in-kill-statistics",
}

local REACTOR_ENTITY_FLAGS = {
--	"not-rotatable", -- added where needed
	"placeable-player",
--	"placeable-neutral",
--	"placeable-enemy",
--	"placeable-off-grid",
	"player-creation",
--	"building-direction-8-way",
--	"filter-directions",
--	"fast-replaceable-no-build-while-moving",
--	"breaths-air",
--	"not-repairable",
--	"not-on-map",
--	"not-blueprintable",
--	"not-deconstructable",
--	"hidden",
--	"hide-alt-info", -- added where needed
--	"fast-replaceable-no-cross-type-while-moving",
--	"no-gap-fill-while-building",
--	"not-flammable",
--	"no-automated-item-removal",
--	"no-automated-item-insertion",
--	"no-copy-paste",
--	"not-selectable-in-game",
--	"not-upgradable",
--	"not-in-kill-statistics",
}

local REACTOR_RUIN_ENTITY_FLAGS = {
	"not-rotatable",
--	"placeable-player",
	"placeable-neutral",
--	"placeable-enemy",
--	"placeable-off-grid",
	"player-creation",
--	"building-direction-8-way",
--	"filter-directions",
--	"fast-replaceable-no-build-while-moving",
--	"breaths-air",
	"not-repairable",
--	"not-on-map",
	"not-blueprintable",
	"not-deconstructable",
--	"hidden",
	"hide-alt-info",
--	"fast-replaceable-no-cross-type-while-moving",
--	"no-gap-fill-while-building",
	"not-flammable",
--	"no-automated-item-removal",
--	"no-automated-item-insertion",
	"no-copy-paste",
--	"not-selectable-in-game",
	"not-upgradable",
	"not-in-kill-statistics",
}

local REACTOR_INTERNAL_ENTITY_FLAGS = {
	"not-rotatable",
	"placeable-player",
--	"placeable-neutral",
--	"placeable-enemy",
--	"placeable-off-grid",
	"player-creation",
--	"building-direction-8-way",
--	"filter-directions",
--	"fast-replaceable-no-build-while-moving",
--	"breaths-air",
	"not-repairable",
	"not-on-map",
--	"not-blueprintable", --added where required
	"not-deconstructable",
	"hidden",
--	"hide-alt-info", --added where required
--	"fast-replaceable-no-cross-type-while-moving",
--	"no-gap-fill-while-building",
	"not-flammable",
--	"no-automated-item-removal",
--	"no-automated-item-insertion",
	"no-copy-paste",
--	"not-selectable-in-game", --added where required
	"not-upgradable",
	"not-in-kill-statistics",
}

local COOLING_TOWER_SMOKE_FLAGS = {
--	"not-rotatable",
--	"placeable-player",
	"placeable-neutral",
--	"placeable-enemy",
	"placeable-off-grid",
--	"player-creation",
--	"building-direction-8-way",
--	"filter-directions",
--	"fast-replaceable-no-build-while-moving",
--	"breaths-air",
	"not-repairable",
	"not-on-map",
	"not-blueprintable",
	"not-deconstructable",
	"hidden",
	"hide-alt-info",
--	"fast-replaceable-no-cross-type-while-moving",
--	"no-gap-fill-while-building",
	"not-flammable",
--	"no-automated-item-removal",
--	"no-automated-item-insertion",
	"no-copy-paste",
	"not-selectable-in-game",
	"not-upgradable",
	"not-in-kill-statistics",
}

local empty_sprite = {
	filename = "__core__/graphics/empty.png",
	flags = { "always-compressed" },
	priority = "extra-high",
	frame_count = 1,
	width = 1,
	height = 1,
}

local interface_led = {
	filename = "__base__/graphics/entity/combinator/activity-leds/decider-combinator-LED-S.png",
	width = 8,
	height = 8,
	frame_count = 1,
	--shift = {-0.28125, -0.34375}
	shift = {-0.15, -0.24},
	scale = 0.3,
}

local red_point = {x=6.9,y=10.8}
local green_point = {x=-6.1,y=10.8}

interface_connection = {
	shadow = {
		red =   util.by_pixel(red_point.x+16, red_point.y+12.5),--{0.796875, 0.5},
		green = util.by_pixel(green_point.x+16, green_point.y+12.5)--{0.203125, 0.5},
	},
	wire = {
		red =   util.by_pixel(red_point.x, red_point.y),--{0.296875, 0.0625},
		green = util.by_pixel(green_point.x, green_point.y)--{-0.296875, 0.0625},
	}
}

-- default reactor (running reactor)
reactor_template = {
	type = "reactor",
	name = "realistic-reactor",
	icon = "__UnrealisticReactors__/graphics/icons/nuclear-reactor.png",
	icon_size = 32,
	order = "f[nuclear-energy]-a[reactor]",
	flags = {"not-deconstructable", unpack(REACTOR_TEMPLATE_ENTITY_FLAGS)},
	max_health = 500,
	corpse = "big-remnants",
	consumption = "40MW",
	neighbour_bonus = 0,
	selectable_in_game = false,
	vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
	meltdown_action = nil,
	collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
	--collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
	--selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
	--collision_box = {{-1.4, -1.4}, {1.4, 0.7}},
	--selection_box = {{-1.5, -3}, {1.5, 0.5}},
	--selection_box = {{-1.4, -3}, {1.4, 1.4}},
	working_light_picture = empty_sprite,
	energy_source = {
		type = "burner",
		fuel_categories = {},
		effectivity = 1,
		fuel_inventory_size = 1,
		burnt_inventory_size = 1,
		light_flicker = {
			minimum_intensity = 0,
			maximum_intensity = 0,
			minimum_light_size = 0,
			light_intensity_to_size_coefficient = 0,
		}
	},
	working_sound = {
		sound = {filename = "__UnrealisticReactors__/sound/reactor-active.ogg", volume = 0.6},
		idle_sound = {filename = "__base__/sound/idle1.ogg", volume = 0.6},
		apparent_volume = 1.5,
	},
	heat_buffer = {
		max_temperature = 1005,
		specific_heat = "5MJ",
		max_transfer = "10GW",
		minimum_glow_temperature = 350,
		connections = {
			{ position = { 1.0, -1.5}, direction = defines.direction.north },
			{ position = { 0.0, -1.5}, direction = defines.direction.north },
			{ position = {-1.0, -1.5}, direction = defines.direction.north },
			{ position = { 1.3, -1.0}, direction = defines.direction.east  },
			{ position = { 1.3,  0.0}, direction = defines.direction.east  },
			{ position = {-1.3,  0.0}, direction = defines.direction.west  },
			{ position = {-1.3, -1.0}, direction = defines.direction.west  },
		}
	},
-- 	connection_patches_connected = {
-- 		sheet = {
-- 			filename = "__UnrealisticReactors__/graphics/entity/reactor-connect-patches-empty.png",
-- 			width = 32,
-- 			height = 32,
-- 			variation_count = 12
-- 		}
-- 	},
-- 	connection_patches_disconnected = {
-- 		sheet = {
-- 			filename = "__UnrealisticReactors__/graphics/entity/reactor-connect-patches-empty.png",
-- 			width = 32,
-- 			height = 32,
-- 			variation_count = 12,
-- 			y = 32
-- 		}
-- 	},
--	pipe_covers = pipecoverspictures(),
}


-- display dummy for normal reactor
reactor_normal = table.deepcopy(reactor_template)
reactor_normal.name = "realistic-reactor-normal"
reactor_normal.flags = {"not-rotatable", "hide-alt-info", unpack(REACTOR_ENTITY_FLAGS)}
reactor_normal.placeable_by = {item="realistic-reactor", count = 1}
reactor_normal.resistances = REACTOR_RESISTANCES_ATTRS
reactor_normal.minable = {mining_time = 1.5, result = "realistic-reactor"}
reactor_normal.consumption = "0.00001W"
reactor_normal.collision_box = {{-1.3, -1.3}, {1.3, 1.4}}
--reactor_normal.selection_box = {{-1.4, -1.9}, {1.4, 0.5}}
reactor_normal.selection_box = {{-1.4, -1.8}, {1.4, 1.35}} --eccs would not be selectable, but interface would.
reactor_normal.selectable_in_game = true
reactor_normal.light = REACTOR_LIGHT
reactor_normal.energy_source.light_flicker = REACTOR_LIGHT_FLICKER_ATTRS

reactor_normal.picture = { layers = {
	{
		filename = "__UnrealisticReactors__/graphics/entity/reactor.png",
		width = REACTOR_DEFAULT_PICTURE_ATTRS.width,
		height = REACTOR_DEFAULT_PICTURE_ATTRS.height,
		scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
		shift = REACTOR_DEFAULT_PICTURE_ATTRS.shift,
	},
	{
		filename = "__UnrealisticReactors__/graphics/entity/reactor-shadow.png",
		draw_as_shadow = true,
		flags = {"shadow"},
		width = 510,
		height = 360,
		scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
		shift = util.by_pixel(40,-10),
	},
}}

reactor_normal.working_light_picture = {
	filename = "__UnrealisticReactors__/graphics/entity/reactor-lights.png",
	blend_mode = "additive",
	draw_as_glow = true,
	flags = {"light"},
	tint = REACTOR_GLOW_COLOR,
	width = REACTOR_DEFAULT_PICTURE_ATTRS.width,
	height = REACTOR_DEFAULT_PICTURE_ATTRS.height,
	scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
	shift = REACTOR_DEFAULT_PICTURE_ATTRS.shift,
}

reactor_normal.lower_layer_picture = {
	filename = "__UnrealisticReactors__/graphics/entity/reactor-pipes.png",
	width = REACTOR_DEFAULT_PICTURE_ATTRS.width,
	height = REACTOR_DEFAULT_PICTURE_ATTRS.height,
	scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
	shift = REACTOR_DEFAULT_PICTURE_ATTRS.shift,
}

reactor_normal.heat_lower_layer_picture = apply_heat_pipe_glow{
	filename = "__UnrealisticReactors__/graphics/entity/reactor-pipes-heated.png",
	priority = "extra-high",
	width = REACTOR_DEFAULT_PICTURE_ATTRS.width,
	height = REACTOR_DEFAULT_PICTURE_ATTRS.height,
	scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
	shift = REACTOR_DEFAULT_PICTURE_ATTRS.shift,
}

reactor_normal.heat_buffer.specific_heat = "1kJ"
reactor_normal.heat_buffer.max_transfer = "0.00001W"
reactor_normal.heat_buffer.heat_picture = apply_heat_pipe_glow{
	filename = "__UnrealisticReactors__/graphics/entity/reactor-heated.png",
	priority = "extra-high",
	blend_mode = "additive-soft",
--	tint = {r = 255, g = 200, b = 0}, -- works, white by default
	width = REACTOR_DEFAULT_PICTURE_ATTRS.width,
	height = REACTOR_DEFAULT_PICTURE_ATTRS.height,
	scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
	shift = REACTOR_DEFAULT_PICTURE_ATTRS.shift,
}

 -- display dummy for breeder reactor
reactor_breeder = table.deepcopy(reactor_normal)
reactor_breeder.name = "realistic-reactor-breeder"
reactor_breeder.icon = "__UnrealisticReactors__/graphics/icons/breeder-reactor.png"
reactor_breeder.minable = {mining_time = 1.5, result = "breeder-reactor"}
reactor_breeder.placeable_by = {item="breeder-reactor", count = 1}
reactor_breeder.resistances = REACTOR_RESISTANCES_ATTRS
reactor_breeder.picture.layers[1].filename = "__UnrealisticReactors__/graphics/entity/breeder.png"
reactor_breeder.heat_buffer.heat_picture = apply_heat_pipe_glow{
	filename = "__UnrealisticReactors__/graphics/entity/breeder-heated.png",
	priority = "extra-high",
	blend_mode = "additive-soft",
--	tint = {r = 255, g = 200, b = 0}, -- works, white by default
	width = REACTOR_DEFAULT_PICTURE_ATTRS.width,
	height = REACTOR_DEFAULT_PICTURE_ATTRS.height,
	scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
	shift = REACTOR_DEFAULT_PICTURE_ATTRS.shift,
}

reactor_breeder.working_light_picture.filename = "__UnrealisticReactors__/graphics/entity/breeder-lights.png"
reactor_breeder.working_light_picture.tint = BREEDER_GLOW_COLOR
reactor_breeder.light = BREEDER_LIGHT
reactor_breeder.energy_source.light_flicker = REACTOR_LIGHT_FLICKER_ATTRS

reactor_default = table.deepcopy(reactor_template)
reactor_default.flags = REACTOR_TEMPLATE_ENTITY_FLAGS  -- deconstructable required for explosion-mode ~= meltdown
reactor_default.collision_mask = {}
reactor_default.resistances = {}


table.insert(reactor_template.flags, "no-automated-item-insertion")
table.insert(reactor_template.flags, "no-automated-item-removal")

-- Nuclear reactor x, running phase
for i=1, 250 do

	local temp_reactor = table.deepcopy(reactor_template)
	temp_reactor.name = "realistic-reactor-"..i
	temp_reactor.collision_mask = {"item-layer"}
	temp_reactor.consumption = i.."MW"

	if debug_core then
		temp_reactor.selection_box = {{-1.4, -2.5}, {1.4, 1.35}}
		temp_reactor.selectable_in_game = true
	end

	data:extend({temp_reactor})

end
 
-- Circuit interface entity for nuclear reactor
reactor_interface = {
	type = "constant-combinator",
	name = "realistic-reactor-interface",
	selection_priority = 255,
	icon = reactor_template.icon,
	icon_size = reactor_template.icon_size,
	order = "f[nuclear-energy]-a[reactor]",
	flags = {"hide-alt-info", unpack(REACTOR_INTERNAL_ENTITY_FLAGS)},
	max_health = reactor_template.max_health,
	collision_box = {{-1.4, -0.25}, {1.4, 0.4}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	item_slot_count = 14,
	sprites = {
		north = empty_sprite,
		east  = empty_sprite,
		south = empty_sprite,
		west  = empty_sprite,
	},
	activity_led_sprites = {
		north = util.draw_as_glow(interface_led),
		east  = util.draw_as_glow(interface_led),
		south = util.draw_as_glow(interface_led),
		west  = util.draw_as_glow(interface_led),
	},
	activity_led_light = {
		intensity = 0.4,
		size = 0.3,
		color = {r = 0.02, g = 0.05, b = 0.55}
	},
	activity_led_light_offsets = {
		interface_led.shift,
		interface_led.shift,
		interface_led.shift,
		interface_led.shift,
	},
	circuit_wire_connection_points = {
		interface_connection,
		interface_connection,
		interface_connection,
		interface_connection,
	},
	circuit_wire_max_distance = 7.5,
	order = "z",
}

local breeder_interface = table.deepcopy(reactor_interface)
breeder_interface.name = "realistic-breeder-interface"


-- ECCS entity for nuclear reactor
reactor_eccs = {
	type = "storage-tank",
	name = "realistic-reactor-eccs",
	collision_mask = {"item-layer"},
	icon = reactor_template.icon,
	icon_size = reactor_template.icon_size,
	order = "f[nuclear-energy]-a[reactor]",
	flags = {"not-blueprintable", unpack(REACTOR_INTERNAL_ENTITY_FLAGS)},
	max_health = reactor_template.max_health,
	collision_mask = {"ghost-layer"},
	collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
	selection_box = {{-1.4,0.5},{1.4,1.7}},
	--drawing_box = {{-1.4,-1.4},{-1,-1}}, --doesnt affect alt-info-overlay
	fluid_box = {
		base_area = 50,
		pipe_covers = pipecoverspictures(),
		pipe_connections = {
			--{position = {-2, -1}},
			{position = {-2, 1}},
			--{position = {-1, -2}},
			{position = {-1, 2}},
			--{position = {1, -2}},
			{position = {1, 2}},
			--{position = {2, -1}},
			{position = {2, 1}},
		}
	},
	window_bounding_box = {{-0.1,-0.1}, {0.1,0.1}},
	pictures = {
		picture = {
			north = empty_sprite,
			east  = empty_sprite,
			south = empty_sprite,
			west  = empty_sprite,
		},
		fluid_background = empty_sprite,
		window_background = empty_sprite,
		flow_sprite = empty_sprite,
		gas_flow = empty_sprite,
	},
	flow_length_in_ticks = 360,
	circuit_wire_max_distance = 0,
	order = "z",
}

-- Power draining entity for normal reactor
reactor_power_normal = {
	type = "electric-energy-interface",
	name = "realistic-reactor-power-normal",
	icon = reactor_normal.icon,
	icon_size = reactor_normal.icon_size,
	flags = {"not-blueprintable", "hide-alt-info", unpack(REACTOR_INTERNAL_ENTITY_FLAGS)},
	order = "f[nuclear-energy]-a[reactor]",
	max_health = 150,
	collision_mask = {"ghost-layer"},
	collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
	selection_box = {{-1.4, -1.4}, {1.4, 1.4}},
	drawing_box = {{-0.5, -2.5}, {0.5, 0.3}},
	selectable_in_game = false,
	energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		input_flow_limit= "17MW",
		buffer_capacity = "17MJ"
	},
	energy_production = "0kW",
	energy_usage = "0kW",
}

-- Power draining entity 2 for nuclear reactor
reactor_power_breeder = table.deepcopy(reactor_power_normal)
reactor_power_breeder.name = "realistic-reactor-power-breeder"
reactor_power_breeder.icon = reactor_breeder.icon
reactor_power_breeder.icon_size = reactor_breeder.icon_size



-- Ruins
reactor_ruin = {
	type = "simple-entity-with-owner",
	name = "reactor-ruin",
	icon = "__UnrealisticReactors__/graphics/icons/nuclear-reactor.png",
	icon_size = 32,
	max_health = 1000,
	order = "f[nuclear-energy]-a[reactor]",
	flags = REACTOR_RUIN_ENTITY_FLAGS,
	placeable_by = { item="reactor-sarcophagus", count = 1},
	collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
-- 	collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
-- 	collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
	selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
	selection_priority = 0,
	minable = {hardness = 999999, mining_time = 999999},
	fast_replaceable_group = "reactor-ruins",
	pictures = {  layers = {
		{
			filename = "__UnrealisticReactors__/graphics/entity/reactor-ruin.png",
			width = 174,
			height = 160,
			shift = {1.2185, -0.59375},
			frame_count=1
		},
		{
			filename = "__UnrealisticReactors__/graphics/entity/reactor-shadow.png",
			draw_as_shadow = true,
			flags = {"shadow"},
			width = 510,
			height = 360,
			scale = REACTOR_DEFAULT_PICTURE_ATTRS.scale,
			shift = util.by_pixel(40,-10),
		},
	}}
}


breeder_ruin = table.deepcopy(reactor_ruin)
breeder_ruin.name = "breeder-ruin"
breeder_ruin.icon = "__UnrealisticReactors__/graphics/icons/breeder-reactor.png"
breeder_ruin.pictures.layers[1].filename = "__UnrealisticReactors__/graphics/entity/breeder-ruin.png"

-- Sarcophagus
sarcophagus = table.deepcopy(reactor_ruin)
sarcophagus.name = "reactor-sarcophagus"
sarcophagus.icon = "__UnrealisticReactors__/graphics/icons/sarcophagus2.png"
sarcophagus.flags = {"player-creation", "not-blueprintable", "not-repairable"}
sarcophagus.minable = {mining_time = 1}
sarcophagus.collision_box = {{-1.5, -1.5}, {1.5, 1.5}}
-- sarcophagus.collision_box = {{-2.2, -2.1}, {2.2, 2.1}}
sarcophagus.selection_box = {{-2.3, -2.4}, {2.1, 2.0}}
sarcophagus.pictures = {
	layers = {
		{
			filename = "__UnrealisticReactors__/graphics/entity/sarcophagus2.png",
			width = 1024,
			height = 768,
			shift = {-0.1, -0.4},
			frame_count=1,
			scale=0.19
		},
		{
			filename = "__UnrealisticReactors__/graphics/entity/sarcophagus2-shadow.png",
			width = 1024,
			height = 768,
			shift = {0.8, -0.07},
			frame_count=1,
			scale=0.18,
			draw_as_shadow = true
		},
	}
}



-- Cooling tower
cooling_tower = {
	type = "furnace",
	name = "rr-cooling-tower",
	icon = "__UnrealisticReactors__/graphics/icons/cooling-tower.png",
	icon_size = 32,
	flags = {"hide-alt-info", unpack(REACTOR_ENTITY_FLAGS)},
	minable = {hardness = 0.2, mining_time = 0.5, result = "rr-cooling-tower"},
	max_health = 500,
	corpse = "medium-remnants",
	resistances = {
		{
			type = "fire",
			percent = 70
		}
	},
	collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
	selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	drawing_box = {{-1.5, -3}, {1.5, 1.5}},
	fluid_boxes = {
		{
			production_type = "input",
			base_area = 25,
			base_level = -1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {
				{position = {-2, -1},type = "input"},
				{position = {-2, 1},type = "input"},
				{position = {-1, -2},type = "input"},
				{position = {-1, 2},type = "input"}
			}
		},
		{
			production_type = "output",
			base_area = 25,
			base_level = 1,
			pipe_covers = pipecoverspictures(),
			pipe_connections = {
				{position = {1, -2},type = "output"},
				{position = {1, 2},type = "output"},
				{position = {2, -1},type = "output"},
				{position = {2, 1},type = "output"}
			}
		}
	},
	source_inventory_size = 0,
	result_inventory_size = 0,
	crafting_categories = {"water-cooling"},
	energy_usage = "120kW",
	crafting_speed = 1,
	energy_source = {
		type = "electric",
		usage_priority = "primary-input",
		emissions = 0,
	},
	animation = {
		layers = {
			{
				filename = "__UnrealisticReactors__/graphics/entity/cooling-tower-shadow.png",
				width = 430, height = 310,
				shift = util.by_pixel(52, -21),
				scale = 0.5,
				draw_as_shadow = true,
				flags = {"shadow"},
			},
			{
				filename = "__UnrealisticReactors__/graphics/entity/cooling-tower.png",
				width = 308, height = 310,
				shift = {0.695, -0.66},
				scale = 0.505,
			},
			{
				filename = "__UnrealisticReactors__/graphics/entity/cooling-tower-light.png",
				scale = 0.505,
				width = 308, height = 310,
				shift = {0.695, -0.66},
				tint = {r = 1, g = 0, b = 0},
				draw_as_light = true,
				priority = "extra-high",
				flags = {"light"},
			},
			{
				filename = "__UnrealisticReactors__/graphics/entity/cooling-tower-glow.png",
				scale = 0.505,
				width = 308, height = 310,
				shift = {0.695, -0.66},
				tint = {r = 1, g = 0, b = 0},
				draw_as_light = true,
				priority = "extra-high",
				flags = {"light"},
			},
		}
	}
}

-- Steam creator for cooling tower
cooling_tower_smoke = {
	type = "furnace",
	name = "rr-cooling-tower-steam",
	selectable_in_game = false,
	icon = cooling_tower.icon,
	icon_size = 32,
	order = "f[nuclear-energy]-a[reactor]",
	flags = COOLING_TOWER_SMOKE_FLAGS,
	max_health = cooling_tower.max_health,
	collision_mask = {"ghost-layer"},
	collision_box = {{-0.5,-0.5},{0.5,0.5}},
	selection_box = {{-0.5,-0.5},{0.5,0.5}},
	fluid_boxes = {
		{
			production_type = "input",
			base_area = 0.1,
			pipe_connections = { }
		},
		{
			production_type = "output",
			base_area = 0.1,
			pipe_connections = { }
		}
	},
	source_inventory_size = 0,
	result_inventory_size = 0,
	crafting_categories = {"steaming"},
	energy_usage = "1W",
	crafting_speed = 1,
	energy_source = {
		type = "burner",
		effectivity = 1,
		fuel_inventory_size = 1,
		emissions = 0,
		light_flicker = {
			minimum_intensity = 0,
			maximum_intensity = 0,
		},
		smoke = {
			{
				name = "cooling-tower-smoke-type",
				type = "trivial-smoke",
				deviation = {0.05, 0.05},
				frequency = 10,
				position = {0.15, -1.95},
				starting_vertical_speed = 0.011,
				starting_vertical_speed_deviation = 0.004,
				starting_frame_deviation = 60,
			}
		}
	},
	animation = empty_sprite,
}

ruin_smoke = table.deepcopy(cooling_tower_smoke)
ruin_smoke.name = "ruin-smoke"
ruin_smoke.energy_source.smoke[1].name = "ruin-smoke-type"
ruin_smoke.energy_source.smoke[1].position = {0.0, -1.8}

local function trivial_smoke(opts) return {
	type = "trivial-smoke",
	flags = {"placeable-off-grid","not-on-map"},
	name = opts.name,
	color = opts.color,
	render_layer = "smoke",
	blend_mode = opts.blend_mode,
	duration = opts.duration or 600,
	fade_in_duration = opts.fade_in_duration or 0,
	fade_away_duration = opts.fade_away_duration or ((opts.duration or 600) - (opts.fade_in_duration or 0)),
	spread_duration = opts.spread_duration or 600,
	start_scale = opts.start_scale or 0.20,
	end_scale = opts.end_scale or 1.0,
	cyclic = opts.cyclic == nil or opts.cyclic,
	affected_by_wind = opts.affected_by_wind == nil or opts.affected_by_wind,
	show_when_smoke_off = opts.show_when_smoke_off,
	animation = {
		width = 152,
		height = 120,
		line_length = 5,
		frame_count = 60,
		shift = {-0.53125, -0.4375},
		priority = "extra-high",
		animation_speed = 0.25,
		filename = "__base__/graphics/entity/smoke/smoke.png",
		flags = { "smoke" },
		scale = opts.scale or 1,
	}
} end
local warning = {
	type = "simple-entity",
	name = "rr-electricity-warning",
	flags = {"placeable-off-grid"},
	picture = {
		filename = "__core__/graphics/icons/alerts/electricity-icon-red.png",
		priority = "high",
		width = 64,
		height = 64,
		frame_count = 1,
		animation_speed = 1,
		scale = 0.44,
	},
	duration = 60,
	fade_in_duration = 3,
	fade_away_duration = 3,
	spread_duration = 0,
	start_scale = 1,
	end_scale = 1,
	cyclic = true,
	affected_by_wind = false,
	movement_slow_down_factor = 0.5,
	show_when_smoke_off = true,
	render_layer = "entity-info-icon-above",
}
local cooling_warning = table.deepcopy(warning)
cooling_warning.name =  "rr-cooling-warning"
cooling_warning.picture.filename = "__core__/graphics/icons/alerts/recharge-icon.png"
data:extend({
	-- electricity warning
	warning,
	cooling_warning,
	-- smoke for cooling tower
	trivial_smoke{
		name = "cooling-tower-smoke-type",
		color = {r=0.65, g=0.65, b=0.65, a=0.3},
		start_scale = 0.77,
		end_scale = 1.3,
		duration = 260,
		spread_duration = 260,
		fade_away_duration = 100,
		fade_in_duration = 20,
		affected_by_wind = true,
		show_when_smoke_off = true,
	},
	-- smoke for reactor ruin
	trivial_smoke{
		name = "ruin-smoke-type",
		blend_mode = "additive-soft",
		color = {r=0.8, g=0.9, b=0.9, a=0.9},
		start_scale = 0.4,
		end_scale = 6.0,
		duration = 1000,
		spread_duration = 1000,
		fade_away_duration = 990,
		fade_in_duration = 10,
		affected_by_wind = true,
		show_when_smoke_off = true,
	},

})


data:extend{
	reactor_default,
	reactor_interface,
	breeder_interface,
	reactor_eccs,
	reactor_power_normal,
	reactor_power_breeder,
	reactor_normal,
	reactor_breeder,
	cooling_tower,
	cooling_tower_smoke,
	ruin_smoke,
	reactor_ruin,
	breeder_ruin,
	sarcophagus,
}

