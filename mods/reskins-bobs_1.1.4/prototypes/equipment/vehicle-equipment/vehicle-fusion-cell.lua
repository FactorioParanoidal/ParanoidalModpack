-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local inputs = {
    type = "generator-equipment",
    icon_name = "vehicle-fusion-cell",
    equipment_category = "energy",
    mod = "bobs",
    group = "vehicle-equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local fusion_cells = {
    ["vehicle-fusion-cell-1"] = 0,
    ["vehicle-fusion-cell-2"] = 1,
    ["vehicle-fusion-cell-3"] = 2,
    ["vehicle-fusion-cell-4"] = 3,
    ["vehicle-fusion-cell-5"] = 4,
    ["vehicle-fusion-cell-6"] = 5,
}

-- Reskin equipment
for name, tier in pairs(fusion_cells) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    if reskins.bobs and reskins.bobs.triggers.equipment.technologies then
        -- Construct technology icon
        inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay{is_vehicle = true} }

        reskins.lib.construct_technology_icon(string.gsub(name, "cell", "cell-equipment"), inputs)
    end

    if reskins.bobs and reskins.bobs.triggers.equipment.equipment then
        -- Construct icon
        reskins.lib.construct_icon(name, tier, inputs)

        -- Reskin the equipment
        equipment.sprite = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-cell/vehicle-fusion-cell-equipment-base.png",
                    size = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-cell/hr-vehicle-fusion-cell-equipment-base.png",
                        size = 128,
                        priority = "medium",
                        flags = { "no-crop" },
                        scale = 0.5,
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-cell/vehicle-fusion-cell-equipment-mask.png",
                    size = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-cell/hr-vehicle-fusion-cell-equipment-mask.png",
                        size = 128,
                        priority = "medium",
                        flags = { "no-crop" },
                        tint = inputs.tint,
                        scale = 0.5,
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-cell/vehicle-fusion-cell-equipment-highlights.png",
                    size = 64,
                    priority = "medium",
                    flags = { "no-crop" },
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-fusion-cell/hr-vehicle-fusion-cell-equipment-highlights.png",
                        size = 128,
                        priority = "medium",
                        flags = { "no-crop" },
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    }
                }
            }
        }
    end

    -- Label to skip to next iteration
    ::continue::
end