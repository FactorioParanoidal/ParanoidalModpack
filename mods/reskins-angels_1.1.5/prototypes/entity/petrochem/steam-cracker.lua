-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "steam-cracker",
    base_entity = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "petrochem",
    make_remnants = false,
}

local tier_map = {
    ["steam-cracker"] = {tier = 1, prog_tier = 2},
    ["steam-cracker-2"] = {tier = 2, prog_tier = 3},
    ["steam-cracker-3"] = {tier = 3, prog_tier = 4},
    ["steam-cracker-4"] = {tier = 4, prog_tier = 5},
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
                filename = "__angelspetrochem__/graphics/entity/steam-cracker/steam-cracker.png",
                priority = "extra-high",
                width = 512,
                height = 512,
                scale = 0.5,
                shift = {0.5, -0.5},
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/steam-cracker/hr-steam-cracker-mask.png",
                priority = "extra-high",
                width = 512,
                height = 512,
                scale = 0.5,
                shift = {0.5, -0.5},
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/steam-cracker/hr-steam-cracker-highlights.png",
                priority = "extra-high",
                width = 512,
                height = 512,
                scale = 0.5,
                shift = {0.5, -0.5},
                blend_mode = reskins.lib.blend_mode,
            },
        }
    }

    entity.working_visualisations = {
        -- Flame
        {
            fadeout = true,
            constant_speed = true,
            animation = {
                filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
                line_length = 10,
                width = 20,
                height = 40,
                frame_count = 60,
                animation_speed = 0.75,
                shift = util.by_pixel(-66, -110),
                draw_as_glow = true,
                hr_version = {
                    filename = "__base__/graphics/entity/oil-refinery/hr-oil-refinery-fire.png",
                    line_length = 10,
                    width = 40,
                    height = 81,
                    frame_count = 60,
                    animation_speed = 0.75,
                    shift = util.by_pixel(-66, -110),
                    draw_as_glow = true,
                    scale = 0.5,
                },
            },
        },

        -- Light
        {
            animation = {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/steam-cracker/hr-steam-cracker-light.png",
                priority = "extra-high",
                width = 512,
                height = 512,
                scale = 0.5,
                shift = {0.5, -0.5},
                blend_mode = "additive-soft",
                draw_as_glow = true,
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end