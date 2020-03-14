--entities.lua

-- assuming this is called from data.lua only
require("copy_prototype")
require("entity_helper")
require("util")

--==============================================================================
-- Overhead Line Poles: Placer

data:extend {
	make_pole_placer("ret-pole-placer", "items/power-pole.png"),
	make_pole_placer("ret-signal-pole-placer", "items/signal-pole.png"),
	make_pole_placer("ret-chain-pole-placer", "items/chain-pole.png")
}

--==============================================================================
-- Overhead Line Poles: Base entities

local simple_pole_straight = make_pole_base("constant-combinator", "ret-pole-base-straight",
	"ret-pole-placer", "items/power-pole.png", pole_circuit_connections_straight)

simple_pole_straight.sprites = { sheet = {
		filename = graphics .. "entities/pole-base-straight.png",
		width = 48, height = 48, shift = util.by_pixel(0, 8)
	}}
-- combinator specific stuff
simple_pole_straight.item_slot_count = 0
simple_pole_straight.activity_led_sprites = { sheet = {
		filename = graphics .. "empty.png", width = 1, height = 1
	}}
simple_pole_straight.activity_led_light_offsets = { {0, 0}, {0, 0}, {0, 0}, {0, 0}}



local simple_pole_diagonal = make_pole_base("constant-combinator", "ret-pole-base-diagonal",
	"ret-pole-placer", "items/power-pole.png", pole_circuit_connections_diagonal)

simple_pole_diagonal.sprites = { sheet = {
		filename = graphics .. "entities/pole-base-diagonal.png",
		width = 48, height = 48, shift = util.by_pixel(0, 8)
	}}
-- combinator specific stuff
simple_pole_diagonal.item_slot_count = 0
simple_pole_diagonal.activity_led_sprites = { sheet = {
		filename = graphics .. "empty.png", width = 1, height = 1
	}}
simple_pole_diagonal.activity_led_light_offsets = { {0, 0}, {0, 0}, {0, 0}, {0, 0}}



local signal_pole = make_pole_base("rail-signal", "ret-signal-pole-base",
	"ret-signal-pole-placer", "items/signal-pole.png", pole_circuit_connections)

signal_pole.animation = {
		filename = graphics .. "entities/signal-pole-base.png",
		width = 48, height = 48, shift = util.by_pixel(0, 8),
		frame_count = 3, direction_count = 8
	}
table.insert(signal_pole.flags, "building-direction-8-way")
-- signal specific stuff
signal_pole.circuit_connector_sprites = empty_circuit_connector_array
signal_pole.rail_piece = data.raw["rail-signal"]["rail-signal"].rail_piece
signal_pole.green_light = {intensity = 0.2, size = 4, color={g=1}}
signal_pole.orange_light = {intensity = 0.2, size = 4, color={r=1, g=0.5}}
signal_pole.red_light = {intensity = 0.2, size = 4, color={r=1}}



local chain_pole = make_pole_base("rail-chain-signal", "ret-chain-pole-base",
	"ret-chain-pole-placer", "items/chain-pole.png", pole_circuit_connections)

chain_pole.animation = {
		filename = graphics .. "entities/chain-pole-base.png",
		width = 136, height = 136, shift = util.by_pixel(15, 17),
		frame_count = 5, direction_count = 8
	}
table.insert(chain_pole.flags, "building-direction-8-way")
-- signal specific stuff
chain_pole.circuit_connector_sprites = empty_circuit_connector_array
chain_pole.selection_box_offsets = data.raw["rail-chain-signal"]["rail-chain-signal"].selection_box_offsets
chain_pole.rail_piece = data.raw["rail-chain-signal"]["rail-chain-signal"].rail_piece
chain_pole.green_light = {intensity = 0.3, size = 4, color={r=0.4, g=1.0, b=0.1}}
chain_pole.orange_light = {intensity = 0.3, size = 4, color={r=0.8, g=0.7, b=0.3}}
chain_pole.red_light = {intensity = 0.3, size = 4, color={r=0.8, g=0.4, b=0.4}}
chain_pole.blue_light = {intensity = 0.3, size = 4, color={r=0.2, g=0.5, b=0.8}}


-- Extend

data:extend{simple_pole_straight, simple_pole_diagonal, signal_pole, chain_pole}

--==============================================================================
-- Pole child entities

local pole_wire = {
	type = "electric-pole",
	name = "ret-pole-wire",
	icon = graphics .. "items/pole-wire.png",
	icon_size = 32,
	flags = { "placeable-off-grid", "not-blueprintable", "not-deconstructable" },
	collision_mask = {},
	selection_box = {{-0.25, -0.25}, {0.25, 0.25}},
	pictures = { 
		filename = graphics .. "empty.png",
		width = 1, height = 1, direction_count = 1
	},
	resistances = { -- immune to any damage
		{type="physical",percent=100},{type="explosion",percent=100},
		{type="acid",percent=100},{type="fire",percent=100}
	},
	selection_priority = 100,
	maximum_wire_distance = config.pole_max_wire_distance + 0.5,
	supply_area_distance = config.pole_supply_area,
	connection_points = {{
		shadow = { copper = {2.1,  0.0 }, green = { 2.0,  0.0 }, red = {2.2,  0.0 } },
		wire   = { copper = {0.0, -2.25}, green = {-0.1, -2.25}, red = {0.1, -2.25} },
	}},
	radius_visualisation_picture = data.raw["electric-pole"]["medium-electric-pole"].radius_visualisation_picture
}



local pole_power_straight = copy_table(pole_child_template, "ret-pole-energy-straight")

pole_power_straight.picture = {
		filename = graphics .. "entities/pole-straight.png",
		width = 128, height = 160, shift = util.by_pixel(45, -55)
	}
pole_power_straight.placeable_by = { item = "ret-dummy-pole-energy", count = 1}
pole_power_straight.energy_source = {
		type = "electric", usage_priority = "secondary-input",
		buffer_capacity = "2MJ", -- this value doesn't matter
		input_flow_limit = toW(config.pole_flow_limit)
	}



local pole_power_diagonal = copy_table(pole_child_template, "ret-pole-energy-diagonal")

pole_power_diagonal.picture = {
		filename = graphics .. "entities/pole-diagonal.png",
		width = 128, height = 160, shift = util.by_pixel(45, -55)
	}
pole_power_diagonal.placeable_by = { item = "ret-dummy-pole-energy", count = 1}
pole_power_diagonal.energy_source = {
		type = "electric", usage_priority = "secondary-input",
		buffer_capacity = "2MJ", -- this value doesn't matter
		input_flow_limit = toW(config.pole_flow_limit)
	}



local pole_holder_straight = copy_table(pole_child_template, "ret-pole-holder-straight")

pole_holder_straight.render_layer = "wires-above"
pole_holder_straight.pictures = { sheets = {{
		filename = graphics .. "entities/wire-holder-straight.png",
		width = 148, height = 108, shift = util.by_pixel(0, -74), frames = 4
	},{
		filename = graphics .. "entities/wire-holder-straight-shadow.png",
		width = 148, height = 108, shift = util.by_pixel(67, 9),
		frames = 4, draw_as_shadow = 1
	}}}
pole_holder_straight.placeable_by = { item = "ret-dummy-pole-holder", count = 1}
pole_holder_straight.energy_source = dummy_energy_source



local pole_holder_diagonal = copy_table(pole_child_template, "ret-pole-holder-diagonal")

pole_holder_diagonal.render_layer = "wires-above"
pole_holder_diagonal.pictures = { sheets = {{
		filename = graphics .. "entities/wire-holder-diagonal.png",
		width = 148, height = 108, shift = util.by_pixel(0, -74), frames = 4
	},{
		filename = graphics .. "entities/wire-holder-diagonal-shadow.png",
		width = 148, height = 108, shift = util.by_pixel(67, 9),
		frames = 4, draw_as_shadow = 1
	}}}
pole_holder_diagonal.placeable_by = { item = "ret-dummy-pole-holder", count = 1}
pole_holder_diagonal.energy_source = dummy_energy_source


-- Extend

data:extend{pole_wire, pole_power_straight, pole_power_diagonal, pole_holder_straight, pole_holder_diagonal}

--==============================================================================
-- Particles

data:extend {
	make_particle("ret-connected-particle", "entities/powered-particle.png"),
	make_particle("ret-disconnected-particle", "entities/unpowered-particle.png")
}

--==============================================================================
-- Electric Locomotives

local electric_locomotive =
	copy_prototype("locomotive", "locomotive", "ret-electric-locomotive")
electric_locomotive.burner.fuel_inventory_size = 0
electric_locomotive.burner.smoke = nil
electric_locomotive.weight = 3000
electric_locomotive.braking_force = 16
electric_locomotive.reversing_power_modifier = 0.8
electric_locomotive.color = { r = 0.00, g = 0.76, b = 0.96, a = 0.5 }
electric_locomotive.max_power = toW(config.locomotive_power)

local electric_locomotive_mk2 =
	copy_prototype("locomotive", "locomotive", "ret-electric-locomotive-mk2")
electric_locomotive_mk2.burner.fuel_inventory_size = 0
electric_locomotive_mk2.burner.smoke = nil
electric_locomotive_mk2.weight = 3000
electric_locomotive_mk2.braking_force = 24
electric_locomotive_mk2.reversing_power_modifier = 0.8
electric_locomotive_mk2.color = { r = 0.00, g = 0.76, b = 0.96, a = 0.5 }
electric_locomotive_mk2.max_power = toW(config.advanced_locomotive_power)
electric_locomotive_mk2.max_speed = 1.4

local modular_electric_locomotive =
	copy_prototype("locomotive", "locomotive", "ret-modular-locomotive")
modular_electric_locomotive.burner.fuel_inventory_size = 0
modular_electric_locomotive.burner.smoke = nil
modular_electric_locomotive.weight = 4000
modular_electric_locomotive.braking_force = 32
modular_electric_locomotive.reversing_power_modifier = 0.8
modular_electric_locomotive.color = { r = 0.00, g = 0.76, b = 0.96, a = 0.5 }
modular_electric_locomotive.max_power = toW(config.modular_locomotive_base_power)
modular_electric_locomotive.max_speed = 1.4
modular_electric_locomotive.equipment_grid = "modular-locomotive-grid"

data:extend{electric_locomotive, electric_locomotive_mk2, modular_electric_locomotive}
