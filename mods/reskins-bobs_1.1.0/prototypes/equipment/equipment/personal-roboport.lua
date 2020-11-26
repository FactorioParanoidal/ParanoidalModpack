-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobequipment"] then return end

local inputs = {
    type = "roboport-equipment",
    icon_name = "personal-roboport",
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local personal_roboports = {
    ["personal-roboport-equipment"] = {1, 2, 1},
    ["personal-roboport-mk2-equipment"] = {2, 3, 1},
    ["personal-roboport-mk3-equipment"] = {3, 4, 2},
    ["personal-roboport-mk4-equipment"] = {4, 5, 2},
}

-- Reskin equipment
for name, map in pairs(personal_roboports) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end
    local equipment_base = map[3]

    -- Setup icon handling
    inputs.icon_base = inputs.icon_name.."-"..equipment_base
    inputs.icon_mask = inputs.icon_base
    inputs.icon_highlights = inputs.icon_base

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/"..inputs.icon_base.."-equipment-base.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/"..inputs.icon_base.."-equipment-mask.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/"..inputs.icon_base.."-equipment-highlights.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
            }
        }
    }

    -- Construct technology icon
    inputs.icon_base = nil
    inputs.icon_mask = nil
    inputs.icon_highlights = nil

    inputs.technology_icon_extras = {
        {
            icon = reskins.bobs.directory.."/graphics/technology/equipment/personal-equipment-symbol.png"
        }
    }

    reskins.lib.construct_technology_icon(name, inputs)

    -- Label to skip to next iteration
    ::continue::
end