local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")

data:extend { {
    type = "technology",
    name = "maraxsis-hydro-plant",
    icon = "__maraxsis__/graphics/technology/hydro-plant.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-hydro-plant",
        },
    },
    prerequisites = { "planet-discovery-maraxsis" },
    research_trigger = {
        type = "mine-entity",
        entities = { "big-sand-rock-underwater" }
    },
    order = "ea[hydro-plant]",
} }

local working_visualisations = {
    {
        always_draw = true,
        animation = {
            filename = "__maraxsis__/graphics/entity/hydro-plant/hydro-plant.png",
            priority = "high",
            width = 2560 / 8,
            height = 2960 / 8,
            shift = { 0, -0.5 },
            frame_count = 60,
            line_length = 8,
            animation_speed = 1,
            scale = 0.5,
            flags = { "no-scale" }
        },
    },
    {
        always_draw = true,
        animation = {
            filename = "__maraxsis__/graphics/entity/hydro-plant/sh.png",
            priority = "high",
            width = 600,
            height = 400,
            shift = util.by_pixel(0, -16),
            frame_count = 1,
            line_length = 1,
            animation_speed = 1,
            scale = 0.5,
            draw_as_shadow = true,
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
    },
}

data:extend { {
    type = "recipe-category",
    name = "maraxsis-hydro-plant",
} }

data:extend { {
    type = "assembling-machine",
    name = "maraxsis-hydro-plant",
    icon = "__maraxsis__/graphics/icons/hydro-plant.png",
    maraxsis_buildability_rules = { water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false },
    icon_size = 64,
    open_sound = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].open_sound),
    close_sound = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].close_sound),
    working_sound = {
        sound = {
            filename = "__maraxsis__/sounds/hydro-plant.ogg",
            volume = 0.50,
        },
        apparent_volume = 1.5,
        max_sounds_per_type = 3,
        audible_distance_modifier = 1,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 0.5, results = { { type = "item", name = "maraxsis-hydro-plant", amount = 1 } } },
    max_health = 400,
    fast_replaceable_group = "maraxsis-hydro-plant",
    corpse = data.raw["assembling-machine"]["electromagnetic-plant"].corpse,
    dying_explosion = "big-explosion",
    circuit_connector = circuit_connector_definitions["maraxsis-hydro-plant"],
    circuit_wire_max_distance = _G.default_circuit_wire_max_distance,
    localised_description = localised_description,
    resistances = {
        { type = "physical", percent = 50 },
        { type = "fire",     percent = 100 },
        { type = "impact",   percent = 80 },
    },
    heating_energy = "2000kW",
    module_slots = 4,
    icons_positioning = {{
        inventory_index = defines.inventory.crafter_modules, shift = { 0, 1 }
    }},
    use_mirroring = true,
    allowed_effects = { "consumption", "speed", "productivity", "pollution", "quality" },
    water_reflection = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").water_reflection,
    collision_box = { { -1.9, -1.9 }, { 1.9, 1.9 } },
    selection_box = { { -2, -2 }, { 2, 2 } },
    effect_receiver = { base_effect = { quality = 0.5 } },
    drawing_box_vertical_extension = 1,
    damaged_trigger_effect = hit_effects.entity(),
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            pipe_connections = { { direction = defines.direction.south, flow_direction = "input-output", position = { -0.5, 1.5 } } },
            secondary_draw_orders = { north = -1 },
        },
        {
            production_type = "output",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            pipe_connections = { { direction = defines.direction.east, flow_direction = "input-output", position = { 1.5, -0.5 } } },
            secondary_draw_orders = { north = -1 },
        },
        {
            production_type = "input",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            pipe_connections = { { direction = defines.direction.north, flow_direction = "input-output", position = { 0.5, -1.5 } } },
            secondary_draw_orders = { north = -1 },
        },
        {
            production_type = "output",
            pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
            pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
            pipe_covers = pipecoverspictures(),
            volume = 100,
            pipe_connections = { { direction = defines.direction.west, flow_direction = "input-output", position = { -1.5, 0.5 } } },
            secondary_draw_orders = { north = -1 },
        },
    },
    perceived_performance = { minimum = 0.25, performance_to_activity_rate = 20.0, maximum = 5 },
    off_when_no_fluid_recipe = true,
    graphics_set = {
        working_visualisations = working_visualisations
    },
    crafting_categories = {
        "maraxsis-hydro-plant",
        mods["Krastorio2-spaced-out"] and  "kr-fluid-filtration" or nil
    },
    scale_entity_info_icon = true,
    impact_category = data.raw["assembling-machine"]["electromagnetic-plant"].impact_category,
    idle_sound = { filename = "__base__/sound/idle1.ogg" },
    crafting_speed = 2,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {
            pollution = 6,
        }
    },
    icon_draw_specification = { scale = 1.75, shift = { 0, -0.3 } },
    energy_usage = "3MW",
    collision_mask = { layers = { item = true, object = true, player = true, water_tile = true } },
} }

data:extend { {
    type = "item",
    name = "maraxsis-hydro-plant",
    icon = "__maraxsis__/graphics/icons/hydro-plant.png",
    icon_size = 64,
    place_result = "maraxsis-hydro-plant",
    stack_size = 20,
    scale = 0.5,
} }

data:extend { {
    type = "recipe",
    name = "maraxsis-hydro-plant",
    enabled = false,
    energy_required = 5,
    ingredients = {
        { type = "item",  name = "tungsten-plate",        amount = 20 },
        { type = "item",  name = "pipe",                  amount = 10 },
        { type = "item",  name = "processing-unit",       amount = 10 },
        { type = "item",  name = "quality-module-3",       amount = 1 },
        { type = "fluid", name = "maraxsis-saline-water", amount = 300 },
    },
    results = {
        { type = "item", name = "maraxsis-hydro-plant", amount = 1 },
    },
    auto_recycle = true,
    categories = { "maraxsis-hydro-plant", "chemistry" },
    surface_conditions = maraxsis.surface_conditions(),
} }

local extra_module_slots = table.deepcopy(data.raw["assembling-machine"]["maraxsis-hydro-plant"])
extra_module_slots.name = "maraxsis-hydro-plant-extra-module-slots"
extra_module_slots.module_slots = extra_module_slots.module_slots + 4
extra_module_slots.icons_positioning = { {
    inventory_index = defines.inventory.crafter_modules, shift = { 0, 0.9 }, max_icons_per_row = 4
} }
extra_module_slots.hidden_in_factoriopedia = true
extra_module_slots.factoriopedia_alternative = "maraxsis-hydro-plant"
extra_module_slots.placeable_by = { { item = "maraxsis-hydro-plant", count = 1 } }
extra_module_slots.flags = { "placeable-player", "player-creation", "not-in-made-in" }

data:extend { extra_module_slots }

-- previously, maraxsis had a script that replaced the
-- hydro plant with its extra-module-slot variant in the
-- trench and on space platforms. this feature has been rolled into PlanetsLib
for surface_name in pairs(maraxsis_constants.MARAXSIS_TRENCH_SURFACES) do
    PlanetsLib.assign_entity_replacement(
        surface_name,
        "maraxsis-hydro-plant",
        extra_module_slots.name,
        "maraxsis-runtime-entity-replacement"
    )
end

PlanetsLib.assign_entity_replacement(
    "space-platform",
    "maraxsis-hydro-plant",
    extra_module_slots.name,
    "maraxsis-runtime-entity-replacement"
)
