-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "ore-powderizer",
    base_entity_name = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "refining",
    make_remnants = false,
}

local tier_map = {
    ["ore-powderizer"] = {tier = 1, prog_tier = 2},
    ["ore-powderizer-2"] = {tier = 2, prog_tier = 3},
    ["ore-powderizer-3"] = {tier = 3, prog_tier = 4},
}

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
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = {
        layers = {
            -- Base
            {
                filename = "__angelsrefining__/graphics/entity/ore-powderizer/powderizer-lr.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                frame_count = 36,
                line_length = 6,
                shift = {0, 0},
                animation_speed = 0.5,
                hr_version = {
                    filename = "__angelsrefining__/graphics/entity/ore-powderizer/powderizer-hr.png",
                    priority = "extra-high",
                    width = 256,
                    height = 256,
                    frame_count = 36,
                    line_length = 6,
                    shift = {0, 0},
                    animation_speed = 0.5,
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-powderizer/ore-powderizer-mask.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                repeat_count = 36,
                shift = {0, 0},
                animation_speed = 0.5,
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-powderizer/hr-ore-powderizer-mask.png",
                    priority = "extra-high",
                    width = 256,
                    height = 256,
                    repeat_count = 36,
                    shift = {0, 0},
                    animation_speed = 0.5,
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-powderizer/ore-powderizer-highlights.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                repeat_count = 36,
                shift = {0, 0},
                animation_speed = 0.5,
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-powderizer/hr-ore-powderizer-highlights.png",
                    priority = "extra-high",
                    width = 256,
                    height = 256,
                    repeat_count = 36,
                    shift = {0, 0},
                    animation_speed = 0.5,
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5
                }
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end