-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobpower"] then return end

local inputs = {
    type = "burner-generator",
    icon_name = "burner-electric-generator",
    base_entity = "steam-engine",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "power",
    particles = {["medium"] = 2,["big"] = 1},
    tint = util.color("26262660"),
    make_remnants = false,
}

inputs.icon_filename = inputs.directory.."/graphics/icons/power/burner-electric-generator/burner-electric-generator.png"

local name = "bob-burner-generator"

-- Fetch entity
local entity = data.raw[inputs.type][name]

-- Check if entity exists, if not, return
if not entity then return end

reskins.lib.setup_standard_entity(name, 0, inputs)

-- Reskin entity
entity.animation = {
    layers = {
        -- Base
        {
            filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/burner-electric-generator.png",
            width = 106,
            height = 136,
            frame_count = 32,
            line_length = 8,
            repeat_count = 3,
            shift = util.by_pixel(0, -12.5),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/hr-burner-electric-generator.png",
                width = 212,
                height = 272,
                frame_count = 32,
                line_length = 8,
                repeat_count = 3,
                shift = util.by_pixel(0, -12.5),
                scale = 0.5
            }
        },
        -- Fire
        {
            filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/burner-electric-generator-fire.png",
            priority = "high",
            line_length = 8,
            width = 29,
            height = 41,
            frame_count = 48,
            direction_count = 1,
            repeat_count = 2,
            blend_mode = "additive",
            shift = util.by_pixel(-1, 9.5),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/hr-burner-electric-generator-fire.png",
                priority = "high",
                line_length = 8,
                width = 58,
                height = 82,
                frame_count = 48,
                direction_count = 1,
                repeat_count = 2,
                blend_mode = "additive",
                shift = util.by_pixel(-1, 9.5),
                scale = 0.5
            }
        },
        -- Radiant Light
        {
            filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/burner-electric-generator-working-light-animated.png",
            width = 106,
            height = 136,
            frame_count = 32,
            line_length = 8,
            repeat_count = 3,
            blend_mode = "additive",
            shift = util.by_pixel(0, -12.5),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/hr-burner-electric-generator-working-light-animated.png",
                width = 212,
                height = 272,
                frame_count = 32,
                line_length = 8,
                repeat_count = 3,
                blend_mode = "additive",
                shift = util.by_pixel(0, -12.5),
                scale = 0.5
            }
        },
        -- Shadow
        {
            filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/burner-electric-generator-shadow.png",
            width = 144,
            height = 85,
            frame_count = 32,
            line_length = 8,
            repeat_count = 3,
            draw_as_shadow = true,
            shift = util.by_pixel(30, 12),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/hr-burner-electric-generator-shadow.png",
                width = 288,
                height = 170,
                frame_count = 32,
                line_length = 8,
                repeat_count = 3,
                draw_as_shadow = true,
                shift = util.by_pixel(30, 12),
                scale = 0.5
            }
        }
    }
}

entity.idle_animation = {
    layers = {
        -- Base
        {        
            filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/burner-electric-generator.png",
            width = 106,
            height = 136,
            frame_count = 32,
            line_length = 8,
            repeat_count = 3,
            shift = util.by_pixel(0, -12.5),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/hr-burner-electric-generator.png",
                width = 212,
                height = 272,
                frame_count = 32,
                line_length = 8,
                repeat_count = 3,
                shift = util.by_pixel(0, -12.5),
                scale = 0.5
            }
        },
        -- Shadow
        {
            filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/burner-electric-generator-shadow.png",
            width = 144,
            height = 85,
            frame_count = 32,
            line_length = 8,
            repeat_count = 3,
            draw_as_shadow = true,
            shift = util.by_pixel(30, 12),
            hr_version = {
                filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/hr-burner-electric-generator-shadow.png",
                width = 288,
                height = 170,
                frame_count = 32,
                line_length = 8,
                repeat_count = 3,
                draw_as_shadow = true,
                shift = util.by_pixel(30, 12),
                scale = 0.5
            }
        }
    }
}

-- Handle smoke
entity.burner.smoke = {
    {
        name = "smoke",
        north_position = util.by_pixel(72/2, -141/2),
        east_position = util.by_pixel(72/2, -141/2),
        south_position = util.by_pixel(72/2, -141/2),
        west_position = util.by_pixel(72/2, -141/2),
        frequency = 15,
        starting_vertical_speed = 0.08,
        starting_frame_deviation = 60,
    }
}

entity.water_reflection = {
    pictures = {
        filename = inputs.directory.."/graphics/entity/power/burner-electric-generator/burner-electric-generator-reflection.png",
        priority = "extra-high",
        width = 28,
        height = 36,
        shift = util.by_pixel(5, 60),
        variation_count = 1,
        scale = 5,
    },
    rotate = false,
    orientation_to_variation = false
}

-- Fix drawing box
entity.drawing_box = {{-1.5, -2.25}, {1.5, 1.5}}