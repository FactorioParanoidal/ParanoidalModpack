-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then return end
if not (reskins.angels and reskins.angels.triggers.bioprocessing.entities) then return end

-- Set input parameters
local inputs = {
    type = "furnace",
    icon_name = "hatchery",
    base_entity = "assembling-machine-1",
    mod = "compatibility",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "extendedangels",
    make_remnants = false,
}

local tier_map = {
    ["bio-hatchery"] = {tier = 1},
    ["bio-hatchery-2"] = {tier = 2},
    ["bio-hatchery-3"] = {tier = 3},
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
    entity.animation = nil
    entity.idle_animation = {
        layers = {
            -- Base
            {
                filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-off.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                shift = {0, 0},
            },
            -- Mask
            {
                filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/hatchery/hatchery-idle-mask.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                shift = {0, 0},
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/hatchery/hatchery-idle-highlights.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                shift = {0, 0},
                blend_mode = reskins.lib.blend_mode,
            },
        },
    }

    entity.working_visualisations = {
        {
            animation = {
                layers = {
                    -- Base
                    {
                        filename = "__angelsbioprocessing__/graphics/entity/bio-hatchery/bio-hatchery-animation.png",
                        priority = "extra-high",
                        width = 160,
                        height = 160,
                        frame_count = 25,
                        line_length = 5,
                        shift = {0, 0},
                        animation_speed = 0.35,
                    },
                    -- Base
                    {
                        filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/hatchery/hatchery-working-mask.png",
                        priority = "extra-high",
                        width = 160,
                        height = 160,
                        frame_count = 25,
                        line_length = 5,
                        shift = {0, 0},
                        animation_speed = 0.35,
                        tint = inputs.tint,
                    },
                    -- Base
                    {
                        filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/hatchery/hatchery-working-highlights.png",
                        priority = "extra-high",
                        width = 160,
                        height = 160,
                        frame_count = 25,
                        line_length = 5,
                        shift = {0, 0},
                        animation_speed = 0.35,
                        blend_mode = reskins.lib.blend_mode,
                    },
                }
            }
        },

        -- Shadow
        {
            always_draw = true,
            animation = {
                filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/hatchery/hatchery-shadow.png",
                width = 160,
                height = 160,
                shift = {0, 0},
                draw_as_shadow = true,
            },
        },

        -- Lights
        {
            fadeout = true,
            animation = {
                filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/hatchery/hatchery-working-light.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                frame_count = 25,
                line_length = 5,
                shift = {0, 0},
                animation_speed = 0.35,
                draw_as_light = true,
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end