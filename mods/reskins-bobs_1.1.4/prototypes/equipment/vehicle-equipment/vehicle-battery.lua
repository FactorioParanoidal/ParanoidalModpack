-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local inputs = {
    type = "battery-equipment",
    icon_name = "vehicle-battery",
    equipment_category = "energy",
    mod = "bobs",
    group = "vehicle-equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local batteries = {
    ["vehicle-battery-1"] = 0,
    ["vehicle-battery-2"] = 1,
    ["vehicle-battery-3"] = 2,
    ["vehicle-battery-4"] = 3,
    ["vehicle-battery-5"] = 4,
    ["vehicle-battery-6"] = 5,
}

-- Reskin equipment
for name, tier in pairs(batteries) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    if reskins.bobs and reskins.bobs.triggers.equipment.technologies then
        -- Construct technology icon
        inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay{is_vehicle = true} }

        reskins.lib.construct_technology_icon(string.gsub(name, "battery", "battery-equipment"), inputs)
    end

    if reskins.bobs and reskins.bobs.triggers.equipment.equipment then
        -- Construct icon
        reskins.lib.construct_icon(name, tier, inputs)

        -- Reskin the equipment
        equipment.sprite = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-battery/vehicle-battery-equipment-base.png",
                    size = 32,
                    priority = "medium",
                    flags = { "no-crop" },
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-battery/vehicle-battery-equipment-mask.png",
                    size = 32,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-battery/vehicle-battery-equipment-highlights.png",
                    size = 32,
                    priority = "medium",
                    flags = { "no-crop" },
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                }
            }
        }
    end

    -- Label to skip to next iteration
    ::continue::
end