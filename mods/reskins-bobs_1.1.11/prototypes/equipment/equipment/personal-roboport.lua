-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.equipment.equipment) then return end

local inputs = {
    type = "roboport-equipment",
    icon_name = "personal-roboport",
    mod = "bobs",
    group = "equipment",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local personal_roboports = {
    ["personal-roboport-equipment"] = {tier = 1, prog_tier = 2, base = 1},
    ["personal-roboport-mk2-equipment"] = {tier = 2, prog_tier = 3, base = 1},
    ["personal-roboport-mk3-equipment"] = {tier = 3, prog_tier = 4, base = 2},
    ["personal-roboport-mk4-equipment"] = {tier = 4, prog_tier = 5, base = 2},
}

-- Reskin equipment
for name, map in pairs(personal_roboports) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Setup icon handling
    inputs.icon_base = inputs.icon_name.."-"..map.base
    inputs.icon_mask = inputs.icon_base
    inputs.icon_highlights = inputs.icon_base

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/"..inputs.icon_base.."-equipment-base.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/hr-"..inputs.icon_base.."-equipment-base.png",
                    size = 128,
                    priority = "medium",
                    flags = { "no-crop" },
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/"..inputs.icon_base.."-equipment-mask.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/hr-"..inputs.icon_base.."-equipment-mask.png",
                    size = 128,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/"..inputs.icon_base.."-equipment-highlights.png",
                size = 64,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/equipment/equipment/personal-roboport/hr-"..inputs.icon_base.."-equipment-highlights.png",
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