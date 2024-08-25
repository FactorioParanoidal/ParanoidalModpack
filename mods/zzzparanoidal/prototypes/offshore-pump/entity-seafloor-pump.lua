local blank = {
    filename = "__zzzparanoidal__/graphics/blank.png",
    priority = "high",
    width = 1,
    height = 1,
    frame_count = 1
}

local offshore_pump_output_template = {
    type = "pump",
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
    glass_pictures = nil,
    fluid_animation = nil,
    water_reflection = nil,
    circuit_wire_connection_points = circuit_connector_definitions["pump"].points,
    circuit_connector_sprites = circuit_connector_definitions["pump"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
}

-- ##############################
-----SEAFLOOR MK1

local seafloor_pump = data.raw["offshore-pump"]["seafloor-pump"]
seafloor_pump.flags = seafloor_pump.flags or {}
table.insert(seafloor_pump.flags, "hide-alt-info")
seafloor_pump.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
seafloor_pump.selectable_in_game = false

local seafloor_pump_output = table.deepcopy(offshore_pump_output_template)
seafloor_pump_output.animations = {
    north = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
        width = 160,
        height = 160,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {0, -1},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
            width = 160,
            height = 160,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {0, -1}
        }
    },
    east = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
        width = 160,
        height = 160,
        x = 160,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {1, 0},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
            width = 160,
            height = 160,
            x = 160,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {1, 0}
        }
    },

    south = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
        width = 160,
        height = 160,
        x = 320,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {0, 1},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
            width = 160,
            height = 160,
            x = 320,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {0, 1}
        }
    },
    west = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
        width = 160,
        height = 160,
        x = 480,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {-1, 0},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump.png",
            width = 160,
            height = 160,
            x = 480,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {-1, 0}
        }
    }
}
seafloor_pump_output.name = "seafloor-pump-output"
seafloor_pump_output.icon = "__angelsrefining__/graphics/icons/seafloor-pump-ico.png"
seafloor_pump_output.icon_size = 32
seafloor_pump_output.localised_name = {"entity-name.seafloor-pump"}
seafloor_pump_output.minable = seafloor_pump.minable
seafloor_pump_output.placeable_by = {item = "seafloor-pump", count = 1}
seafloor_pump_output.pumping_speed = seafloor_pump.pumping_speed
seafloor_pump_output.selectable_in_game = true
-- seafloor_pump_output.create_ghost_on_death = false --test
seafloor_pump_output.selection_box = seafloor_pump.selection_box
seafloor_pump_output.energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = 10}
seafloor_pump_output.energy_usage = "500kW"
data:extend({seafloor_pump_output})

-- ##############################
-----SEAFLOOR MK2

local seafloor_mk2_pump = data.raw["offshore-pump"]["seafloor-pump-2"]
seafloor_mk2_pump.flags = seafloor_mk2_pump.flags or {}
table.insert(seafloor_mk2_pump.flags, "hide-alt-info")
seafloor_mk2_pump.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
seafloor_mk2_pump.selectable_in_game = false

local seafloor_mk2_pump_output = table.deepcopy(offshore_pump_output_template)
seafloor_mk2_pump_output.animations = {
    north = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
        width = 160,
        height = 160,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {0, -1},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
            width = 160,
            height = 160,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {0, -1}
        }
    },
    east = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
        width = 160,
        height = 160,
        x = 160,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {1, 0},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
            width = 160,
            height = 160,
            x = 160,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {1, 0}
        }
    },

    south = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
        width = 160,
        height = 160,
        x = 320,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {0, 1},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
            width = 160,
            height = 160,
            x = 320,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {0, 1}
        }
    },
    west = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
        width = 160,
        height = 160,
        x = 480,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {-1, 0},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2.png",
            width = 160,
            height = 160,
            x = 480,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {-1, 0}
        }
    }
}
seafloor_mk2_pump_output.name = "seafloor-pump-2-output"
seafloor_mk2_pump_output.icon = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk2-ico.png"
seafloor_mk2_pump_output.icon_size = 32
seafloor_mk2_pump_output.localised_name = {"entity-name.seafloor-pump-2"}
seafloor_mk2_pump_output.minable = seafloor_mk2_pump.minable
seafloor_mk2_pump_output.placeable_by = {item = "seafloor-pump-2", count = 1}
seafloor_mk2_pump_output.pumping_speed = seafloor_mk2_pump.pumping_speed
seafloor_mk2_pump_output.selectable_in_game = true
-- seafloor_mk2_pump_output.create_ghost_on_death = false --test
seafloor_mk2_pump_output.selection_box = seafloor_mk2_pump.selection_box
seafloor_mk2_pump_output.energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = 5}
seafloor_mk2_pump_output.energy_usage = "1000kW"
data:extend({seafloor_mk2_pump_output})

-- ##############################
-----SEAFLOOR MK3

local seafloor_mk3_pump = data.raw["offshore-pump"]["seafloor-pump-3"]
seafloor_mk3_pump.flags = seafloor_mk3_pump.flags or {}
table.insert(seafloor_mk3_pump.flags, "hide-alt-info")
seafloor_mk3_pump.fluid_box.pipe_connections = {{
    type = "output",
    position = {0, 0.6}
}}
seafloor_mk3_pump.selectable_in_game = false

local seafloor_mk3_pump_output = table.deepcopy(offshore_pump_output_template)
seafloor_mk3_pump_output.animations = {
    north = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
        width = 160,
        height = 160,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {0, -1},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
            width = 160,
            height = 160,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {0, -1}
        }
    },
    east = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
        width = 160,
        height = 160,
        x = 160,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {1, 0},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
            width = 160,
            height = 160,
            x = 160,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {1, 0}
        }
    },

    south = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
        width = 160,
        height = 160,
        x = 320,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {0, 1},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
            width = 160,
            height = 160,
            x = 320,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {0, 1}
        }
    },
    west = {
        filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
        width = 160,
        height = 160,
        x = 480,
        line_length = 1,
        frame_count = 1,
        animation_speed = 0.5,
        shift = {-1, 0},
        hr_version = {
            filename = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3.png",
            width = 160,
            height = 160,
            x = 480,
            line_length = 1,
            frame_count = 1,
            animation_speed = 0.5,
            shift = {-1, 0}
        }
    }
}
seafloor_mk3_pump_output.name = "seafloor-pump-3-output"
seafloor_mk3_pump_output.icon = "__angelsrefining__/graphics/entity/seafloor-pump/seafloor-pump-mk3-ico.png"
seafloor_mk3_pump_output.icon_size = 32
seafloor_mk3_pump_output.localised_name = {"entity-name.seafloor-pump-3"}
seafloor_mk3_pump_output.minable = seafloor_mk3_pump.minable
seafloor_mk3_pump_output.placeable_by = {item = "seafloor-pump-3", count = 1}
seafloor_mk3_pump_output.pumping_speed = seafloor_mk3_pump.pumping_speed
seafloor_mk3_pump_output.selectable_in_game = true
-- seafloor_mk3_pump_output.create_ghost_on_death = false --test
seafloor_mk3_pump_output.selection_box = seafloor_mk3_pump.selection_box
seafloor_mk3_pump_output.energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = 5}
seafloor_mk3_pump_output.energy_usage = "1500kW"
data:extend({seafloor_mk3_pump_output})