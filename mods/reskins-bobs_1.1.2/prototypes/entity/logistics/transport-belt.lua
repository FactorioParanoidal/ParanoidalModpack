-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- We reskin the base entities only if we're doing custom colors
local custom_colors = true
if reskins.lib.setting("reskins-lib-customize-tier-colors") == false then
    custom_colors = false
end

-- Set input parameters
local inputs = {
    type = "transport-belt",
    icon_name = "transport-belt",
    mod = "bobs",
    group = "logistics",
    particles = {["medium"] = 1, ["small"] = 2},
    icon_layers = 2,
}

-- Handle belt tier labels
if reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") == true then
    inputs.tier_labels = true
end

local tier_map = {
    ["basic-transport-belt"] = {0, 1, true, "transport-belt"},
    ["transport-belt"] = {1, 1, custom_colors, "transport-belt"},
    ["fast-transport-belt"] = {2, 2, custom_colors, "express-transport-belt"},
    ["express-transport-belt"] = {3, 2, custom_colors, "express-transport-belt"},
    ["turbo-transport-belt"] = {4, 2, true, "express-transport-belt"},
    ["ultimate-transport-belt"] = {5, 2, true, "express-transport-belt"},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    local variant = map[2]
    local do_reskin = map[3]

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    -- Handle base_entity
    inputs.base_entity = map[4]

    -- Check if we're doing reskin operations on the vanilla belts
    if do_reskin == false then
        reskins.lib.append_tier_labels_to_vanilla_icon(name, tier, inputs)
        goto continue
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet(2, {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/transport-belt/remnants/transport-belt-remnants-base.png",
                line_length = 1,
                width = 54,
                height = 52,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(1, 0),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/transport-belt/remnants/hr-transport-belt-remnants-base.png",
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
                filename = reskins.bobs.directory.."/graphics/entity/logistics/transport-belt/remnants/transport-belt-remnants-mask.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/transport-belt/remnants/hr-transport-belt-remnants-mask.png",
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
            }
        }
    })

    -- Reskin entities
    entity.belt_animation_set = reskins.bobs.transport_belt_animation_set(inputs.tint, variant)

    -- Label to skip to next iteration
    ::continue::
end