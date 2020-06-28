-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Set input parameters
local inputs = {
    type = "roboport",
    icon_name = "zone-expander",
    base_entity = "roboport",
    directory = reskins.bobs.directory,
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
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    if reskins.lib.setting("reskins-lib-tier-mapping") == "name-map" then
        tier = map[1]
    else
        tier = map[2]
    end
    subtier = map[1]

    -- Setup icon details
    inputs.icon_base = "zone-expander-"..subtier

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]
    
    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.base = {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-base.png",
                width = 28,
                height = 71,
                shift = util.by_pixel(0, -25.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-base.png",
                    width = 56,
                    height = 142,
                    shift = util.by_pixel(0, -25.5),
                    scale = 0.5
                }
            },
            -- Grid
            {
                filename = inputs.directory.."/graphics/entity/logistics/zone-expander/grids/grid-"..subtier..".png",
                width = 28,
                height = 71,
                shift = util.by_pixel(0, -25.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/zone-expander/grids/hr-grid-"..subtier..".png",
                    width = 56,
                    height = 142,
                    shift = util.by_pixel(0, -25.5),
                    scale = 0.5
                }
            },
            -- Metal
            {
                filename = inputs.directory.."/graphics/entity/logistics/zone-expander/metal/metal-"..subtier..".png",
                width = 28,
                height = 71,
                shift = util.by_pixel(0, -25.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/zone-expander/metal/hr-metal-"..subtier..".png",
                    width = 56,
                    height = 142,
                    shift = util.by_pixel(0, -25.5),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-mask.png",
                width = 28,
                height = 71,
                shift = util.by_pixel(0, -25.5),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-mask.png",
                    width = 56,
                    height = 142,
                    shift = util.by_pixel(0, -25.5),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-highlights.png",
                width = 28,
                height = 71,
                shift = util.by_pixel(0, -25.5),
                blend_mode = "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-highlights.png",
                    width = 56,
                    height = 142,
                    shift = util.by_pixel(0, -25.5),
                    blend_mode = "additive",
                    scale = 0.5
                }
            },
            -- Shadow Fix (we'll do a proper fix later...)
            {
                filename = inputs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-shadow-fix.png",
                width = 28,
                height = 71,
                shift = util.by_pixel(0, -25.5),
                draw_as_shadow = true,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-shadow-fix.png",
                    width = 56,
                    height = 142,
                    shift = util.by_pixel(0, -25.5),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            },
        }

    }

    entity.base_animation = {
        layers = {
            -- Antenna
            {            
                filename = inputs.directory.."/graphics/entity/logistics/roboport/base/antennas/roboport-"..subtier.."-base-animation.png",
                priority = "medium",
                width = 42,
                height = 31,
                frame_count = 8,
                animation_speed = 0.5,
                shift = util.by_pixel(0, -60),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/roboport/base/antennas/hr-roboport-"..subtier.."-base-animation.png",
                    priority = "medium",
                    width = 83,
                    height = 59,
                    frame_count = 8,
                    animation_speed = 0.5,
                    shift = util.by_pixel(0, -60),
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = inputs.directory.."/graphics/entity/logistics/zone-expander/zone-expander-shadow.png",
                width = 95,
                height = 30,
                frame_count = 8,
                shift = util.by_pixel(48, 0),
                draw_as_shadow = true,
                run_mode = "backward", -- (Lawd, we'll fix this later...)
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/zone-expander/hr-zone-expander-shadow.png",
                    width = 190,
                    height = 60,
                    frame_count = 8,
                    shift = util.by_pixel(48, 0),
                    draw_as_shadow = true,
                    run_mode = "backward",
                    scale = 0.5
                }
            }
        }
    }

    -- Set drawing box so the entity appears properly within the GUI
    entity.drawing_box = {{-0.5, -2.5}, {0.5, 0.5}}

    -- Label to skip to next iteration
    ::continue::
end