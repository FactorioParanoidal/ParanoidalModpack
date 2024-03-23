-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

local inputs = {
    type = "furnace",
    icon_name = "clarifier",
    mod = "angels",
    group = "refining",
    icon_layers = 1,
    make_remnants = false,
    make_explosions = false
}

local entity = data.raw[inputs.type]["clarifier"]
if not entity then return end

local shadows = reskins.lib.make_4way_animation_from_spritesheet({
    filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/clarifier-shadow.png",
    priority = "extra-high",
    width = 189,
    height = 184,
    shift = util.by_pixel(9.5, 1),
    draw_as_shadow = true,
    hr_version = {
        filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/hr-clarifier-shadow.png",
        priority = "extra-high",
        width = 374,
        height = 365,
        shift = util.by_pixel(10, 0),
        draw_as_shadow = true,
        scale = 0.5,
    },
})

local pipe_properties = {
    north = {normal = 0, hr = 0},
    -- East frame mapping: 2-All, 12-30, 13-31, 14-32, 15-33, 16-34, 15,35, 16-36
    east = {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 12, 13, 14,
        15, 16, 17, 18, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    south = {normal = 189*2, hr = 374*2},
    -- West frame mapping: 4-All, 5-1, 6-2, 7-3, 8-61, 9-62, 10-63, 11-64
    west = {5, 6, 7, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 8, 9.5, 10, 11}
}

local function get_pipe_connections(direction, is_animated)
    if is_animated then
        return {
            filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/clarifier-pipe-connections.png",
            priority = "extra-high",
            width = 189,
            height = 184,
            frame_count = 18,
            line_length = 6,
            animation_speed = 0.5,
            frame_sequence = pipe_properties[direction],
            shift = util.by_pixel(9.5, 1),
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/hr-clarifier-pipe-connections.png",
                priority = "extra-high",
                width = 374,
                height = 365,
                frame_count = 18,
                line_length = 6,
                animation_speed = 0.5,
                frame_sequence = pipe_properties[direction],
                shift = util.by_pixel(10, 0),
                scale = 0.5,
            }
        }
    else
        return {
            filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/clarifier-pipe-connections.png",
            priority = "extra-high",
            width = 189,
            height = 184,
            x = pipe_properties[direction].normal,
            shift = util.by_pixel(9.5, 1),
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/hr-clarifier-pipe-connections.png",
                priority = "extra-high",
                width = 374,
                height = 365,
                x = pipe_properties[direction].hr,
                shift = util.by_pixel(10, 0),
                scale = 0.5,
            }
        }
    end
end

reskins.lib.setup_standard_entity("clarifier", 0, inputs)

entity.animation = {
    filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/clarifier-base.png",
    priority = "extra-high",
    frame_count = 64,
    line_length = 8,
    animation_speed = 0.5,
    width = 189,
    height = 184,
    shift = util.by_pixel(9.5, 1),
    hr_version = {
        filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/hr-clarifier-base.png",
        priority = "extra-high",
        frame_count = 64,
        line_length = 8,
        animation_speed = 0.5,
        width = 374,
        height = 365,
        shift = util.by_pixel(10, 0),
        scale = 0.5,
    },
}

entity.working_visualisations = {
    -- Shadows
    {
        always_draw = true,
        north_animation = shadows.north,
        east_animation = shadows.east,
        south_animation = shadows.south,
        west_animation = shadows.west,
    },

    -- Pipes North/South
    {
        always_draw = true,
        north_animation = get_pipe_connections("north"),
        south_animation = get_pipe_connections("south"),
    },

    -- Pipes East/West
    {
        always_draw = true,
        render_layer = "higher-object-under",
        east_animation = get_pipe_connections("east", true),
        west_animation = get_pipe_connections("west", true),
    },

    -- Recipe mask
    {
        apply_recipe_tint = "primary",
        fadeout = true,
        animation = {
            filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/clarifier-recipe-mask.png",
            priority = "extra-high",
            frame_count = 64,
            line_length = 8,
            animation_speed = 0.5,
            width = 189,
            height = 184,
            shift = util.by_pixel(9.5, 1),
            hr_version = {
                filename = reskins.angels.directory.."/graphics/entity/refining/clarifier/hr-clarifier-recipe-mask.png",
                priority = "extra-high",
                frame_count = 64,
                line_length = 8,
                animation_speed = 0.5,
                width = 374,
                height = 365,
                shift = util.by_pixel(10, 0),
                scale = 0.5,
            },
        }
    },

    -- Vertical Pipe Shadow
    {
        always_draw = true,
        south_animation = reskins.lib.vertical_pipe_shadow({0, -2}),
    }
}