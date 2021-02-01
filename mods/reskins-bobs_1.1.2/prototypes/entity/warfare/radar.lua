-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobwarfare"] then return end
if reskins.lib.setting("reskins-bobs-do-bobwarfare") == false then return end

-- Set input parameters
local inputs = {
    type = "radar",
    icon_name = "radar",
    base_entity = "radar",
    mod = "bobs",
    group = "warfare",
    particles = {["medium"] = 2},
}

local tier_map = {
    ["radar"] = 1,
    ["radar-2"] = 2,
    ["radar-3"] = 3,
    ["radar-4"] = 4,
    ["radar-5"] = 5
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
                filename = "__base__/graphics/entity/radar/remnants/radar-remnants.png",
                line_length = 1,
                width = 142,
                height = 106,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(12, 4),
                hr_version = {
                    filename = "__base__/graphics/entity/radar/remnants/hr-radar-remnants.png",
                    line_length = 1,
                    width = 282,
                    height = 212,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(12, 4.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/remnants/radar-remnants-mask.png",
                line_length = 1,
                width = 142,
                height = 106,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(12, 4),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/remnants/hr-radar-remnants-mask.png",
                    line_length = 1,
                    width = 282,
                    height = 212,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(12, 4.5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/remnants/radar-remnants-highlights.png",
                line_length = 1,
                width = 142,
                height = 106,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(12, 4),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/remnants/hr-radar-remnants-highlights.png",
                    line_length = 1,
                    width = 282,
                    height = 212,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(12, 4.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            }
        }
    })

    -- Reskin entity
    entity.integration_patch = {
        filename = "__base__/graphics/entity/radar/radar-integration.png",
        priority = "low",
        width = 119,
        height = 108,
        direction_count = 1,
        shift = util.by_pixel(1.5, 4),
        hr_version = {
            filename = "__base__/graphics/entity/radar/hr-radar-integration.png",
            priority = "low",
            width = 238,
            height = 216,
            direction_count = 1,
            shift = util.by_pixel(1.5, 4),
            scale = 0.5
        }
    }

    entity.pictures = {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/radar/radar.png",
                priority = "low",
                width = 98,
                height = 128,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(1, -16),
                hr_version = {
                    filename = "__base__/graphics/entity/radar/hr-radar.png",
                    priority = "low",
                    width = 196,
                    height = 254,
                    apply_projection = false,
                    direction_count = 64,
                    line_length = 8,
                    shift = util.by_pixel(1, -16),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/radar-mask.png",
                priority = "low",
                width = 98,
                height = 128,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(1, -16),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/hr-radar-mask.png",
                    priority = "low",
                    width = 196,
                    height = 254,
                    apply_projection = false,
                    direction_count = 64,
                    line_length = 8,
                    shift = util.by_pixel(1, -16),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/radar-highlights.png",
                priority = "low",
                width = 98,
                height = 128,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(1, -16),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/radar/hr-radar-highlights.png",
                    priority = "low",
                    width = 196,
                    height = 254,
                    apply_projection = false,
                    direction_count = 64,
                    line_length = 8,
                    shift = util.by_pixel(1, -16),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = "__base__/graphics/entity/radar/radar-shadow.png",
                priority = "low",
                width = 172,
                height = 94,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(39,3),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__base__/graphics/entity/radar/hr-radar-shadow.png",
                    priority = "low",
                    width = 343,
                    height = 186,
                    apply_projection = false,
                    direction_count = 64,
                    line_length = 8,
                    shift = util.by_pixel(39.25,3),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    }

    if name ~= "radar" then
        entity.water_reflection = util.copy(data.raw[inputs.type]["radar"].water_reflection)
    end

    -- Label to skip to next iteration
    ::continue::
end