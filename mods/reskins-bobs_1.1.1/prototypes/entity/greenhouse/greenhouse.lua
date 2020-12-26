-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobgreenhouse"] then return end
if reskins.lib.setting("reskins-bobs-do-bobgreenhouse") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "greenhouse",
    base_entity = "lab",
    mod = "bobs",
    group = "greenhouse",
    icon_layers = 1,
}

-- Fetch entity
local entity = data.raw["assembling-machine"]["bob-greenhouse"]

-- Check if entity exists, if not, return
if not entity then return end

reskins.lib.setup_standard_entity("bob-greenhouse", 0, inputs)

local greenhouse_base = reskins.lib.make_4way_animation_from_spritesheet({
    -- Base
    filename = reskins.bobs.directory.."/graphics/entity/greenhouse/greenhouse-base.png",
    width = 97,
    height = 96,
    shift = util.by_pixel(0, 0),
    hr_version = {
        filename = reskins.bobs.directory.."/graphics/entity/greenhouse/hr-greenhouse-base.png",
        width = 194,
        height = 192,
        shift = util.by_pixel(0, 0),
        scale = 0.5
    },
})

local greenhouse_integration_patch = {
    filename = "__base__/graphics/entity/lab/lab-integration.png",
    width = 122,
    height = 81,
    shift = util.by_pixel(0, 15.5),
    hr_version = {
        filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
        width = 242,
        height = 162,
        shift = util.by_pixel(0, 15.5),
        scale = 0.5
    }
}

local greenhouse_shadow = {
    filename = "__base__/graphics/entity/lab/lab-shadow.png",
    width = 122,
    height = 68,
    shift = util.by_pixel(13, 11),
    draw_as_shadow = true,
    hr_version = {
        filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
        width = 242,
        height = 136,
        shift = util.by_pixel(13, 11),
        scale = 0.5,
        draw_as_shadow = true
    }
}

-- Reskin the entity
entity.animation = {
    north = {
        layers = {
            greenhouse_base.north,
            greenhouse_integration_patch,
            greenhouse_shadow
        }
    },
    east = {
        layers = {
            greenhouse_base.east,
            greenhouse_integration_patch,
            greenhouse_shadow
        }
    },
    south = {
        layers = {
            greenhouse_base.south,
            greenhouse_integration_patch,
            greenhouse_shadow
        }
    },
    west = {
        layers = {
            greenhouse_base.west,
            greenhouse_integration_patch,
            greenhouse_shadow
        }
    },
}

entity.idle_animation = nil

local greenhouse_working = reskins.lib.make_4way_animation_from_spritesheet({
    layers = {
        -- Light Underlayer
        {
            filename = reskins.bobs.directory.."/graphics/entity/greenhouse/greenhouse-lit.png",
            width = 97,
            height = 96,
            shift = util.by_pixel(0, 0),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/greenhouse/hr-greenhouse-lit.png",
                width = 194,
                height = 192,
                shift = util.by_pixel(0, 0),
                scale = 0.5
            }
        },
        -- Light
        {
            filename = reskins.bobs.directory.."/graphics/entity/greenhouse/greenhouse-light.png",
            width = 97,
            height = 96,
            shift = util.by_pixel(0, 0),
            draw_as_light = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/greenhouse/hr-greenhouse-light.png",
                width = 194,
                height = 192,
                shift = util.by_pixel(0, 0),
                draw_as_light = true,
                scale = 0.5
            }
        },
    }
})

entity.working_visualisations = {
    {
        fadeout = true,
        north_animation = greenhouse_working.north,
        east_animation = greenhouse_working.east,
        west_animation = greenhouse_working.west,
        south_animation = greenhouse_working.south,
    },

    -- Pipe shadow fixes
    {
        always_draw = true,
        north_animation = reskins.lib.vertical_pipe_shadow{0, -1},
        south_animation = reskins.lib.vertical_pipe_shadow{0, 1},
    }
}

entity.fluid_boxes[1].pipe_picture = nil
entity.fluid_boxes[1].secondary_draw_orders = {east = 3, west = 3, south = 3}