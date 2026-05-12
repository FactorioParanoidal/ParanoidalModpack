-- if you don't have space age, this thing would just produce water
if not mods["space-age"] then return end
if mods["space-is-fake"] then return end

-- py basically already has this feature
if mods.pypetroleumhandling then return end

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local F = "__factorissimo-2-notnotmelon__"
local pf = "p-q-"

data:extend {{
    type = "item",
    name = "borehole-pump",
    icon = F .. "/graphics/icon/borehole-pump.png",
    icon_size = 64,
    flags = {},
    subgroup = "factorissimo2",
    order = "c-c",
    place_result = "borehole-pump",
    stack_size = 10,
}}

data:extend {{
    type = "recipe",
    name = "borehole-pump",
    enabled = false,
    ingredients = {
        {type = "item", name = "offshore-pump",        amount = 3},
        {type = "item", name = "tungsten-plate",       amount = 50},
        {type = "item", name = "electric-engine-unit", amount = 10},
        {type = "item", name = "pipe-to-ground",       amount = 10},
    },
    results = {
        {type = "item", name = "borehole-pump", amount = 1},
    },
    energy_required = 5,
}}

data:extend {{
    type = "technology",
    name = "factory-upgrade-borehole-pump",
    icon = F .. "/graphics/technology/factory-upgrade-borehole-pump.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t3", "electromagnetic-science-pack"},
    effects = {
        {type = "unlock-recipe", recipe = "borehole-pump"},
    },
    unit = {
        count = 2000,
        ingredients = {
            {"automation-science-pack",      1},
            {"logistic-science-pack",        1},
            {"chemical-science-pack",        1},
            {"space-science-pack",           1},
            {"utility-science-pack",         1},
            {"metallurgic-science-pack",     1},
            {"electromagnetic-science-pack", 1},
        },
        time = 60
    },
    order = pf .. "d-c",
}}

local function get_shifted_underground_pipe_picture(direction, shift)
    local underground_pipe_pictures = data.raw["pipe-to-ground"]["pipe-to-ground"].pictures
    local picture = table.deepcopy(underground_pipe_pictures[direction])
    picture.shift = shift
    return picture
end

data:extend {{
    type = "assembling-machine",
    name = "borehole-pump",
    fixed_quality = "normal",
    heating_energy = data.raw["assembling-machine"]["assembling-machine-3"].heating_energy,
    flags = {"placeable-neutral", "player-creation"},
    icon = F .. "/graphics/icon/borehole-pump.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation", "filter-directions"},
    minable = {mining_time = 0.5, result = "borehole-pump"},
    max_health = 450,
    corpse = "burner-mining-drill-remnants",
    dying_explosion = "burner-mining-drill-explosion",
    resistances = table.deepcopy(data.raw["offshore-pump"]["offshore-pump"].resistances),
    collision_box = {{-0.9, -1.4}, {0.9, 1.4}},
    selection_box = {{-1, -1.5}, {1, 1.5}},
    damaged_trigger_effect = hit_effects.entity(),
    fluid_boxes = {{
        volume = 500,
        pipe_covers = pipecoverspictures(),
        production_type = "output",
        pipe_connections = {
            {
                position = {0.5, 1},
                flow_direction = "output",
                direction = defines.direction.south
            },
        }
    }},
    impact_category = "default",
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    working_sound = {
        sound = {
            {
                filename = "__base__/sound/offshore-pump.ogg",
                volume = 0.7,
                speed = 0.7,
            },
            {
                filename = "__base__/sound/burner-mining-drill-1.ogg",
                volume = 0.75
            },
            {
                filename = "__base__/sound/burner-mining-drill-2.ogg",
                volume = 0.75
            }
        },
        match_volume_to_activity = true,
        audible_distance_modifier = 0.7,
        max_sounds_per_type = 3,
        fade_in_ticks = 4,
        fade_out_ticks = 20,
    },
    graphics_set = {
        underwater_layer_offset = 30,
        base_render_layer = "ground-patch",
        animation =
        {
            north = {
                layers = {
                    get_shifted_underground_pipe_picture("south", util.by_pixel(16, 32)),
                    {
                        priority = "high",
                        filename = F .. "/graphics/entity/borehole-pump-n.png",
                        line_length = 1,
                        width = 224,
                        height = 282,
                        scale = 0.5,
                        frame_count = 1,
                        direction_count = 1,
                        shift = util.by_pixel(0, -24),
                        repeat_count = 1,
                    },
                    {
                        filename = F .. "/graphics/entity/borehole-pump-n-sh.png",
                        priority = "high",
                        width = 332,
                        height = 226,
                        direction_count = 1,
                        shift = util.by_pixel(30, 2),
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                }
            },
            east = {
                layers = {
                    get_shifted_underground_pipe_picture("west", util.by_pixel(-32, 16)),
                    {
                        priority = "high",
                        filename = F .. "/graphics/entity/borehole-pump-e.png",
                        line_length = 1,
                        width = 224,
                        height = 282,
                        scale = 0.5,
                        frame_count = 1,
                        direction_count = 1,
                        shift = util.by_pixel(0, -24),
                        repeat_count = 1,
                    },
                    {
                        filename = F .. "/graphics/entity/borehole-pump-e-sh.png",
                        priority = "high",
                        width = 332,
                        height = 226,
                        direction_count = 1,
                        shift = util.by_pixel(30, 2),
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                }
            },
            south = {
                layers = {
                    get_shifted_underground_pipe_picture("north", util.by_pixel(-16, -32)),
                    {
                        priority = "high",
                        filename = F .. "/graphics/entity/borehole-pump-s.png",
                        line_length = 1,
                        width = 224,
                        height = 282,
                        scale = 0.5,
                        frame_count = 1,
                        direction_count = 1,
                        shift = util.by_pixel(0, -24),
                        repeat_count = 1,
                    },
                    {
                        filename = F .. "/graphics/entity/borehole-pump-s-sh.png",
                        priority = "high",
                        width = 332,
                        height = 226,
                        direction_count = 1,
                        shift = util.by_pixel(30, 2),
                        draw_as_shadow = true,
                        scale = 0.5,
                    },

                }
            },
            west = {
                layers = {
                    get_shifted_underground_pipe_picture("east", util.by_pixel(32, -16)),
                    {
                        priority = "high",
                        filename = F .. "/graphics/entity/borehole-pump-w.png",
                        line_length = 1,
                        width = 224,
                        height = 282,
                        scale = 0.5,
                        frame_count = 1,
                        direction_count = 1,
                        shift = util.by_pixel(0, -24),
                        repeat_count = 1,
                    },
                    {
                        filename = F .. "/graphics/entity/borehole-pump-w-sh.png",
                        priority = "high",
                        width = 332,
                        height = 226,
                        direction_count = 1,
                        shift = util.by_pixel(30, 9),
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                }
            },
        },
    },
    circuit_connector = table.deepcopy(circuit_connector_definitions["burner-mining-drill"]),
    circuit_wire_max_distance = _G.default_circuit_wire_max_distance,
    enable_logistic_control_behavior = false,
    ingredient_count = 0,
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    module_slots = 2,
    crafting_speed = 1,
    crafting_categories = {"borehole-pump"},
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input",
        emissions_per_minute = {
            pollution = 15
        },
    },
    energy_usage = "1.65MW",
    surface_conditions = {{
        property = "ceiling",
        max = 0,
    }},
    return_ingredients_on_change = false
}}

data:extend {{
    type = "recipe-category",
    name = "borehole-pump"
}}

data:extend {{
    name = "borehole-pump-smokestack",
    type = "fire",
    damage_per_tick = {amount = 0, type = "physical"},
    spread_delay = 0,
    spread_delay_deviation = 0,
    smoke = {{
        name = "light-smoke",
        north_position = {0.9, 0.0},
        east_position = {-2.0, -2.0},
        frequency = 10 / 32 * 20,
        starting_vertical_speed = 0.08,
        starting_frame_deviation = 60,
        deviation = {0.3, 0.3},
        vertical_speed_slowdown = 0.965,
    }},
    flags = {"placeable-off-grid", "not-on-map"},
    initial_lifetime = 33,
    maximum_lifetime = 33,
    lifetime_increase_by = 0,
    burnt_patch_lifetime = 0,
    icon = data.raw.fire["fire-flame"].icon,
    icon_size = 64,
    hidden = true
}}
