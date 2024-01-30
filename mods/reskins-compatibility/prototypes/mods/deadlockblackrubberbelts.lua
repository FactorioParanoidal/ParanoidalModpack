-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["DeadlockBlackRubberBelts"] then return end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

local actions = require("__DeadlockBlackRubberBelts__.code.functions")

local inputs = {
    type = "transport-belt",
    base = "steel",
}

local tier_map = {
    ["basic-transport-belt"] = { tier = 0 },
    ["transport-belt"] = { tier = 1 },
    ["fast-transport-belt"] = { tier = 2 },
    ["express-transport-belt"] = { tier = 3 },
    ["turbo-transport-belt"] = { tier = 4 },
    ["ultimate-transport-belt"] = { tier = 5 },
}

reskins.lib.parse_inputs(inputs)

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.belt_tint_index[map.tier] -- actions.hsva2rgba(reskins.lib.RGBtoHSV(reskins.lib.belt_tint_index[map.tier]).h, 0.8, 1)

    -- Reskin icon
    ---@type data.IconData[]
    local icons = {
        {
            icon = actions.icons_path .. "/rubber-belt-" .. inputs.base .. ".png",
            icon_size = 64,
            icon_mipmaps = 4,
        },
        {
            icon = actions.icons_path .. "/rubber-belt-mask.png",
            icon_size = 64,
            icon_mipmaps = 4,
            tint = inputs.tint,
        },
    }

    inputs.icon = reskins.lib.add_tier_labels_to_icons(icons, map.tier)
    inputs.icon_picture = reskins.lib.convert_icons_to_sprite(icons, 0.25)

    reskins.lib.assign_icons(name, inputs)

    -- Reskin entity
    entity.belt_animation_set.animation_set = actions.get_belt_animation_set(inputs.tint, inputs.base)

    -- Label to skip to next iteration
    ::continue::
end
