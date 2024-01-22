-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "crystallizer",
    base_entity_name = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "refining",
    make_remnants = false,
}

local tier_map = {
    ["crystallizer"] = {tier = 1, prog_tier = 2},
    ["crystallizer-2"] = {tier = 2, prog_tier = 3},
    ["crystallizer-3"] = {tier = 3, prog_tier = 4},

    -- Extended Angels
    ["crystallizer-4"] = {tier = 4, prog_tier = 5},
}

-- Sea Block compatibility
if mods["SeaBlock"] then
    tier_map["crystallizer"].prog_tier = 1
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
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = {
        layers = {
            -- Base
            {
                filename = "__angelsrefining__/graphics/entity/crystallizer/crystallizer.png",
                priority = "extra-high",
                width = 195,
                height = 163,
                shift = util.by_pixel(15.5, -0.5),
                hr_version = {
                    filename = "__angelsrefining__/graphics/entity/crystallizer/hr-crystallizer.png",
                    priority = "extra-high",
                    width = 390,
                    height = 326,
                    shift = util.by_pixel(16, 0),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/crystallizer/crystallizer-mask.png",
                priority = "extra-high",
                width = 195,
                height = 163,
                shift = util.by_pixel(15.5, -0.5),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/crystallizer/hr-crystallizer-mask.png",
                    priority = "extra-high",
                    width = 390,
                    height = 326,
                    shift = util.by_pixel(16, 0),
                    tint = inputs.tint,
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/crystallizer/crystallizer-highlights.png",
                priority = "extra-high",
                width = 195,
                height = 163,
                shift = util.by_pixel(15.5, -0.5),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/crystallizer/hr-crystallizer-highlights.png",
                    priority = "extra-high",
                    width = 390,
                    height = 326,
                    shift = util.by_pixel(16, 0),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                },
            },
            -- Shadow
            {
                filename = "__angelsrefining__/graphics/entity/crystallizer/crystallizer-shadow.png",
                priority = "extra-high",
                width = 195,
                height = 163,
                shift = util.by_pixel(15.5, -0.5),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__angelsrefining__/graphics/entity/crystallizer/hr-crystallizer-shadow.png",
                    priority = "extra-high",
                    width = 390,
                    height = 326,
                    shift = util.by_pixel(16, 0),
                    draw_as_shadow = true,
                    scale = 0.5,
                },
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end