-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobpower"] then return end
if reskins.lib.setting("bobmods-power-fluidgenerator") == false then return end
if reskins.lib.setting("reskins-bobs-do-bobpower") == false then return end

-- Set input parameters
local inputs = {
    type = "generator",
    icon_name = "fluid-generator",
    base_entity = "steam-turbine",
    mod = "bobs",
    group = "power",
    particles = {["medium"] = 2,["big"] = 1},
    make_remnants = false,
}

-- Determine which tint we're using for the hydrazine-generator
if reskins.lib.setting("reskins-bobs-hydrazine-is-blue") == true then
    reskins.bobs.hydrazine_tint = util.color("7ac1de")
else
    reskins.bobs.hydrazine_tint = nil
end

local fluid_generators = {
    ["fluid-generator"] = {1, 2, 2/16},
    ["fluid-generator-2"] = {2, 3, 3/16},
    ["fluid-generator-3"] = {3, 4, 4/16},
    ["hydrazine-generator"] = {4, 5, 5/16, reskins.bobs.hydrazine_tint}
}

local function setup_fluid_generator(tint)
    return
    {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/fluid-generator-base.png",
                width = 101,
                height = 130,
                frame_count = 8,
                line_length = 4,
                shift = util.by_pixel(2.5, -11),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/hr-fluid-generator-base.png",
                    width = 202,
                    height = 260,
                    frame_count = 8,
                    line_length = 4,
                    shift = util.by_pixel(2.5, -11),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/fluid-generator-mask.png",
                width = 101,
                height = 130,
                repeat_count = 8,
                tint = inputs.tint,
                shift = util.by_pixel(2.5, -11),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/hr-fluid-generator-mask.png",
                    width = 202,
                    height = 260,
                    repeat_count = 8,
                    tint = inputs.tint,
                    shift = util.by_pixel(2.5, -11),
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/fluid-generator-highlights.png",
                width = 101,
                height = 130,
                repeat_count = 8,
                blend_mode = reskins.lib.blend_mode, -- "additive",
                shift = util.by_pixel(2.5, -11),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/hr-fluid-generator-highlights.png",
                    width = 202,
                    height = 260,
                    repeat_count = 8,
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    shift = util.by_pixel(2.5, -11),
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/fluid-generator-shadow.png",
                width = 162,
                height = 130,
                repeat_count = 8,
                draw_as_shadow = true,
                shift = util.by_pixel(33, -11),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/hr-fluid-generator-shadow.png",
                    width = 324,
                    height = 260,
                    repeat_count = 8,
                    draw_as_shadow = true,
                    shift = util.by_pixel(33, -11),
                    scale = 0.5
                }
            },
        }
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(fluid_generators) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    local frequency = map[3]

    -- Determine what tint we're using
    inputs.tint = map[4] or reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.horizontal_animation = setup_fluid_generator(inputs.tint)
    entity.vertical_animation = setup_fluid_generator(inputs.tint)

    -- Clear out working_visualisations
    entity.working_visualisations = nil

    -- Handle smoke
    if name == "hydrazine-generator" then
        entity.smoke = {
            {
                name = "light-smoke",
                north_position = util.by_pixel(-30, -44),
                east_position = util.by_pixel(-30, -44),
                frequency = frequency,
                starting_vertical_speed = 0.08,
                slow_down_factor = 1,
                starting_frame_deviation = 60
            }
        }
    else
        entity.smoke = {
            {
                name = "smoke",
                north_position = util.by_pixel(-30, -44),
                east_position = util.by_pixel(-30, -44),
                frequency = frequency,
                starting_vertical_speed = 0.08,
                slow_down_factor = 1,
                starting_frame_deviation = 60
            }
        }
    end

    entity.water_reflection = {
        pictures = {
            filename = reskins.bobs.directory.."/graphics/entity/power/fluid-generator/fluid-generator-reflection.png",
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

    -- Label to skip to next iteration
    ::continue::
end
