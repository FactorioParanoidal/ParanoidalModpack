-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Set input parameters
local inputs = {
    type = "construction-robot",
    icon_name = "construction-robot",
    base_entity = "construction-robot",
    mod = "bobs",
    group = "logistics",
    particles = {["medium"] = 2},
}

local tier_map = {
    ["construction-robot"] = {1, 2},
    ["bob-construction-robot-2"] = {2, 3},
    ["bob-construction-robot-3"] = {3, 4},
    ["bob-construction-robot-4"] = {4, 5},
    ["bob-construction-robot-5"] = {5, 5, util.color(reskins.lib.setting("reskins-bobs-fusion-robot-color"))},
}

-- Animations
local function generate_robot_animations(tint)
    return
    {
        idle = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/construction-robot/construction-robot.png",
                    priority = "high",
                    line_length = 16,
                    width = 32,
                    height = 36,
                    frame_count = 1,
                    shift = util.by_pixel(0,-4.5),
                    direction_count = 16,
                    hr_version = {
                        filename = "__base__/graphics/entity/construction-robot/hr-construction-robot.png",
                        priority = "high",
                        line_length = 16,
                        width = 66,
                        height = 76,
                        frame_count = 1,
                        shift = util.by_pixel(0,-4.5),
                        direction_count = 16,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/construction-robot-mask.png",
                    priority = "high",
                    line_length = 16,
                    width = 32,
                    height = 36,
                    frame_count = 1,
                    shift = util.by_pixel(0,-4.5),
                    tint = tint,
                    direction_count = 16,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/hr-construction-robot-mask.png",
                        priority = "high",
                        line_length = 16,
                        width = 66,
                        height = 76,
                        frame_count = 1,
                        shift = util.by_pixel(0,-4.5),
                        tint = tint,
                        direction_count = 16,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/construction-robot-highlights.png",
                    priority = "high",
                    line_length = 16,
                    width = 32,
                    height = 36,
                    frame_count = 1,
                    shift = util.by_pixel(0,-4.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    direction_count = 16,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/hr-construction-robot-highlights.png",
                        priority = "high",
                        line_length = 16,
                        width = 66,
                        height = 76,
                        frame_count = 1,
                        shift = util.by_pixel(0,-4.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
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
                    filename = "__base__/graphics/entity/construction-robot/construction-robot.png",
                    priority = "high",
                    line_length = 16,
                    width = 32,
                    height = 36,
                    frame_count = 1,
                    shift = util.by_pixel(0, -4.5),
                    direction_count = 16,
                    y = 36,
                    hr_version = {
                        filename = "__base__/graphics/entity/construction-robot/hr-construction-robot.png",
                        priority = "high",
                        line_length = 16,
                        width = 66,
                        height = 76,
                        frame_count = 1,
                        shift = util.by_pixel(0, -4.5),
                        direction_count = 16,
                        y = 76,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/construction-robot-mask.png",
                    priority = "high",
                    line_length = 16,
                    width = 32,
                    height = 36,
                    frame_count = 1,
                    shift = util.by_pixel(0, -4.5),
                    tint = tint,
                    direction_count = 16,
                    y = 36,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/hr-construction-robot-mask.png",
                        priority = "high",
                        line_length = 16,
                        width = 66,
                        height = 76,
                        frame_count = 1,
                        shift = util.by_pixel(0, -4.5),
                        tint = tint,
                        direction_count = 16,
                        y = 76,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/construction-robot-highlights.png",
                    priority = "high",
                    line_length = 16,
                    width = 32,
                    height = 36,
                    frame_count = 1,
                    shift = util.by_pixel(0, -4.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    direction_count = 16,
                    y = 36,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/hr-construction-robot-highlights.png",
                        priority = "high",
                        line_length = 16,
                        width = 66,
                        height = 76,
                        frame_count = 1,
                        shift = util.by_pixel(0, -4.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        direction_count = 16,
                        y = 76,
                        scale = 0.5
                    }
                }
            }
        },

        working = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/construction-robot/construction-robot-working.png",
                    priority = "high",
                    line_length = 2,
                    width = 28,
                    height = 36,
                    frame_count = 2,
                    shift = util.by_pixel(-0.25, -5),
                    direction_count = 16,
                    animation_speed = 0.3,
                    hr_version = {
                        filename = "__base__/graphics/entity/construction-robot/hr-construction-robot-working.png",
                        priority = "high",
                        line_length = 2,
                        width = 57,
                        height = 74,
                        frame_count = 2,
                        shift = util.by_pixel(-0.25, -5),
                        direction_count = 16,
                        animation_speed = 0.3,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/construction-robot-working-mask.png",
                    priority = "high",
                    line_length = 2,
                    width = 28,
                    height = 36,
                    frame_count = 2,
                    shift = util.by_pixel(-0.25, -5),
                    tint = tint,
                    direction_count = 16,
                    animation_speed = 0.3,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/hr-construction-robot-working-mask.png",
                        priority = "high",
                        line_length = 2,
                        width = 57,
                        height = 74,
                        frame_count = 2,
                        shift = util.by_pixel(-0.25, -5),
                        tint = tint,
                        direction_count = 16,
                        animation_speed = 0.3,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/construction-robot-working-highlights.png",
                    priority = "high",
                    line_length = 2,
                    width = 28,
                    height = 36,
                    frame_count = 2,
                    shift = util.by_pixel(-0.25, -5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    direction_count = 16,
                    animation_speed = 0.3,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/hr-construction-robot-working-highlights.png",
                        priority = "high",
                        line_length = 2,
                        width = 57,
                        height = 74,
                        frame_count = 2,
                        shift = util.by_pixel(-0.25, -5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        direction_count = 16,
                        animation_speed = 0.3,
                        scale = 0.5
                    }
                }
            }
        },

        shadow_idle = {
            filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 53,
            height = 25,
            frame_count = 1,
            shift = util.by_pixel(33.5, 18.5),
            direction_count = 16,
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/construction-robot/hr-construction-robot-shadow.png",
                priority = "high",
                line_length = 16,
                width = 104,
                height = 49,
                frame_count = 1,
                shift = util.by_pixel(33.5, 18.75),
                direction_count = 16,
                scale = 0.5,
                draw_as_shadow = true
            }
        },

        shadow_in_motion = {
            filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 53,
            height = 25,
            frame_count = 1,
            shift = util.by_pixel(33.5, 18.5),
            direction_count = 16,
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/construction-robot/hr-construction-robot-shadow.png",
                priority = "high",
                line_length = 16,
                width = 104,
                height = 49,
                frame_count = 1,
                shift = util.by_pixel(33.5, 18.75),
                direction_count = 16,
                scale = 0.5,
                draw_as_shadow = true
            }
        },

        shadow_working = {
            filename = "__base__/graphics/entity/construction-robot/construction-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 53,
            height = 25,
            frame_count = 1,
            repeat_count = 2,
            shift = util.by_pixel(33.5, 18.5),
            direction_count = 16,
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/construction-robot/hr-construction-robot-shadow.png",
                priority = "high",
                line_length = 16,
                width = 104,
                height = 49,
                frame_count = 1,
                repeat_count = 2,
                shift = util.by_pixel(33.5, 18.75),
                direction_count = 16,
                scale = 0.5,
                draw_as_shadow = true
            }
        }
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    local fusion_robot_color
    if (reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" and reskins.lib.setting("reskins-bobs-do-progression-based-robots")) then
        tier = map[2]
        fusion_robot_color = map[3]
    end

    -- Determine what tint we're using
    inputs.tint = fusion_robot_color or reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Generate robot animations
    local animations = generate_robot_animations(inputs.tint)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet (3, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/construction-robot/remnants/construction-robot-remnants.png",
                line_length = 1,
                width = 60,
                height = 58,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(2, 1),
                hr_version = {
                    filename = "__base__/graphics/entity/construction-robot/remnants/hr-construction-robot-remnants.png",
                    line_length = 1,
                    width = 120,
                    height = 114,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(2, 1),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/remnants/construction-robot-remnants-mask.png",
                line_length = 1,
                width = 60,
                height = 58,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(2, 1),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/remnants/hr-construction-robot-remnants-mask.png",
                    line_length = 1,
                    width = 120,
                    height = 114,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(2, 1),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/remnants/construction-robot-remnants-highlights.png",
                line_length = 1,
                width = 60,
                height = 58,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(2, 1),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/construction-robot/remnants/hr-construction-robot-remnants-highlights.png",
                    line_length = 1,
                    width = 120,
                    height = 114,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(2, 1),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            }
        }
    })

    -- Clear this, construction robots do not generate the corpse directly
    entity.corpse = nil

    -- Reskin entities
    entity.idle = animations.idle
    entity.in_motion = animations.in_motion
    entity.working = animations.working
    entity.shadow_idle = animations.shadow_idle
    entity.shadow_in_motion = animations.shadow_in_motion
    entity.shadow_working = animations.shadow_working

    -- Setup remnants and destruction animation
    reskins.bobs.make_robot_particle(entity)

    -- Label to skip to next iteration
    ::continue::
end