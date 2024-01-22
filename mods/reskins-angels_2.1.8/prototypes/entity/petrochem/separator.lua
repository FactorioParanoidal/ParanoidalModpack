-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "separator",
    base_entity_name = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "petrochem",
    make_remnants = false,
}

local tier_map = {
    ["separator"] = {tier = 1, prog_tier = 2},
    ["separator-2"] = {tier = 2, prog_tier = 3},
    ["separator-3"] = {tier = 3, prog_tier = 4},
    ["separator-4"] = {tier = 4, prog_tier = 5},
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
                filename = "__angelspetrochem__/graphics/entity/separator/separator.png",
                priority = "extra-high",
                width = 224,
                height = 224,
                shift = {0, 0},
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/separator/separator-mask.png",
                priority = "extra-high",
                width = 224,
                height = 224,
                shift = {0, 0},
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/separator/separator-highlights.png",
                priority = "extra-high",
                width = 224,
                height = 224,
                shift = {0, 0},
                blend_mode = reskins.lib.blend_mode,
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end