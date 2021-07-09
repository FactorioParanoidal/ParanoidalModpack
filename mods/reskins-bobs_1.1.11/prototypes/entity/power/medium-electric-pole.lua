-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if not (reskins.bobs and reskins.bobs.triggers.power.poles) then return end

-- Set input parameters
local inputs = {
    type = "electric-pole",
    icon_name = "medium-electric-pole",
    base_entity = "medium-electric-pole",
    mod = "bobs",
    group = "power",
    particles = {["medium-long"] = 1},
}

local tier_map = {
    ["medium-electric-pole"] = {1, 2},
    ["medium-electric-pole-2"] = {2, 3},
    ["medium-electric-pole-3"] = {3, 4},
    ["medium-electric-pole-4"] = {4, 5},
}

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

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet(3, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-base-remnants.png",
                line_length = 1,
                width = 142,
                height = 70,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(35, -5),
                hr_version = {
                    filename = "__base__/graphics/entity/medium-electric-pole/remnants/hr-medium-electric-pole-base-remnants.png",
                    line_length = 1,
                    width = 284,
                    height = 140,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(35, -5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-base-remnants-mask.png",
                line_length = 1,
                width = 142,
                height = 70,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(35, -5),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/hr-medium-electric-pole-base-remnants-mask.png",
                    line_length = 1,
                    width = 284,
                    height = 140,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(35, -5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-base-remnants-highlights.png",
                line_length = 1,
                width = 142,
                height = 70,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(35, -5),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/hr-medium-electric-pole-base-remnants-highlights.png",
                    line_length = 1,
                    width = 284,
                    height = 140,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(35, -5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            },
        }
    })

    remnant.animation_overlay = make_rotated_animation_variations_from_sheet(3, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/medium-electric-pole/remnants/medium-electric-pole-top-remnants.png",
                line_length = 1,
                width = 50,
                height = 92,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0 , -39),
                hr_version = {
                    filename = "__base__/graphics/entity/medium-electric-pole/remnants/hr-medium-electric-pole-top-remnants.png",
                    line_length = 1,
                    width = 100,
                    height = 184,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(0, -38.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-top-remnants-mask.png",
                line_length = 1,
                width = 50,
                height = 92,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0 , -39),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/hr-medium-electric-pole-top-remnants-mask.png",
                    line_length = 1,
                    width = 100,
                    height = 184,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(0, -38.5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/medium-electric-pole-top-remnants-highlights.png",
                line_length = 1,
                width = 50,
                height = 92,
                frame_count = 1,
                direction_count = 1,
                shift = util.by_pixel(0 , -39),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/remnants/hr-medium-electric-pole-top-remnants-highlights.png",
                    line_length = 1,
                    width = 100,
                    height = 184,
                    frame_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(0, -38.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            }
        }
    })

    -- Reskin entities
    entity.pictures = {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole.png",
                priority = "extra-high",
                width = 40,
                height = 124,
                direction_count = 4,
                shift = util.by_pixel(4, -44),
                hr_version = {
                    filename = "__base__/graphics/entity/medium-electric-pole/hr-medium-electric-pole.png",
                    priority = "extra-high",
                    width = 84,
                    height = 252,
                    direction_count = 4,
                    shift = util.by_pixel(3.5, -44),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/medium-electric-pole-mask.png",
                priority = "extra-high",
                width = 40,
                height = 124,
                direction_count = 4,
                shift = util.by_pixel(4, -44),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/hr-medium-electric-pole-mask.png",
                    priority = "extra-high",
                    width = 84,
                    height = 252,
                    direction_count = 4,
                    shift = util.by_pixel(3.5, -44),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/medium-electric-pole-highlights.png",
                priority = "extra-high",
                width = 40,
                height = 124,
                direction_count = 4,
                shift = util.by_pixel(4, -44),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/power/medium-electric-pole/hr-medium-electric-pole-highlights.png",
                    priority = "extra-high",
                    width = 84,
                    height = 252,
                    direction_count = 4,
                    shift = util.by_pixel(3.5, -44),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/medium-electric-pole/medium-electric-pole-shadow.png",
                priority = "extra-high",
                width = 140,
                height = 32,
                direction_count = 4,
                shift = util.by_pixel(56, -1),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__base__/graphics/entity/medium-electric-pole/hr-medium-electric-pole-shadow.png",
                    priority = "extra-high",
                    width = 280,
                    height = 64,
                    direction_count = 4,
                    shift = util.by_pixel(56.5, -1),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end