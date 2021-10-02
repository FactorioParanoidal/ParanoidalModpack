-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "ore-flotation-cell",
    base_entity = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "refining",
    make_remnants = false,
}

local tier_map = {
    ["ore-floatation-cell"] = {tier = 1, prog_tier = 2},
    ["ore-floatation-cell-2"] = {tier = 2, prog_tier = 3},
    ["ore-floatation-cell-3"] = {tier = 3, prog_tier = 4},

    -- Extended Angels
    ["ore-floatation-cell-4"] = {tier = 4, prog_tier = 5},
}

local function return_base_animation(direction)
    local animation = {
        layers = {
            -- Base
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-base.png",
                priority = "extra-high",
                width = 168,
                height = 182,
                x = direction*168,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-base.png",
                    priority = "extra-high",
                    width = 333,
                    height = 363,
                    x = direction*333,
                    shift = util.by_pixel_hr(-1, -1),
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-shadow.png",
                priority = "extra-high",
                width = 196,
                height = 164,
                x = direction*196,
                shift = util.by_pixel(15, 9),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-shadow.png",
                    priority = "extra-high",
                    width = 390,
                    height = 326,
                    x = direction*390,
                    shift = util.by_pixel_hr(29, 18),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            },
        }
    }

    return animation
end

local function return_pipe_overlay(direction)
    local animation = {
        filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-pipe-cover-overlays.png",
        priority = "extra-high",
        width = 168,
        height = 182,
        x = direction*168,
        shift = util.by_pixel(0, 0),
        hr_version = {
            filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-pipe-cover-overlays.png",
            priority = "extra-high",
            width = 333,
            height = 363,
            x = direction*333,
            shift = util.by_pixel_hr(-1, -1),
            scale = 0.5,
        }
    }
    return animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = {
        north = return_base_animation(0),
        east = return_base_animation(1),
        south = return_base_animation(0),
        west = return_base_animation(1),
    }

    entity.working_visualisations = {
        -- Idle animation
        {
            always_draw = true,
            animation = {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-animation-idle.png",
                priority = "extra-high",
                width = 82,
                height = 58,
                frame_count = 32,
                line_length = 8,
                shift = util.by_pixel(31, 3),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-animation-idle.png",
                    priority = "extra-high",
                    width = 166,
                    height = 117,
                    frame_count = 32,
                    line_length = 8,
                    shift = util.by_pixel_hr(62, 5),
                    scale = 0.5,
                }
            },
        },

        -- Animation
        {
            fadeout = true,
            animation = {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-animation-base.png",
                priority = "extra-high",
                width = 82,
                height = 58,
                frame_count = 64,
                line_length = 8,
                shift = util.by_pixel(31, 3),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-animation-base.png",
                    priority = "extra-high",
                    width = 166,
                    height = 117,
                    frame_count = 64,
                    line_length = 8,
                    shift = util.by_pixel_hr(62, 5),
                    scale = 0.5,
                }
            },
        },

        -- Water recipe mask
        {
            fadeout = true,
            apply_recipe_tint = "primary",
            animation = {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-animation-water-tintable.png",
                priority = "extra-high",
                width = 82,
                height = 58,
                frame_count = 64,
                line_length = 8,
                shift = util.by_pixel(31, 3),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-animation-water-tintable.png",
                    priority = "extra-high",
                    width = 166,
                    height = 117,
                    frame_count = 64,
                    line_length = 8,
                    shift = util.by_pixel_hr(62, 5),
                    scale = 0.5,
                }
            },
        },

        -- Froth recipe mask
        {
            fadeout = true,
            apply_recipe_tint = "secondary",
            animation = {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-animation-froth-tintable.png",
                priority = "extra-high",
                width = 82,
                height = 58,
                frame_count = 64,
                line_length = 8,
                shift = util.by_pixel(31, 3),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-animation-froth-tintable.png",
                    priority = "extra-high",
                    width = 166,
                    height = 117,
                    frame_count = 64,
                    line_length = 8,
                    shift = util.by_pixel_hr(62, 5),
                    scale = 0.5,
                }
            },
        },

        -- Color mask
        {
            always_draw = true,
            animation = {
                layers = {
                    -- Mask
                    {
                        filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-mask.png",
                        priority = "extra-high",
                        width = 168,
                        height = 182,
                        shift = util.by_pixel(0, 0),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-mask.png",
                            priority = "extra-high",
                            width = 333,
                            height = 363,
                            shift = util.by_pixel_hr(-1, -1),
                            tint = inputs.tint,
                            scale = 0.5,
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/ore-flotation-cell-highlights.png",
                        priority = "extra-high",
                        width = 168,
                        height = 182,
                        shift = util.by_pixel(0, 0),
                        blend_mode = reskins.lib.blend_mode,
                        hr_version = {
                            filename = reskins.angels.directory.."/graphics/entity/refining/ore-flotation-cell/hr-ore-flotation-cell-highlights.png",
                            priority = "extra-high",
                            width = 333,
                            height = 363,
                            shift = util.by_pixel_hr(-1, -1),
                            blend_mode = reskins.lib.blend_mode,
                            scale = 0.5,
                        }
                    },
                }
            }
        },

        -- Pipe cover overlays
        {
            always_draw = true,
            render_layer = "higher-object-under",
            north_animation = return_pipe_overlay(0),
            east_animation = return_pipe_overlay(1),
            south_animation = return_pipe_overlay(0),
            west_animation = return_pipe_overlay(1),
        },

        -- Vertical Pipe Shadow Patch
        {
            always_draw = true,
            north_animation = reskins.lib.vertical_pipe_shadow({0, -2}),
            south_animation = reskins.lib.vertical_pipe_shadow({0, -2}),
        },
    }

    -- Clear out pipe_pictures
    entity.fluid_boxes[1].pipe_picture = nil
    entity.fluid_boxes[2].pipe_picture = nil

    -- Maybe fix animation speed shenanigans?
    entity.match_animation_speed_to_activity = false

    -- Label to skip to next iteration
    ::continue::
end