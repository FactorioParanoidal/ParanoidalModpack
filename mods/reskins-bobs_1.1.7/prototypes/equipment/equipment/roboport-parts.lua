-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.equipment.equipment) then return end

local inputs = {
    type = "roboport-equipment",
    mod = "bobs",
    group = "vehicle-equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local categories = {
    "robot",
    "chargepad",
    "antenna",
}

local properties = {
    {suffix = "", tier = 1, prog_tier = 2},
    {suffix = "-2", tier = 2, prog_tier = 3},
    {suffix = "-3", tier = 3, prog_tier = 4},
    {suffix = "-4", tier = 4, prog_tier = 5},
}

-- Reskin equipment
for _, category in pairs(categories) do
    for index, map in pairs(properties) do
        -- Fetch equipment
        local name = "personal-roboport-"..category.."-equipment"..map.suffix
        local equipment = data.raw[inputs.type][name]

        -- Check if entity exists, if not, skip this iteration
        if not equipment then goto continue end

        -- Handle tier
        local tier = map.tier
        if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
            tier = map.prog_tier or map.tier
        end

        -- Setup icon handling
        inputs.icon_name = "vehicle-part-"..category

        local equipment_path
        if category ~= "robot" then
            equipment_path = "vehicle-part-"..category.."-"..index
            inputs.icon_base = "vehicle-part-"..category.."-"..index
        else
            equipment_path = "vehicle-part-"..category
            inputs.icon_base = nil
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
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-part-"..category.."/"..equipment_path.."-equipment-base.png",
                    size = 32,
                    priority = "medium",
                    flags = { "no-crop" },
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-part-"..category.."/hr-"..equipment_path.."-equipment-base.png",
                        size = 64,
                        priority = "medium",
                        flags = { "no-crop" },
                        scale = 0.5,
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-part-"..category.."/vehicle-part-"..category.."-equipment-mask.png",
                    size = 32,
                    priority = "medium",
                    flags = { "no-crop" },
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-part-"..category.."/hr-vehicle-part-"..category.."-equipment-mask.png",
                        size = 64,
                        priority = "medium",
                        flags = { "no-crop" },
                        tint = inputs.tint,
                        scale = 0.5,
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-part-"..category.."/vehicle-part-"..category.."-equipment-highlights.png",
                    size = 32,
                    priority = "medium",
                    flags = { "no-crop" },
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/equipment/vehicle-equipment/vehicle-part-"..category.."/hr-vehicle-part-"..category.."-equipment-highlights.png",
                        size = 64,
                        priority = "medium",
                        flags = { "no-crop" },
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    }
                }
            }
        }

        -- equipment.sprite = {
        --     layers = {
        --         -- Base
        --         {
        --             filename = reskins.bobs.directory.."/graphics/equipment/equipment/part-"..category.."/"..equipment_path.."-equipment-base.png",
        --             size = 32,
        --             priority = "medium",
        --             flags = { "no-crop" },
        --             hr_version = {
        --                 filename = reskins.bobs.directory.."/graphics/equipment/equipment/part-"..category.."/hr-"..equipment_path.."-equipment-base.png",
        --                 size = 64,
        --                 priority = "medium",
        --                 flags = { "no-crop" },
        --                 scale = 0.5,
        --             }
        --         },
        --         -- Mask
        --         {
        --             filename = reskins.bobs.directory.."/graphics/equipment/equipment/part-"..category.."/part-"..category.."-equipment-mask.png",
        --             size = 32,
        --             priority = "medium",
        --             flags = { "no-crop" },
        --             tint = inputs.tint,
        --             hr_version = {
        --                 filename = reskins.bobs.directory.."/graphics/equipment/equipment/part-"..category.."/hr-part-"..category.."-equipment-mask.png",
        --                 size = 64,
        --                 priority = "medium",
        --                 flags = { "no-crop" },
        --                 tint = inputs.tint,
        --                 scale = 0.5,
        --             }
        --         },
        --         -- Highlights
        --         {
        --             filename = reskins.bobs.directory.."/graphics/equipment/equipment/part-"..category.."/part-"..category.."-equipment-highlights.png",
        --             size = 32,
        --             priority = "medium",
        --             flags = { "no-crop" },
        --             blend_mode = reskins.lib.blend_mode, -- "additive",
        --             hr_version = {
        --                 filename = reskins.bobs.directory.."/graphics/equipment/equipment/part-"..category.."/hr-part-"..category.."-equipment-highlights.png",
        --                 size = 64,
        --                 priority = "medium",
        --                 flags = { "no-crop" },
        --                 blend_mode = reskins.lib.blend_mode, -- "additive",
        --                 scale = 0.5,
        --             }
        --         }
        --     }
        -- }

        -- Label to skip to next iteration
        ::continue::
    end
end