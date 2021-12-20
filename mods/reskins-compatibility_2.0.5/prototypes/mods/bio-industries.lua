-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["Bio_Industries"] then return end
if reskins.lib.migration.is_version_or_newer(mods["Bio_Industries"], "1.2.0") then return end -- Handle the graphics overhaul when it lands

-- Setup inputs
local inputs = {
    mod = "compatibility",
    group = "bio-industries",
    make_icon_pictures = false,
    flat_icon = true,
}

local shift_upleft = {-8, -8}
local shift_upright = {8, -8}
local scale = 0.5

local intermediates = {}

if (reskins.bobs and reskins.bobs.triggers.greenhouse.items) then
    intermediates["seedling"] = {mod = "bobs", group = "greenhouse", subgroup = "items"}
end

if (reskins.bobs and reskins.bobs.triggers.electronics.items) then
    intermediates["bob-resin-wood"] = {mod = "bobs", type = "recipe", group = "plates", subgroup = "recipes"}
end

if (reskins.bobs and reskins.bobs.triggers.plates.items) then
    intermediates["carbon"] = {mod = "bobs", group = "plates", subgroup = "items"}
end

reskins.lib.create_icons_from_list(intermediates, inputs)

local composite_recipes = {
    -- Seeds
    ["bi-seed-1"] = {["bi-seed"] = {}, ["water"] = {type = "fluid", scale = scale, shift = shift_upleft}},
    ["bi-seed-2"] = {["bi-seed"] = {}, ["bi-ash"] = {scale = scale, shift = shift_upleft}},
    ["bi-seed-3"] = {["bi-seed"] = {}, ["fertilizer"] = {scale = scale, shift = shift_upleft}},
    ["bi-seed-4"] = {["bi-seed"] = {}, ["bi-adv-fertilizer"] = {scale = scale, shift = shift_upleft}},

    -- Seedlings
    ["bi-seedling-1"] = {["seedling"] = {}, ["water"] = {type = "fluid", scale = scale, shift = shift_upleft}},
    ["bi-seedling-2"] = {["seedling"] = {}, ["bi-ash"] = {scale = scale, shift = shift_upleft}},
    ["bi-seedling-3"] = {["seedling"] = {}, ["fertilizer"] = {scale = scale, shift = shift_upleft}},
    ["bi-seedling-4"] = {["seedling"] = {}, ["bi-adv-fertilizer"] = {scale = scale, shift = shift_upleft}},

    -- Wood
    ["bi-logs-1"] = {["wood"] = {}, ["water"] = {type = "fluid", scale = scale, shift = shift_upleft}},
    ["bi-logs-2"] = {["wood"] = {}, ["bi-ash"] = {scale = scale, shift = shift_upleft}},
    ["bi-logs-3"] = {["wood"] = {}, ["fertilizer"] = {scale = scale, shift = shift_upleft}},
    ["bi-logs-4"] = {["wood"] = {}, ["bi-adv-fertilizer"] = {scale = scale, shift = shift_upleft}},

    -- Miscellaneous
    ["bi-battery"] = {["battery"] = {}, ["bi-biomass"] = {type = "fluid", scale = scale, shift = shift_upleft}},
    ["bi-sulfur"] = {["sulfur"] = {}, ["bi-ash"] = {scale = scale, shift = shift_upleft}},
    ["bi-acid"] = {["sulfuric-acid"] = {type = "fluid"}, ["bi-biomass"] = {type = "fluid", scale = scale, shift = shift_upleft}},
    ["bi-basic-gas-processing"] = {["petroleum-gas"] = {type = "fluid"}, ["coal"] = {scale = scale, shift = shift_upleft}, ["resin"] = {scale = scale, shift = shift_upright}},
    ["bi-solid-fuel"] = {["solid-fuel"] = {}, ["wood-bricks"] = {scale = scale, shift = shift_upleft}},

    -- Wood and Pulp related recipes
    ["bi-woodpulp"] = {["bi-woodpulp"] = {}, ["wood"] = {scale = scale, shift = shift_upleft}},
    ["bi-resin-pulp"] = {["resin"] = {}, ["bi-woodpulp"] = {scale = scale, shift = shift_upleft}},
    ["bi-wood-from-pulp"] = {["wood"] = {}, ["bi-woodpulp"] = {scale = scale, shift = shift_upleft}, ["resin"] = {scale = scale, shift = shift_upright}},

    -- Ash
    ["bi-ash-1"] = {["bi-ash"] = {}, ["wood"] = {scale = scale, shift = shift_upleft}},
    ["bi-ash-2"] = {["bi-ash"] = {}, ["bi-woodpulp"] = {scale = scale, shift = shift_upleft}},

    -- Charcoal
    ["bi-charcoal-1"] = {["wood-charcoal"] = {}, ["bi-woodpulp"] = {scale = scale, shift = shift_upleft}},
    ["bi-charcoal-2"] = {["wood-charcoal"] = {}, ["wood"] = {scale = scale, shift = shift_upleft}},

    -- Pellets
    ["bi-coke-coal"] = {["pellet-coke"] = {}, ["coal"] = {scale = scale, shift = shift_upleft}},
    ["bi-pellet-coke"] = {["pellet-coke"] = {}, ["solid-fuel"] = {scale = scale, shift = shift_upleft}},
    ["bi-pellet-coke-2"] = {["pellet-coke"] = {}, ["carbon"] = {scale = scale, shift = shift_upleft}},

    -- Stone and Crushed Stone
    ["bi-stone-brick"] = {["stone-brick"] = {}, ["bi-ash"] = {scale = scale, shift = shift_upleft}, ["stone-crushed"] = {scale = scale, shift = shift_upright}},
    ["bi-crushed-stone-1"] = {["stone-crushed"] = {}, ["stone"] = {scale = scale, shift = shift_upleft}},
    ["bi-crushed-stone-2"] = {["stone-crushed"] = {}, ["concrete"] = {scale = scale, shift = shift_upleft}},
    ["bi-crushed-stone-3"] = {["stone-crushed"] = {}, ["hazard-concrete"] = {scale = scale, shift = shift_upleft}},
    ["bi-crushed-stone-4"] = {["stone-crushed"] = {}, ["refined-concrete"] = {scale = scale, shift = shift_upleft}},
    ["bi-crushed-stone-5"] = {["stone-crushed"] = {}, ["refined-hazard-concrete"] = {scale = scale, shift = shift_upleft}},

    -- Fertilizer
    ["bi-fertilizer-1"] = {["fertilizer"] = {}, ["sulfur"] = {scale = scale, shift = shift_upleft}},
    ["bi-fertilizer-2"] = {["fertilizer"] = {}, ["sodium-hydroxide"] = {scale = scale, shift = shift_upleft}},
    ["bi-adv-fertilizer-1"] = {["bi-adv-fertilizer"] = {}, ["alien-artifact"] = {scale = scale, shift = shift_upleft}},
    ["bi-adv-fertilizer-2"] = {["bi-adv-fertilizer"] = {}, ["bi-biomass"] = {type = "fluid", scale = scale, shift = shift_upleft}},

    -- Plastic
    ["bi-plastic-1"] = {["plastic-bar"] = {}, ["wood"] = {scale = scale, shift = shift_upleft}},
    ["bi-plastic-2"] = {["plastic-bar"] = {}, ["bi-cellulose"] = {scale = scale, shift = shift_upleft}},

    -- Cellulose
    ["bi-cellulose-2"] = {["bi-cellulose"] = {}, ["steam"] = {type = "fluid", scale = scale, shift = shift_upleft}},
}

if mods["bobelectronics"] and reskins.lib.setting("reskins-bobs-do-bobelectronics-circuit-style") ~= "off" then
    composite_recipes["wooden-board"] = {["wooden-board"] = {}, ["wood"] = {scale = scale, shift = shift_upleft}}
    composite_recipes["bi-press-wood"] = {["wooden-board"] = {}, ["bi-woodpulp"] = {scale = scale, shift = shift_upleft}, ["resin"] = {scale = scale, shift = shift_upright}}
end

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end

-- BOILER
if reskins.bobs and reskins.bobs.triggers.power.entities then
    -- Set input parameters
    local inputs = {
        type = "boiler",
        base_entity = "boiler",
        icon_name = "boiler",
        mod = "bobs",
        group = "power",
        particles = {["big"] = 3},
    }

    local boilers = {
        ["bi-bio-boiler"] = {tint = util.color("80801a")}
    }

    for name, map in pairs(boilers) do
        -- Fetch entity
        local entity = data.raw[inputs.type][name]

        -- Check if entity exists, if not, skip this iteration
        if not entity then goto continue end

        inputs.tint = map.tint

        reskins.lib.setup_standard_entity(name, 0, inputs)

        -- Fetch remnant
        local remnant = data.raw["corpse"][name.."-remnants"]

        -- Reskin remnants
        remnant.animation = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/boiler/remnants/boiler-remnants.png",
                    line_length = 1,
                    width = 138,
                    height = 110,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0, -3),
                    hr_version = {
                        filename = "__base__/graphics/entity/boiler/remnants/hr-boiler-remnants.png",
                        line_length = 1,
                        width = 274,
                        height = 220,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        shift = util.by_pixel(-0.5, -3),
                        scale = 0.5,
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/boiler-remnants-mask.png",
                    line_length = 1,
                    width = 138,
                    height = 110,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0, -3),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/hr-boiler-remnants-mask.png",
                        line_length = 1,
                        width = 274,
                        height = 220,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        shift = util.by_pixel(-0.5, -3),
                        tint = inputs.tint,
                        scale = 0.5,
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/boiler-remnants-highlights.png",
                    line_length = 1,
                    width = 138,
                    height = 110,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0, -3),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/remnants/hr-boiler-remnants-highlights.png",
                        line_length = 1,
                        width = 274,
                        height = 220,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 4,
                        shift = util.by_pixel(-0.5, -3),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    }
                }
            }
        }

        -- Reskin entities
        entity.structure = {
            north = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-N-idle.png",
                        priority = "extra-high",
                        width = 131,
                        height = 108,
                        shift = util.by_pixel(-0.5, 4),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-N-idle.png",
                            priority = "extra-high",
                            width = 269,
                            height = 221,
                            shift = util.by_pixel(-1.25, 5.25),
                            scale = 0.5
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-N-idle-mask.png",
                        priority = "extra-high",
                        width = 131,
                        height = 108,
                        shift = util.by_pixel(-0.5, 4),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-N-idle-mask.png",
                            priority = "extra-high",
                            width = 269,
                            height = 221,
                            shift = util.by_pixel(-1.25, 5.25),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-N-idle-highlights.png",
                        priority = "extra-high",
                        width = 131,
                        height = 108,
                        shift = util.by_pixel(-0.5, 4),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-N-idle-highlights.png",
                            priority = "extra-high",
                            width = 269,
                            height = 221,
                            shift = util.by_pixel(-1.25, 5.25),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-N-shadow.png",
                        priority = "extra-high",
                        width = 137,
                        height = 82,
                        shift = util.by_pixel(20.5, 9),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-N-shadow.png",
                            priority = "extra-high",
                            width = 274,
                            height = 164,
                            scale = 0.5,
                            shift = util.by_pixel(20.5, 9),
                            draw_as_shadow = true
                        }
                    }
                }
            },
            east = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-E-idle.png",
                        priority = "extra-high",
                        width = 105,
                        height = 147,
                        shift = util.by_pixel(-3.5, -0.5),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-E-idle.png",
                            priority = "extra-high",
                            width = 216,
                            height = 301,
                            shift = util.by_pixel(-3, 1.25),
                            scale = 0.5
                        }
                    },
                    -- Color mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-E-idle-mask.png",
                        priority = "extra-high",
                        width = 105,
                        height = 147,
                        shift = util.by_pixel(-3.5, -0.5),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-E-idle-mask.png",
                            priority = "extra-high",
                            width = 216,
                            height = 301,
                            shift = util.by_pixel(-3, 1.25),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-E-idle-highlights.png",
                        priority = "extra-high",
                        width = 105,
                        height = 147,
                        shift = util.by_pixel(-3.5, -0.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-E-idle-highlights.png",
                            priority = "extra-high",
                            width = 216,
                            height = 301,
                            shift = util.by_pixel(-3, 1.25),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-E-shadow.png",
                        priority = "extra-high",
                        width = 92,
                        height = 97,
                        shift = util.by_pixel(30, 9.5),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-E-shadow.png",
                            priority = "extra-high",
                            width = 184,
                            height = 194,
                            scale = 0.5,
                            shift = util.by_pixel(30, 9.5),
                            draw_as_shadow = true
                        }
                    }
                }
            },
            south = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-S-idle.png",
                        priority = "extra-high",
                        width = 128,
                        height = 95,
                        shift = util.by_pixel(3, 12.5),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-S-idle.png",
                            priority = "extra-high",
                            width = 260,
                            height = 192,
                            shift = util.by_pixel(4, 13),
                            scale = 0.5
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-S-idle-mask.png",
                        priority = "extra-high",
                        width = 128,
                        height = 95,
                        shift = util.by_pixel(3, 12.5),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-S-idle-mask.png",
                            priority = "extra-high",
                            width = 260,
                            height = 192,
                            shift = util.by_pixel(4, 13),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-S-idle-highlights.png",
                        priority = "extra-high",
                        width = 128,
                        height = 95,
                        shift = util.by_pixel(3, 12.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-S-idle-highlights.png",
                            priority = "extra-high",
                            width = 260,
                            height = 192,
                            shift = util.by_pixel(4, 13),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-S-shadow.png",
                        priority = "extra-high",
                        width = 156,
                        height = 66,
                        shift = util.by_pixel(30, 16),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-S-shadow.png",
                            priority = "extra-high",
                            width = 311,
                            height = 131,
                            scale = 0.5,
                            shift = util.by_pixel(29.75, 15.75),
                            draw_as_shadow = true
                        }
                    }
                }
            },
            west = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-W-idle.png",
                        priority = "extra-high",
                        width = 96,
                        height = 132,
                        shift = util.by_pixel(1, 5),
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-W-idle.png",
                            priority = "extra-high",
                            width = 196,
                            height = 273,
                            shift = util.by_pixel(1.5, 7.75),
                            scale = 0.5
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-W-idle-mask.png",
                        priority = "extra-high",
                        width = 96,
                        height = 132,
                        shift = util.by_pixel(1, 5),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-W-idle-mask.png",
                            priority = "extra-high",
                            width = 196,
                            height = 273,
                            shift = util.by_pixel(1.5, 7.75),
                            tint = inputs.tint,
                            scale = 0.5
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/power/boiler/boiler-W-idle-highlights.png",
                        priority = "extra-high",
                        width = 96,
                        height = 132,
                        shift = util.by_pixel(1, 5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/power/boiler/hr-boiler-W-idle-highlights.png",
                            priority = "extra-high",
                            width = 196,
                            height = 273,
                            shift = util.by_pixel(1.5, 7.75),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                            scale = 0.5
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/boiler/boiler-W-shadow.png",
                        priority = "extra-high",
                        width = 103,
                        height = 109,
                        shift = util.by_pixel(19.5, 6.5),
                        draw_as_shadow = true,
                        hr_version = {
                            filename = "__base__/graphics/entity/boiler/hr-boiler-W-shadow.png",
                            priority = "extra-high",
                            width = 206,
                            height = 218,
                            scale = 0.5,
                            shift = util.by_pixel(19.5, 6.5),
                            draw_as_shadow = true
                        }
                    }
                }
            }
        }

        entity.fluid_box.pipe_covers = pipecoverspictures()
        entity.output_fluid_box.pipe_covers = pipecoverspictures()

        -- Handle ambient-light
        entity.energy_source.light_flicker = {
            color = {0, 0, 0},
            minimum_light_size = 0,
            light_intensity_to_size_coefficient = 0,
        }

        -- Label to skip to next iteration
        ::continue::
    end
end

-- Recipe fixes
data.raw.recipe["bi-bio-boiler"].normal.main_product = nil
data.raw.recipe["bi-bio-boiler"].expensive.main_product = nil