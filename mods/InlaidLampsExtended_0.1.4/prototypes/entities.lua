local light_intensity = settings.startup["inlaid-lamps-extended-light_intensity"].value						--0.9
local light_size = settings.startup["inlaid-lamps-extended-light_size"].value								--40
local light_colored_intensity = settings.startup["inlaid-lamps-extended-light_colored_intensity"].value		--1
local light_colored_size = settings.startup["inlaid-lamps-extended-light_colored_size"].value				--6
local loc_glow_color_intensity = settings.startup["inlaid-lamps-extended-loc_glow_color_intensity"].value	--0.235
local loc_glow_size = settings.startup["inlaid-lamps-extended-loc_glow_size"].value							--6
local loc_energy_usage = math.ceil(math.max(5*light_intensity*light_size/36,5*light_colored_intensity*light_colored_size/36)).."KW"

data:extend({
    -- Flat Lamp Entity
    {
        type = "lamp",
        name = "flat-lamp",
        icon = "__InlaidLampsExtended__/graphics/icon/flat-lamp.png",
		icon_size = 32,
        flags = { "placeable-neutral", "player-creation" },
        minable = { hardness = 0.2, mining_time = 0.5, result = "flat-lamp" },
        max_health = 100,
        corpse = "small-remnants",
        render_layer = "ground-tile",
        collision_mask={"doodad-layer","object-layer"},
        collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input"
        },
        energy_usage_per_tick = "5KW",
        -- RGB Red (251, 30, 10)
        light = {intensity = light_intensity, size = light_size, color = {r=1.0, g=1.0, b=1.0}},
        light_when_colored = {intensity = light_colored_intensity, size = light_colored_size, color = {r=1.0, g=1.0, b=1.0}},
        glow_size = loc_glow_size,
        glow_color_intensity = loc_glow_color_intensity,
        picture_off = {
            layers = {
                {
                    filename = "__InlaidLampsExtended__/graphics/light-off-flat.png",
                    priority = "high",
                    width = 90,
                    height = 78,
                    frame_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(0, -7),
                    scale = 1
                },
            }
        },
        picture_on = {
            filename = "__InlaidLampsExtended__/graphics/light-on-flat.png",
            priority = "high",
            width = 90,
            height = 78,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(0, -7),
            scale = 1
        },
        circuit_wire_connection_point =
        {
            shadow = {
                red = {-0.32, -0.32},
                green = {-0.32, -0.32},
            },
            wire = {
                red = {-0.32, -0.32},
                green = {-0.32, -0.32},
            }
        },
        circuit_wire_max_distance = 7.5,
        signal_to_color_mapping =
        {
            {type="virtual", name="signal-red", color={r=1,g=0,b=0}},
            {type="virtual", name="signal-green", color={r=0,g=1,b=0}},
            {type="virtual", name="signal-blue", color={r=0,g=0,b=1}},
            {type="virtual", name="signal-yellow", color={r=1,g=1,b=0}},
            {type="virtual", name="signal-pink", color={r=1,g=0,b=1}},
            {type="virtual", name="signal-cyan", color={r=0,g=1,b=1}}
        },

        circuit_wire_max_distance = default_circuit_wire_max_distance,
     
        circuit_connector_sprites = {
            blue_led_light_offset = {
                0.0,
                0.0
            },
            connector_main = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-main.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.32, -0.32 },
                x = 0,
                y = 0
            },
            led_blue = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-led-blue.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.32, -0.32 },
                x = 0,
                y = 0
            },
            led_green = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-led-green.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.32, -0.32 },
                x = 0,
                y = 0
            },
            led_light = {
                intensity = 0.8,
                size = 0.9
            },
            led_red = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-led-red.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.32, -0.32 },
                x = 0,
                y = 0
            },
            logistic_animation = {
                blend_mode = "additive",
                filename = "__base__/graphics/entity/circuit-connector/circuit-connector-logistic-animation.png",
                frame_count = 15,
                height = 43,
                line_length = 4,
                priority = "low",
                shift = { 0.0, 0.0 },
                width = 43
            },
            red_green_led_light_offset = {
                -0.3,
                -0.3
            }
        },
        circuit_wire_max_distance = 7.5,
        fast_replaceable_group = "lamps"
    }, 
    -- 2x2 Flat Lamp Entity
    {
        type = "lamp",
        name = "flat-lamp-big",
        icon = "__InlaidLampsExtended__/graphics/icon/flat-lamp.png",
		icon_size = 32,
        flags = { "placeable-neutral", "player-creation" },
        minable = { hardness = 0.2, mining_time = 0.5, result = "flat-lamp-big" },
        max_health = 100,
        corpse = "small-remnants",
        render_layer = "ground-tile",
        collision_mask={"doodad-layer","object-layer"},
        collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
        selection_box = {{-1, -1}, {1, 1}},
		tile_height = 2,
		tile_width = 2,
        vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input"
        },
        energy_usage_per_tick = "5KW",
        -- RGB Red (251, 30, 10)
        light = {intensity = light_intensity, size = light_size, color = {r=1.0, g=1.0, b=1.0}},
        light_when_colored = {intensity = light_colored_intensity, size = light_colored_size, color = {r=1.0, g=1.0, b=1.0}},
        glow_size = loc_glow_size,
        glow_color_intensity = loc_glow_color_intensity,
        picture_off = {
            layers = {
                {
                    filename = "__InlaidLampsExtended__/graphics/light-off-flat.png",
                    priority = "high",
                    width = 90,
                    height = 78,
                    frame_count = 1,
                    axially_symmetrical = true,
                    direction_count = 1,
                    shift = util.by_pixel(0, -14),
                    scale = 2
                },
            }
        },
        picture_on = {
            filename = "__InlaidLampsExtended__/graphics/light-on-flat.png",
            priority = "high",
            width = 90,
            height = 78,
            frame_count = 1,
            axially_symmetrical = true,
            direction_count = 1,
            shift = util.by_pixel(0, -14),
            scale = 2
        },
        circuit_wire_connection_point =
        {
            shadow = {
                red = {-0.64, -0.64},
                red = {-0.64, -0.64},
            },
            wire = {
                red = {-0.64, -0.64},
                green = {-0.64, -0.64},
            }
        },
        circuit_wire_max_distance = 7.5,
        signal_to_color_mapping =
        {
            {type="virtual", name="signal-red", color={r=1,g=0,b=0}},
            {type="virtual", name="signal-green", color={r=0,g=1,b=0}},
            {type="virtual", name="signal-blue", color={r=0,g=0,b=1}},
            {type="virtual", name="signal-yellow", color={r=1,g=1,b=0}},
            {type="virtual", name="signal-pink", color={r=1,g=0,b=1}},
            {type="virtual", name="signal-cyan", color={r=0,g=1,b=1}}
        },

        circuit_wire_max_distance = default_circuit_wire_max_distance,
     
        circuit_connector_sprites = {
            blue_led_light_offset = {
                0.0,
                0.0
            },
            connector_main = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-main.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.64, -0.64 },
                x = 0,
                y = 0
            },
            led_blue = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-led-blue.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.64, -0.64 },
                x = 0,
                y = 0
            },
            led_green = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-led-green.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.64, -0.64 },
                x = 0,
                y = 0
            },
            led_light = {
                intensity = 0.8,
                size = 0.9
            },
            led_red = {
                filename = "__InlaidLampsExtended__/graphics/circuit/connector-led-red.png",
                height = 12,
                width = 12,
                priority = "low",
                shift = { -0.64, -0.64 },
                x = 0,
                y = 0
            },
            logistic_animation = {
                blend_mode = "additive",
                filename = "__base__/graphics/entity/circuit-connector/circuit-connector-logistic-animation.png",
                frame_count = 15,
                height = 43,
                line_length = 4,
                priority = "low",
                shift = { 0.0, 0.0 },
                width = 43
            },
            red_green_led_light_offset = {
                -0.6,
                -0.6
            }
        },
        circuit_wire_max_distance = 7.5,
        fast_replaceable_group = "lamps"
    }, 
})

-- edit the existing lamp to enable fast replacing
data.raw["lamp"]["small-lamp"].fast_replaceable_group="lamps";


-- ==============================================================
if settings.startup["inlaid_lamps_extended_change_energy_usage"].value then
	local flat_lamp = data.raw.lamp["flat-lamp"]
	flat_lamp.energy_usage_per_tick = loc_energy_usage
	local flat_lamp_big = data.raw.lamp["flat-lamp-big"]
	flat_lamp_big.energy_usage_per_tick = loc_energy_usage
end
if mods["Dectorio"] then
	local lamp = data.raw.lamp["small-lamp"]
	local flat_lamp = data.raw.lamp["flat-lamp"]
	flat_lamp.signal_to_color_mapping = lamp.signal_to_color_mapping
	local flat_lamp_big = data.raw.lamp["flat-lamp-big"]
	flat_lamp_big.signal_to_color_mapping = lamp.signal_to_color_mapping
end
-- ==============================================================