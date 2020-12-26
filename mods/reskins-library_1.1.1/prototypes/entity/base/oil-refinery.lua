-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not data.raw["assembling-machine"]["oil-refinery-2"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end
if reskins.lib.setting("reskins-angels-do-angelspetrochem") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "oil-refinery",
    base_entity = "oil-refinery",
    mod = "lib",
    group = "base",
    particles = {["big-tint"] = 5, ["medium"] = 2},
}

local tier_map = {
    ["oil-refinery"] = {tier = 1, prog_tier = 2},
    ["oil-refinery-2"] = {tier = 2, prog_tier = 3},
    ["oil-refinery-3"] = {tier = 3, prog_tier = 4},
    ["oil-refinery-4"] = {tier = 4, prog_tier = 5},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Handle tier details
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- COMPATIBILITY WITH SHINY RESKIN MODS
    inputs.defer_to_data_final_fixes = true

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet(1, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/oil-refinery/remnants/refinery-remnants.png",
                line_length = 1,
                width = 234,
                height = 200,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 0), --moved from -8.5 to -4.5
                hr_version = {
                    filename = "__base__/graphics/entity/oil-refinery/remnants/hr-refinery-remnants.png",
                    line_length = 1,
                    width = 467,
                    height = 415,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-0.25, -0.25), --moved from -8.5 to -4.5
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/refinery-remnants-mask.png",
                line_length = 1,
                width = 234,
                height = 200,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 0),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/hr-refinery-remnants-mask.png",
                    line_length = 1,
                    width = 467,
                    height = 415,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-0.25, -0.25),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/refinery-remnants-highlights.png",
                line_length = 1,
                width = 234,
                height = 200,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0, 0),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/remnants/hr-refinery-remnants-highlights.png",
                    line_length = 1,
                    width = 467,
                    height = 415,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-0.25, -0.25),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            }
        }
    })

    -- Reskin entity
    entity.animation = reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/oil-refinery/oil-refinery.png",
                width = 337,
                height = 255,
                frame_count = 1,
                shift = {2.515625, 0.484375},
                hr_version = {
                filename = "__base__/graphics/entity/oil-refinery/hr-oil-refinery.png",
                width = 386,
                height = 430,
                frame_count = 1,
                shift = util.by_pixel(0, -7.5),
                scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/oil-refinery-mask.png",
                width = 337,
                height = 255,
                frame_count = 1,
                shift = {2.515625, 0.484375},
                tint = inputs.tint,
                hr_version = {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/hr-oil-refinery-mask.png",
                width = 386,
                height = 430,
                frame_count = 1,
                shift = util.by_pixel(0, -7.5),
                tint = inputs.tint,
                scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/oil-refinery-highlights.png",
                width = 337,
                height = 255,
                frame_count = 1,
                shift = {2.515625, 0.484375},
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                filename = reskins.lib.directory.."/graphics/entity/base/oil-refinery/hr-oil-refinery-highlights.png",
                width = 386,
                height = 430,
                frame_count = 1,
                shift = util.by_pixel(0, -7.5),
                blend_mode = reskins.lib.blend_mode,
                scale = 0.5
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/oil-refinery/oil-refinery-shadow.png",
                width = 337,
                height = 213,
                frame_count = 1,
                shift = util.by_pixel(82.5, 26.5),
                draw_as_shadow = true,
                hr_version = {
                filename = "__base__/graphics/entity/oil-refinery/hr-oil-refinery-shadow.png",
                width = 674,
                height = 426,
                frame_count = 1,
                shift = util.by_pixel(82.5, 26.5),
                draw_as_shadow = true,
                force_hr_shadow = true,
                scale = 0.5
                }
            }
        }
    })

    -- Label to skip to next iteration
    ::continue::
end