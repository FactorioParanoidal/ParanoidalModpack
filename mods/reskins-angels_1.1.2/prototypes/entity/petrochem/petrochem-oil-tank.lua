-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Set input parameters
local inputs = {
    type = "storage-tank",
    icon_name = "petrochem-oil-tank",
    base_entity = "roboport",
    mod = "angels",
    group = "petrochem",
    icon_layers = 1,
    particles = {["medium"] = 2},
    make_remnants = false,
}

-- Fetch entity
local name = "angels-storage-tank-2"
local entity = data.raw[inputs.type][name]

-- Check if entity exists, if not, skip this iteration
if not entity then return end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.pictures.picture = {
    sheets = {
        {
            filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-oil-tank/petrochem-oil-tank.png",
            priority = "extra-high",
            frames = 2,
            width = 135,
            height = 154,
            shift = util.by_pixel(-1, -1),
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-oil-tank/hr-petrochem-oil-tank.png",
                priority = "extra-high",
                frames = 2,
                width = 273,
                height = 307,
                shift = util.by_pixel(0, -2),
                scale = 0.5
            }
        },
        {
            filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-oil-tank/petrochem-oil-tank-shadow.png",
            priority = "extra-high",
            frames = 2,
            width = 167,
            height = 165,
            shift = util.by_pixel(15, 8.5),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-oil-tank/hr-petrochem-oil-tank-shadow.png",
                priority = "extra-high",
                frames = 2,
                width = 335,
                height = 328,
                shift = util.by_pixel(16.5, 9.5),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

-- Fix drawing box
entity.drawing_box = {{-2, -3}, {2, 2}}