-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "blast-furnace",
    base_entity_name = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "smelting",
    make_remnants = false,
}

local tier_map = {
    ["blast-furnace"] = {tier = 1},
    ["blast-furnace-2"] = {tier = 2},
    ["blast-furnace-3"] = {tier = 3},
    ["blast-furnace-4"] = {tier = 4},
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
                filename = "__angelssmelting__/graphics/entity/blast-furnace/blast-furnace-base.png",
                priority = "extra-high",
                width = 164,
                height = 189,
                shift = util.by_pixel(0, -14),
                hr_version = {
                    filename = "__angelssmelting__/graphics/entity/blast-furnace/hr-blast-furnace-base.png",
                    priority = "extra-high",
                    width = 328,
                    height = 376,
                    shift = util.by_pixel(0, -13.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/blast-furnace/blast-furnace-mask.png",
                priority = "extra-high",
                width = 164,
                height = 189,
                shift = util.by_pixel(0, -14),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/smelting/blast-furnace/hr-blast-furnace-mask.png",
                    priority = "extra-high",
                    width = 328,
                    height = 376,
                    shift = util.by_pixel(0, -13.5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/blast-furnace/blast-furnace-highlights.png",
                priority = "extra-high",
                width = 164,
                height = 189,
                shift = util.by_pixel(0, -14),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/smelting/blast-furnace/hr-blast-furnace-highlights.png",
                    priority = "extra-high",
                    width = 328,
                    height = 376,
                    shift = util.by_pixel(0, -13.5),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = "__angelssmelting__/graphics/entity/blast-furnace/blast-furnace-shadow.png",
                priority = "extra-high",
                width = 224,
                height = 124,
                shift = util.by_pixel(30, 20),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__angelssmelting__/graphics/entity/blast-furnace/hr-blast-furnace-shadow.png",
                    priority = "extra-high",
                    width = 445,
                    height = 245,
                    shift = util.by_pixel(29, 19.5),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            },
        }
    }

    -- Handle ambient-light
    entity.energy_source.light_flicker = {
        color = {0, 0, 0},
        minimum_light_size = 0,
        light_intensity_to_size_coefficient = 0,
    }

    -- Label to skip to next iteration
    ::continue::
end