-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.vehicle_equipment.equipment) then return end

local inputs = {
    type = "roboport-equipment",
    icon_name = "vehicle-roboport",
    equipment_category = "utility",
    mod = "bobs",
    group = "vehicle-equipment",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local vehicle_roboports = {
    ["vehicle-roboport"] = {tier = 1, prog_tier = 2, base = 1},
    ["vehicle-roboport-2"] = {tier = 2, prog_tier = 3, base = 1},
    ["vehicle-roboport-3"] = {tier = 3, prog_tier = 4, base = 2},
    ["vehicle-roboport-4"] = {tier = 4, prog_tier = 5, base = 2},
}

-- Reskin equipment
for name, map in pairs(vehicle_roboports) do
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

    -- Setup icon handling
    inputs.icon_base = inputs.icon_name.."-"..map.base

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
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/hr-"..inputs.icon_base.."-equipment-base.png",
                    size = 128,
                    priority = "medium",
                    flags = { "no-crop" },
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/vehicle-roboport-equipment-mask.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/hr-vehicle-roboport-equipment-mask.png",
                    size = 128,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/vehicle-roboport-equipment-highlights.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-roboport/hr-vehicle-roboport-equipment-highlights.png",
                    size = 128,
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