-- Hidden pumps split pipeline extents. Keep all four pump names for existing connections.

local pump_pictures = {
    north = data.raw.pipe.pipe.pictures.ending_up,
    south = data.raw.pipe.pipe.pictures.ending_down,
    east = data.raw.pipe.pipe.pictures.ending_right,
    west = data.raw.pipe.pipe.pictures.ending_left,
}

-- Fixed values instead of numbers derived from whatever pump and qualities exist at this point of loading:
-- they used to depend on load order (the Bob pump at data-updates time and only the vanilla qualities).
-- These are the values the modpack had: 100 units per tick for a normal factory port, and fluid flow
-- raised from 100 to 250 units per tick (a legendary port). Higher qualities are capped by max_fluid_flow.
-- Factorio 2.1 removed the utility constant max_fluid_flow (2.0: this mod raised it to 250 for the whole game);
-- the limit is derived from the fluid box volume, which is 250 for the port pumps below.
local fluid_port = require("prototypes.fluid-port")
local pumping_speed = fluid_port.pumping_speed
local pumping_speed_with_quality = fluid_port.max_fluid_flow

data:extend {{
    type = "pump",
    name = "factory-inside-pump-input",
    icon = data.raw["pump"]["pump"].icon,
    icon_size = data.raw["pump"]["pump"].icon_size,
    localised_name = {"entity-name.factory-pump"},
    localised_description = {"entity-description.factory-pump"},
    flags = {"not-blueprintable", "not-deconstructable", "not-on-map", "not-flammable", "not-repairable", "hide-alt-info"},
    max_health = 50,
    hidden = true,
    fluid_box = {
        volume = pumping_speed_with_quality,
        pipe_connections = {
            {position = {0, 0}, direction = defines.direction.north, flow_direction = "input",  connection_type = "normal", hide_connection_info = true},
            {position = {0, 0}, direction = defines.direction.south, flow_direction = "output", connection_type = "linked", linked_connection_id = 0, hide_connection_info = true},
        },
    },
    energy_source = {
        type = "void",
    },
    integration_patch = table.deepcopy(pump_pictures),
    integration_patch_render_layer = "lower-object-above-shadow",
    pumping_speed = pumping_speed,
    energy_usage = "1W",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {layers = {}},
    quality_indicator_scale = 0,
    squeak_behaviour = false
}}

data:extend {{
    type = "pump",
    name = "factory-inside-pump-output",
    icon = data.raw["pump"]["pump"].icon,
    icon_size = data.raw["pump"]["pump"].icon_size,
    localised_name = {"entity-name.factory-pump"},
    localised_description = {"entity-description.factory-pump"},
    flags = {"not-blueprintable", "not-deconstructable", "not-on-map", "not-flammable", "not-repairable", "hide-alt-info"},
    max_health = 50,
    hidden = true,
    fluid_box = {
        volume = pumping_speed_with_quality,
        pipe_connections = {
            {position = {0, 0}, direction = defines.direction.north, flow_direction = "output", connection_type = "normal", hide_connection_info = true},
            {position = {0, 0}, direction = defines.direction.south, flow_direction = "input",  connection_type = "linked", linked_connection_id = 0, hide_connection_info = true},
        },
    },
    integration_patch = table.deepcopy(pump_pictures),
    integration_patch_render_layer = "lower-object-above-shadow",
    energy_source = {
        type = "void",
    },
    pumping_speed = pumping_speed,
    energy_usage = "1W",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {layers = {}},
    quality_indicator_scale = 0,
    squeak_behaviour = false
}}

local outside_input = table.deepcopy(data.raw["pump"]["factory-inside-pump-input"])
outside_input.name = "factory-outside-pump-input"
outside_input.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
outside_input.selection_priority = 51

local outside_output = table.deepcopy(data.raw["pump"]["factory-inside-pump-output"])
outside_output.name = "factory-outside-pump-output"
outside_output.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
outside_output.selection_priority = 51

-- Only the other end of a new port is passive. It joins the local pipeline, including its extent.
local inside_terminal = {
    type = "storage-tank",
    name = "factory-fluid-terminal-inside",
    icon = outside_input.icon,
    icon_size = outside_input.icon_size,
    localised_name = {"entity-name.factory-pump"},
    flags = table.deepcopy(outside_input.flags),
    max_health = outside_input.max_health,
    hidden = true,
    collision_box = table.deepcopy(outside_input.collision_box),
    collision_mask = {layers = {}},
    integration_patch = table.deepcopy(pump_pictures),
    integration_patch_render_layer = outside_input.integration_patch_render_layer,
    quality_indicator_scale = 0,
    squeak_behaviour = false,
    window_bounding_box = {{0, 0}, {0, 0}},
    flow_length_in_ticks = 1,
    show_fluid_icon = false,
    fluid_box = {
        volume = pumping_speed_with_quality,
        pipe_connections = {
            {position = {0, 0}, direction = defines.direction.north, hide_connection_info = true},
            {connection_type = "linked", linked_connection_id = 0, hide_connection_info = true},
        },
    },
}
local outside_terminal = table.deepcopy(inside_terminal)
outside_terminal.name = "factory-fluid-terminal-outside"
outside_terminal.selection_box = table.deepcopy(outside_input.selection_box)
outside_terminal.selection_priority = outside_input.selection_priority

data:extend {outside_input, outside_output, inside_terminal, outside_terminal}
