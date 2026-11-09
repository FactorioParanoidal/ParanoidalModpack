data:extend {{
    type = "item",
    name = "maraxsis-a-breath-of-fresh-air",
    icon = "__maraxsis__/maraxsis-start/graphics/icons/a-breath-of-fresh-air.png",
    icon_size = 64,
    subgroup = "extraction-machine",
    order = "z",
    stack_size = 1,
    place_result = "maraxsis-a-breath-of-fresh-air",
    flags = {"not-stackable"},
    weight = 1000000,
    default_import_location = "maraxsis",
    auto_recycle = false
}}

data:extend {{
    type = "fuel-category",
    name = "maraxsis-hidden-fuel-category",
    hidden = true,
    localised_name = "",
}}

data:extend {{
    type = "item",
    name = "maraxsis-hidden-fuel",
    icon = data.raw.fluid["maraxsis-atmosphere"].icon,
    icon_size = 64,
    fuel_value = "999QJ",
    hidden = true,
    stack_size = 1,
    fuel_categories = {"maraxsis-hidden-fuel-category"},
    localised_name = "",
}}

data:extend {{
    type = "infinity-pipe",
    name = "maraxsis-a-breath-of-fresh-air-infinity-pipe",
    icon = "__maraxsis__/maraxsis-start/graphics/icons/a-breath-of-fresh-air.png",
    icon_size = 64,
    max_health = 100,
    horizontal_window_bounding_box = {{0, 0}, {0, 0}},
    vertical_window_bounding_box = {{0, 0}, {0, 0}},
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = {layers = {}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    selectable_in_game = false,
    hidden = true,
    gui_mode = "none",
    factoriopedia_alternative = "maraxsis-a-breath-of-fresh-air",
    localised_name = {"entity-name.maraxsis-a-breath-of-fresh-air"},
    localised_description = {"entity-description.maraxsis-a-breath-of-fresh-air"},
    flags = {"placeable-neutral", "player-creation"},
    fluid_box = {
        filter = "maraxsis-atmosphere",
        production_type = "output",
        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
        pipe_covers = pipecoverspictures(),
        always_draw_covers = true,
        secondary_draw_orders = {north = -1, east = -1, west = -1},
        volume = 500,
        pipe_connections = {
            {
                position = {0, -1},
                direction = defines.direction.north
            },
            {
                position = {0, 1},
                direction = defines.direction.south
            },
            {
                position = {-1, 0},
                direction = defines.direction.west
            },
            {
                position = {1, 0},
                direction = defines.direction.east
            }
        }
    },
    minable = nil,
}}

data:extend {{
    type = "burner-generator",
    name = "maraxsis-a-breath-of-fresh-air",
    icon = "__maraxsis__/maraxsis-start/graphics/icons/a-breath-of-fresh-air.png",
    icon_size = 64,
    maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false},
    surface_conditions = maraxsis.surface_conditions(),
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.4, result = "maraxsis-a-breath-of-fresh-air"},
    heating_energy = "50kW",
    max_health = 100,
    open_sound = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].open_sound),
    close_sound = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].close_sound),
    match_animation_speed_to_activity = false,
    working_sound = {
        sound = {
            filename = "__maraxsis__/sounds/regulator.ogg",
            volume = 0.3
        },
        max_sounds_per_type = 3,
        audible_distance_modifier = 0.4,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    burner = {
        type = "burner",
        fuel_inventory_size = 0,
        fuel_categories = {"maraxsis-hidden-fuel-category"},
        initial_fuel_percent = 1,
        initial_fuel = "maraxsis-hidden-fuel",
        smoke = {
            {
                name = "maraxsis-swimming-bubbles",
                frequency = 100,
                position = {-0, -0},
                height = 0.55,
                starting_vertical_speed = 0.03
            }
        },
        effectivity = 1000000000000,
    },
    energy_source = {
        type = "electric",
        usage_priority = "primary-output",
        render_no_power_icon = false,
        render_no_network_icon = true,
        buffer_capacity = "5MJ",
    },
    max_power_output = "5MW",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    created_effect = {
        type = "direct",
        action_delivery = {
            type = "instant",
            source_effects = {
                type = "script",
                effect_id = "on_built_a_breath_of_fresh_air",
            }
        }
    },
    animation = {
        layers = {
            {
                filename = "__maraxsis__/maraxsis-start/graphics/entity/a-breath-of-fresh-air.png",
                width = 1120 / 4,
                height = 315,
                frame_count = 4,
                shift = {0, -0.2},
                scale = 0.375,
                tint = {0.9, 0.9, 0.9, 1}
            },
            {
                filename = "__maraxsis__/maraxsis-start/graphics/entity/a-breath-of-fresh-air-sh.png",
                width = 373,
                height = 320,
                frame_count = 1,
                repeat_count = 4,
                shift = {1, -0.2},
                draw_as_shadow = true,
                scale = 0.375,
                tint = {0.9, 0.9, 0.9, 1}
            },
        },
    },
    perceived_performance = {minimum = 1, maximum = 1},
}}