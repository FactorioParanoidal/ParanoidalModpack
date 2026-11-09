local constants = require "__FluidMustFlow__.prototypes.constants"
local hit_effects = require("__base__.prototypes.entity.hit-effects")

data:extend { {
    type = "item",
    name = "maraxsis-geothermal-generator",
    icon = "__maraxsis__/graphics/entity/geothermal-generator/icon.png",
    icon_size = 64,
    place_result = "maraxsis-geothermal-generator",
    stack_size = 5,
} }

data:extend { {
    type = "recipe",
    name = "maraxsis-geothermal-generator",
    enabled = false,
    energy_required = 10,
    ingredients = {
        { type = "item", name = "maraxsis-glass-panes", amount = 200 },
        { type = "item", name = "tungsten-plate",       amount = 50 },
        { type = "item", name = "processing-unit",      amount = 25 },
        { type = "item", name = "maraxsis-trench-duct", amount = 1 },
    },
    results = {
        { type = "item", name = "maraxsis-geothermal-generator", amount = 1 },
    },
    auto_recycle = true,
    categories = { "maraxsis-hydro-plant" },
    surface_conditions = maraxsis.surface_conditions(),
} }

data:extend { {
    type = "technology",
    name = "maraxsis-geothermal-energy",
    icon = "__maraxsis__/graphics/entity/geothermal-generator/technology.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-geothermal-generator"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-oversized-steam-turbine"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-supercritical-steam"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-supercritical-steam-cooling"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-geothermal-sulfur"
        },
    },
    prerequisites = { "ducts", "maraxsis-glassworking" },
    research_trigger = {
        type = "build-entity",
        entity = "maraxsis-trench-duct"
    },
    order = "d-e",
} }

data:extend { {
    type = "recipe-category",
    name = "maraxsis-geothermal-generator"
} }

local working_visualisations = {
    {
        always_draw = true,
        animation = {
            priority = "high",
            width = 330,
            height = 410,
            frame_count = 80,
            shift = util.by_pixel_hr(0, -36),
            animation_speed = 1.25,
            scale = 0.5,
            stripes = {
                {
                    filename = "__maraxsis__/graphics/entity/geothermal-generator/geothermal-generator-1.png",
                    width_in_frames = 8,
                    height_in_frames = 8,
                },
                {
                    filename = "__maraxsis__/graphics/entity/geothermal-generator/geothermal-generator-2.png",
                    width_in_frames = 8,
                    height_in_frames = 2,
                },
            },
        },
    },
    {
        always_draw = true,
        animation = {
            filename = "__maraxsis__/graphics/entity/geothermal-generator/sh.png",
            width = 900,
            height = 500,
            frame_count = 1,
            line_length = 1,
            repeat_count = 80,
            animation_speed = 1.25,
            shift = util.by_pixel(13, -9),
            scale = 0.5,
            draw_as_shadow = true
        },
    },
    {
        fadeout = true,
        constant_speed = true,
        light = {
            intensity = 0.65,
            size = 10,
            color = { r = 1, g = 1, b = 0.75 },
        },
        animation = {
            priority = "high",
            width = 330,
            height = 410,
            frame_count = 80,
            shift = util.by_pixel_hr(0, -36),
            draw_as_glow = true,
            scale = 0.5,
            animation_speed = 1.25,
            blend_mode = "additive",
            stripes = {
                {
                    filename = "__maraxsis__/graphics/entity/geothermal-generator/glow-1.png",
                    width_in_frames = 8,
                    height_in_frames = 8,
                },
                {
                    filename = "__maraxsis__/graphics/entity/geothermal-generator/glow-2.png",
                    width_in_frames = 8,
                    height_in_frames = 2,
                },
            },
        },
    },
}

data:extend { {
    type = "assembling-machine",
    name = "maraxsis-geothermal-generator",
    icon = "__maraxsis__/graphics/entity/geothermal-generator/icon.png",
    maraxsis_buildability_rules = { water = false, dome = false, coral = false, trench = true, trench_entrance = false, trench_lava = true },
    icon_size = 64,
    open_sound = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].open_sound),
    close_sound = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].close_sound),
    working_sound = {
        sound = {
            filename = "__maraxsis__/sounds/geothermal-generator.ogg",
            volume = 0.50,
        },
        apparent_volume = 1.5,
        max_sounds_per_type = 3,
        audible_distance_modifier = 1,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 0.5, results = { { type = "item", name = "maraxsis-geothermal-generator", amount = 1 } } },
    max_health = 600,
    fast_replaceable_group = "maraxsis-geothermal-generator",
    corpse = data.raw["assembling-machine"]["electromagnetic-plant"].corpse,
    dying_explosion = "big-explosion",
    circuit_connector = circuit_connector_definitions["maraxsis-hydro-plant"],
    circuit_wire_max_distance = _G.default_circuit_wire_max_distance,
    localised_description = localised_description,
    heating_energy = "2000kW",
    module_slots = 5,
    icons_positioning = { {
        inventory_index = defines.inventory.crafter_modules, shift = { 0, 1 }
    } },
    use_mirroring = true,
    allowed_effects = { "consumption", "speed", "productivity", "pollution", "quality" },
    water_reflection = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").water_reflection,
    collision_box = { { -2.9, -2.9 }, { 2.9, 2.9 } },
    selection_box = { { -3.0, -3.0 }, { 3.0, 3.0 } },
    drawing_box_vertical_extension = 1,
    damaged_trigger_effect = hit_effects.entity(),
    fluid_boxes_off_when_no_fluid_recipe = false,
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = require("duct-pipe-pictures"),
            pipe_covers = nil,
            volume = 100,
            pipe_connections = {
                { connection_category = "ducts", direction = defines.direction.south, flow_direction = "input-output", position = { 0, 2.5 } },
            },
            max_pipeline_extent = constants.extent,
            secondary_draw_orders = { north = -1, west = -1, east = -1 },
        },
        {
            production_type = "input",
            pipe_picture = require("duct-pipe-pictures"),
            pipe_covers = nil,
            volume = 100,
            pipe_connections = {
                { connection_category = "ducts", direction = defines.direction.north, flow_direction = "input-output", position = { 0, -2.5 } },
            },
            max_pipeline_extent = constants.extent,
            secondary_draw_orders = { north = -1, west = -1, east = -1 },
        },
        {
            production_type = "output",
            pipe_picture = require("duct-pipe-pictures"),
            pipe_covers = nil,
            volume = 100,
            pipe_connections = {
                { connection_category = "ducts", direction = defines.direction.east, flow_direction = "input-output", position = { 2.5, 0 } }
            },
            max_pipeline_extent = constants.extent,
            secondary_draw_orders = { north = -1, west = -1, east = -1 },
        },
        {
            production_type = "output",
            pipe_picture = require("duct-pipe-pictures"),
            pipe_covers = nil,
            volume = 100,
            pipe_connections = {
                { connection_category = "ducts", direction = defines.direction.west, flow_direction = "input-output", position = { -2.5, 0 } },
            },
            max_pipeline_extent = constants.extent,
            secondary_draw_orders = { north = -1, west = -1, east = -1 },
        },
    },
    perceived_performance = { minimum = 0.25, performance_to_activity_rate = 20.0, maximum = 5 },
    off_when_no_fluid_recipe = true,
    graphics_set = {
        working_visualisations = working_visualisations
    },
    crafting_categories = {
        "maraxsis-geothermal-generator",
    },
    scale_entity_info_icon = true,
    impact_category = data.raw["assembling-machine"]["electromagnetic-plant"].impact_category,
    idle_sound = { filename = "__base__/sound/idle1.ogg" },
    crafting_speed = 1,
    energy_source = {
        type = "void",
    },
    icon_draw_specification = { scale = 1.75, shift = { 0, -0.3 } },
    energy_usage = "1W",
    collision_mask = { layers = { object = true, ground_tile = true } },
    tile_buildability_rules = {
        {
            required_tiles = { layers = { lava_tile = true } },
            area = { { -2.9, -2.9 }, { 2.9, 2.9 } },
        },
    },
} }
