-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobvehicleequipment"] then return end

local inputs = {
    type = "generator-equipment",
    icon_name = "fusion-reactor",
    icon_background = "vehicle-equipment",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local fusion_reactors = {
    ["vehicle-fusion-reactor-1"] = 0,
    ["vehicle-fusion-reactor-2"] = 1,
    ["vehicle-fusion-reactor-3"] = 2,
    ["vehicle-fusion-reactor-4"] = 3,
    ["vehicle-fusion-reactor-5"] = 4,
    ["vehicle-fusion-reactor-6"] = 5,
}

-- Reskin equipment
for name, tier in pairs(fusion_reactors) do
    -- Fetch equipment
    equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Construct technology icon
    inputs.technology_icon_extras = {
        {
            icon = inputs.directory.."/graphics/technology/equipment/vehicle-equipment-symbol.png"
        }
    }

    reskins.lib.construct_technology_icon(string.gsub(name, "reactor", "reactor-equipment"), inputs)
    
    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = inputs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-reactor/vehicle-fusion-reactor-equipment-base.png",
                width = 64,
                height = 128,
                priority = "medium",
                flags = { "no-crop" },
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-reactor/vehicle-fusion-reactor-equipment-mask.png",
                width = 64,
                height = 128,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-reactor/vehicle-fusion-reactor-equipment-highlights.png",
                width = 64,
                height = 128,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = "additive",
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end