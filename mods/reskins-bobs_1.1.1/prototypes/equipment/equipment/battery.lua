-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobequipment"] then return end

local inputs = {
    type = "battery-equipment",
    icon_name = "battery",
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local batteries = {
    ["battery-equipment"] = {0, "battery-equipment"},
    ["battery-mk2-equipment"] = {1, "battery-mk2-equipment"},
    ["battery-mk3-equipment"] = {2, "bob-battery-equipment-3"},
    ["battery-mk4-equipment"] = {3, "bob-battery-equipment-4"},
    ["battery-mk5-equipment"] = {4, "bob-battery-equipment-5"},
    ["battery-mk6-equipment"] = {5, "bob-battery-equipment-6"},
}

-- Reskin equipment
for name, map in pairs(batteries) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Parse map
    local tier = map[1]
    local technology = map[2]

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Construct technology icon
    inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay() }

    reskins.lib.construct_technology_icon(technology, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/battery/battery-equipment-base.png",
                width = 32,
                height = 64,
                priority = "medium",
                flags = { "no-crop" },
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/battery/battery-equipment-mask.png",
                width = 32,
                height = 64,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/battery/battery-equipment-highlights.png",
                width = 32,
                height = 64,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end