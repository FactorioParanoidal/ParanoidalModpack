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
    ["heat-exchanger"] = {tier = 1, prog_tier = 3, material = "base"},
    ["heat-exchanger-2"] = {tier = 2, prog_tier = 4, material = "silver-aluminum"},
    ["heat-exchanger-3"] = {tier = 3, prog_tier = 5, material = "gold-copper"},
}

if reskins.lib.migration.is_version_or_newer(mods["bobpower"], "1.1.6") then
    tier_map["heat-exchanger"].prog_tier = 2

    tier_map["heat-exchanger-2"].material = "aluminum-invar"
    tier_map["heat-exchanger-2"].prog_tier = 3

    tier_map["heat-exchanger-3"].material = "silver-titanium"
    tier_map["heat-exchanger-3"].prog_tier = 4

    tier_map["heat-exchanger-4"] = {
        tier = 4,
        prog_tier = 5,
        material = "gold-copper",
    }
end

-- Reskin entities, create and assign extra details
for name, mapping in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Parse map
    local tier = mapping.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = mapping.prog_tier or mapping.tier
    end

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    -- Setup icon details
    inputs.icon_base = "heat-exchanger-"..mapping.material

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
                filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/heatex-remnants.png",
                line_length = 1,
                width = 136,
                height = 132,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(0, 8),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/hr-heatex-remnants.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/heatex-N-idle.png",
                    priority = "extra-high",
                    width = 131,
                    height = 108,
                    shift = util.by_pixel(-0.5, 4),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/hr-heatex-N-idle.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/heatex-E-idle.png",
                    priority = "extra-high",
                    width = 102,
                    height = 147,
                    shift = util.by_pixel(-2, -0.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/hr-heatex-E-idle.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/heatex-S-idle.png",
                    priority = "extra-high",
                    width = 128,
                    height = 100,
                    shift = util.by_pixel(3, 10),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/hr-heatex-S-idle.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/heatex-W-idle.png",
                    priority = "extra-high",
                    width = 96,
                    height = 132,
                    shift = util.by_pixel(1, 5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/hr-heatex-W-idle.png",
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
        filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/heatex-endings.png",
        width = 32,
        height = 32,
        direction_count = 4,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/power/heat-exchanger/heat-pipes/"..mapping.material.."/hr-heatex-endings.png",
            width = 64,
            height = 64,
            direction_count = 4,
            scale = 0.5
        }
    })

    -- Label to skip to next iteration
    ::continue::
end