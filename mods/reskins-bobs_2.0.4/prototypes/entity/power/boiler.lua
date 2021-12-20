-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if not (reskins.bobs and reskins.bobs.triggers.power.steam) then return end

-- Set input parameters
local inputs = {
    type = "boiler",
    base_entity = "boiler",
    mod = "bobs",
    group = "power",
    particles = {["big"] = 3},
}

local tier_map = {
    ["boiler"] = {1, 1},
    ["boiler-2"] = {2, 2},
    ["boiler-3"] = {3, 3},
    ["boiler-4"] = {4, 4},
    ["boiler-5"] = {5, 5},
    ["oil-boiler"] = {1, 2, true},
    ["oil-boiler-2"] = {2, 3, true},
    ["oil-boiler-3"] = {3, 4, true},
    ["oil-boiler-4"] = {4, 5, true},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end
    local has_fluids = map[3]

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    -- Setup icon details
    if has_fluids == true then
        inputs.icon_name = "oil-boiler"
    else
        inputs.icon_name = "boiler"
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

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

    -- Handle ambient-light
    entity.energy_source.light_flicker = {
        color = {0, 0, 0},
        minimum_light_size = 0,
        light_intensity_to_size_coefficient = 0,
    }

    -- Handle pipes
    if has_fluids then
        entity.energy_source.fluid_box.pipe_covers = pipecoverspictures()
        entity.energy_source.fluid_box.pipe_picture = reskins.bobs.assembly_pipe_pictures(inputs.tint)
    end

    -- Label to skip to next iteration
    ::continue::
end