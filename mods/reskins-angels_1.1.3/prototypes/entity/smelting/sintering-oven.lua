-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "sintering-oven",
    base_entity = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "smelting",
    make_remnants = false,
}

local tier_map = {
    ["sintering-oven"] = {tier = 1, prog_tier = 2},
    ["sintering-oven-2"] = {tier = 2, prog_tier = 3},
    ["sintering-oven-3"] = {tier = 3, prog_tier = 4},
    ["sintering-oven-4"] = {tier = 4, prog_tier = 5},
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
                filename = "__angelssmelting__/graphics/entity/sintering-oven/sintering-oven-base.png",
                priority = "high",
                width = 165,
                height = 177,
                shift = util.by_pixel(-1, -7),
                hr_version = {
                    filename = "__angelssmelting__/graphics/entity/sintering-oven/hr-sintering-oven-base.png",
                    priority = "high",
                    width = 326,
                    height = 350,
                    shift = util.by_pixel(-1, -6.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/sintering-oven/sintering-oven-mask.png",
                priority = "high",
                width = 165,
                height = 177,
                shift = util.by_pixel(-1, -7),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/smelting/sintering-oven/hr-sintering-oven-mask.png",
                    priority = "high",
                    width = 326,
                    height = 350,
                    shift = util.by_pixel(-1, -6.5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/sintering-oven/sintering-oven-highlights.png",
                priority = "high",
                width = 165,
                height = 177,
                shift = util.by_pixel(-1, -7),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/smelting/sintering-oven/hr-sintering-oven-highlights.png",
                    priority = "high",
                    width = 326,
                    height = 350,
                    shift = util.by_pixel(-1, -6.5),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = "__angelssmelting__/graphics/entity/sintering-oven/sintering-oven-shadow.png",
                priority = "high",
                width = 213,
                height = 115,
                shift = util.by_pixel(24, 29),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__angelssmelting__/graphics/entity/sintering-oven/hr-sintering-oven-shadow.png",
                    priority = "high",
                    width = 424,
                    height = 227,
                    shift = util.by_pixel(23, 28),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end