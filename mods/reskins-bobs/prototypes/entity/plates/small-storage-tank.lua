-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.plates.entities) then return end

-- Set input parameters
local inputs = {
    type = "storage-tank",
    icon_name = "small-storage-tank",
    base_entity_name = "storage-tank",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "plates",
    particles = {["big"] = 1},
    tint = util.color("b29270"),
    icon_layers = 1,
    make_remnants = false,
}

local tier_map = {
    ["bob-small-storage-tank"] = {},
    ["bob-small-inline-storage-tank"] = {inline = true},
}

-- All-way small storage tank
local all_way_sheets = {
    {
        filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/small-storage-tank.png",
        priority = "extra-high",
        frames = 1,
        width = 32,
        height = 64,
        shift = util.by_pixel(0, -16),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/hr-small-storage-tank.png",
            priority = "extra-high",
            frames = 1,
            width = 64,
            height = 128,
            shift = util.by_pixel(0, -16),
            scale = 0.5,
        }
    },
    {
        filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/small-storage-tank-shadow.png",
        priority = "extra-high",
        frames = 1,
        width = 64,
        height = 32,
        shift = util.by_pixel(16, 0),
        draw_as_shadow = true,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/hr-small-storage-tank-shadow.png",
            priority = "extra-high",
            frames = 1,
            width = 128,
            height = 64,
            shift = util.by_pixel(16, 0),
            draw_as_shadow = true,
            scale = 0.5,
        }
    },
}

local inline_sheets = {
    {
        filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/inline-storage-tank.png",
        priority = "extra-high",
        frames = 2,
        width = 32,
        height = 64,
        shift = util.by_pixel(0, -16),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/hr-inline-storage-tank.png",
            priority = "extra-high",
            frames = 2,
            width = 64,
            height = 128,
            shift = util.by_pixel(0, -16),
            scale = 0.5,
        }
    },
    {
        filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/inline-storage-tank-shadow.png",
        priority = "extra-high",
        frames = 2,
        width = 64,
        height = 32,
        shift = util.by_pixel(16, 0),
        draw_as_shadow = true,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/hr-inline-storage-tank-shadow.png",
            priority = "extra-high",
            frames = 2,
            width = 128,
            height = 64,
            shift = util.by_pixel(16, 0),
            draw_as_shadow = true,
            scale = 0.5,
        }
    },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Setup icon details
    inputs.icon_base = map.inline and "inline-small-storage-tank" or nil

    reskins.lib.setup_standard_entity(name, 0, inputs)

    -- Reskin entities
    entity.window_bounding_box = {util.by_pixel(5.5, -21.5), util.by_pixel(10.5, -3.5)}
    entity.pictures = {
        picture = {sheets = map.inline and inline_sheets or all_way_sheets},
        fluid_background = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/fluid-background.png",
            priority = "extra-high",
            width = 5,
            height = 18,
        },
        window_background = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/window-background.png",
            priority = "extra-high",
            width = 5,
            height = 18,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/hr-window-background.png",
                priority = "extra-high",
                width = 10,
                height = 36,
                scale = 0.5
            }
        },
        flow_sprite = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/fluid-flow.png",
            priority = "extra-high",
            width = 160,
            height = 10,
        },
        gas_flow = {
            filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/steam.png",
            priority = "extra-high",
            line_length = 10,
            width = 7,
            height = 15,
            frame_count = 60,
            axially_symmetrical = false,
            direction_count = 1,
            animation_speed = 0.25,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/plates/small-storage-tank/hr-steam.png",
                priority = "extra-high",
                line_length = 10,
                width = 14,
                height = 30,
                frame_count = 60,
                axially_symmetrical = false,
                animation_speed = 0.25,
                direction_count = 1,
                scale = 0.5
            }
        },
    }

    -- Clear assembling machine pipe pictures
    entity.fluid_box.pipe_picture = nil

    -- Label to skip to next iteration
    ::continue::
end