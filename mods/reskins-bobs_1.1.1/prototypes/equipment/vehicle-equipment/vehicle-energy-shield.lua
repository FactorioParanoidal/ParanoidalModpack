-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobvehicleequipment"] then return end

local inputs = {
    type = "energy-shield-equipment",
    icon_name = "vehicle-energy-shield",
    equipment_category = "defense",
    mod = "bobs",
    group = "vehicle-equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local vehicle_shield = {
    ["vehicle-shield-1"] = {0, "vehicle-energy-shield-equipment-1"},
    ["vehicle-shield-2"] = {1, "vehicle-energy-shield-equipment-2"},
    ["vehicle-shield-3"] = {2, "vehicle-energy-shield-equipment-3"},
    ["vehicle-shield-4"] = {3, "vehicle-energy-shield-equipment-4"},
    ["vehicle-shield-5"] = {4, "vehicle-energy-shield-equipment-5"},
    ["vehicle-shield-6"] = {5, "vehicle-energy-shield-equipment-6"},
}

-- Reskin equipment
for name, map in pairs(vehicle_shield) do
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
    inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay{is_vehicle = true} }

    reskins.lib.construct_technology_icon(technology, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-energy-shield/vehicle-energy-shield-equipment-base.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-energy-shield/vehicle-energy-shield-equipment-mask.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-energy-shield/vehicle-energy-shield-equipment-highlights.png",
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