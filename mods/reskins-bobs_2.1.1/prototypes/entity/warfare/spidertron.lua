-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then return end

local spidertrons = {
    "antron",
    "tankotron",
    "logistic-spidertron",
    "heavy-spidertron"
}

local function spidertron_icons(name)
    local item = data.raw["item-with-entity-data"][name]
    if not item then return end

    ---@type inputs.assign_icons
    local inputs = {
        type = "spider-vehicle",
        icon = reskins.bobs.directory.."/graphics/icons/warfare/spidertron/"..name..".png",
        icon_size = 64,
        icon_mipmaps = 4,
    }

    reskins.lib.assign_icons(name, inputs)

    -- Setup the tintable icons
    item.icon_tintable = reskins.bobs.directory.."/graphics/icons/warfare/spidertron/"..name.."-tintable.png"
    item.icon_tintable_mask = reskins.bobs.directory.."/graphics/icons/warfare/spidertron/"..name.."-tintable-mask.png"
end

for _,name in pairs(spidertrons) do
    spidertron_icons(name)
end

-- Add a tank cannon to the Tankotron
local tankotron = data.raw["spider-vehicle"]["tankotron"]
if tankotron then
    table.insert(tankotron.graphics_set.animation.layers, 1, {
        filename = "__base__/graphics/entity/tank/tank-turret-mask.png",
        width = 36,
        height = 33,
        line_length = 8,
        direction_count = 64,
        apply_runtime_tint = true,
        shift = util.by_pixel(0, -10),
        hr_version = {
            filename = "__base__/graphics/entity/tank/hr-tank-turret-mask.png",
            width = 72,
            height = 66,
            line_length = 8,
            direction_count = 64,
            scale = 0.5,
            apply_runtime_tint = true,
            shift = util.by_pixel(0, -10)
        }
    })

    table.insert(tankotron.graphics_set.animation.layers, 1, {
        filename = "__base__/graphics/entity/tank/tank-turret.png",
        width = 90,
        height = 67,
        line_length = 8,
        direction_count = 64,
        shift = util.by_pixel(0, -9),
        hr_version = {
            filename = "__base__/graphics/entity/tank/hr-tank-turret.png",
            width = 179,
            height = 132,
            line_length = 8,
            direction_count = 64,
            scale = 0.5,
            shift = util.by_pixel(0, -9)
        }
    })

    data.raw["spider-vehicle"]["tankotron"].drawing_box = {{-3, -3.5}, {3, 1.75}}
end



-- Revise projectile locations for the various spidertrons
local guns = {
    ["spidertron-gatling-gun"] = {
            projectile_center = {0, 2.3},
            projectile_creation_distance = 1.5,
            projectile_orientation_offset = 1,
        },
    ["spidertron-cannon-1"] = {
            projectile_center = {0.3, 2},
            projectile_creation_distance = 1.65,
            projectile_orientation_offset = 0, -- -1.65
        },
    ["spidertron-cannon-2"] = {
            projectile_center = {-0.3, 2},
            projectile_creation_distance = 1.65, -- 1.65
            projectile_orientation_offset = 0, -- -1.65
        },
}

for gun, attack_parameters in pairs(guns) do
    local spidertron_gun = data.raw["gun"][gun]
    if spidertron_gun then
        spidertron_gun.attack_parameters = util.merge({spidertron_gun.attack_parameters, attack_parameters})
    end
end

-- Beam weapon projectile centers cannot be adjusted on player/unit prototypes, unfortunately.
-- See https://forums.factorio.com/viewtopic.php?f=28&t=100458&p=555629&hilit=source_offset#p555629