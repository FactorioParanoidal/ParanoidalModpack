-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then return end

-- Set input parameters
local inputs = {
    type = "roboport",
    icon_name = "zone-expander",
    base_entity = "roboport",
    mod = "bobs",
    group = "logistics",
    particles = {["medium"] = 2},
    make_remnants = false,
}

local tier_map = {
    ["bob-logistic-zone-expander"] = {1, 2},
    ["bob-logistic-zone-expander-2"] = {2, 3},
    ["bob-logistic-zone-expander-3"] = {3, 4},
    ["bob-logistic-zone-expander-4"] = {4, 5},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end
    local subtier = map[1]

    -- Setup icon details
    inputs.icon_base = "zone-expander-"..subtier

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.base = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-"..subtier.."-base.png",
                width = 28,
                height = 78,
                shift = util.by_pixel(0.5, -29.5),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-"..subtier.."-base.png",
                    width = 56,
                    height = 156,
                    shift = util.by_pixel(0.5, -29.5),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-mask.png",
                width = 19,
                height = 15,
                shift = util.by_pixel(0.5, 0),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-mask.png",
                    width = 38,
                    height = 30,
                    shift = util.by_pixel(0.5, 0),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-highlights.png",
                width = 19,
                height = 15,
                shift = util.by_pixel(0.5, 0),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-highlights.png",
                    width = 38,
                    height = 30,
                    shift = util.by_pixel(0.5, 0),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
        }
    }

    entity.base_animation = {
        layers = {
            -- Antenna
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/roboport/base/antennas/roboport-"..subtier.."-base-animation.png",
                priority = "medium",
                width = 42,
                height = 31,
                frame_count = 8,
                animation_speed = 0.5,
                shift = util.by_pixel(0.25, -66),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/roboport/base/antennas/hr-roboport-"..subtier.."-base-animation.png",
                    priority = "medium",
                    width = 83,
                    height = 59,
                    frame_count = 8,
                    animation_speed = 0.5,
                    shift = util.by_pixel(0.25, -66),
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-shadow.png",
                width = 114,
                height = 30,
                frame_count = 8,
                shift = util.by_pixel(44.5, -1.5),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-shadow.png",
                    width = 228,
                    height = 60,
                    frame_count = 8,
                    shift = util.by_pixel(44.5, -1.5),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    }

    -- Set drawing box so the entity appears properly within the GUI
    entity.drawing_box = {{-0.5, -2.5}, {0.5, 0.5}}

    entity.water_reflection = {
        pictures = {
            filename = reskins.bobs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-reflection.png",
            priority = "extra-high",
            width = 12,
            height = 23,
            shift = util.by_pixel(0, 45),
            variation_count = 1,
            scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
    }

    -- Label to skip to next iteration
    ::continue::
end