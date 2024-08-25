
-- Fetch external properties
local offshore_pump = data.raw["offshore-pump"]["offshore-pump"]

local ofshore_pump_template = {
    type = "offshore-pump",
	icon = offshore_pump.icon,
    icon_size = offshore_pump.icon_size,
    icon_mipmaps = offshore_pump.icon_mipmaps,
    flags = offshore_pump.flags,
    collision_mask = offshore_pump.collision_mask,
    center_collision_mask = offshore_pump.center_collision_mask,
    fluid_box_tile_collision_test = offshore_pump.fluid_box_tile_collision_test,
    adjacent_tile_collision_test = offshore_pump.adjacent_tile_collision_test,
    adjacent_tile_collision_mask = offshore_pump.adjacent_tile_collision_mask,
    adjacent_tile_collision_box = offshore_pump.adjacent_tile_collision_box,
    max_health = offshore_pump.max_health,
    corpse = offshore_pump.corpse,
    dying_explosion = offshore_pump.dying_explosion,
    fluid = offshore_pump.fluid,
    resistances = offshore_pump.resistances,
    collision_box = offshore_pump.collision_box,
    selection_box = offshore_pump.selection_box,
    damaged_trigger_effect = offshore_pump.damaged_trigger_effect,
    fluid_box = offshore_pump.fluid_box,
    pumping_speed = offshore_pump.pumping_speed,
    tile_width = offshore_pump.tile_width,
    tile_height = offshore_pump.tile_height,
    vehicle_impact_sound = offshore_pump.vehicle_impact_sound,
    open_sound = offshore_pump.open_sound,
    close_sound = offshore_pump.close_sound,
    working_sound = offshore_pump.working_sound,
    min_perceived_performance = offshore_pump.min_perceived_performance,
    always_draw_fluid = offshore_pump.always_draw_fluid,
    graphics_set = offshore_pump.graphics_set,
    fluid_animation = offshore_pump.fluid_animation,
    glass_pictures = offshore_pump.glass_pictures,
    base_pictures = offshore_pump.base_pictures,
    underwater_pictures = offshore_pump.underwater_pictures,
    placeable_position_visualization = offshore_pump.placeable_position_visualization,
    circuit_wire_connection_points = offshore_pump.circuit_wire_connection_points,
    circuit_connector_sprites = offshore_pump.circuit_connector_sprites,
    circuit_wire_max_distance = offshore_pump.circuit_wire_max_distance,
    water_reflection = offshore_pump.water_reflection

}

local ofshore_mk0_template = table.deepcopy(ofshore_pump_template)
ofshore_mk0_template.name = "offshore-mk0-pump"
ofshore_mk0_template.minable = {mining_time = 1, result = "offshore-mk0-pump"}
data:extend({ofshore_mk0_template})

local ofshore_mk2_template = table.deepcopy(ofshore_pump_template)
ofshore_mk2_template.name = "offshore-mk2-pump"
ofshore_mk2_template.minable = {mining_time = 1, result = "offshore-mk2-pump"}
data:extend({ofshore_mk2_template})

local ofshore_mk3_template = table.deepcopy(ofshore_pump_template)
ofshore_mk3_template.name = "offshore-mk3-pump"
ofshore_mk3_template.minable = {mining_time = 1, result = "offshore-mk3-pump"}
data:extend({ofshore_mk3_template})

local ofshore_mk4_template = table.deepcopy(ofshore_pump_template)
ofshore_mk4_template.name = "offshore-mk4-pump"
ofshore_mk4_template.minable = {mining_time = 1, result = "offshore-mk4-pump"}
data:extend({ofshore_mk4_template})