-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "hydro-plant",
    base_entity_name = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "refining",
    make_remnants = false,
}

local tier_map = {
    ["hydro-plant"] = {tier = 1},
    ["hydro-plant-2"] = {tier = 2},
    ["hydro-plant-3"] = {tier = 3},

    -- Extended Angels
    ["hydro-plant-4"] = {tier = 4, prog_tier = 5},
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
                filename = "__angelsrefining__/graphics/entity/hydro-plant/hydro-plant-base.png",
                priority = "extra-high",
                width = 231,
                height = 247,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = "__angelsrefining__/graphics/entity/hydro-plant/hr-hydro-plant-base.png",
                    priority = "extra-high",
                    width = 459,
                    height = 491,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/hydro-plant/hydro-plant-mask.png",
                priority = "extra-high",
                width = 231,
                height = 247,
                shift = util.by_pixel(0, 0),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/hydro-plant/hr-hydro-plant-mask.png",
                    priority = "extra-high",
                    width = 459,
                    height = 491,
                    shift = util.by_pixel(0, 0),
                    tint = inputs.tint,
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/hydro-plant/hydro-plant-highlights.png",
                priority = "extra-high",
                width = 231,
                height = 247,
                shift = util.by_pixel(0, 0),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/hydro-plant/hr-hydro-plant-highlights.png",
                    priority = "extra-high",
                    width = 459,
                    height = 491,
                    shift = util.by_pixel(0, 0),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                },
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end