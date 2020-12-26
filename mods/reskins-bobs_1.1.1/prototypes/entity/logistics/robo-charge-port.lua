-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Set input parameters
local inputs = {
    type = "roboport",
    icon_name = "robo-charge-port",
    base_entity = "roboport",
    mod = "bobs",
    group = "logistics",
    particles = {["medium"] = 2},
    make_remnants = false,
}

local tier_map = {
    ["bob-robo-charge-port"] = {1, 2},
    ["bob-robo-charge-port-large"] = {1, 2, true},
    ["bob-robo-charge-port-2"] = {2, 3},
    ["bob-robo-charge-port-large-2"] = {2, 3, true},
    ["bob-robo-charge-port-3"] = {3, 4},
    ["bob-robo-charge-port-large-3"] = {3, 4, true},
    ["bob-robo-charge-port-4"] = {4, 5},
    ["bob-robo-charge-port-large-4"] = {4, 5, true},
}

local function charge_port_base(shift_x, shift_y, subtier, tint)
    local shift = {shift_x, shift_y}
    return
    {
        -- Base
        {
            filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/robo-charge-port-"..subtier.."-base.png",
            priority = "medium",
            animation_speed = 0.2,
            width = 30,
            height = 28,
            repeat_count = 12,
            shift = shift,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/hr-robo-charge-port-"..subtier.."-base.png",
                priority = "medium",
                animation_speed = 0.2,
                width = 60,
                height = 56,
                repeat_count = 12,
                shift = shift,
                scale = 0.5,
            }
        },
        -- Mask
        {
            filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/robo-charge-port-mask.png",
            priority = "medium",
            animation_speed = 0.2,
            width = 30,
            height = 28,
            repeat_count = 12,
            shift = shift,
            tint = tint,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/hr-robo-charge-port-mask.png",
                priority = "medium",
                animation_speed = 0.2,
                width = 60,
                height = 56,
                repeat_count = 12,
                shift = shift,
                tint = tint,
                scale = 0.5,
            }
        },
        -- Highlights
        {
            filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/robo-charge-port-highlights.png",
            priority = "medium",
            animation_speed = 0.2,
            width = 30,
            height = 28,
            repeat_count = 12,
            shift = shift,
            blend_mode = reskins.lib.blend_mode, -- "additive",
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/hr-robo-charge-port-highlights.png",
                priority = "medium",
                animation_speed = 0.2,
                width = 60,
                height = 56,
                repeat_count = 12,
                shift = shift,
                blend_mode = reskins.lib.blend_mode, -- "additive",
                scale = 0.5,
            }
        },
        -- Shadow
        {
            filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/robo-charge-port-shadow.png",
            priority = "medium",
            animation_speed = 0.2,
            width = 35,
            height = 29,
            repeat_count = 12,
            shift = util.by_pixel(shift_x*32+2.5, shift_y*32+0.5),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/hr-robo-charge-port-shadow.png",
                priority = "medium",
                animation_speed = 0.2,
                width = 70,
                height = 58,
                repeat_count = 12,
                shift = util.by_pixel(shift_x*32+2.5, shift_y*32+0.5),
                draw_as_shadow = true,
                scale = 0.5,
            }
        },
        -- Lights Mask
        {
            filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/robo-charge-port-lights-mask.png",
            priority = "medium",
            animation_speed = 0.2,
            width = 16,
            height = 16,
            frame_count = 12,
            shift = util.by_pixel(shift_x*32, shift_y*32+1),
            draw_as_glow = true,
            tint = tint,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/hr-robo-charge-port-lights-mask.png",
                priority = "medium",
                animation_speed = 0.2,
                width = 32,
                height = 32,
                frame_count = 12,
                shift = util.by_pixel(shift_x*32, shift_y*32+1),
                draw_as_glow = true,
                tint = tint,
                scale = 0.5,
            }
        },
        -- Lights Highlights
        {
            filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/robo-charge-port-lights-highlights.png",
            priority = "medium",
            animation_speed = 0.2,
            width = 16,
            height = 16,
            frame_count = 12,
            shift = util.by_pixel(shift_x*32, shift_y*32+1),
            draw_as_glow = true,
            blend_mode = "additive",
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/robo-charge-port/hr-robo-charge-port-lights-highlights.png",
                priority = "medium",
                animation_speed = 0.2,
                width = 32,
                height = 32,
                frame_count = 12,
                shift = util.by_pixel(shift_x*32, shift_y*32+1),
                draw_as_glow = true,
                blend_mode = "additive",
                scale = 0.5,
            }
        },
    }
end

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
    local is_large = map[3]

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    -- Icon handling

    if is_large then
        inputs.icon_base = "large-"..inputs.icon_name.."-"..subtier
        inputs.icon_mask = "large-"..inputs.icon_name
        inputs.icon_highlights = "large-"..inputs.icon_name
    else
        inputs.icon_base = inputs.icon_name.."-"..subtier
        inputs.icon_mask = nil
        inputs.icon_highlights = nil
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.base_animation = {layers = {}}

    -- Setup array bounds
    local array_start, array_end = -0.5, 0.5
    if is_large then
        array_start = -1
        array_end = 1
    end

    -- Generate charge port array
    for i = array_start, array_end do
        for j = array_start, array_end do
            local charge_port_array = charge_port_base(i, j, subtier, inputs.tint)
            for k = 1, #charge_port_array do
                table.insert(entity.base_animation.layers, charge_port_array[k])
            end
        end
    end

    -- Restore some defaults
    entity.recharging_animation = {
        filename = reskins.bobs.directory.."/graphics/entity/logistics/roboport/base/roboport-recharging.png",
        priority = "high",
        width = 37,
        height = 35,
        frame_count = 16,
        scale = 1.5,
        animation_speed = 0.5
    }

    -- Label to skip to next iteration
    ::continue::
end