-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobvehicleequipment"] then return end

local inputs = {
    type = "solar-panel-equipment",
    icon_name = "solar-panel",
    equipment_category = "energy",
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local solar_panels = {
    ["vehicle-solar-panel-1"] = 0,
    ["vehicle-solar-panel-2"] = 1,
    ["vehicle-solar-panel-3"] = 2,
    ["vehicle-solar-panel-4"] = 3,
    ["vehicle-solar-panel-5"] = 4,
    ["vehicle-solar-panel-6"] = 5,
}

-- Reskin equipment
for name, tier in pairs(solar_panels) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Construct technology icon
    inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay{is_vehicle = true} }

    reskins.lib.construct_technology_icon(string.gsub(name, "panel", "panel-equipment"), inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-solar-panel/vehicle-solar-panel-equipment-base.png",
                width = 64,
                height = 32,
                priority = "medium",
                flags = { "no-crop" },
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-solar-panel/hr-vehicle-solar-panel-equipment-base.png",
                    width = 128,
                    height = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-solar-panel/vehicle-solar-panel-equipment-mask.png",
                width = 64,
                height = 32,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-solar-panel/hr-vehicle-solar-panel-equipment-mask.png",
                    width = 128,
                    height = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-solar-panel/vehicle-solar-panel-equipment-highlights.png",
                width = 64,
                height = 32,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-solar-panel/hr-vehicle-solar-panel-equipment-highlights.png",
                    width = 128,
                    height = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end