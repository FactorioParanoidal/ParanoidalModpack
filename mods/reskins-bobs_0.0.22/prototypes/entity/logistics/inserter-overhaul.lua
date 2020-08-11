-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Set input parameters
local inputs = {
    type = "inserter",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "logistics",
    particles = {["medium"] = 1},
}

local inserter_map
if reskins.lib.setting("bobmods-logistics-inserteroverhaul") == true then
    inserter_map = {
        -- Standard inserters
        ["inserter"] = 1,
        ["red-inserter"] = 2,
        ["long-handed-inserter"] = 2,
        ["fast-inserter"] = 3,
        ["turbo-inserter"] = 4,
        ["express-inserter"] = 5,

        -- Filter inserters
        ["yellow-filter-inserter"] = 1,
        ["red-filter-inserter"] = 2,
        ["filter-inserter"] = 3,
        ["turbo-filter-inserter"] = 4,
        ["express-filter-inserter"] = 5,

        -- Stack inserters
        ["red-stack-inserter"] = 2,
        ["stack-inserter"] = 3,
        ["turbo-stack-inserter"] = 4,
        ["express-stack-inserter"] = 5,

        -- Stack filter inserters
        ["red-stack-filter-inserter"] = 2,
        ["stack-filter-inserter"] = 3,
        ["turbo-stack-filter-inserter"] = 4,
        ["express-stack-filter-inserter"] = 5,
    }
else
    return
end

-- Inserter Remnants
local function inserter_remnants(parameters)
    -- Parse out parameters.type
    if parameters.type == "stack-inserter" then
        parameters.base = "stack-inserter"
        parameters.mask = "stack-inserter"
    else
        parameters.base = "inserter"
        parameters.mask = "inserter"
    end

    if parameters.filter == true then
        parameters.mask = "filter-"..parameters.mask
    end

    local remnant = make_rotated_animation_variations_from_sheet (4, {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/remnants/"..parameters.base.."-remnants-base.png",
                line_length = 1,
                width = 67,
                height = 47,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(3, -1.5),
                hr_version =
                {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/remnants/hr-"..parameters.base.."-remnants-base.png",
                    line_length = 1,
                    width = 134,
                    height = 94,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(3, -1.5),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/remnants/"..parameters.mask.."-remnants-mask.png",
                line_length = 1,
                width = 67,
                height = 47,
                tint = parameters.tint,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(3, -1.5),
                hr_version =
                {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/remnants/hr-"..parameters.mask.."-remnants-mask.png",
                    line_length = 1,
                    width = 134,
                    height = 94,
                    tint = parameters.tint,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(3, -1.5),
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/remnants/"..parameters.mask.."-remnants-highlights.png",
                line_length = 1,
                width = 67,
                height = 47,
                blend_mode = "additive",
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(3, -1.5),
                hr_version =
                {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/remnants/hr-"..parameters.mask.."-remnants-highlights.png",
                    line_length = 1,
                    width = 134,
                    height = 94,
                    blend_mode = "additive",
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(3, -1.5),
                    scale = 0.5,
                },
            }
        }
    })
    return remnant
end

-- Inserter Arms
local function inserter_arm_picture(parameters)
    local arm_picture = {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/inserter-arm-base.png",
                priority = "extra-high",
                width = 16,
                height = 68,
                flags = {"no-crop"},
                scale = 0.5,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/hr-inserter-arm-base.png",
                    priority = "extra-high",
                    width = 32,
                    height = 136,
                    flags = {"no-crop"},
                    scale = 0.25
                }
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/inserter-arm-mask.png",
                priority = "extra-high",
                width = 16,
                height = 68,
                flags = {"no-crop"},
                tint = parameters.tint,
                scale = 0.5,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/hr-inserter-arm-mask.png",
                    priority = "extra-high",
                    width = 32,
                    height = 136,
                    flags = {"no-crop"},
                    tint = parameters.tint,
                    scale = 0.25
                }
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/inserter-arm-highlights.png",
                priority = "extra-high",
                width = 16,
                height = 68,
                flags = {"no-crop"},
                blend_mode = "additive",
                scale = 0.5,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/hr-inserter-arm-highlights.png",
                    priority = "extra-high",
                    width = 32,
                    height = 136,
                    flags = {"no-crop"},
                    blend_mode = "additive",
                    scale = 0.25
                }
            }
        }
    }

    -- Check to see if we're a filter inserter, and if so, replace the mask/highlights
    if parameters.filter then
        arm_picture.layers[2].filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/filter-inserter-arm-mask.png"
        arm_picture.layers[2].hr_version.filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/hr-filter-inserter-arm-mask.png"
        arm_picture.layers[3].filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/filter-inserter-arm-highlights.png"
        arm_picture.layers[3].hr_version.filename = inputs.directory.."/graphics/entity/logistics/inserter/arms/hr-filter-inserter-arm-highlights.png"
    end

    return arm_picture       
end

local function inserter_arm_shadow()
    return
    {
        filename = inputs.directory.."/graphics/entity/logistics/inserter/shadows/inserter-arm-shadow.png",
        priority = "extra-high",
        width = 16,
        height = 68,
        flags = {"no-crop"},
        draw_as_shadow = true,
        scale = 0.5,
        hr_version = {
            filename = inputs.directory.."/graphics/entity/logistics/inserter/shadows/hr-inserter-arm-shadow.png",
            priority = "extra-high",
            width = 32,
            height = 136,
            flags = {"no-crop"},
            draw_as_shadow = true,
            scale = 0.25
        }
    }
end

-- Hand open, closed for stack, standard, and long-handed inserters
local function inserter_hand_picture(parameters)
    local hand_picture = {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/"..parameters.type.."-hand-"..parameters.hand.."-base.png",
                priority = "extra-high",
                width = 65,
                height = 82,
                flags = {"no-crop"},
                scale = 0.5,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/hr-"..parameters.type.."-hand-"..parameters.hand.."-base.png",
                    priority = "extra-high",
                    width = 130,
                    height = 164,
                    flags = {"no-crop"},
                    scale = 0.25
                }
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/"..parameters.type.."-hand-"..parameters.hand.."-mask.png",
                priority = "extra-high",
                width = 65,
                height = 82,
                flags = {"no-crop"},
                scale = 0.5,
                tint = parameters.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/hr-"..parameters.type.."-hand-"..parameters.hand.."-mask.png",
                    priority = "extra-high",
                    width = 130,
                    height = 164,
                    flags = {"no-crop"},
                    tint = parameters.tint,
                    scale = 0.25
                }
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/"..parameters.type.."-hand-"..parameters.hand.."-highlights.png",
                priority = "extra-high",
                width = 65,
                height = 82,
                flags = {"no-crop"},
                scale = 0.5,
                blend_mode = "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/hr-"..parameters.type.."-hand-"..parameters.hand.."-highlights.png",
                    priority = "extra-high",
                    width = 130,
                    height = 164,
                    flags = {"no-crop"},
                    blend_mode = "additive",
                    scale = 0.25
                }
            }
        }
    }

    -- Check to see if we're a filter inserter, and if so, replace the mask/highlights
    if parameters.filter then
        hand_picture.layers[2].filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/filter-"..parameters.type.."-hand-mask.png"
        hand_picture.layers[2].hr_version.filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/hr-filter-"..parameters.type.."-hand-mask.png"
        hand_picture.layers[3].filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/filter-"..parameters.type.."-hand-highlights.png"
        hand_picture.layers[3].hr_version.filename = inputs.directory.."/graphics/entity/logistics/inserter/hands/hr-filter-"..parameters.type.."-hand-highlights.png"
    end

    return hand_picture    
end

local function inserter_hand_shadow(parameters)
    -- Long-handed inserter types share a shadow with standard inserters
    if parameters.type == "long-inserter" then
        parameters.shadow = "inserter"
    else
        parameters.shadow = parameters.type
    end
    return

    -- Shadow
    {
        filename = inputs.directory.."/graphics/entity/logistics/inserter/shadows/"..parameters.shadow.."-hand-"..parameters.hand.."-shadow.png",
        priority = "extra-high",
        width = 65,
        height = 82,
        flags = {"no-crop"},
        scale = 0.5,
        draw_as_shadow = true,
        hr_version = {
            filename = inputs.directory.."/graphics/entity/logistics/inserter/shadows/hr-"..parameters.shadow.."-hand-"..parameters.hand.."-shadow.png",
            priority = "extra-high",
            width = 130,
            height = 164,
            flags = {"no-crop"},
            draw_as_shadow = true,
            scale = 0.25
        }
    }
end

-- Platform
local function inserter_platform_picture(parameters)
    return
    {
        sheets = {
            -- Base
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/platform/inserter-platform-base.png",
                priority = "extra-high",
                width = 53,
                height = 40,
                shift = util.by_pixel(1.75, 6.75),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/platform/hr-inserter-platform-base.png",
                    priority = "extra-high",
                    width = 106,
                    height = 80,
                    shift = util.by_pixel(1.75, 6.75),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/platform/inserter-platform-mask.png",
                priority = "extra-high",
                width = 53,
                height = 40,
                tint = parameters.tint,
                shift = util.by_pixel(1.75, 6.75),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/platform/hr-inserter-platform-mask.png",
                    priority = "extra-high",
                    width = 106,
                    height = 80,
                    tint = parameters.tint,
                    shift = util.by_pixel(1.75, 6.75),
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/platform/inserter-platform-highlights.png",
                priority = "extra-high",
                width = 53,
                height = 40,
                blend_mode = "additive",
                shift = util.by_pixel(1.75, 6.75),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/platform/hr-inserter-platform-highlights.png",
                    priority = "extra-high",
                    width = 106,
                    height = 80,
                    blend_mode = "additive",
                    shift = util.by_pixel(1.75, 6.75),
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = inputs.directory.."/graphics/entity/logistics/inserter/shadows/inserter-platform-shadow.png",
                priority = "extra-high",
                width = 53,
                height = 40,
                draw_as_shadow = true,
                shift = util.by_pixel(1.75, 6.75),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/logistics/inserter/shadows/hr-inserter-platform-shadow.png",
                    priority = "extra-high",
                    width = 106,
                    height = 80,
                    draw_as_shadow = true,
                    shift = util.by_pixel(1.75, 6.75),
                    scale = 0.5
                }
            }
        }
    }
end

-- Reskin entities, create and assign extra details
for name, tier in pairs(inserter_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end
 
    -- Handle base_entity
    if string.find(name, "stack%-inserter") then
        inputs.base_entity = "stack-inserter"
    else
        inputs.base_entity = "inserter"
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]
    if string.find(name, "filter") then        
        inputs.platform_tint = util.color("bfbfbf") -- Whiteish
    else
        inputs.platform_tint = inputs.tint
    end

    -- Handle entity reskin parameters
    local inserter_type
    if string.find(name, "stack") then
        inserter_type = "stack-inserter"
        if reskins.lib.setting("reskins-bobs-flip-stack-inserter-icons") == true then
            inputs.icon_name = "flipped-stack-inserter"
        else
            inputs.icon_name = "stack-inserter"
        end
    elseif mods["bobsinserters"] or reskins.lib.setting("bobmods-logistics-inserteroverhaul") == true then
        inserter_type = "long-inserter"
        inputs.icon_name = "inserter"
    else
        inserter_type = "inserter"
        inputs.icon_name = "inserter"
    end

    local inserter_filter = false
    if string.find(name, "filter") then
        inserter_filter = true
        inputs.icon_name = "filter-"..inputs.icon_name
        if reskins.lib.setting("reskins-bobs-do-inserter-filter-symbol") == true then
            inputs.icon_extras = {
                {
                    icon = inputs.directory.."/graphics/icons/logistics/inserter/filter.png"
                },
                {
                    icon = inputs.directory.."/graphics/icons/logistics/inserter/filter.png",
                    tint = reskins.lib.adjust_alpha(reskins.lib.tint_index["tier-"..tier], 0.75)
                },
            }
        end
    else
        inputs.icon_extras = nil
    end

    if reskins.lib.setting("reskins-bobs-do-inserter-tier-labeling") == false then
        inputs.tier_labels = false
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)    

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnnant
    remnant.animation = inserter_remnants{type = inserter_type, tint = inputs.tint, filter = inserter_filter}

    -- Common to all inserters
    entity.hand_base_picture = inserter_arm_picture{tint = inputs.tint, filter = inserter_filter}
    entity.hand_base_shadow = inserter_arm_shadow()
    entity.platform_picture = inserter_platform_picture{tint = inputs.platform_tint}

    -- Inserter hands
    entity.hand_open_picture = inserter_hand_picture{type = inserter_type, tint = inputs.tint, hand = "open", filter = inserter_filter}
    entity.hand_closed_picture = inserter_hand_picture{type = inserter_type, tint = inputs.tint, hand = "closed", filter = inserter_filter}
    entity.hand_open_shadow = inserter_hand_shadow{type = inserter_type, hand = "open"}
    entity.hand_closed_shadow = inserter_hand_shadow{type = inserter_type, hand = "closed"}

    -- Label to skip to next iteration
    ::continue::
end