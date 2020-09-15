-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] and not mods["bobplates"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end

-- Set input parameters
local inputs = {
    type = "furnace",
    icon_name = "distillery",
    base_entity = "steel-furnace",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "assembly",
    particles = {["medium"] = 2},
    make_remnants = false,
}

local tier_map = {
    ["bob-distillery"] = 1,
    ["bob-distillery-2"] = 2,
    ["bob-distillery-3"] = 3,
    ["bob-distillery-4"] = 4,
    ["bob-distillery-5"] = 5,
}

-- Reskin entities, create and assign extra details
for name, tier in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entity
    entity.animation = reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/distillery-base.png",
                width = 74,
                height = 96,
                frame_count = 1,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/hr-distillery-base.png",
                    width = 148,
                    height = 192,
                    frame_count = 1,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/distillery-mask.png",
                width = 64,
                height = 96,
                frame_count = 1,
                shift = util.by_pixel(0, 0),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/hr-distillery-mask.png",
                    width = 128,
                    height = 192,
                    frame_count = 1,
                    shift = util.by_pixel(0, 0),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/distillery-highlights.png",
                width = 64,
                height = 96,
                frame_count = 1,
                shift = util.by_pixel(0, 0),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/hr-distillery-highlights.png",
                    width = 128,
                    height = 192,
                    frame_count = 1,
                    shift = util.by_pixel(0, 0),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/distillery-shadow.png",
                width = 96,
                height = 67,
                frame_count = 1,
                shift = util.by_pixel(16, 1.5),
                draw_as_shadow = true,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/hr-distillery-shadow.png",
                    width = 192,
                    height = 134,
                    frame_count = 1,
                    shift = util.by_pixel(16, 1.5),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            }
        }
    })

    -- Handle Working Visualization
    entity.working_visualisations = {
        {
            effect = "uranium-glow",
            light = {intensity = 0.5, size = 2, color = {r = 1.0, g = 1.0, b = 1.0}},
            fadeout = true,
            north_position = util.by_pixel(-7.5, -9),
            east_position = util.by_pixel(10, -9),
            south_position = util.by_pixel(8, 3.5),
            west_position = util.by_pixel(-10, 3),
            north_animation = {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/distillery-light-north.png",
                width = 33,
                height = 31,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/hr-distillery-light-north.png",
                    width = 66,
                    height = 62,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            },
            east_animation = {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/distillery-light-east.png",
                width = 34,
                height = 30,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/hr-distillery-light-east.png",
                    width = 68,
                    height = 60,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            },
            south_animation = {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/distillery-light-south.png",
                width = 33,
                height = 32,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/hr-distillery-light-south.png",
                    width = 66,
                    height = 64,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            },
            west_animation = {
                filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/distillery-light-west.png",
                width = 33,
                height = 29,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/distillery/lights/hr-distillery-light-west.png",
                    width = 66,
                    height = 58,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            },
        }
    }

    entity.water_reflection = {
        pictures = {
            filename = inputs.directory.."/graphics/entity/assembly/distillery/distillery-reflection.png",
            priority = "extra-high",
            width = 28,
            height = 36,
            shift = util.by_pixel(10/3, 35),
            variation_count = 4,
            scale = 10/3,
        },
        rotate = false,
        orientation_to_variation = true
    }

    -- Label to skip to next iteration
    ::continue::
end