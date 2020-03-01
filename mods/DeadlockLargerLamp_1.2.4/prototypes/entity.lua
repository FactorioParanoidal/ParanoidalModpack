require("prototypes.globals")
require("prototypes.functions")

-- electric large lamp

local circuits = circuit_connector_definitions.create (
    universal_connector_template,
    {{ variation = 26, main_offset = util.by_pixel(0, 10), shadow_offset = util.by_pixel(0, 10), show_shadow = true }}
)

local signal_colours = data.raw.lamp["small-lamp"].signal_to_color_mapping
if not signal_colours then
	signal_colours = {
		{type="virtual", name="signal-red", color={r=1,g=0,b=0}},
		{type="virtual", name="signal-green", color={r=0,g=1,b=0}},
		{type="virtual", name="signal-blue", color={r=0,g=0,b=1}},
		{type="virtual", name="signal-yellow", color={r=1,g=1,b=0}},
		{type="virtual", name="signal-pink", color={r=1,g=0,b=1}},
		{type="virtual", name="signal-cyan", color={r=0,g=1,b=1}}
	}
end

local lamp = {
    circuit_connector_sprites = circuits.sprites,
    circuit_wire_connection_point = circuits.points,
    circuit_wire_max_distance = 9,
    collision_box = { {-0.6,-0.6}, {0.6,0.6} },
    selection_box = { {-1.0,-1.0}, {1.0,1.0} },
    tile_width = 2,
    tile_height = 2,
    corpse = "medium-remnants",
    darkness_for_all_lamps_off = 0.3,
    darkness_for_all_lamps_on = 0.5,
    energy_source = {
        type = "electric",
        usage_priority = "lamp"
    },
    energy_usage_per_tick = "20KW",
	fast_replaceable_group = "large-lamp",
    flags = {"placeable-neutral","player-creation"},
    glow_color_intensity = 0.125,
    glow_size = 12,
    icon = string.format("%s/deadlock-large-lamp-64.png", DLL.icon_path),
    icon_size = 64,
    light = {
        color = DLL.glow_colour,
        intensity = 0.75,
        size = 80,
    },
    light_when_colored = {
		color = { b = 1, g = 1, r = 1 },
        intensity = 1,
        size = 6,
    },
    max_health = 150,
    minable = {
        mining_time = 0.5,
        result = DLL.name,
    },
    mined_sound = {
        filename = "__base__/sound/deconstruct-bricks.ogg"
    },
    name = DLL.name,
    picture_off = {
        layers = {
            {
                axially_symmetrical = false,
                direction_count = 1,
                filename = string.format("%s/lr-large-lamp-base.png", DLL.entity_path),
                frame_count = 1,
                height = 64,
                hr_version = {
                    axially_symmetrical = false,
                    direction_count = 1,
                    filename = string.format("%s/hr-large-lamp-base.png", DLL.entity_path),
                    frame_count = 1,
                    height = 128,
                    priority = "high",
                    scale = 0.5,
                    shift = {0,0},
                    width = 128,
                },
                priority = "high",
                shift = {0,0},
                width = 64
            },
            {
                axially_symmetrical = false,
                direction_count = 1,
                draw_as_shadow = true,
                filename = string.format("%s/lr-large-lamp-shadow.png", DLL.entity_path),
                frame_count = 1,
                height = 64,
                hr_version = {
                    axially_symmetrical = false,
                    direction_count = 1,
                    draw_as_shadow = true,
                    filename = string.format("%s/hr-large-lamp-shadow.png", DLL.entity_path),
                    frame_count = 1,
                    height = 128,
                    priority = "high",
                    scale = 0.5,
                    shift = {0,0},
                    width = 128
                },
                priority = "high",
                shift = {0,0},
                width = 64
            }
        }
    },
    picture_on = {
        axially_symmetrical = false,
        direction_count = 1,
        filename = string.format("%s/lr-large-lamp-light.png", DLL.entity_path),
        frame_count = 1,
        height = 64,
        hr_version = {
            axially_symmetrical = false,
            direction_count = 1,
            filename = string.format("%s/hr-large-lamp-light.png", DLL.entity_path),
            frame_count = 1,
            height = 128,
            priority = "high",
            scale = 0.5,
            shift = {0,0},
			tint = DLL.glow_colour,
            width = 128
        },
        priority = "high",
        shift = {0,0},
		tint = DLL.glow_colour,
        width = 64
    },
    resistances = {
        {
            type = "fire",
            percent = 50
        },
    },
    signal_to_color_mapping = signal_colours,
    type = "lamp",
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    }
}

data:extend({lamp})

-- copper lamp

local lamp = {
    name = DLL.copper_name,
    type = "furnace",
    minable = {
        mining_time = 0.5,
        result = DLL.copper_name,
    },
    icon = string.format("%s/deadlock-large-lamp-64.png", DLL.icon_path),
    icon_size = 64,
    fast_replaceable_group = "large-lamp",
    crafting_speed = 1,
    crafting_categories = {"deadlock-lamp-burning"},
    show_recipe_icon = false,
    source_inventory_size = 1,
    result_inventory_size = 1,
    energy_source = {
        emissions_per_minute = 0.25,
        type = "void"
    },
    energy_usage = "9.6kW",
    max_health = 100,
    resistances = {
        {
            type = "fire",
            percent = 95
        },
    },
    corpse = "medium-remnants",
    flags = {"placeable-player", "placeable-neutral", "player-creation"},
    collision_box = { {-0.6,-0.6}, {0.6,0.6} },
    selection_box = { {-1.0,-1.0}, {1.0,1.0} },
    tile_width = 2,
    tile_height = 2,
    animation = {
        layers = {
            get_layer("copper-lamp-base", nil, nil, false, nil, nil, 128, 128, 0, 0, 128, 128, {0,0}),
            get_layer("copper-lamp-shadow", nil, nil, true, nil, nil, 128, 128, 0, 0, 128, 128, {0,0}),
        }
    },
    working_visualisations = {
        {
            animation = get_layer("copper-lamp-working", 30, 6, false, nil, 1, 128, 128, 0, 0, 128, 128, {0,0}, "additive"),
            light = { color = {1.0,0.75,0.5}, intensity = 0.75, size = 80},
        }
    },
    working_sound = {
        sound = {
            filename = "__base__/sound/furnace.ogg",
            volume = 1.0
        }
    },
    open_sound = {
        filename = "__base__/sound/machine-open.ogg",
        volume = 0.75
    },
    close_sound = {
        filename = "__base__/sound/machine-close.ogg",
        volume = 0.75
    },
    mined_sound = {
        filename = "__base__/sound/deconstruct-bricks.ogg"
    },
    vehicle_impact_sound = {
        filename = "__base__/sound/car-metal-impact.ogg",
        volume = 0.65
    },
}

data:extend({lamp})
