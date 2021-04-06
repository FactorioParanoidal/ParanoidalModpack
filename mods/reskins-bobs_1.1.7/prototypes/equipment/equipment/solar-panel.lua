-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local inputs = {
    type = "solar-panel-equipment",
    icon_name = "solar-panel",
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local solar_panels = {
    ["solar-panel-equipment"] = {1, 2},
    ["solar-panel-equipment-2"] = {2, 3},
    ["solar-panel-equipment-3"] = {3, 4},
    ["solar-panel-equipment-4"] = {4, 5},
}

-- Reskin equipment
for name, map in pairs(solar_panels) do
    -- Fetch equipment
    local equipment = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not equipment then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    if reskins.bobs and reskins.bobs.triggers.equipment.technologies then
        -- Construct technology icon
        inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay() }

        reskins.lib.construct_technology_icon(name, inputs)
    end

    if reskins.bobs and reskins.bobs.triggers.equipment.equipment then
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
    end

    -- Label to skip to next iteration
    ::continue::
end