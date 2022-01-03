-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if not (reskins.bobs and reskins.bobs.triggers.power.steam) then return end

-- Set input parameters
local inputs = {
    type = "boiler",
    icon_name = "heat-exchanger",
    base_entity_name = "heat-exchanger",
    mod = "bobs",
    group = "power",
    particles = {["big"] = 3},
}

local tier_map = {
    ["heat-exchanger"] = {1, 3},
    ["heat-exchanger-2"] = {2, 4},
    ["heat-exchanger-3"] = {3, 5},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end
    local pipe = map[1]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    -- Setup icon details
    inputs.icon_base = "heat-exchanger-"..pipe

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/heat-exchanger/remnants/heat-exchanger-remnants.png",
                line_length = 1,
                width = 136,
                height = 132,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(0, 8),
                hr_version = {
                    filename = "__base__/graphics/entity/heat-exchanger/remnants/hr-heat-exchanger-remnants.png",
                    line_length = 1,
                    width = 272,
                    height = 262,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0.5, 8),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/remnants/heatex-remnants-mask.png",
                line_length = 1,
                width = 136,
                height = 132,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(0, 8),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/remnants/hr-heatex-remnants-mask.png",
                    line_length = 1,
                    width = 272,
                    height = 262,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0.5, 8),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/remnants/heatex-remnants-highlights.png",
                line_length = 1,
                width = 136,
                height = 132,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(0, 8),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/remnants/hr-heatex-remnants-highlights.png",
                    line_length = 1,
                    width = 272,
                    height = 262,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0.5, 8),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            },
            -- Pipes
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/remnants/pipes/heatex-pipe-"..pipe.."-remnants.png",
                line_length = 1,
                width = 136,
                height = 132,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(0, 8),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/remnants/pipes/hr-heatex-pipe-"..pipe.."-remnants.png",
                    line_length = 1,
                    width = 272,
                    height = 262,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(0.5, 8),
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
                    filename = "__base__/graphics/entity/heat-exchanger/heatex-N-idle.png",
                    priority = "extra-high",
                    width = 131,
                    height = 108,
                    shift = util.by_pixel(-0.5, 4),
                    hr_version = {
                        filename = "__base__/graphics/entity/heat-exchanger/hr-heatex-N-idle.png",
                        priority = "extra-high",
                        width = 269,
                        height = 221,
                        shift = util.by_pixel(-1.25, 5.25),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-N-idle-mask.png",
                    priority = "extra-high",
                    width = 131,
                    height = 108,
                    shift = util.by_pixel(-0.5, 4),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-N-idle-mask.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-N-idle-highlights.png",
                    priority = "extra-high",
                    width = 131,
                    height = 108,
                    shift = util.by_pixel(-0.5, 4),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-N-idle-highlights.png",
                        priority = "extra-high",
                        width = 269,
                        height = 221,
                        shift = util.by_pixel(-1.25, 5.25),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Pipes
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/heatex-N-pipe-"..pipe..".png",
                    priority = "extra-high",
                    width = 131,
                    height = 108,
                    shift = util.by_pixel(-0.5, 4),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/hr-heatex-N-pipe-"..pipe..".png",
                        priority = "extra-high",
                        width = 269,
                        height = 221,
                        shift = util.by_pixel(-1.25, 5.25),
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
                    filename = "__base__/graphics/entity/heat-exchanger/heatex-E-idle.png",
                    priority = "extra-high",
                    width = 102,
                    height = 147,
                    shift = util.by_pixel(-2, -0.5),
                    hr_version = {
                        filename = "__base__/graphics/entity/heat-exchanger/hr-heatex-E-idle.png",
                        priority = "extra-high",
                        width = 211,
                        height = 301,
                        shift = util.by_pixel(-1.75, 1.25),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-E-idle-mask.png",
                    priority = "extra-high",
                    width = 102,
                    height = 147,
                    shift = util.by_pixel(-2, -0.5),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-E-idle-mask.png",
                        priority = "extra-high",
                        width = 211,
                        height = 301,
                        shift = util.by_pixel(-1.75, 1.25),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-E-idle-highlights.png",
                    priority = "extra-high",
                    width = 102,
                    height = 147,
                    shift = util.by_pixel(-2, -0.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-E-idle-highlights.png",
                        priority = "extra-high",
                        width = 211,
                        height = 301,
                        shift = util.by_pixel(-1.75, 1.25),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Pipes
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/heatex-E-pipe-"..pipe..".png",
                    priority = "extra-high",
                    width = 102,
                    height = 147,
                    shift = util.by_pixel(-2, -0.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/hr-heatex-E-pipe-"..pipe..".png",
                        priority = "extra-high",
                        width = 211,
                        height = 301,
                        shift = util.by_pixel(-1.75, 1.25),
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
                    filename = "__base__/graphics/entity/heat-exchanger/heatex-S-idle.png",
                    priority = "extra-high",
                    width = 128,
                    height = 100,
                    shift = util.by_pixel(3, 10),
                    hr_version = {
                        filename = "__base__/graphics/entity/heat-exchanger/hr-heatex-S-idle.png",
                        priority = "extra-high",
                        width = 260,
                        height = 201,
                        shift = util.by_pixel(4, 10.75),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-S-idle-mask.png",
                    priority = "extra-high",
                    width = 128,
                    height = 100,
                    shift = util.by_pixel(3, 10),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-S-idle-mask.png",
                        priority = "extra-high",
                        width = 260,
                        height = 201,
                        shift = util.by_pixel(4, 10.75),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-S-idle-highlights.png",
                    priority = "extra-high",
                    width = 128,
                    height = 100,
                    shift = util.by_pixel(3, 10),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-S-idle-highlights.png",
                        priority = "extra-high",
                        width = 260,
                        height = 201,
                        shift = util.by_pixel(4, 10.75),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Pipes
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/heatex-S-pipe-"..pipe..".png",
                    priority = "extra-high",
                    width = 128,
                    height = 100,
                    shift = util.by_pixel(3, 10),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/hr-heatex-S-pipe-"..pipe..".png",
                        priority = "extra-high",
                        width = 260,
                        height = 201,
                        shift = util.by_pixel(4, 10.75),
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
                    filename = "__base__/graphics/entity/heat-exchanger/heatex-W-idle.png",
                    priority = "extra-high",
                    width = 96,
                    height = 132,
                    shift = util.by_pixel(1, 5),
                    hr_version = {
                        filename = "__base__/graphics/entity/heat-exchanger/hr-heatex-W-idle.png",
                        priority = "extra-high",
                        width = 196,
                        height = 273,
                        shift = util.by_pixel(1.5, 7.75),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-W-idle-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 132,
                    shift = util.by_pixel(1, 5),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-W-idle-mask.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heatex-W-idle-highlights.png",
                    priority = "extra-high",
                    width = 96,
                    height = 132,
                    shift = util.by_pixel(1, 5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/hr-heatex-W-idle-highlights.png",
                        priority = "extra-high",
                        width = 196,
                        height = 273,
                        shift = util.by_pixel(1.5, 7.75),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Pipes
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/heatex-W-pipe-"..pipe..".png",
                    priority = "extra-high",
                    width = 96,
                    height = 132,
                    shift = util.by_pixel(1, 5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/pipes/hr-heatex-W-pipe-"..pipe..".png",
                        priority = "extra-high",
                        width = 196,
                        height = 273,
                        shift = util.by_pixel(1.5, 7.75),
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

    entity.energy_source.pipe_covers = reskins.lib.make_4way_animation_from_spritesheet({
        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/base/heatex-endings-"..pipe..".png",
        width = 32,
        height = 32,
        direction_count = 4,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/base/hr-heatex-endings-"..pipe..".png",
            width = 64,
            height = 64,
            direction_count = 4,
            scale = 0.5
        }
    })

    -- Label to skip to next iteration
    ::continue::
end