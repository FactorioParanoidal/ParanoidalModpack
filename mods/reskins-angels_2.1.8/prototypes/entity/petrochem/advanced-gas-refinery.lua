-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "advanced-gas-refinery",
    base_entity_name = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "petrochem",
    make_remnants = false,
}

local tier_map = {
    ["gas-refinery"] = {tier = 1, prog_tier = 3},
    ["gas-refinery-2"] = {tier = 2, prog_tier = 4},
    ["gas-refinery-3"] = {tier = 3, prog_tier = 5},
    ["gas-refinery-4"] = {tier = 4, prog_tier = 6},
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
                filename = "__angelspetrochem__/graphics/entity/advanced-gas-refinery/advanced-gas-refinery-base.png",
                priority = "extra-high",
                width = 232,
                height = 330,
                shift = util.by_pixel(0, -41),
                hr_version = {
                    filename = "__angelspetrochem__/graphics/entity/advanced-gas-refinery/hr-advanced-gas-refinery-base.png",
                    priority = "extra-high",
                    width = 462,
                    height = 657,
                    shift = util.by_pixel(0, -42),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/advanced-gas-refinery-mask.png",
                priority = "extra-high",
                width = 232,
                height = 330,
                shift = util.by_pixel(0, -41),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/hr-advanced-gas-refinery-mask.png",
                    priority = "extra-high",
                    width = 462,
                    height = 657,
                    shift = util.by_pixel(0, -42),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/advanced-gas-refinery-highlights.png",
                priority = "extra-high",
                width = 232,
                height = 330,
                shift = util.by_pixel(0, -41),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/hr-advanced-gas-refinery-highlights.png",
                    priority = "extra-high",
                    width = 462,
                    height = 657,
                    shift = util.by_pixel(0, -42),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow
            -- ATTN Lovely Santa: These sprites are vertically oriented, so you'll need to either hard-code the vertical offsets, or adapt
            -- the make_4way_animation_from_spritesheet function as done in reskins-library to process vertically oriented spritesheets.
            {
                filename = "__angelspetrochem__/graphics/entity/advanced-gas-refinery/advanced-gas-refinery-shadow.png",
                priority = "extra-high",
                vertically_oriented = true, -- This is a custom parameter used by function reskins.lib.make_4way_animation_from_spritesheet
                width = 328,
                height = 229,
                shift = util.by_pixel(48, 9),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__angelspetrochem__/graphics/entity/advanced-gas-refinery/hr-advanced-gas-refinery-shadow.png",
                    priority = "extra-high",
                    vertically_oriented = true, -- This is a custom parameter used by function reskins.lib.make_4way_animation_from_spritesheet
                    width = 655,
                    height = 454,
                    shift = util.by_pixel(48.5, 9.5),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            },
        }
    })

    -- Label to skip to next iteration
    ::continue::
end