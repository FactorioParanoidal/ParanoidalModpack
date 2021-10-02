-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["NauvisDay"] then return end
if not (reskins.bobs and reskins.bobs.triggers.greenhouse.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "dead-greenhouse",
    base_entity = "lab",
    mod = "compatibility",
    group = "nauvisday",
    icon_layers = 1,
}

-- Fetch entity
local entity = data.raw["assembling-machine"]["dead-greenhouse"]

-- Check if entity exists, if not, return
if not entity then return end

reskins.lib.setup_standard_entity("dead-greenhouse", 0, inputs)

local dead_greenhouse_base = reskins.lib.make_4way_animation_from_spritesheet({
    -- Base
    filename = reskins.compatibility.directory.."/graphics/entity/nauvisday/dead-greenhouse/dead-greenhouse-base.png",
    width = 97,
    height = 96,
    shift = util.by_pixel(0, 0),
    hr_version = {
        filename = reskins.compatibility.directory.."/graphics/entity/nauvisday/dead-greenhouse/hr-dead-greenhouse-base.png",
        width = 194,
        height = 192,
        shift = util.by_pixel(0, 0),
        scale = 0.5
    },
})

local dead_greenhouse_integration_patch = {
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

local dead_greenhouse_shadow = {
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
            dead_greenhouse_base.north,
            dead_greenhouse_integration_patch,
            dead_greenhouse_shadow
        }
    },
    east = {
        layers = {
            dead_greenhouse_base.east,
            dead_greenhouse_integration_patch,
            dead_greenhouse_shadow
        }
    },
    south = {
        layers = {
            dead_greenhouse_base.south,
            dead_greenhouse_integration_patch,
            dead_greenhouse_shadow
        }
    },
    west = {
        layers = {
            dead_greenhouse_base.west,
            dead_greenhouse_integration_patch,
            dead_greenhouse_shadow
        }
    },
}

entity.idle_animation = nil

local dead_greenhouse_working = reskins.lib.make_4way_animation_from_spritesheet({
    layers = {
        -- Light Underlayer
        {
            filename = reskins.compatibility.directory.."/graphics/entity/nauvisday/dead-greenhouse/dead-greenhouse-lit.png",
            width = 97,
            height = 96,
            shift = util.by_pixel(0, 0),
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/nauvisday/dead-greenhouse/hr-dead-greenhouse-lit.png",
                width = 194,
                height = 192,
                shift = util.by_pixel(0, 0),
                scale = 0.5
            }
        },
        -- Light
        {
            filename = reskins.compatibility.directory.."/graphics/entity/nauvisday/dead-greenhouse/dead-greenhouse-light.png",
            width = 97,
            height = 96,
            shift = util.by_pixel(0, 0),
            draw_as_light = true,
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/nauvisday/dead-greenhouse/hr-dead-greenhouse-light.png",
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
        north_animation = dead_greenhouse_working.north,
        east_animation = dead_greenhouse_working.east,
        west_animation = dead_greenhouse_working.west,
        south_animation = dead_greenhouse_working.south,
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

-- Disable burner energy source light
entity.energy_source.light_flicker = {
    color = {0, 0, 0},
    minimum_light_size = 0,
    light_intensity_to_size_coefficient = 0,
}