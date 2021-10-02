-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then return end

-- Set input parameters
local inputs = {
    type = "storage-tank",
    icon_name = "petrochem-inline-tank",
    base_entity = "storage-tank",
    mod = "angels",
    group = "petrochem",
    tint = util.color("c20600"), -- Red
    icon_layers = 1,
    particles = {["big"] = 1},
    make_remnants = false,
}

-- Fetch entity
local name = "angels-storage-tank-3"
local entity = data.raw[inputs.type][name]

-- Check if entity exists, if not, skip this iteration
if not entity then return end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.pictures.picture = {
    sheets = {
        {
            filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-inline-tank/petrochem-inline-tank.png",
            priority = "extra-high",
            frames = 4,
            width = 71,
            height = 102,
            shift = util.by_pixel(-0.5, -8),
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-inline-tank/hr-petrochem-inline-tank.png",
                priority = "extra-high",
                frames = 4,
                width = 142,
                height = 199,
                shift = util.by_pixel(0, -7.5),
                scale = 0.5
            }
        },
        {
            filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-inline-tank/petrochem-inline-tank-shadow.png",
            priority = "extra-high",
            frames = 4,
            width = 106,
            height = 101,
            shift = util.by_pixel(17, 8),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-inline-tank/hr-petrochem-inline-tank-shadow.png",
                priority = "extra-high",
                frames = 4,
                width = 207,
                height = 199,
                shift = util.by_pixel(16.5, 9),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

-- Fix drawing box
entity.drawing_box = {{-1, -1.75}, {1, 1}}