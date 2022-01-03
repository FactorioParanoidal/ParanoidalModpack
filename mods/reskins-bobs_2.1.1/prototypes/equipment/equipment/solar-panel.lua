-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.equipment.equipment) then return end

local inputs = {
    type = "solar-panel-equipment",
    icon_name = "solar-panel",
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local solar_panels = {
    ["solar-panel-equipment"] = {tier = 1, prog_tier = 2},
    ["solar-panel-equipment-2"] = {tier = 2, prog_tier = 3},
    ["solar-panel-equipment-3"] = {tier = 3, prog_tier = 4},
    ["solar-panel-equipment-4"] = {tier = 4, prog_tier = 5},
}

-- Reskin equipment
for name, map in pairs(solar_panels) do
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
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/solar-panel/solar-panel-equipment-base.png",
                size = 32,
                priority = "medium",
                flags = { "no-crop" },
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/equipment/solar-panel/hr-solar-panel-equipment-base.png",
                    size = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/solar-panel/solar-panel-equipment-mask.png",
                size = 32,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/equipment/solar-panel/hr-solar-panel-equipment-mask.png",
                    size = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/solar-panel/solar-panel-equipment-highlights.png",
                size = 32,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/equipment/solar-panel/hr-solar-panel-equipment-highlights.png",
                    size = 64,
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