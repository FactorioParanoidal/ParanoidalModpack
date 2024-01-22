-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "ore-refinery",
    base_entity_name = "oil-refinery",
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
                filename = "__angelsrefining__/graphics/entity/ore-refinery/ore-refinery-base.png",
                priority = "extra-high",
                width = 221,
                height = 256,
                shift = util.by_pixel(0, -16),
                hr_version = {
                    filename = "__angelsrefining__/graphics/entity/ore-refinery/hr-ore-refinery-base.png",
                    priority = "extra-high",
                    width = 440,
                    height = 509,
                    shift = util.by_pixel(0.5, -16),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-refinery/ore-refinery-mask.png",
                priority = "extra-high",
                width = 221,
                height = 256,
                shift = util.by_pixel(0, -16),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-refinery/hr-ore-refinery-mask.png",
                    priority = "extra-high",
                    width = 440,
                    height = 509,
                    shift = util.by_pixel(0.5, -16),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-refinery/ore-refinery-highlights.png",
                priority = "extra-high",
                width = 221,
                height = 256,
                shift = util.by_pixel(0, -16),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-refinery/hr-ore-refinery-highlights.png",
                    priority = "extra-high",
                    width = 440,
                    height = 509,
                    shift = util.by_pixel(0.5, -16),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow

            {
                filename = "__angelsrefining__/graphics/entity/ore-refinery/ore-refinery-shadow.png",
                priority = "extra-high",
                width = 261,
                height = 170,
                shift = util.by_pixel(22, 30),
                draw_as_shadow = true,
                hr_version = {
                    filename = "__angelsrefining__/graphics/entity/ore-refinery/hr-ore-refinery-shadow.png",
                    priority = "extra-high",
                    width = 522,
                    height = 340,
                    shift = util.by_pixel(21.5, 29),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end