-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "ore-refinery",
    base_entity = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "refining",
    make_remnants = false,
}

local tier_map = {
    ["ore-refinery"] = {tier = 1, prog_tier = 4},
    ["ore-refinery-2"] = {tier = 2, prog_tier = 5},

    -- Extended Angels
    ["ore-refinery-3"] = {tier = 3, prog_tier = 6},
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
                filename = "__angelsrefining__/graphics/entity/ore-refinery/1ore-refinery.png",
                priority = "extra-high",
                width = 256,
                height = 256,
                frame_count = 16,
                line_length = 4,
                animation_speed = 0.5,
                shift = {0.5, -0.5},
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-refinery/ore-refinery-mask.png",
                priority = "extra-high",
                width = 256,
                height = 256,
                repeat_count = 16,
                animation_speed = 0.5,
                shift = {0.5, -0.5},
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-refinery/ore-refinery-highlights.png",
                priority = "extra-high",
                width = 256,
                height = 256,
                repeat_count = 16,
                animation_speed = 0.5,
                shift = {0.5, -0.5},
                blend_mode = reskins.lib.blend_mode,
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end