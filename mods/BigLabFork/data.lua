local hit_effects = require("__base__/prototypes/entity/hit-effects")

data:extend{{
    type = "item",
    name = "big-lab",
    icon = "__BigLabFork__/biglab.png",
    icon_size = 32,
    subgroup = "production-machine",
    order = "z[lab]-b",
    place_result = "big-lab",
    stack_size = 1,
}, {
    type = "recipe",
    name = "big-lab",
    energy_required = 2,
    ingredients = {
        {type = "item", name = "electronic-circuit", amount = 25},
        {type = "item", name = "lab", amount = 25},
    },
    results = {{type = "item", name = "big-lab", amount = 1}},
}, {
    type = "lab",
    name = "big-lab",
    icon = "__BigLabFork__/biglab.png",
    icon_size = 32,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 1, result = "big-lab"},
    max_health = 1500,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-7.2, -7.2}, {7.2, 7.2}},
    selection_box = {{-7.5, -7.5}, {7.5, 7.5}},
    damaged_trigger_effect = hit_effects.entity(),
    light = {intensity = 0.75, size = 8, color = {r = 1.0, g = 1.0, b = 1.0}},
    on_animation = {
        layers = {{
            filename = "__base__/graphics/entity/lab/lab.png",
            width = 194,
            height = 174,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 1.5),
            scale = 2.5
        }, {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 242,
            height = 162,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 2.5
        }, {
            filename = "__base__/graphics/entity/lab/lab-light.png",
            blend_mode = "additive",
            draw_as_light = true,
            width = 216,
            height = 194,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 0),
            scale = 2.5
        }, {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 2.5,
            draw_as_shadow = true
        }},
    },
    off_animation = {
        layers = {{
            filename = "__base__/graphics/entity/lab/lab.png",
            width = 194,
            height = 174,
            shift = util.by_pixel(0, 1.5),
            scale = 2.5
        }, {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 242,
            height = 162,
            shift = util.by_pixel(0, 15.5),
            scale = 2.5
        }, {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            shift = util.by_pixel(13, 11),
            draw_as_shadow = true,
            scale = 2.5
        }}
    },
    working_sound = {
        sound = {
            filename = "__base__/sound/lab.ogg", volume = 0.7,
            modifiers = {volume_multiplier("main-menu", 2.2), volume_multiplier("tips-and-tricks", 0.8)} ---@diagnostic disable-line: undefined-global
        },
        audible_distance_modifier = 0.7,
        fade_in_ticks = 4,
        fade_out_ticks = 20
    },
    impact_category = "glass",
    open_sound = {filename = "__base__/sound/open-close/lab-open.ogg", volume = 0.6},
    close_sound = {filename = "__base__/sound/open-close/lab-close.ogg", volume = 0.6},
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
    },
    energy_usage = "1500kW",
    researching_speed = 25,
    inputs = {},
    module_slots = 6,
    icons_positioning = {
        {inventory_index = defines.inventory.lab_modules, shift = {0, 0.6}}, ---@diagnostic disable-line: assign-type-mismatch
        {inventory_index = defines.inventory.lab_input, shift = {0, 0}, separation_multiplier = 1/1.1}, ---@diagnostic disable-line: assign-type-mismatch
    },
}}

---@diagnostic disable: undefined-global
if DiscoScience and DiscoScience.prepareLab then
    DiscoScience.prepareLab(data.raw["lab"]["big-lab"])
end