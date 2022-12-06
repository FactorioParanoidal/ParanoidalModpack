-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check if reskinning needs to be done
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then return end

-- Set input parameters
local inputs = {
    type = "storage-tank",
    icon_name = "valve",
    base_entity_name = "pipe",
    mod = "bobs",
    group = "logistics",
    particles = {["small"] = 2},
    icon_layers = 2,
    make_remnants = false,
}

local tint_map = {
    ["bob-valve"] = util.color("2ac0ff"),
    ["bob-overflow-valve"] = util.color("ff3b29"),
    ["bob-topup-valve"] = util.color("4dff2a"),
}

local function cardinal_pictures(x, tint)
    local x_lr = 64*x
    local x_hr = 128*x

    return
    {
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/valve/valve-base.png",
                priority = "extra-high",
                x = x_lr,
                width = 64,
                height = 64,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/valve/hr-valve-base.png",
                    priority = "extra-high",
                    x = x_hr,
                    width = 128,
                    height = 128,
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/valve/valve-mask.png",
                priority = "extra-high",
                x = x_lr,
                width = 64,
                height = 64,
                tint = tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/valve/hr-valve-mask.png",
                    priority = "extra-high",
                    x = x_hr,
                    width = 128,
                    height = 128,
                    tint = tint,
                    scale = 0.5
                }
            }
        }
    }
end

-- Reskin entities, create and assign extra details
for name, tint in pairs(tint_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Assign tint
    inputs.tint = tint

    reskins.lib.setup_standard_entity(name, 0, inputs)

    -- Reskin entities
    entity.pictures.picture.north = cardinal_pictures(0, inputs.tint)
    entity.pictures.picture.east = cardinal_pictures(1, inputs.tint)
    entity.pictures.picture.south = cardinal_pictures(2, inputs.tint)
    entity.pictures.picture.west = cardinal_pictures(3, inputs.tint)

    -- Label to skip to next iteration
    ::continue::
end