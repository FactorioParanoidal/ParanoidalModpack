-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local inputs = {
    type = "movement-bonus-equipment",
    equipment_category = "utility",
    mod = "bobs",
    group = "vehicle-equipment",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    technology_icon_layers = 1,
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

    if reskins.bobs and reskins.bobs.triggers.equipment.equipment then
        -- Construct icon
        reskins.lib.construct_icon(name, 0, inputs)

        -- Reskin the equipment
        equipment.sprite = {
            filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/"..name.."/"..name.."-equipment.png",
            size = 64,
            priority = "medium",
            flags = { "no-crop" },
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/"..name.."/hr-"..name.."-equipment.png",
                size = 128,
                priority = "medium",
                flags = { "no-crop" },
                scale = 0.5,
            }
        }
    end

    if reskins.bobs and reskins.bobs.triggers.equipment.technologies then
        -- Construct technology icon
        inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay{scale = 1, is_vehicle = true} }

        reskins.lib.construct_technology_icon(name.."-equipment", inputs)
    end

    -- Label to skip to next iteration
    ::continue::
end