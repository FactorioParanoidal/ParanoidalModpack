-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE in the project directory for license information.

-- Check if reskinning needs to be done
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

-- We reskin the base entities only if we're doing custom colors
local use_custom_colors = reskins.lib.setting("reskins-lib-customize-tier-colors")

-- Set input parameters
local inputs = {
    type = "transport-belt",
    icon_name = "transport-belt",
    mod = "lib",
    group = "base",
    particles = {["medium"] = 1, ["small"] = 2},
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
    ["basic-transport-belt"] = {tier = 0, sprite_variant = 1, base_entity = "transport-belt"},
    ["transport-belt"] = {tier = 1, sprite_variant = 1, recolor = use_custom_colors, base_entity = "transport-belt"},
    ["fast-transport-belt"] = {tier = 2, sprite_variant = 2, recolor = use_custom_colors, base_entity = "express-transport-belt"},
    ["express-transport-belt"] = {tier = 3, sprite_variant = 2, recolor = use_custom_colors, base_entity = "express-transport-belt"},
    ["turbo-transport-belt"] = {tier = 4, sprite_variant = 2, base_entity = "express-transport-belt"},
    ["ultimate-transport-belt"] = {tier = 5, sprite_variant = 2, base_entity = "express-transport-belt"},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.belt_tint_index[map.tier]

    -- Handle base_entity
    inputs.base_entity = map.base_entity

    -- Check if we're doing reskin operations on the vanilla splitters
    if map.recolor == false then
        reskins.lib.append_tier_labels_to_vanilla_icon(name, map.tier, inputs)
        goto continue
    end

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet(2, {
        layers = {
            -- Base
            {
                filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-base.png",
                line_length = 1,
                width = 54,
                height = 52,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(1, 0),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/remnants/hr-transport-belt-remnants-base.png",
                    line_length = 1,
                    width = 106,
                    height = 102,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(1, -0.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-mask.png",
                line_length = 1,
                width = 54,
                height = 52,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                tint = inputs.tint,
                shift = util.by_pixel(1, 0),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/remnants/hr-transport-belt-remnants-mask.png",
                    line_length = 1,
                    width = 106,
                    height = 102,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    tint = inputs.tint,
                    shift = util.by_pixel(1, -0.5),
                    scale = 0.5,
                }
            },
            -- -- Highlights
            -- {
            --     filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/remnants/transport-belt-remnants-mask.png",
            --     line_length = 1,
            --     width = 54,
            --     height = 52,
            --     frame_count = 1,
            --     variation_count = 1,
            --     axially_symmetrical = false,
            --     direction_count = 4,
            --     tint = inputs.tint,
            --     shift = util.by_pixel(1, 0),
            --     hr_version = {
            --         filename = reskins.lib.directory.."/graphics/entity/base/transport-belt/remnants/hr-transport-belt-remnants-mask.png",
            --         line_length = 1,
            --         width = 106,
            --         height = 102,
            --         frame_count = 1,
            --         variation_count = 1,
            --         axially_symmetrical = false,
            --         direction_count = 4,
            --         tint = inputs.tint,
            --         shift = util.by_pixel(1, -0.5),
            --         scale = 0.5,
            --     }
            -- }
        }
    })

    -- Reskin entities
    entity.belt_animation_set = reskins.lib.transport_belt_animation_set(inputs.tint, map.sprite_variant)

    -- Label to skip to next iteration
    ::continue::
end