-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "ore-processing-machine",
    base_entity = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "smelting",
    make_remnants = false,
}

local tier_map = {
    ["ore-processing-machine"] = {tier = 1},
    ["ore-processing-machine-2"] = {tier = 2},
    ["ore-processing-machine-3"] = {tier = 3},
    ["ore-processing-machine-4"] = {tier = 4},
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
                filename = "__angelssmelting__/graphics/entity/ore-processing-machine/ore-processing-machine-base.png",
                priority = "extra-high",
                width = 100,
                height = 105,
                line_length = 5,
                frame_count = 25,
                animation_speed = 0.5,
                shift = util.by_pixel(0, -3),
                hr_version = {
                    filename = "__angelssmelting__/graphics/entity/ore-processing-machine/hr-ore-processing-machine-base.png",
                    priority = "extra-high",
                    width = 196,
                    height = 206,
                    line_length = 5,
                    frame_count = 25,
                    animation_speed = 0.5,
                    shift = util.by_pixel(-0.5, -2 ),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/ore-processing-machine/ore-processing-machine-mask.png",
                priority = "extra-high",
                width = 100,
                height = 105,
                line_length = 5,
                frame_count = 25,
                animation_speed = 0.5,
                shift = util.by_pixel(0, -3),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/smelting/ore-processing-machine/hr-ore-processing-machine-mask.png",
                    priority = "extra-high",
                    width = 196,
                    height = 206,
                    line_length = 5,
                    frame_count = 25,
                    animation_speed = 0.5,
                    shift = util.by_pixel(-0.5, -2 ),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/smelting/ore-processing-machine/ore-processing-machine-highlights.png",
                priority = "extra-high",
                width = 100,
                height = 105,
                line_length = 5,
                frame_count = 25,
                animation_speed = 0.5,
                shift = util.by_pixel(0, -3),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/smelting/ore-processing-machine/hr-ore-processing-machine-highlights.png",
                    priority = "extra-high",
                    width = 196,
                    height = 206,
                    line_length = 5,
                    frame_count = 25,
                    animation_speed = 0.5,
                    shift = util.by_pixel(-0.5, -2 ),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = "__angelssmelting__/graphics/entity/ore-processing-machine/ore-processing-machine-shadow.png",
                priority = "extra-high",
                width = 122,
                height = 70,
                repeat_count = 25,
                animation_speed = 0.5,
                draw_as_shadow = true,
                shift = util.by_pixel(13, 16),
                hr_version = {
                    filename = "__angelssmelting__/graphics/entity/ore-processing-machine/hr-ore-processing-machine-shadow.png",
                    priority = "extra-high",
                    width = 243,
                    height = 137,
                    repeat_count = 25,
                    animation_speed = 0.5,
                    draw_as_shadow = true,
                    shift = util.by_pixel(12.5, 16),
                    scale = 0.5,
                }
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end