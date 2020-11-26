-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobpower"] then return end
if reskins.lib.setting("bobmods-power-steam") == false then return end
if reskins.lib.setting("reskins-bobs-do-bobpower") == false then return end

-- Set input parameters
local inputs = {
    type = "generator",
    icon_name = "steam-engine",
    base_entity = "steam-engine",
    mod = "bobs",
    group = "power",
    particles = {["medium"] = 2,["big"] = 1},
}

local tier_map = {
    ["steam-engine"] = 1,
    ["steam-engine-2"] = 2,
    ["steam-engine-3"] = 3,
    ["steam-engine-4"] = 4,
    ["steam-engine-5"] = 5
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

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet (1, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/steam-engine/remnants/steam-engine-remnants.png",
                line_length = 1,
                width = 232,
                height = 194,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(17, 7),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/remnants/hr-steam-engine-remnants.png",
                    line_length = 1,
                    width = 462,
                    height = 386,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(17, 6.5),
                    scale = 0.5,
                }
            },
            -- Color Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/remnants/steam-engine-remnants-mask.png",
                line_length = 1,
                width = 232,
                height = 194,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(17, 7),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/remnants/hr-steam-engine-remnants-mask.png",
                    line_length = 1,
                    width = 462,
                    height = 386,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(17, 6.5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/remnants/steam-engine-remnants-highlights.png",
                line_length = 1,
                width = 232,
                height = 194,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(17, 7),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/remnants/hr-steam-engine-remnants-highlights.png",
                    line_length = 1,
                    width = 462,
                    height = 386,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(17, 6.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            }
        }
    })

    -- Reskin entities
    entity.horizontal_animation = {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-H.png",
                width = 176,
                height = 128,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H.png",
                    width = 352,
                    height = 257,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }
            },
            -- Color Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/steam-engine-H-mask.png",
                width = 176,
                height = 128,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(1, -5),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/hr-steam-engine-H-mask.png",
                    width = 352,
                    height = 257,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(1, -4.75),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/steam-engine-H-highlights.png",
                width = 176,
                height = 128,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(1, -5),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/hr-steam-engine-H-highlights.png",
                    width = 352,
                    height = 257,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(1, -4.75),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
                width = 254,
                height = 80,
                frame_count = 32,
                line_length = 8,
                draw_as_shadow = true,
                shift = util.by_pixel(48, 24),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H-shadow.png",
                    width = 508,
                    height = 160,
                    frame_count = 32,
                    line_length = 8,
                    draw_as_shadow = true,
                    shift = util.by_pixel(48, 24),
                    scale = 0.5
                }
            }
        }
    }

    entity.vertical_animation = {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-V.png",
                width = 112,
                height = 195,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(5, -6.5),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V.png",
                    width = 225,
                    height = 391,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }
            },
            -- Color mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/steam-engine-V-mask.png",
                width = 112,
                height = 195,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(5, -6.5),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/hr-steam-engine-V-mask.png",
                    width = 225,
                    height = 391,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(4.75, -6.25),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/steam-engine-V-highlights.png",
                width = 112,
                height = 195,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(5, -6.5),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/steam-engine/hr-steam-engine-V-highlights.png",
                    width = 225,
                    height = 391,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel(4.75, -6.25),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
                width = 165,
                height = 153,
                frame_count = 32,
                line_length = 8,
                draw_as_shadow = true,
                shift = util.by_pixel(40.5, 9.5),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V-shadow.png",
                    width = 330,
                    height = 307,
                    frame_count = 32,
                    line_length = 8,
                    draw_as_shadow = true,
                    shift = util.by_pixel(40.5, 9.25),
                    scale = 0.5
                }
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end