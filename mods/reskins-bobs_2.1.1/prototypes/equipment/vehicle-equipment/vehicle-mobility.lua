-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.vehicle_equipment.equipment) then return end

local inputs = {
    type = "movement-bonus-equipment",
    equipment_category = "utility",
    mod = "bobs",
    group = "vehicle-equipment",
    icon_layers = 1,
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local equipment_list = {
    "vehicle-motor",
    "vehicle-engine",
}

-- Reskin equipment
for _, name in pairs(equipment_list) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    inputs.icon_name = name

    -- Construct icon
    reskins.lib.construct_icon(name, 0, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/"..name.."/"..name.."-equipment.png",
        size = 64,
        priority = "medium",
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/"..name.."/hr-"..name.."-equipment.png",
            size = 128,
            priority = "medium",
            scale = 0.5,
        }
    }

    -- Label to skip to next iteration
    ::continue::
end