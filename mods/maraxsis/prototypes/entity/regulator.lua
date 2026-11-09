local regulator = table.deepcopy(data.raw.roboport.roboport)

regulator.name = "maraxsis-regulator"
regulator.maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false}
regulator.logistics_connection_distance = 90
regulator.radar_range = 2
regulator.logistics_radius = 30
regulator.construction_radius = 60
regulator.base_animation = nil
regulator.base = nil
regulator.base_patch = nil
regulator.frozen_patch = nil
regulator.door_animation_up = nil
regulator.door_animation_down = nil
regulator.hidden = false
regulator.energy_source.render_no_network_icon = false
regulator.energy_source.render_no_power_icon = false
regulator.drawing_box_vertical_extension = 0.75
regulator.energy_source.input_flow_limit = "25MW"
regulator.energy_usage = "2.5MW"
regulator.charging_energy = "2.5MW"
regulator.use_mirroring = true

local sqrt_2 = 1.41421356237
regulator.charging_offsets = {
    {-1.5, -1}, {1.5, -1}, {1.5, 1}, {-1.5, 1},
    {-sqrt_2 * 1.5, -sqrt_2}, {sqrt_2 * 1.5, -sqrt_2}, {sqrt_2 * 1.5, sqrt_2}, {-sqrt_2 * 1.5, sqrt_2}
}

regulator.integration_patch = {
    layers = {
        {
            filename = "__maraxsis__/graphics/entity/regulator/regulator.png",
            priority = "high",
            width = 1680 / 8,
            height = 2320 / 8,
            shift = {0, -0.5},
            frame_count = 60,
            line_length = 8,
            animation_speed = 1,
            scale = 0.5 * 4 / 3,
            flags = {"no-scale"}
        },
        {
            filename = "__maraxsis__/graphics/entity/regulator/sh.png",
            priority = "high",
            width = 400,
            height = 350,
            shift = util.by_pixel(0, -16),
            frame_count = 1,
            line_length = 1,
            repeat_count = 60,
            animation_speed = 1,
            scale = 0.5 * 4 / 3,
            draw_as_shadow = true,
        }
    }
}
regulator.integration_patch_render_layer = "object-under"
regulator.placeable_by = {item = "maraxsis-pressure-dome", count = 1}
regulator.minable = nil
regulator.icon = "__maraxsis__/graphics/icons/regulator.png"
regulator.icon_size = 64
regulator.surface_conditions = maraxsis.surface_conditions()
regulator.circuit_connector = circuit_connector_definitions["maraxsis-regulator"]
regulator.circuit_wire_max_distance = _G.default_circuit_wire_max_distance

data:extend {regulator}

data:extend {{
    type = "recipe",
    name = "maraxsis-regulator",
    enabled = false,
    hidden = true,
    energy_required = 100,
    ingredients = {},
    results = {},
    categories = {"maraxsis-regulator"},
    subgroup = "fluid",
    order = "a[fluid]-a[maraxsis-atmosphere]-a[regulator]",
    icon = "__maraxsis__/graphics/icons/atmosphere.png",
    icon_size = 64,
    auto_recycle = false,
    localised_name = {"entity-name.maraxsis-regulator"},
}}

data:extend {{
    type = "recipe-category",
    name = "maraxsis-regulator",
}}
