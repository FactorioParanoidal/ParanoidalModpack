-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.ores.entities) then return end

local inputs = {
    type = "resource",
    mod = "bobs",
    group = "ores",
}

reskins.lib.parse_inputs(inputs)

local fluids = {
    "ground-water",
    "lithia-water",
}

for _, name in pairs(fluids) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Setup icons
    inputs.icon = reskins.bobs.directory.."/graphics/icons/ores/ores/"..name.."/"..name..".png"

    reskins.lib.assign_icons(name, inputs)

    -- Reskin entity
    entity.stages = {
        sheet = {
            filename = reskins.bobs.directory.."/graphics/entity/ores/"..name.."/"..name..".png",
            priority = "extra-high",
            width = 74,
            height = 60,
            frame_count = 4,
            variation_count = 1,
            shift = util.by_pixel(0, -2),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/ores/"..name.."/hr-"..name..".png",
                priority = "extra-high",
                width = 148,
                height = 120,
                frame_count = 4,
                variation_count = 1,
                shift = util.by_pixel(0, -2),
                scale = 0.5,
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end


