local circuit_wire_connection_point = {
    shadow = {
        green = {0.71875, 0.6875},
        red = {0.625, 0.875}
    },
    wire = {
        green = {-0.265625, -0.84375},
        red = {-0.34375, -0.640625}
    }
}

local circuit_connector_sprite = {
    blue_led_light_offset = {-0.015625, -0.8125},
    connector_main = {
        filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04a-base-sequence.png",
        height = 50,
        priority = "low",
        scale = 0.5,
        shift = {0, -0.484375},
        width = 52,
        x = 312,
        y = 0
    },
    led_blue = {
        draw_as_glow = true,
        filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04e-blue-LED-on-sequence.png",
        height = 60,
        priority = "low",
        scale = 0.5,
        shift = {0, -0.515625},
        width = 60,
        x = 360,
        y = 0
    },
    led_blue_off = {
        filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04f-blue-LED-off-sequence.png",
        height = 44,
        priority = "low",
        scale = 0.5,
        shift = {0, -0.515625},
        width = 46,
        x = 276,
        y = 0
    },
    led_green = {
        draw_as_glow = true,
        filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04h-green-LED-sequence.png",
        height = 46,
        priority = "low",
        scale = 0.5,
        shift = {0, -0.515625},
        width = 48,
        x = 288,
        y = 0
    },
    led_light = {
        intensity = 0,
        size = 0.9
    },
    led_red = {
        draw_as_glow = true,
        filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04i-red-LED-sequence.png",
        height = 46,
        priority = "low",
        scale = 0.5,
        shift = {0, -0.515625},
        width = 48,
        x = 288,
        y = 0
    },
    red_green_led_light_offset = {-0.015625, -0.6875},
    wire_pins = {
        filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04c-wire-sequence.png",
        height = 58,
        priority = "low",
        scale = 0.5,
        shift = {0, -0.515625},
        width = 62,
        x = 372,
        y = 0
    },
    wire_pins_shadow = {
        draw_as_shadow = true,
        filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04d-wire-shadow-sequence.png",
        height = 54,
        priority = "low",
        scale = 0.5,
        shift = {0.15625, -0.390625},
        width = 70,
        x = 420,
        y = 0
    }
}

data:extend({
    {
        type = "storage-tank",
        name = "pipe-meter",
        icon = "__PipeMeterWLK__/graphics/icon-dial_face.png",
        icon_size = 32,
        flags = {"placeable-player", "player-creation"},
        minable = {
            mining_time = 0.5,
            result = "pipe-meter"
        },
        max_health = 150,
        fast_replaceable_group = "pipe",
        collision_box = {
            {-0.29, -0.29},
            {0.29, 0.29}
        },
        selection_box = {
            {-0.5, -0.5},
            {0.5, 0.5}
        },
        fluid_box = {
            base_area = 1,
            pipe_connections = {
                {position = {-1, 0}},
                {position = {0, 1}},
                {position = {1, 0}},
                {position = {0, -1}}
            },
            pipe_covers = pipecoverspictures()
        },
        window_bounding_box = {
            {-0.125, 0.6875},
            {0.1875, 1.1875}
        },
        corpse = "small-remnants",
        pictures = {
            picture = {
                sheet = {
                    filename = "__PipeMeterWLK__/graphics/entity-pipe_meter.png",
                    priority = "extra-high",
                    frames = 1,
                    width = 40,
                    height = 40
                    -- width = 46,
                    -- height = 52,
                    -- shift = {0.09375, 0.03125},
                }
            },
            fluid_background = {
                filename = "__core__/graphics/empty.png",
                width = 1,
                height = 1
                -- width = 32,
                -- height = 15
            },
            window_background = {
                filename = "__core__/graphics/empty.png",
                width = 1,
                height = 1
                -- width = 17,
                -- height = 24
            },
            flow_sprite = {
                filename = "__core__/graphics/empty.png",
                width = 1,
                height = 1
                -- width = 160,
                -- height = 20
            },
            gas_flow = {
                filename = "__core__/graphics/empty.png",
                width = 1,
                height = 1
            }
        },
        flow_length_in_ticks = 360,
        vehicle_impact_sound = {
            {
                filename = "__base__/sound/car-metal-impact-2.ogg",
                volume = 0.5
            },
            {
                filename = "__base__/sound/car-metal-impact-3.ogg",
                volume = 0.5
            },
            {
                filename = "__base__/sound/car-metal-impact-4.ogg",
                volume = 0.5
            },
            {
                filename = "__base__/sound/car-metal-impact-5.ogg",
                volume = 0.5
            },
            {
                filename = "__base__/sound/car-metal-impact-6.ogg",
                volume = 0.5
            }
        },
        working_sound = {
            sound = {
                filename = "__base__/sound/storage-tank.ogg",
                volume = 0.6
            },
            audible_distance_modifier = 0.5,
            match_volume_to_activity = true,
            max_sounds_per_type = 3,
        },
        open_sound = {
            {
                filename = "__base__/sound/machine-open.ogg",
                volume = 0.5
            }
        },
        close_sound = {
            {
                filename = "__base__/sound/machine-close.ogg",
                volume = 0.5
            }
        },
        circuit_wire_connection_points = {
            circuit_wire_connection_point,
            circuit_wire_connection_point,
            circuit_wire_connection_point,
            circuit_wire_connection_point
        },
        circuit_connector_sprites = {
            circuit_connector_sprite,
            circuit_connector_sprite,
            circuit_connector_sprite,
            circuit_connector_sprite
        },
        circuit_wire_max_distance = 7.5
    }
})
