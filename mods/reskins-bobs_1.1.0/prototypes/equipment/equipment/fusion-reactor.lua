-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobequipment"] then return end

local inputs = {
    type = "generator-equipment",
    icon_name = "fusion-reactor",
    mod = "bobs",
    group = "equipment",
}

-- Setup defaults
reskins.lib.parse_inputs(inputs)

local fusion_reactors = {
    ["fusion-reactor-equipment"] = {1, 2},
    ["fusion-reactor-equipment-2"] = {2, 3},
    ["fusion-reactor-equipment-3"] = {3, 4},
    ["fusion-reactor-equipment-4"] = {4, 5},
}

-- Reskin equipment
for name, map in pairs(fusion_reactors) do
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
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    -- Construct icon
    reskins.lib.construct_icon(name, tier, inputs)

    -- Construct technology icon
    inputs.technology_icon_extras = {
        {
            icon = reskins.bobs.directory.."/graphics/technology/equipment/personal-equipment-symbol.png"
        }
    }

    reskins.lib.construct_technology_icon(name, inputs)

    -- Reskin the equipment
    equipment.sprite = {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/fusion-reactor/fusion-reactor-equipment-base.png",
                size = 128,
                priority = "medium",
                flags = { "no-crop" },
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/fusion-reactor/fusion-reactor-equipment-mask.png",
                size = 128,
                priority = "medium",
                flags = { "no-crop" },
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/equipment/equipment/fusion-reactor/fusion-reactor-equipment-highlights.png",
                size = 128,
                priority = "medium",
                flags = { "no-crop" },
                blend_mode = reskins.lib.blend_mode, -- "additive",
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end