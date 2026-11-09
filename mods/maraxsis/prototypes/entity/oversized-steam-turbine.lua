local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local constants = require "__FluidMustFlow__.prototypes.constants"

data:extend { {
    type = "item",
    name = "maraxsis-oversized-steam-turbine",
    icon = "__maraxsis__/graphics/icons/oversized-steam-turbine.png",
    icon_size = 64,
    place_result = "maraxsis-oversized-steam-turbine",
    stack_size = 5,
} }

data:extend { {
    type = "recipe",
    name = "maraxsis-oversized-steam-turbine",
    enabled = false,
    energy_required = 10,
    ingredients = {
        { type = "item", name = "maraxsis-glass-panes", amount = 100 },
        { type = "item", name = "tungsten-plate",       amount = 100 },
        { type = "item", name = "processing-unit",      amount = 50 },
        { type = "item", name = "steam-turbine",        amount = 3 },
    },
    results = {
        { type = "item", name = "maraxsis-oversized-steam-turbine", amount = 1 },
    },
    auto_recycle = true,
    categories = { "maraxsis-hydro-plant" },
    surface_conditions = maraxsis.surface_conditions(),
} }

local function pictures()
    local offset = 2 * 32

    local vertical_animation = {
        layers = {
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V.png",
                width = 217,
                height = 374,
                frame_count = 8,
                line_length = 4,
                shift = util.by_pixel(4.75, 6.75 - offset),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
                width = 302,
                height = 260,
                repeat_count = 8,
                line_length = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(39.5, 24.5 - offset),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V.png",
                width = 217,
                height = 374,
                frame_count = 8,
                line_length = 4,
                shift = util.by_pixel(4.75, 6.75),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
                width = 302,
                height = 260,
                repeat_count = 8,
                line_length = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(39.5, 24.5),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V.png",
                width = 217,
                height = 374,
                frame_count = 8,
                line_length = 4,
                shift = util.by_pixel(4.75, 6.75 + offset),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
                width = 302,
                height = 260,
                repeat_count = 8,
                line_length = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(39.5, 24.5 + offset),
                run_mode = "backward",
                scale = 0.5,
            },
        },
    }

    local horizontal_animation = {
        layers = {
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H.png",
                width = 320,
                height = 245,
                frame_count = 8,
                line_length = 4,
                shift = util.by_pixel(0 + offset, -2.75),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
                width = 435,
                height = 150,
                repeat_count = 8,
                line_length = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(28.5 + offset, 18),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H.png",
                width = 320,
                height = 245,
                frame_count = 8,
                line_length = 4,
                shift = util.by_pixel(0, -2.75),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
                width = 435,
                height = 150,
                repeat_count = 8,
                line_length = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(28.5, 18),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H.png",
                width = 320,
                height = 245,
                frame_count = 8,
                line_length = 4,
                shift = util.by_pixel(0 - offset, -2.75),
                run_mode = "backward",
                scale = 0.5,
            },
            {
                filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
                width = 435,
                height = 150,
                repeat_count = 8,
                line_length = 1,
                draw_as_shadow = true,
                shift = util.by_pixel(28.5 - offset, 18),
                run_mode = "backward",
                scale = 0.5,
            },
        },
    }

    local pictures = {
        north = { animation = vertical_animation },
        south = { animation = vertical_animation },
        east = { animation = horizontal_animation },
        west = { animation = horizontal_animation },
    }

    return pictures
end

local function smoke(y_offset)
    return {
        name = "turbine-smoke",
        north_position = { 0.0, -1.0 + y_offset },
        south_position = { 0.0, -1.0 + y_offset },
        east_position = { 0.75 + y_offset, -0.75 },
        west_position = { 0.75 + y_offset, -0.75 },
        frequency = 0.08,
        starting_vertical_speed = 0.08,
        starting_frame_deviation = 60,
    }
end

data:extend { {
    type = "generator",
    name = "maraxsis-oversized-steam-turbine",
    heating_energy = data.raw["generator"]["steam-turbine"].heating_energy,
    icon = "__maraxsis__/graphics/icons/oversized-steam-turbine.png",
    maraxsis_buildability_rules = { water = false, dome = true, coral = false, trench = true, trench_entrance = false, trench_lava = false },
    flags = { "placeable-neutral", "player-creation" },
    minable = { mining_time = 0.5, result = "maraxsis-oversized-steam-turbine" },
    max_health = 1000,
    corpse = "steam-turbine-remnants",
    dying_explosion = "steam-turbine-explosion",
    alert_icon_shift = util.by_pixel(0, -12),
    use_mirroring = true,
    resistances = {
        {
            type = "fire",
            percent = 70,
        },
    },
    smoke = {
        smoke(0),
        smoke(2),
        smoke(-2),
    },
    fluid_usage_per_tick = 80 / second, -- at normal quality
    maximum_temperature = 2000,
    effectivity = 1,
    collision_box = { { -1.25, -2.35 - 2 }, { 1.25, 2.35 + 2 } },
    selection_box = { { -1.5, -2.5 - 2 }, { 1.5, 2.5 + 2 } },
    damaged_trigger_effect = hit_effects.entity(),
    fluid_box = {
        volume = 200,
        pipe_picture = require("duct-pipe-pictures"),
        pipe_covers = nil,
        secondary_draw_orders = { north = -1, east = -1, west = -1 },
        pipe_connections = {
            { flow_direction = "input-output", direction = defines.direction.east, position = { 1, 1.5 },   connection_category = "ducts" },
            { flow_direction = "input-output", direction = defines.direction.west, position = { -1, -1.5 }, connection_category = "ducts" },
        },
        max_pipeline_extent = constants.extent,
        production_type = "input",
        filter = "maraxsis-supercritical-steam",
    },
    output_fluid_box = {
        volume = 200,
        pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
        pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
        pipe_covers = pipecoverspictures(),
        secondary_draw_orders = { north = -1, east = -1, west = -1 },
        pipe_connections = {
            { flow_direction = "input-output", direction = defines.direction.north, position = { 0, -4 } },
            { flow_direction = "input-output", direction = defines.direction.south, position = { 0, 4 } },
            { flow_direction = "input-output", direction = defines.direction.east,  position = { 1, -2 } },
            { flow_direction = "input-output", direction = defines.direction.west,  position = { -1, 2 } },
        },
        production_type = "output",
        filter = "water",
    },
    energy_source = {
        type = "electric",
        usage_priority = "secondary-output",
    },
    burns_fluid = false,
    pictures = pictures(),
    impact_category = "metal-large",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    working_sound = {
        sound = {
            filename = "__base__/sound/steam-turbine.ogg",
            volume = 0.49,
            modifiers = volume_multiplier("main-menu", 0.7),
            speed_smoothing_window_size = 60,
            advanced_volume_control = { attenuation = "exponential" },
            audible_distance_modifier = 0.8,
        },
        match_speed_to_activity = true,
        max_sounds_per_prototype = 3,
        fade_in_ticks = 4,
        fade_out_ticks = 20,
    },
    perceived_performance = { minimum = 0.25, performance_to_activity_rate = 1.0 },
    spent_fluid = {
        name = "water",
        amount = 78 / 80,
        temperature = data.raw.fluid.water.default_temperature,
    },
} }
