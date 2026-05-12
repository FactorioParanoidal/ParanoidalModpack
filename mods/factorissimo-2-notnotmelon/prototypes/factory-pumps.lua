-- Hidden pumps to work around the extents @raiguard

local pump_pictures = {
    north = data.raw.pipe.pipe.pictures.ending_up,
    south = data.raw.pipe.pipe.pictures.ending_down,
    east = data.raw.pipe.pipe.pictures.ending_right,
    west = data.raw.pipe.pipe.pictures.ending_left,
}

local highest_quality_level = 0
for _, quality in pairs(data.raw.quality) do
    if quality.level > highest_quality_level then highest_quality_level = quality.level end
end
local pumping_speed = data.raw.pump.pump.pumping_speed * 10
local pumping_speed_with_quality = pumping_speed * (1 + highest_quality_level * 0.3)

-- Multiply the max fluid flow to allow factorissimo pumps to transfer at high speed.
data.raw["utility-constants"]["default"].max_fluid_flow = math.max(data.raw["utility-constants"]["default"].max_fluid_flow or 0, pumping_speed_with_quality)

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
        hide_connection_info = true,
        pipe_connections = {
            {position = {0, 0}, direction = defines.direction.north, flow_direction = "input",  connection_type = "normal"},
            {position = {0, 0}, direction = defines.direction.south, flow_direction = "output", connection_type = "linked", linked_connection_id = 0},
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
        hide_connection_info = true,
        pipe_connections = {
            {position = {0, 0}, direction = defines.direction.north, flow_direction = "output", connection_type = "normal"},
            {position = {0, 0}, direction = defines.direction.south, flow_direction = "input",  connection_type = "linked", linked_connection_id = 0},
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

data:extend {outside_input, outside_output}
