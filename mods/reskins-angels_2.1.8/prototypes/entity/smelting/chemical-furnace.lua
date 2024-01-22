-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "chemical-furnace",
    base_entity_name = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "smelting",
    make_remnants = false,
}

local tier_map
if angelsmods.trigger.early_chemical_furnace then
    tier_map = {
        ["angels-chemical-furnace"] = {tier = 1, prog_tier = 2},
        ["angels-chemical-furnace-2"] = {tier = 2, prog_tier = 3},
        ["angels-chemical-furnace-3"] = {tier = 3, prog_tier = 4},
        ["angels-chemical-furnace-4"] = {tier = 4, prog_tier = 5},
    }
else
   tier_map = {
        ["angels-chemical-furnace-2"] = {tier = 1, prog_tier = 3, defer_to_data_updates = true},
        ["angels-chemical-furnace-3"] = {tier = 2, prog_tier = 4, defer_to_data_updates = true},
        ["angels-chemical-furnace-4"] = {tier = 3, prog_tier = 5, defer_to_data_updates = true},
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Determine what tint we're using
    inputs.defer_to_data_updates = map.defer_to_data_updates
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = {
        layers = {
            -- Base
            {
                filename = "__angelssmelting__/graphics/entity/chemical-furnace/chemical-furnace-base.png",
                priority = "extra-high",
                width = 168,
                height = 189,
                line_length = 6,
                frame_count = 36,
                animation_speed = 0.5,
                shift = util.by_pixel(-1, -12),
                hr_version = {
                    priority = "extra-high",
                    width = 332,
                    height = 374,
                    frame_count = 36,
                    stripes = {
                        {
                            filename = "__angelssmelting__/graphics/entity/chemical-furnace/hr-chemical-furnace-base_01.png",
                            width_in_frames = 6,
                            height_in_frames = 3,
                        },
                        {
                            filename = "__angelssmelting__/graphics/entity/chemical-furnace/hr-chemical-furnace-base_02.png",
                            width_in_frames = 6,
                            height_in_frames = 3,
                        },
                    },
                    animation_speed = 0.5,
                    shift = util.by_pixel(-1, -11.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/chemical-furnace/chemical-furnace-mask.png",
                priority = "extra-high",
                width = 168,
                height = 189,
                line_length = 6,
                frame_count = 36,
                animation_speed = 0.5,
                tint = inputs.tint,
                shift = util.by_pixel(-1, -12),
                hr_version = {
                    priority = "extra-high",
                    width = 332,
                    height = 374,
                    frame_count = 36,
                    stripes = {
                        {
                            filename = reskins.angels.directory.."/graphics/entity/smelting/chemical-furnace/hr-chemical-furnace-mask_01.png",
                            width_in_frames = 6,
                            height_in_frames = 3,
                        },
                        {
                            filename = reskins.angels.directory.."/graphics/entity/smelting/chemical-furnace/hr-chemical-furnace-mask_02.png",
                            width_in_frames = 6,
                            height_in_frames = 3,
                        },
                    },
                    animation_speed = 0.5,
                    tint = inputs.tint,
                    shift = util.by_pixel(-1, -11.5),
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/chemical-furnace/chemical-furnace-highlights.png",
                priority = "extra-high",
                width = 168,
                height = 189,
                line_length = 6,
                frame_count = 36,
                animation_speed = 0.5,
                blend_mode = reskins.lib.blend_mode,
                shift = util.by_pixel(-1, -12),
                hr_version = {
                    priority = "extra-high",
                    width = 332,
                    height = 374,
                    frame_count = 36,
                    stripes = {
                        {
                            filename = reskins.angels.directory.."/graphics/entity/smelting/chemical-furnace/hr-chemical-furnace-highlights_01.png",
                            width_in_frames = 6,
                            height_in_frames = 3,
                        },
                        {
                            filename = reskins.angels.directory.."/graphics/entity/smelting/chemical-furnace/hr-chemical-furnace-highlights_02.png",
                            width_in_frames = 6,
                            height_in_frames = 3,
                        },
                    },
                    animation_speed = 0.5,
                    blend_mode = reskins.lib.blend_mode,
                    shift = util.by_pixel(-1, -11.5),
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = "__angelssmelting__/graphics/entity/chemical-furnace/chemical-furnace-shadow.png",
                priority = "extra-high",
                width = 224,
                height = 141,
                line_length = 6,
                frame_count = 36,
                animation_speed = 0.5,
                draw_as_shadow = true,
                shift = util.by_pixel(28, 13),
                hr_version = {
                    priority = "extra-high",
                    width = 448,
                    height = 280,
                    frame_count = 36,
                    stripes = {
                        {
                            filename = "__angelssmelting__/graphics/entity/chemical-furnace/hr-chemical-furnace-shadow_01.png",
                            width_in_frames = 4,
                            height_in_frames = 7,
                        },
                        {
                            filename = "__angelssmelting__/graphics/entity/chemical-furnace/hr-chemical-furnace-shadow_02.png",
                            width_in_frames = 4,
                            height_in_frames = 2,
                        },
                    },
                    animation_speed = 0.5,
                    draw_as_shadow = true,
                    shift = util.by_pixel(28, 12.5),
                    scale = 0.5,
                }
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end