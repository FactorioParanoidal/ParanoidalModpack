-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.vehicle_equipment.equipment) then return end

local inputs = {
    type = "active-defense-equipment",
    icon_name = "vehicle-plasma-turret",
    equipment_category = "offense",
    mod = "bobs",
    group = "vehicle-equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local plasma_turret = {
    ["vehicle-big-turret-1"] = {tier = 0},
    ["vehicle-big-turret-2"] = {tier = 1},
    ["vehicle-big-turret-3"] = {tier = 2},
    ["vehicle-big-turret-4"] = {tier = 3},
    ["vehicle-big-turret-5"] = {tier = 4},
    ["vehicle-big-turret-6"] = {tier = 5},
}

-- Reskin equipment
for name, map in pairs(plasma_turret) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-plasma-turret/vehicle-plasma-turret-equipment-base.png",
                size = 128,
                priority = "medium",
                flags = { "no-crop" },
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-plasma-turret/hr-vehicle-plasma-turret-equipment-base.png",
                    size = 256,
                    priority = "medium",
                    flags = { "no-crop" },
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-plasma-turret/vehicle-plasma-turret-equipment-mask.png",
                size = 128,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-plasma-turret/hr-vehicle-plasma-turret-equipment-mask.png",
                    size = 256,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-plasma-turret/vehicle-plasma-turret-equipment-highlights.png",
                size = 128,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-plasma-turret/hr-vehicle-plasma-turret-equipment-highlights.png",
                    size = 256,
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