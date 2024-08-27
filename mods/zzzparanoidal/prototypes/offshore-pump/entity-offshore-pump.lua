-- #############
---------Set local template
local blank = {
    filename = "__zzzparanoidal__/graphics/blank.png",
    priority = "high",
    width = 1,
    height = 1,
    frame_count = 1
}

local offshore_pump_output_template = {
    type = "pump",
    selection_box = {{-1, -1.5}, {1, 1}},
    collision_box = {{-0.9, -0}, {0.9, 0.65}},
    collision_mask = {"not-colliding-with-itself"},
    fluid_box = {
        base_area = 1,
        height = 2,
        pipe_covers = pipecoverspictures(),
        pipe_connections = {{
            position = {0, 0.9},
            type = "output"
        }, {
            position = {0, -0.1},
            type = "input"
        }}
    },
    order = "z",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation", "not-deconstructable", "not-blueprintable", "placeable-off-grid"},
    max_health = 150,
    resistances = {{
        type = "fire",
        percent = 70
    }, {
        type = "impact",
        percent = 30
    }},
    corpse = nil,
    pumping_speed = 10000, -- change in zzz
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
    glass_pictures = {
        north = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png",
            width = 18,
            height = 20,
            shift = util.by_pixel(-2, -22),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-glass.png",
                width = 36,
                height = 40,
                shift = util.by_pixel(-2, -22),
                scale = 0.5
            }
        },
        east = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png",
            width = 18,
            height = 18,
            shift = util.by_pixel(4, -14),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-glass.png",
                width = 30,
                height = 32,
                shift = util.by_pixel(5, -13),
                scale = 0.5
            }
        },
        south = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png",
            width = 22,
            height = 12,
            shift = util.by_pixel(-2, -6),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-glass.png",
                width = 40,
                height = 24,
                shift = util.by_pixel(-1, -6),
                scale = 0.5
            }
        },
        west = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png",
            width = 16,
            height = 16,
            shift = util.by_pixel(-6, -14),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-glass.png",
                width = 30,
                height = 32,
                shift = util.by_pixel(-6, -14),
                scale = 0.5
            }
        }
    },
    fluid_animation = {
        north = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-fluid.png",
            apply_runtime_tint = true,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            width = 22,
            height = 20,
            shift = util.by_pixel(-2, -22),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-fluid.png",
                apply_runtime_tint = true,
                line_length = 8,
                frame_count = 32,
                animation_speed = 0.5,
                width = 40,
                height = 40,
                shift = util.by_pixel(-1, -22),
                scale = 0.5
            }
        },
        east = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-fluid.png",
            apply_runtime_tint = true,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            width = 20,
            height = 24,
            shift = util.by_pixel(6, -10),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-fluid.png",
                apply_runtime_tint = true,
                line_length = 8,
                frame_count = 32,
                animation_speed = 0.5,
                width = 38,
                height = 50,
                shift = util.by_pixel(6, -11),
                scale = 0.5
            }
        },
        south = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-fluid.png",
            apply_runtime_tint = true,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            width = 20,
            height = 8,
            shift = util.by_pixel(-2, -4),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-fluid.png",
                apply_runtime_tint = true,
                line_length = 8,
                frame_count = 32,
                animation_speed = 0.5,
                width = 36,
                height = 14,
                shift = util.by_pixel(-1, -4),
                scale = 0.5
            }
        },
        west = {
            filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-fluid.png",
            apply_runtime_tint = true,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            width = 20,
            height = 24,
            shift = util.by_pixel(-8, -10),
            hr_version = {
                filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-fluid.png",
                apply_runtime_tint = true,
                line_length = 8,
                frame_count = 32,
                animation_speed = 0.5,
                width = 36,
                height = 50,
                shift = util.by_pixel(-7, -11),
                scale = 0.5
            }
        }
    },

    -- glass_pictures =  nil, --устарело
    -- fluid_animation = nil, --устарело
    -- water_reflection = nil, --устарело
    circuit_wire_connection_points = circuit_connector_definitions["pump"].points,
    circuit_connector_sprites = circuit_connector_definitions["pump"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
}

-- ##############################
--------Burner PUMP

local offshore_mk0_pump = data.raw["offshore-pump"]["offshore-mk0-pump"]
offshore_mk0_pump.flags = offshore_mk0_pump.flags or {}
table.insert(offshore_mk0_pump.flags, "hide-alt-info")
offshore_mk0_pump.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
offshore_mk0_pump.collision_box = {{-0.6, -1.45}, {0.6, 0.45}}
offshore_mk0_pump.selection_box = {{-0.95, -1.45}, {0.95, 0.45}}
offshore_mk0_pump.selectable_in_game = false

local offshore_mk0_pump_output = table.deepcopy(offshore_pump_output_template)
offshore_mk0_pump_output.animations = blank
offshore_mk0_pump_output.name = "offshore-mk0-pump-output"
offshore_mk0_pump_output.icon = "__zzzparanoidal__/graphics/icons/offshore-pump-0.png"
offshore_mk0_pump_output.localised_name = {"entity-name.offshore-mk0-pump"}
offshore_mk0_pump_output.minable = offshore_mk0_pump.minable
offshore_mk0_pump_output.placeable_by = {
    item = "offshore-mk0-pump",
    count = 1
} -- Allow pressing Q on a pump
offshore_mk0_pump_output.pumping_speed = offshore_mk0_pump.pumping_speed
offshore_mk0_pump_output.selectable_in_game = true
-- offshore_mk0_pump_output.create_ghost_on_death = false --test
offshore_mk0_pump_output.selection_box = offshore_mk0_pump.selection_box

offshore_mk0_pump_output.energy_source = {
    type = "burner",
    fuel_category = "chemical",
    effectivity = 1,
    fuel_inventory_size = 1,
    emissions_per_minute = 9
}
offshore_mk0_pump_output.energy_usage = "900kW"

data:extend({offshore_mk0_pump_output})

-- ##############################
--------MK 1
local offshore_pump = data.raw["offshore-pump"]["offshore-pump"]
offshore_pump.flags = offshore_pump.flags or {}
table.insert(offshore_pump.flags, "hide-alt-info")
offshore_pump.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
offshore_pump.collision_box = {{-0.6, -1.45}, {0.6, 0.45}}
offshore_pump.selection_box = {{-0.95, -1.45}, {0.95, 0.45}}
offshore_pump.selectable_in_game = false

local offshore_pump_output = table.deepcopy(offshore_pump_output_template)

offshore_pump_output.animations = offshore_pump.graphics_set.animation
offshore_pump_output.name = "offshore-pump-output"
offshore_pump_output.icon = "__zzzparanoidal__/graphics/icons/offshore-pump-1.png"
offshore_pump_output.localised_name = {"entity-name.offshore-pump"}
offshore_pump_output.minable = offshore_pump.minable
offshore_pump_output.placeable_by = {
    item = "offshore-pump",
    count = 1
} -- Allow pressing Q on a pump
offshore_pump_output.pumping_speed = offshore_pump.pumping_speed
offshore_pump_output.selectable_in_game = true
-- offshore_pump_output.create_ghost_on_death = false --test
offshore_pump_output.selection_box = offshore_pump.selection_box
offshore_pump_output.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = 1
}
offshore_pump_output.energy_usage = "1200kW"

data:extend({offshore_pump_output})

-- ##############################
-----MK2

local offshore_pump_mk2 = data.raw["offshore-pump"]["offshore-mk2-pump"]
offshore_pump_mk2.flags = offshore_pump_mk2.flags or {}
table.insert(offshore_pump_mk2.flags, "hide-alt-info")
offshore_pump_mk2.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
offshore_pump_mk2.collision_box = {{-0.6, -1.45}, {0.6, 0.45}}
offshore_pump_mk2.selection_box = {{-0.95, -1.45}, {0.95, 0.45}}
offshore_pump_mk2.selectable_in_game = false

local offshore_pump_mk2_output = table.deepcopy(offshore_pump_output_template)
offshore_pump_mk2_output.animations = blank
offshore_pump_mk2_output.name = "offshore-mk2-pump-output"
offshore_pump_mk2_output.icon = "__zzzparanoidal__/graphics/icons/offshore-pump-2.png"
offshore_pump_mk2_output.localised_name = {"entity-name.offshore-mk2-pump"}
offshore_pump_mk2_output.minable = offshore_pump_mk2.minable
offshore_pump_mk2_output.placeable_by = {
    item = "offshore-mk2-pump",
    count = 1
} -- Allow pressing Q on a pump
offshore_pump_mk2_output.pumping_speed = offshore_pump_mk2.pumping_speed
offshore_pump_mk2_output.selectable_in_game = true
-- offshore_pump_mk2_output.create_ghost_on_death = false --test
offshore_pump_mk2_output.selection_box = offshore_pump_mk2.selection_box
offshore_pump_mk2_output.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = 1
}
offshore_pump_mk2_output.energy_usage = "2000kW"

data:extend({offshore_pump_mk2_output})

-- ##############################
-----MK3

local offshore_pump_mk3 = data.raw["offshore-pump"]["offshore-mk3-pump"]
offshore_pump_mk3.flags = offshore_pump_mk3.flags or {}
table.insert(offshore_pump_mk3.flags, "hide-alt-info")
offshore_pump_mk3.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
offshore_pump_mk3.collision_box = {{-0.6, -1.45}, {0.6, 0.45}}
offshore_pump_mk3.selection_box = {{-0.95, -1.45}, {0.95, 0.45}}
offshore_pump_mk3.selectable_in_game = false

local offshore_pump_mk3_output = table.deepcopy(offshore_pump_output_template)
offshore_pump_mk3_output.animations = blank
offshore_pump_mk3_output.name = "offshore-mk3-pump-output"
offshore_pump_mk3_output.icon = "__zzzparanoidal__/graphics/icons/offshore-pump-3.png"
offshore_pump_mk3_output.localised_name = {"entity-name.offshore-mk3-pump"}
offshore_pump_mk3_output.minable = offshore_pump_mk3.minable
offshore_pump_mk3_output.placeable_by = {
    item = "offshore-mk3-pump",
    count = 1
} -- Allow pressing Q on a pump
offshore_pump_mk3_output.pumping_speed = offshore_pump_mk3.pumping_speed
offshore_pump_mk3_output.selectable_in_game = true
-- offshore_pump_mk3_output.create_ghost_on_death = false --test
offshore_pump_mk3_output.selection_box = offshore_pump_mk3.selection_box
offshore_pump_mk3_output.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = 1
}
offshore_pump_mk3_output.energy_usage = "2000kW"

data:extend({offshore_pump_mk3_output})

-- ##############################
-----MK4

local offshore_pump_mk4 = data.raw["offshore-pump"]["offshore-mk4-pump"]
offshore_pump_mk4.flags = offshore_pump_mk4.flags or {}
table.insert(offshore_pump_mk4.flags, "hide-alt-info")
offshore_pump_mk4.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
offshore_pump_mk4.collision_box = {{-0.6, -1.45}, {0.6, 0.45}}
offshore_pump_mk4.selection_box = {{-0.95, -1.45}, {0.95, 0.45}}
offshore_pump_mk4.selectable_in_game = false

local offshore_pump_mk4_output = table.deepcopy(offshore_pump_output_template)
offshore_pump_mk4_output.animations = blank
offshore_pump_mk4_output.name = "offshore-mk4-pump-output"
offshore_pump_mk4_output.icon = "__zzzparanoidal__/graphics/icons/offshore-pump-3.png"
offshore_pump_mk4_output.localised_name = {"entity-name.offshore-mk4-pump"}
offshore_pump_mk4_output.minable = offshore_pump_mk4.minable
offshore_pump_mk4_output.placeable_by = {
    item = "offshore-mk4-pump",
    count = 1
} -- Allow pressing Q on a pump
offshore_pump_mk4_output.pumping_speed = offshore_pump_mk4.pumping_speed
offshore_pump_mk4_output.selectable_in_game = true
-- offshore_pump_mk4_output.create_ghost_on_death = false --test
offshore_pump_mk4_output.selection_box = offshore_pump_mk4.selection_box
offshore_pump_mk4_output.energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = 1
}
offshore_pump_mk4_output.energy_usage = "2000kW"

data:extend({offshore_pump_mk4_output})

