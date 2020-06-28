-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Set input parameters
local inputs = {
    type = "logistic-robot",
    icon_name = "logistic-robot",
    base_entity = "logistic-robot",    
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "logistics",
    particles = {["medium"] = 2},
}

local tier_map = {
    ["logistic-robot"] = 1,
    ["bob-logistic-robot-2"] = 2,
    ["bob-logistic-robot-3"] = 3,
    ["bob-logistic-robot-4"] = 4,
    ["bob-logistic-robot-5"] = 5,
}

-- Animations
local function generate_robot_animations(tint)
    return
    {
        idle = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    direction_count = 16,
                    y = 42,
                    hr_version = {
                        filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        direction_count = 16,
                        y = 84,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    tint = tint,
                    direction_count = 16,
                    y = 42,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-mask.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        tint = tint,
                        direction_count = 16,
                        y = 84,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    blend_mode = "additive",
                    direction_count = 16,
                    y = 42,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-highlights.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        blend_mode = "additive",
                        direction_count = 16,
                        y = 84,
                        scale = 0.5
                    }
                }
            }
        },

        idle_with_cargo = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    direction_count = 16,
                    hr_version = {
                        filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        direction_count = 16,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    tint = tint,
                    direction_count = 16,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-mask.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        tint = tint,
                        direction_count = 16,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    blend_mode = "additive",
                    direction_count = 16,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-highlights.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        blend_mode = "additive",
                        direction_count = 16,
                        scale = 0.5
                    }
                }
            }
        },
        
        in_motion = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    direction_count = 16,
                    y = 126,
                    hr_version = {
                        filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        direction_count = 16,
                        y = 252,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    tint = tint,
                    direction_count = 16,
                    y = 126,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-mask.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        tint = tint,
                        direction_count = 16,
                        y = 252,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    blend_mode = "additive",
                    direction_count = 16,
                    y = 126,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-highlights.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        blend_mode = "additive",
                        direction_count = 16,
                        y = 252,
                        scale = 0.5
                    }
                }
            }
        },
        
        in_motion_with_cargo = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    direction_count = 16,
                    y = 84,
                    hr_version = {
                        filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        direction_count = 16,
                        y = 168,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-mask.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    tint = tint,
                    direction_count = 16,
                    y = 84,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-mask.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        tint = tint,
                        direction_count = 16,
                        y = 168,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/logistic-robot-highlights.png",
                    priority = "high",
                    line_length = 16,
                    width = 41,
                    height = 42,
                    frame_count = 1,
                    shift = util.by_pixel(0, -3),
                    blend_mode = "additive",
                    direction_count = 16,
                    y = 84,
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/hr-logistic-robot-highlights.png",
                        priority = "high",
                        line_length = 16,
                        width = 80,
                        height = 84,
                        frame_count = 1,
                        shift = util.by_pixel(0, -3),
                        blend_mode = "additive",
                        direction_count = 16,
                        y = 168,
                        scale = 0.5
                    }
                }
            }
        },
        
        shadow_idle = {
            filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 58,
            height = 29,
            frame_count = 1,
            shift = util.by_pixel(32, 19.5),
            direction_count = 16,
            y = 29,
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot-shadow.png",
                priority = "high",
                line_length = 16,
                width = 115,
                height = 57,
                frame_count = 1,
                shift = util.by_pixel(31.75, 19.75),
                direction_count = 16,
                y = 57,
                scale = 0.5,
                draw_as_shadow = true
            }
        },

        shadow_idle_with_cargo = {
            filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 58,
            height = 29,
            frame_count = 1,
            shift = util.by_pixel(32, 19.5),
            direction_count = 16,
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot-shadow.png",
                priority = "high",
                line_length = 16,
                width = 115,
                height = 57,
                frame_count = 1,
                shift = util.by_pixel(31.75, 19.75),
                direction_count = 16,
                scale = 0.5,
                draw_as_shadow = true
            }
        },

        shadow_in_motion = {
            filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 58,
            height = 29,
            frame_count = 1,
            shift = util.by_pixel(32, 19.5),
            direction_count = 16,
            y = 29,
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot-shadow.png",
                priority = "high",
                line_length = 16,
                width = 115,
                height = 57,
                frame_count = 1,
                shift = util.by_pixel(31.75, 19.75),
                direction_count = 16,
                y = 57*3,
                scale = 0.5,
                draw_as_shadow = true
            }
        },

        shadow_in_motion_with_cargo = {
            filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 58,
            height = 29,
            frame_count = 1,
            shift = util.by_pixel(32, 19.5),
            direction_count = 16,
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot-shadow.png",
                priority = "high",
                line_length = 16,
                width = 115,
                height = 57,
                frame_count = 1,
                shift = util.by_pixel(31.75, 19.75),
                direction_count = 16,
                y = 114,
                scale = 0.5,
                draw_as_shadow = true
            }
        }
    }
end

-- Reskin entities, create and assign extra details
for name, tier in pairs(tier_map) do
    -- Fetch entity
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Generate robot animations
    animations = generate_robot_animations(inputs.tint)

    -- Fetch remnant
    remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet (3, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/logistic-robot/remnants/logistic-robot-remnants.png",
                line_length = 1,
                width = 58,
                height = 58,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(1, 1),
                hr_version = {
                    filename = "__base__/graphics/entity/logistic-robot/remnants/hr-logistic-robot-remnants.png",
                    line_length = 1,
                    width = 116,
                    height = 114,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(1, 1),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/remnants/logistic-robot-remnants-mask.png",
                line_length = 1,
                width = 58,
                height = 58,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(1, 1),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/remnants/hr-logistic-robot-remnants-mask.png",
                    line_length = 1,
                    width = 116,
                    height = 114,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(1, 1),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/remnants/logistic-robot-remnants-highlights.png",
                line_length = 1,
                width = 58,
                height = 58,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(1, 1),
                blend_mode = "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/logistic-robot/remnants/hr-logistic-robot-remnants-highlights.png",
                    line_length = 1,
                    width = 116,
                    height = 114,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(1, 1),
                    blend_mode = "additive",
                    scale = 0.5,
                }
            }
        }
    })

    -- Clear this, logistic robots do not generate the corpse directly
    entity.corpse = nil

    -- Reskin entities
    entity.idle = animations.idle
    entity.idle_with_cargo = animations.idle_with_cargo
    entity.in_motion = animations.in_motion
    entity.in_motion_with_cargo = animations.in_motion_with_cargo
    entity.shadow_idle = animations.shadow_idle
    entity.shadow_idle_with_cargo = animations.shadow_idle_with_cargo
    entity.shadow_in_motion = animations.shadow_in_motion
    entity.shadow_in_motion_with_cargo = animations.shadow_in_motion_with_cargo

    -- Setup remnants and destruction animation
    reskins.bobs.make_robot_particle(entity)

    -- Label to skip to next iteration
    ::continue::
end