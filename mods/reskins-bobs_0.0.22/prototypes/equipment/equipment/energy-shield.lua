-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobequipment"] then return end

local inputs = {
    type = "energy-shield-equipment",
    icon_name = "energy-shield",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local batteries = {
    ["energy-shield-equipment"] = {0, "energy-shield-equipment"},
    ["energy-shield-mk2-equipment"] = {1, "energy-shield-mk2-equipment"},
    ["energy-shield-mk3-equipment"] = {2, "bob-energy-shield-equipment-3"},
    ["energy-shield-mk4-equipment"] = {3, "bob-energy-shield-equipment-4"},
    ["energy-shield-mk5-equipment"] = {4, "bob-energy-shield-equipment-5"},
    ["energy-shield-mk6-equipment"] = {5, "bob-energy-shield-equipment-6"},
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
    inputs.technology_icon_extras = {
        {
            icon = inputs.directory.."/graphics/technology/equipment/personal-equipment-symbol.png"
        }
    }

    reskins.lib.construct_technology_icon(technology, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/equipment/equipment/energy-shield/energy-shield-equipment-base.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/equipment/equipment/energy-shield/energy-shield-equipment-mask.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/equipment/equipment/energy-shield/energy-shield-equipment-highlights.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = "additive",
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end