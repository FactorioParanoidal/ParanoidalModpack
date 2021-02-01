-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Set input parameters
local inputs = {
    type = "storage-tank",
    icon_name = "petrochem-gas-tank",
    base_entity = "oil-refinery",
    mod = "angels",
    group = "petrochem",
    icon_layers = 1,
    particles = {["medium-long"] = 4, ["big-tint"] = 5, ["medium"] = 2},
    make_remnants = false,
}

-- Fetch entity
local name = "angels-storage-tank-1"
local entity = data.raw[inputs.type][name]

-- Check if entity exists, if not, skip this iteration
if not entity then return end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.pictures.picture = {
    sheets = {
        {
            filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-gas-tank/petrochem-gas-tank.png",
            priority = "extra-high",
            frames = 1,
            width = 167,
            height = 192,
            shift = util.by_pixel(-1, -7),
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-gas-tank/hr-petrochem-gas-tank.png",
                priority = "extra-high",
                frames = 1,
                width = 334,
                height = 387,
                shift = util.by_pixel(-0.5, -6),
                scale = 0.5
            }
        },
        {
            filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-gas-tank/petrochem-gas-tank-shadow.png",
            priority = "extra-high",
            frames = 1,
            width = 220,
            height = 120,
            shift = util.by_pixel(26, 31),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/petrochem-gas-tank/hr-petrochem-gas-tank-shadow.png",
                priority = "extra-high",
                frames = 1,
                width = 437,
                height = 237,
                shift = util.by_pixel(26, 32),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

-- Fix drawing box
entity.drawing_box = {{-2.5, -3.75}, {2.5, 2.5}}