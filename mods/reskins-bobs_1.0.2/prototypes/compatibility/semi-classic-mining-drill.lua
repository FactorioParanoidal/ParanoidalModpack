-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["semi-classic-mining-drill"] then return end
if not mods["bobmining"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmining") == false then return end

-- Set input parameters
local inputs = {
    type = "mining-drill",
    icon_name = "electric-mining-drill",
    base_entity = "electric-mining-drill",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "compatibility",
    subgroup = "semi-classic-mining-drill",
    particles = {["medium-long"] = 3},
}

local tier_map = {
    ["electric-mining-drill"] = {1, 1},
    ["bob-mining-drill-1"] = {2, 2},
    ["bob-mining-drill-2"] = {3, 3},
    ["bob-mining-drill-3"] = {4, 4},
    ["bob-mining-drill-4"] = {5, 5},
    ["bob-area-mining-drill-1"] = {1, 2},
    ["bob-area-mining-drill-2"] = {2, 3},
    ["bob-area-mining-drill-3"] = {3, 4},
    ["bob-area-mining-drill-4"] = {4, 5},
}

-- Setup local functions for reskinning the mining drill animation
local function vertical_drill_animation(speed, inputs)
    return
    {
        layers = {
            -- Base
            {
                priority = "high",
                filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill.png",
                line_length = 6,
                width = 98,
                height = 80,
                frame_count = 30,
                animation_speed = speed,
                frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                direction_count = 1,
                shift = util.by_pixel(0, -22),
                hr_version = {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill.png",
                    line_length = 6,
                    width = 194,
                    height = 154,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(0, -21),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                priority = "high",
                filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-mask.png",
                line_length = 6,
                width = 98,
                height = 80,
                frame_count = 30,
                animation_speed = speed,
                frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                direction_count = 1,
                shift = util.by_pixel(0, -22),
                tint = inputs.tint,
                hr_version = {
                    priority = "high",
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/hr-electric-mining-drill-mask.png",
                    line_length = 6,
                    width = 194,
                    height = 154,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(0, -21),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                priority = "high",
                filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-highlights.png",
                line_length = 6,
                width = 98,
                height = 80,
                frame_count = 30,
                animation_speed = speed,
                frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                direction_count = 1,
                shift = util.by_pixel(0, -22),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    priority = "high",
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/hr-electric-mining-drill-highlights.png",
                    line_length = 6,
                    width = 194,
                    height = 154,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(0, -21),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                priority = "high",
                filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-shadow.png",
                line_length = 7,
                width = 118,
                height = 28,
                frame_count = 21,
                animation_speed = speed,
                frame_sequence = reskins.bobs.electric_drill_animation_shadow_sequence,
                draw_as_shadow = true,
                shift = util.by_pixel(48, 6),
                hr_version = {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-shadow.png",
                    line_length = 7,
                    width = 232,
                    height = 50,
                    frame_count = 21,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_shadow_sequence,
                    draw_as_shadow = true,
                    shift = util.by_pixel(49, 7),
                    scale = 0.5,
                }
            }
        }
    }
end

local function horizontal_drill_animation(speed, inputs, is_front)
    local function horizontal_drill_shadow(speed)
        return
        {
            priority = "high",
            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal-shadow.png",
            line_length = 7,
            width = 118,
            height = 68,
            frame_count = 21,
            animation_speed = speed,
            frame_sequence = reskins.bobs.electric_drill_animation_shadow_sequence,
            draw_as_shadow = true,
            shift = util.by_pixel(48, 6),
            hr_version = {
                priority = "high",
                filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-horizontal-shadow.png",
                line_length = 7,
                width = 236,
                height = 138,
                frame_count = 21,
                animation_speed = speed,
                frame_sequence = reskins.bobs.electric_drill_animation_shadow_sequence,
                draw_as_shadow = true,
                shift = util.by_pixel(48, 5),
                scale = 0.5,
            }
        }
    end

    local drill_animation
    if is_front then
        -- Front horizontal animation
        drill_animation = {
            layers = {
                -- Base
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal-front.png",
                    line_length = 6,
                    width = 28,
                    height = 66,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(14, -22),
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-horizontal-front.png",
                        line_length = 6,
                        width = 54,
                        height = 136,
                        frame_count = 30,
                        animation_speed = speed,
                        frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                        direction_count = 1,
                        shift = util.by_pixel(14, -23),
                        scale = 0.5,
                    }
                },
                -- Mask
                {
                    priority = "high",
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-front-mask.png",
                    line_length = 6,
                    width = 28,
                    height = 66,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(14, -22),
                    tint = inputs.tint,
                    hr_version = {
                        priority = "high",
                        filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/hr-electric-mining-drill-horizontal-front-mask.png",
                        line_length = 6,
                        width = 54,
                        height = 136,
                        frame_count = 30,
                        animation_speed = speed,
                        frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                        direction_count = 1,
                        shift = util.by_pixel(14, -23),
                        tint = inputs.tint,
                        scale = 0.5,
                    }
                },
                -- Highlights
                {
                    priority = "high",
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-front-highlights.png",
                    line_length = 6,
                    width = 28,
                    height = 66,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(14, -22),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        priority = "high",
                        filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/hr-electric-mining-drill-horizontal-front-highlights.png",
                        line_length = 6,
                        width = 54,
                        height = 136,
                        frame_count = 30,
                        animation_speed = speed,
                        frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                        direction_count = 1,
                        shift = util.by_pixel(14, -23),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    }
                },
                -- Shadow
                horizontal_drill_shadow(speed)
            }
        }
    else
        -- Standard horizontal animation
        drill_animation = {
            layers = {
                -- Base
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-horizontal.png",
                    line_length = 6,
                    width = 54,
                    height = 92,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(-4, -28),
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-horizontal.png",
                        line_length = 6,
                        width = 104,
                        height = 178,
                        frame_count = 30,
                        animation_speed = speed,
                        frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                        direction_count = 1,
                        shift = util.by_pixel(-3, -27),
                        scale = 0.5,
                    }
                },
                -- Mask
                {
                    priority = "high",
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-mask.png",
                    line_length = 6,
                    width = 54,
                    height = 92,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(-4, -28),
                    tint = inputs.tint,
                    hr_version = {
                        priority = "high",
                        filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/hr-electric-mining-drill-horizontal-mask.png",
                        line_length = 6,
                        width = 104,
                        height = 178,
                        frame_count = 30,
                        animation_speed = speed,
                        frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                        direction_count = 1,
                        shift = util.by_pixel(-3, -27),
                        tint = inputs.tint,
                        scale = 0.5,
                    }
                },
                -- Highlights
                {
                    priority = "high",
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/electric-mining-drill-horizontal-highlights.png",
                    line_length = 6,
                    width = 54,
                    height = 92,
                    frame_count = 30,
                    animation_speed = speed,
                    frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                    direction_count = 1,
                    shift = util.by_pixel(-4, -28),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        priority = "high",
                        filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/drill/hr-electric-mining-drill-horizontal-highlights.png",
                        line_length = 6,
                        width = 104,
                        height = 178,
                        frame_count = 30,
                        animation_speed = speed,
                        frame_sequence = reskins.bobs.electric_drill_animation_sequence,
                        direction_count = 1,
                        shift = util.by_pixel(-3, -27),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    }
                },
                -- Shadow
                horizontal_drill_shadow(speed)
            }
        }
    end

    return drill_animation
end

-- Setup local functions for reskinning the frames
local function drill_dry_animation(speed, inputs)
    local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
    if inputs.is_area_drill then
        drill_type = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/area-frame"
    end

    return
    {
        north = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-N.png",
                    line_length = 1,
                    width = 98,
                    height = 122,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -12),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-N.png",
                        line_length = 1,
                        width = 194,
                        height = 242,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -12),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Drill Output
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-N-output.png",
                    line_length = 5,
                    width = 38,
                    height = 34,
                    frame_count = 5,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(-2, -44),
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-N-output.png",
                        line_length = 5,
                        width = 72,
                        height = 66,
                        frame_count = 5,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-1, -44),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-shadow.png",
                    line_length = 1,
                    width = 136,
                    height = 102,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(20, -2),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-shadow.png",
                        line_length = 1,
                        width = 274,
                        height = 206,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(19, -3),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
        east = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-E.png",
                    line_length = 1,
                    width = 98,
                    height = 50,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -34),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-E.png",
                        line_length = 1,
                        width = 194,
                        height = 94,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -33),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Drill Output
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-output.png",
                    line_length = 5,
                    width = 26,
                    height = 26,
                    frame_count = 5,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(30, -10),
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-output.png",
                        line_length = 5,
                        width = 50,
                        height = 56,
                        frame_count = 5,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(30, -11),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-shadow.png",
                    line_length = 1,
                    width = 138,
                    height = 86,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(20, 6),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-shadow.png",
                        line_length = 1,
                        width = 276,
                        height = 170,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(20, 6),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
        south = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-S.png",
                    line_length = 1,
                    width = 98,
                    height = 122,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -8),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-S.png",
                        line_length = 1,
                        width = 194,
                        height = 240,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -7),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-shadow.png",
                    line_length = 1,
                    width = 136,
                    height = 102,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(20, 2),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-shadow.png",
                        line_length = 1,
                        width = 274,
                        height = 204,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(19, 2),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
        west = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-W.png",
                    line_length = 1,
                    width = 98,
                    height = 50,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -34),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-W.png",
                        line_length = 1,
                        width = 194,
                        height = 94,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -33),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Drill Output
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-output.png",
                    line_length = 5,
                    width = 24,
                    height = 28,
                    frame_count = 5,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(-30, -12),
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-output.png",
                        line_length = 5,
                        width = 50,
                        height = 56,
                        frame_count = 5,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-31, -12),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-shadow.png",
                    line_length = 1,
                    width = 144,
                    height = 86,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(14, 6),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-shadow.png",
                        line_length = 1,
                        width = 282,
                        height = 170,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(15, 6),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
    }
end

local function drill_dry_working_visualisation(speed, inputs)
    local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
    if inputs.is_area_drill then
        drill_type = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/area-frame"
    end

    return
    {
        -- Dust Animation 1
        {
            constant_speed = true,
            synced_fadeout = true,
            align_to_waypoint = true,
            apply_tint = "resource-color",
            animation = reskins.bobs.electric_mining_drill_smoke(),
            north_position = {0, 0.25},
            east_position = {0, 0},
            south_position = {0, 0.25},
            west_position = {0, 0},
        },

        -- Directional Dust Animation 1
        {
            constant_speed = true,
            fadeout = true,
            apply_tint = "resource-color",
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-smoke.png",
                        line_length = 5,
                        width = 26,
                        height = 30,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -44),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-smoke.png",
                            line_length = 5,
                            width = 46,
                            height = 58,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(1, -44),
                            scale = 0.5,
                        }
                    }
                }
            },
            east_animation = nil,
            south_animation = nil,
            west_animation = nil,
        },

        -- Drill Back Animation
        {
            animated_shift = true,
            always_draw = true,
            north_animation = vertical_drill_animation(speed, inputs),
            east_animation = horizontal_drill_animation(speed, inputs),
            south_animation = vertical_drill_animation(speed, inputs),
            west_animation = horizontal_drill_animation(speed, inputs),
        },

        -- Dust Animation 2
        {
            constant_speed = true,
            synced_fadeout = true,
            align_to_waypoint = true,
            apply_tint = "resource-color",
            animation = reskins.bobs.electric_mining_drill_smoke_front(),
            north_position = {0, 0.25},
            east_position = {0, 0},
            south_position = {0, 0.25},
            west_position = {0, 0},
        },

        -- Directional Dust Animation 2
        {
            constant_speed = true,
            fadeout = true,
            apply_tint = "resource-color",
            north_animation = nil,
            east_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-smoke.png",
                        line_length = 5,
                        width = 28,
                        height = 28,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(24, -12),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-smoke.png",
                            line_length = 5,
                            width = 52,
                            height = 56,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(25, -12),
                            scale = 0.5,
                        }
                    }
                }
            },
            south_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-smoke.png",
                        line_length = 5,
                        width = 24,
                        height = 18,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-2, 20),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-smoke.png",
                            line_length = 5,
                            width = 48,
                            height = 36,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-2, 20),
                            scale = 0.5,
                        }
                    }
                }
            },
            west_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-smoke.png",
                        line_length = 5,
                        width = 26,
                        height = 30,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-26, -12),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-smoke.png",
                            line_length = 5,
                            width = 46,
                            height = 54,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-25, -11),
                            scale = 0.5,
                        }
                    }
                }
            }
        },

        -- Front Frame
        {
            always_draw = true,
            north_animation = nil,
            east_animation = {
                priority = "high",
                filename =  drill_type.."/electric-mining-drill-E-front.png",
                line_length = 1,
                width = 106,
                height = 94,
                frame_count = 1,
                animation_speed = speed,
                direction_count = 1,
                shift = util.by_pixel(2, 2),
                hr_version = {
                    priority = "high",
                    filename =  drill_type.."/hr-electric-mining-drill-E-front.png",
                    line_length = 1,
                    width = 208,
                    height = 186,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(3, 2),
                    scale = 0.5,
                }
            },
            south_animation = {
                layers = {
                    {
                        priority = "high",
                        filename =  drill_type.."/electric-mining-drill-S-output.png",
                        line_length = 5,
                        width = 42,
                        height = 28,
                        frame_count = 5,
                        animation_speed = speed,
                        shift = util.by_pixel(-2, 34),
                        hr_version = {
                            priority = "high",
                            filename =  drill_type.."/hr-electric-mining-drill-S-output.png",
                            line_length = 5,
                            width = 82,
                            height = 56,
                            frame_count = 5,
                            animation_speed = speed,
                            shift = util.by_pixel(-1, 34),
                            scale = 0.5,
                        }
                    },
                    {
                        priority = "high",
                        filename =  drill_type.."/electric-mining-drill-S-front.png",
                        line_length = 1,
                        width = 86,
                        height = 24,
                        frame_count = 1,
                        animation_speed = speed,
                        repeat_count = 5,
                        shift = util.by_pixel(0, 12),
                        hr_version = {
                            priority = "high",
                            filename =  drill_type.."/hr-electric-mining-drill-S-front.png",
                            line_length = 1,
                            width = 172,
                            height = 42,
                            frame_count = 1,
                            animation_speed = speed,
                            repeat_count = 5,
                            shift = util.by_pixel(0, 13),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = {
                priority = "high",
                filename =  drill_type.."/electric-mining-drill-W-front.png",
                line_length = 1,
                width = 106,
                height = 94,
                frame_count = 1,
                animation_speed = speed,
                direction_count = 1,
                shift = util.by_pixel(-4, 2),
                hr_version = {
                    priority = "high",
                    filename =  drill_type.."/hr-electric-mining-drill-W-front.png",
                    line_length = 1,
                    width = 210,
                    height = 190,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(-4, 1),
                    scale = 0.5,
                }
            }
        },

        -- Drill Front Animation
        {
            animated_shift = true,
            always_draw = true,
            east_animation = horizontal_drill_animation(speed, inputs, true),
            west_animation = horizontal_drill_animation(speed, inputs, true),
        },

        -- LEDs
        electric_mining_drill_status_leds_working_visualisation(),

        -- Light
        {
            light = {intensity = 1, size = 2, color={r=1, g=1, b=1}},
            north_position = {1, -2.0},
            east_position = {1.5, -1.5},
            south_position = {1, 0.5},
            west_position = {-1.5, -1.5},
        }
    }
end

local function drill_wet_animation(speed, inputs)
    local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
    if inputs.is_area_drill then
        drill_type = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/area-frame"
    end

    return
    {
        north = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-N-wet.png",
                    line_length = 1,
                    width = 98,
                    height = 122,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -12),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-N-wet.png",
                        line_length = 1,
                        width = 194,
                        height = 242,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -12),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Drill Output
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-N-output.png",
                    line_length = 5,
                    width = 38,
                    height = 34,
                    frame_count = 5,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(-2, -44),
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-N-output.png",
                        line_length = 5,
                        width = 72,
                        height = 66,
                        frame_count = 5,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-1, -44),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-shadow.png",
                    line_length = 1,
                    width = 136,
                    height = 110,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(20, 2),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-shadow.png",
                        line_length = 1,
                        width = 276,
                        height = 222,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(19, 1),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
        east = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet.png",
                    line_length = 1,
                    width = 98,
                    height = 50,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -34),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-wet.png",
                        line_length = 1,
                        width = 194,
                        height = 94,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -33),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Drill Output
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-output.png",
                    line_length = 5,
                    width = 26,
                    height = 26,
                    frame_count = 5,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(30, -10),
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-output.png",
                        line_length = 5,
                        width = 50,
                        height = 56,
                        frame_count = 5,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(30, -11),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-shadow.png",
                    line_length = 1,
                    width = 138,
                    height = 98,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(20, 8),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-wet-shadow.png",
                        line_length = 1,
                        width = 276,
                        height = 194,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(20, 8),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
        south = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-S-wet.png",
                    line_length = 1,
                    width = 98,
                    height = 122,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -8),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-S-wet.png",
                        line_length = 1,
                        width = 194,
                        height = 240,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -7),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-shadow.png",
                    line_length = 1,
                    width = 136,
                    height = 102,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(20, 2),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-wet-shadow.png",
                        line_length = 1,
                        width = 276,
                        height = 204,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(19, 2),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
        west = {
            layers = {
                -- Drill
                {
                    priority = "high",
                    filename = drill_type.."/electric-mining-drill-W-wet.png",
                    line_length = 1,
                    width = 98,
                    height = 50,
                    frame_count = 1,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(0, -34),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = drill_type.."/hr-electric-mining-drill-W-wet.png",
                        line_length = 1,
                        width = 194,
                        height = 94,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -33),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                },
                -- Drill Output
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-output.png",
                    line_length = 5,
                    width = 24,
                    height = 28,
                    frame_count = 5,
                    animation_speed = speed,
                    direction_count = 1,
                    shift = util.by_pixel(-30, -12),
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-output.png",
                        line_length = 5,
                        width = 50,
                        height = 56,
                        frame_count = 5,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-31, -12),
                        scale = 0.5,
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-shadow.png",
                    line_length = 1,
                    width = 144,
                    height = 98,
                    frame_count = 1,
                    animation_speed = speed,
                    draw_as_shadow = true,
                    shift = util.by_pixel(14, 8),
                    repeat_count = 5,
                    hr_version = {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-wet-shadow.png",
                        line_length = 1,
                        width = 284,
                        height = 194,
                        frame_count = 1,
                        animation_speed = speed,
                        draw_as_shadow = true,
                        shift = util.by_pixel(15, 8),
                        repeat_count = 5,
                        scale = 0.5,
                    }
                }
            }
        },
    }

end

local function drill_wet_working_visualisation(speed, inputs)
    local drill_type = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill"
    if inputs.is_area_drill then
        drill_type = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/area-frame"
    end

    return
    {
        -- Dust Animation 1
        {
            constant_speed = true,
            synced_fadeout = true,
            align_to_waypoint = true,
            apply_tint = "resource-color",
            animation = reskins.bobs.electric_mining_drill_smoke(),
            north_position = {0, 0.25},
            east_position = {0, 0},
            south_position = {0, 0.25},
            west_position = {0, 0},
        },

        -- Directional Dust Animation 1
        {
            constant_speed = true,
            fadeout = true,
            apply_tint = "resource-color",
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-smoke.png",
                        line_length = 5,
                        width = 26,
                        height = 30,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -44),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-smoke.png",
                            line_length = 5,
                            width = 46,
                            height = 58,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(1, -44),
                            scale = 0.5,
                        }
                    }
                }
            },
            east_animation = nil,
            south_animation = nil,
            west_animation = nil
        },

        -- Drill Back Animation
        {
            animated_shift = true,
            always_draw = true,
            north_animation = vertical_drill_animation(speed, inputs),
            east_animation = horizontal_drill_animation(speed, inputs),
            south_animation = vertical_drill_animation(speed, inputs),
            west_animation = horizontal_drill_animation(speed, inputs),
        },

        -- Dust Animation 2
        {
            constant_speed = true,
            synced_fadeout = true,
            align_to_waypoint = true,
            apply_tint = "resource-color",
            animation = reskins.bobs.electric_mining_drill_smoke_front(),
            north_position = {0, 0.25},
            east_position = {0, 0},
            south_position = {0, 0.25},
            west_position = {0, 0},
        },

        -- Directional Dust Animation 2
        {
            constant_speed = true,
            fadeout = true,
            apply_tint = "resource-color",
            north_animation = nil,
            east_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-smoke.png",
                        line_length = 5,
                        width = 28,
                        height = 28,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(24, -12),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-smoke.png",
                            line_length = 5,
                            width = 52,
                            height = 56,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(25, -12),
                            scale = 0.5,
                        }
                    }
                }
            },
            south_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-smoke.png",
                        line_length = 5,
                        width = 24,
                        height = 18,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-2, 20),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-smoke.png",
                            line_length = 5,
                            width = 48,
                            height = 36,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-2, 20),
                            scale = 0.5,
                        }
                    }
                }
            },
            west_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-smoke.png",
                        line_length = 5,
                        width = 26,
                        height = 30,
                        frame_count = 10,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-26, -12),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-smoke.png",
                            line_length = 5,
                            width = 46,
                            height = 54,
                            frame_count = 10,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-25, -11),
                            scale = 0.5,
                        }
                    }
                }
            }
        },

        -- Fluid Window Background (Bottom)
        {
            secondary_draw_order = -49,
            always_draw = true,
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-window-background-front.png",
                        line_length = 1,
                        width = 68,
                        height = 14,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-2, -18),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-window-background-front.png",
                            line_length = 1,
                            width = 132,
                            height = 28,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-1, -18),
                            scale = 0.5,
                        }
                    },
                }
            },
            east_animation = nil,
            south_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-window-background.png",
                        line_length = 1,
                        width = 68,
                        height = 46,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-2, -34),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-wet-window-background.png",
                            line_length = 1,
                            width = 132,
                            height = 88,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-1, -33),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = nil,
        },

        -- Fluid Window Background (Front)
        {
            always_draw = true,
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-window-background.png",
                        line_length = 1,
                        width = 14,
                        height = 12,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(2, 20),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-window-background.png",
                            line_length = 1,
                            width = 30,
                            height = 20,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(1, 21),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-window-background-front.png",
                        line_length = 1,
                        width = 42,
                        height = 44,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(12, 0),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-wet-window-background-front.png",
                            line_length = 1,
                            width = 88,
                            height = 86,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(11, 0),
                            scale = 0.5,
                        }
                    }
                }
            },
            south_animation = nil,
            east_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-window-background-front.png",
                        line_length = 1,
                        width = 44,
                        height = 44,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-12, 0),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-wet-window-background-front.png",
                            line_length = 1,
                            width = 86,
                            height = 86,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-12, 0),
                            scale = 0.5,
                        }
                    },
                }
            },
        },
        -- Fluid Base (Bottom)
        {
            always_draw = true,
            secondary_draw_order = -48,
            apply_tint = "input-fluid-base-color",
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-background-front.png",
                        line_length = 1,
                        width = 66,
                        height = 20,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -18),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-fluid-background-front.png",
                            line_length = 1,
                            width = 130,
                            height = 36,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(0, -17),
                            scale = 0.5,
                        }
                    },
                }
            },
            east_animation = nil,
            south_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-fluid-background.png",
                        line_length = 1,
                        width = 66,
                        height = 48,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(0, -32),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-wet-fluid-background.png",
                            line_length = 1,
                            width = 130,
                            height = 96,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(0, -32),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = nil
        },

        -- Fluid Base (Front)
        {
            always_draw = true,
            apply_tint = "input-fluid-base-color",
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-background.png",
                        line_length = 1,
                        width = 14,
                        height = 10,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(2, 22),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-fluid-background.png",
                            line_length = 1,
                            width = 28,
                            height = 22,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(2, 21),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-fluid-background-front.png",
                        line_length = 1,
                        width = 42,
                        height = 42,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(12, 0),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-wet-fluid-background-front.png",
                            line_length = 1,
                            width = 82,
                            height = 88,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(12, -1),
                            scale = 0.5,
                        }
                    }
                }
            },
            south_animation = nil,
            east_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-fluid-background-front.png",
                        line_length = 1,
                        width = 42,
                        height = 42,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-12, 0),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-wet-fluid-background-front.png",
                            line_length = 1,
                            width = 82,
                            height = 88,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-12, -1),
                            scale = 0.5,
                        }
                    },
                }
            },
        },

        -- Fluid Flow (Bottom)
        {
            secondary_draw_order = -47,
            always_draw = true,
            apply_tint = "input-fluid-flow-color",
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-flow-front.png",
                        line_length = 1,
                        width = 66,
                        height = 16,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-2, -18),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-fluid-flow-front.png",
                            line_length = 1,
                            width = 130,
                            height = 28,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-2, -17),
                            scale = 0.5,
                        }
                    },
                }
            },
            east_animation = nil,
            south_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-S-wet-fluid-flow.png",
                        line_length = 1,
                        width = 66,
                        height = 44,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-2, -32),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-S-wet-fluid-flow.png",
                            line_length = 1,
                            width = 130,
                            height = 88,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-2, -32),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = nil,
        },

        -- Fluid Flow (Front)
        {
            always_draw = true,
            apply_tint = "input-fluid-flow-color",
            north_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-fluid-flow.png",
                        line_length = 1,
                        width = 14,
                        height = 10,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(2, 22),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-fluid-flow.png",
                            line_length = 1,
                            width = 26,
                            height = 20,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(2, 22),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-W-wet-fluid-flow-front.png",
                        line_length = 1,
                        width = 40,
                        height = 44,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(12, 0),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-W-wet-fluid-flow-front.png",
                            line_length = 1,
                            width = 84,
                            height = 86,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(11, 0),
                            scale = 0.5,
                        }
                    }
                }
            },
            south_animation = nil,
            east_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-E-wet-fluid-flow-front.png",
                        line_length = 1,
                        width = 42,
                        height = 44,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-12, 0),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-E-wet-fluid-flow-front.png",
                            line_length = 1,
                            width = 82,
                            height = 86,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-12, 0),
                            scale = 0.5,
                        }
                    },
                }
            },
        },

        -- Front Frame (Wet)
        {
            always_draw = true,
            north_animation =  {
                layers = {
                    {
                        priority = "high",
                        filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/electric-mining-drill-N-wet-front.png",
                        line_length = 1,
                        width = 82,
                        height = 62,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-2, 20),
                        hr_version = {
                            priority = "high",
                            filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-N-wet-front.png",
                            line_length = 1,
                            width = 162,
                            height = 124,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-2, 20),
                            scale = 0.5,
                        }
                    },
                }
            },
            west_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = drill_type.."/electric-mining-drill-W-wet-front.png",
                        line_length = 1,
                        width = 106,
                        height = 94,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(-4, 2),
                        hr_version = {
                            priority = "high",
                            filename = drill_type.."/hr-electric-mining-drill-W-wet-front.png",
                            line_length = 1,
                            width = 210,
                            height = 190,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(-4, 1),
                            scale = 0.5,
                        }
                    }
                }
            },
            south_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = drill_type.."/electric-mining-drill-S-output.png",
                        line_length = 5,
                        width = 42,
                        height = 28,
                        frame_count = 5,
                        animation_speed = speed,
                        shift = util.by_pixel(-2, 34),
                        hr_version = {
                            priority = "high",
                            filename = drill_type.."/hr-electric-mining-drill-S-output.png",
                            line_length = 5,
                            width = 82,
                            height = 56,
                            frame_count = 5,
                            animation_speed = speed,
                            shift = util.by_pixel(-1, 34),
                            scale = 0.5,
                        }
                    },
                    {
                        priority = "high",
                        filename = drill_type.."/electric-mining-drill-S-wet-front.png",
                        line_length = 1,
                        width = 96,
                        height = 38,
                        frame_count = 1,
                        animation_speed = speed,
                        repeat_count = 5,
                        shift = util.by_pixel(0, 18),
                        hr_version = {
                            priority = "high",
                            filename = drill_type.."/hr-electric-mining-drill-S-wet-front.png",
                            line_length = 1,
                            width = 192,
                            height = 70,
                            frame_count = 1,
                            animation_speed = speed,
                            repeat_count = 5,
                            shift = util.by_pixel(0, 19),
                            scale = 0.5,
                        }
                    },
                }
            },
            east_animation = {
                layers = {
                    {
                        priority = "high",
                        filename = drill_type.."/electric-mining-drill-E-wet-front.png",
                        line_length = 1,
                        width = 106,
                        height = 94,
                        frame_count = 1,
                        animation_speed = speed,
                        direction_count = 1,
                        shift = util.by_pixel(2, 2),
                        hr_version =
                        {
                            priority = "high",
                            filename = drill_type.."/hr-electric-mining-drill-E-wet-front.png",
                            line_length = 1,
                            width = 208,
                            height = 186,
                            frame_count = 1,
                            animation_speed = speed,
                            direction_count = 1,
                            shift = util.by_pixel(3, 2),
                            scale = 0.5,
                        }
                    },
                }
            },
        },

        -- Drill Front Animation
        {
            animated_shift = true,
            always_draw = true,
            east_animation = horizontal_drill_animation(speed, inputs, true),
            west_animation = horizontal_drill_animation(speed, inputs, true),
        },

        -- LEDs
        electric_mining_drill_status_leds_working_visualisation(),

        -- Light
        {
            light = {intensity = 1, size = 2, color={r=1, g=1, b=1}},
            north_position = {1, -2.0},
            east_position = {1.5, -1.5},
            south_position = {1, 0.5},
            west_position = {-1.5, -1.5},
        }
    }
end

-- Rescale mining drill animation playback speed to something visually appealing
local max_playback = 1.2   -- Maximum animation playback speed
local min_playback = 0.4 -- Minimum animation playback speed

local mining_speeds = {}
local index = 1

-- Loop through all the drills, figure out the mining speeds
for name, _ in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Fetch mining speed
    mining_speeds[index] = data.raw[inputs.type][name].mining_speed
    index = index + 1

    -- Label to skip to next iteration
    ::continue::
end

-- Determine max and min mining speeds
table.sort(mining_speeds)
local max_speed = mining_speeds[#mining_speeds]
local min_speed = mining_speeds[1]

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

    -- Handle icon base
    if string.find(name, "area") then
        inputs.icon_base = "large-area-electric-mining-drill"
        inputs.is_area_drill = true
        inputs.icon_extras = {
            -- Type indicator
            {
                icon = inputs.directory.."/graphics/icons/mining/electric-mining-drill/area-drill-symbol.png"
            },
            {
                icon = inputs.directory.."/graphics/icons/mining/electric-mining-drill/area-drill-symbol.png",
                tint = reskins.lib.adjust_alpha(reskins.lib.tint_index["tier-"..tier], 0.75)
            }
        }
    else
        inputs.icon_base = "electric-mining-drill"
        inputs.is_area_drill = false
        inputs.icon_extras = nil
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Calculate new animation playback speed
    local speed
    if max_speed - min_speed == 0 then
        speed = entity.mining_speed
    else
        speed = ((entity.mining_speed/(max_speed-min_speed)) - (min_speed/(max_speed-min_speed)))*max_playback
                          + ((max_speed/(max_speed-min_speed)) - (entity.mining_speed/(max_speed-min_speed)))*min_playback
    end

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet (4, {
        layers = {
            {
                filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/remnants/electric-mining-drill-remnants.png",
                line_length = 1,
                width = 178,
                height = 166,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 0),
                hr_version = {
                    filename = "__semi-classic-mining-drill__/graphics/entity/electric-mining-drill/remnants/hr-electric-mining-drill-remnants.png",
                    line_length = 1,
                    width = 356,
                    height = 328,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, -0.5),
                    scale = 0.5,
                },
            },
            {
                filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/remnants/electric-mining-drill-remnants-mask.png",
                line_length = 1,
                width = 178,
                height = 166,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 0),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/remnants/hr-electric-mining-drill-remnants-mask.png",
                    line_length = 1,
                    width = 356,
                    height = 328,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, -0.5),
                    tint = inputs.tint,
                    scale = 0.5,
                },
            },
            {
                filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/remnants/electric-mining-drill-remnants-highlights.png",
                line_length = 1,
                width = 178,
                height = 166,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 0),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/compatibility/semi-classic-mining-drill/electric-mining-drill/remnants/hr-electric-mining-drill-remnants-highlights.png",
                    line_length = 1,
                    width = 356,
                    height = 328,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, -0.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                },
            }
        }
    })

    -- Reskin entities
    entity.graphics_set.drilling_vertical_movement_duration = 10 / speed
    entity.graphics_set.animation = drill_dry_animation(speed, inputs)
    entity.graphics_set.shift_animation_waypoint_stop_duration = 195 / speed
    entity.graphics_set.shift_animation_transition_duration = 30 / speed
    entity.graphics_set.working_visualisations = drill_dry_working_visualisation(speed, inputs)

    entity.wet_mining_graphics_set.drilling_vertical_movement_duration = 10 / speed
    entity.wet_mining_graphics_set.animation = drill_wet_animation(speed, inputs)
    entity.wet_mining_graphics_set.shift_animation_waypoint_stop_duration = 195 / speed
    entity.wet_mining_graphics_set.shift_animation_transition_duration = 30 / speed
    entity.wet_mining_graphics_set.working_visualisations = drill_wet_working_visualisation(speed, inputs)

    -- Label to skip to next iteration
    ::continue::
end