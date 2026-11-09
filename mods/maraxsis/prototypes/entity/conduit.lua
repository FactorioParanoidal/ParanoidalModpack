data:extend {{
    type = "item",
    name = "maraxsis-conduit",
    stack_size = data.raw.item.beacon.stack_size,
    icon = "__maraxsis__/graphics/icons/conduit.png",
    icon_size = 64,
    place_result = "maraxsis-conduit",
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-conduit",
    enabled = false,
    energy_required = 15,
    ingredients = {
        {type = "item", name = "beacon",                           amount = 1},
        {type = "item", name = "maraxsis-glass-panes",             amount = 25},
        {type = "item", name = "superconductor",                  amount = 25},
        {type = "item", name = "maraxsis-super-sealant-substance", amount = 15},
    },
    results = {
        {type = "item", name = "maraxsis-conduit", amount = 1},
    },
    allow_productivity = false,
    categories = {"maraxsis-hydro-plant"},
    auto_recycle = true,
    surface_conditions = maraxsis.surface_conditions(),
}}

data:extend {{
    type = "technology",
    name = "maraxsis-effect-transmission-2",
    icon = "__maraxsis__/graphics/technology/conduit.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-conduit",
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-holmium-recrystalization",
        },
    },
    -- Paranoidal fork: no epic quality technology (hidden in the build, qualities are unlocked by script).
    prerequisites = {"effect-transmission", "maraxsis-project-seadragon", "electromagnetic-science-pack"},
    unit = {
        count = 5000,
        ingredients = {
            {"electromagnetic-science-pack", 1},
            {"hydraulic-science-pack",       1},
        },
        time = 60,
    },
    localised_description = {"entity-description.maraxsis-conduit"},
}}

local total = 0
local profile = {}
for i = 1, 5000 do
    total = total + (0.5 * 2 ^ (-i + 2))
    profile[i] = total / i
end

data:extend {maraxsis.merge(data.raw.beacon.beacon, {
    name = "maraxsis-conduit",
    -- Paranoidal fork: the copied home beacon upgrades into Bob's beacon 2 (another collision mask: the engine refuses).
    next_upgrade = "nil",
    fast_replaceable_group = "nil",
    max_health = 300,
    heating_energy = "1.0MW",
    minable = {mining_time = 0.3, result = "maraxsis-conduit"},
    maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false},
    graphics_set = {
        draw_animation_when_idle = false,
        draw_light_when_idle = false,
        reset_animation_when_frozen = true,
        apply_module_tint = "primary",
        animation_list = {
            {
                animation = {
                    layers = {
                        {
                            filename = "__maraxsis__/graphics/entity/conduit/conduit.png",
                            frame_count = 60,
                            line_length = 8,
                            width = 1600 / 8,
                            height = 2320 / 8,
                            scale = 0.5,
                            flags = {"no-scale"},
                            shift = {0, -0.5},
                        },
                        {
                            filename = "__maraxsis__/graphics/entity/conduit/sh.png",
                            repeat_count = 60,
                            width = 600,
                            height = 400,
                            scale = 0.5,
                            draw_as_shadow = true,
                            shift = {0, -0.5},
                        }
                    },
                },
                apply_tint = false,
            },
            {
                animation = {
                    filename = "__maraxsis__/graphics/entity/conduit/emission.png",
                    frame_count = 60,
                    line_length = 8,
                    width = 1600 / 8,
                    height = 2320 / 8,
                    draw_as_glow = true,
                    blend_mode = "additive-soft",
                    scale = 0.5,
                    shift = {0, -0.5},
                },
                apply_tint = true,
            }
        },
        module_tint_mode = "mix",

    },
    animation = "nil",
    base_picture = "nil",
    allowed_effects = {"consumption", "speed", "pollution", "quality"},
    beacon_counter = "same_type",
    energy_usage = "6MW",
    module_slots = 4,
    icons_positioning = {{inventory_index = defines.inventory.beacon_modules, max_icons_per_row = 2, shift = {0, 0.5}}},
    profile = profile,
    icon = "__maraxsis__/graphics/icons/conduit.png",
    icon_size = 64,
    supply_area_distance = 16,
    distribution_effectivity = 0.5,
    distribution_effectivity_bonus_per_quality_level = 0.05
})}
