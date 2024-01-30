-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "gas-refinery",
    base_entity_name = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "petrochem",
    make_remnants = false,
}

local tier_map = {
    ["gas-refinery-small"] = {tier = 1, prog_tier = 2},
    ["gas-refinery-small-2"] = {tier = 2, prog_tier = 3},
    ["gas-refinery-small-3"] = {tier = 3, prog_tier = 4},
    ["gas-refinery-small-4"] = {tier = 4, prog_tier = 5},
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
    entity.animation = reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery-base.png",
                priority = "extra-high",
                width = 167,
                height = 278,
                shift = util.by_pixel(-0.5, -47),
                hr_version = {
                    filename = "__angelspetrochem__/graphics/entity/gas-refinery/hr-gas-refinery-base.png",
                    priority = "extra-high",
                    width = 334,
                    height = 553,
                    shift = util.by_pixel(0, -48),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/gas-refinery-mask.png",
                priority = "extra-high",
                width = 167,
                height = 278,
                shift = util.by_pixel(-0.5, -47),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/hr-gas-refinery-mask.png",
                    priority = "extra-high",
                    width = 334,
                    height = 553,
                    shift = util.by_pixel(0, -48),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/gas-refinery-highlights.png",
                priority = "extra-high",
                width = 167,
                height = 278,
                shift = util.by_pixel(-0.5, -47),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/hr-gas-refinery-highlights.png",
                    priority = "extra-high",
                    width = 334,
                    height = 553,
                    shift = util.by_pixel(0, -48),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = "__angelspetrochem__/graphics/entity/gas-refinery/gas-refinery-shadow.png",
                priority = "extra-high",
                width = 255,
                height = 171,
                shift = util.by_pixel(44, 7),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__angelspetrochem__/graphics/entity/gas-refinery/hr-gas-refinery-shadow.png",
                    priority = "extra-high",
                    width = 508,
                    height = 338,
                    shift = util.by_pixel(43.5, 6.5),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            },
        }
    })

    -- Label to skip to next iteration
    ::continue::
end