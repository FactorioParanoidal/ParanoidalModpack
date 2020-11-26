-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobvehicleequipment"] then return end

local inputs = {
    type = "roboport-equipment",
    icon_name = "vehicle-roboport",
    equipment_category = "logistics",
    mod = "bobs",
    group = "vehicle-equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local vehicle_roboports = {
    ["vehicle-roboport"] = {1, 2},
    ["vehicle-roboport-2"] = {2, 3},
    ["vehicle-roboport-3"] = {3, 4},
    ["vehicle-roboport-4"] = {4, 5},
}

-- Reskin equipment
for name, map in pairs(vehicle_roboports) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end
    local equipment_base = map[1]

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    -- Construct technology icon
    inputs.icon_base = nil

    inputs.technology_icon_extras = {
        {
            icon = reskins.bobs.directory.."/graphics/technology/equipment/vehicle-equipment-symbol.png"
        }
    }

    reskins.lib.construct_technology_icon(string.gsub(name, "roboport", "roboport-equipment"), inputs)

    -- Setup icon handling
    inputs.icon_base = inputs.icon_name.."-"..equipment_base

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/"..inputs.icon_base.."-equipment-base.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/vehicle-roboport-equipment-mask.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/vehicle-roboport-equipment-highlights.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
            }
        }
    }



    -- Label to skip to next iteration
    ::continue::
end