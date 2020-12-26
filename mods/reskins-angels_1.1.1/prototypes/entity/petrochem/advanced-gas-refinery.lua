-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["angelspetrochem"] then return end
if reskins.lib.setting("reskins-angels-do-angelspetrochem") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "advanced-gas-refinery",
    base_entity = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "petrochem",
    make_remnants = false,
}

local tier_map = {
    ["gas-refinery"] = {tier = 1, prog_tier = 3},
    ["gas-refinery-2"] = {tier = 2, prog_tier = 4},
    ["gas-refinery-3"] = {tier = 3, prog_tier = 5},
    ["gas-refinery-4"] = {tier = 4, prog_tier = 6},
}

-- Create light layer for working visualisation
local refinery_lights = reskins.lib.make_4way_animation_from_spritesheet({
    filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/advanced-gas-refinery-light.png",
    priority = "high",
    width = 232,
    height = 330,
    shift = util.by_pixel(0, -41),
    blend_mode = "additive-soft",
    draw_as_glow = true,
    hr_version = {
        filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/hr-advanced-gas-refinery-light.png",
        priority = "high",
        width = 462,
        height = 657,
        shift = util.by_pixel(0, -42),
        blend_mode = "additive-soft",
        draw_as_glow = true,
        scale = 0.5,
    }
})

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
    inputs.tint = map.tint or reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/advanced-gas-refinery-base.png",
                priority = "high",
                width = 232,
                height = 330,
                shift = util.by_pixel(0, -41),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/hr-advanced-gas-refinery-base.png",
                    priority = "high",
                    width = 462,
                    height = 657,
                    shift = util.by_pixel(0, -42),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/advanced-gas-refinery-mask.png",
                priority = "high",
                width = 232,
                height = 330,
                shift = util.by_pixel(0, -41),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/hr-advanced-gas-refinery-mask.png",
                    priority = "high",
                    width = 462,
                    height = 657,
                    shift = util.by_pixel(0, -42),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/advanced-gas-refinery-highlights.png",
                priority = "high",
                width = 232,
                height = 330,
                shift = util.by_pixel(0, -41),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/hr-advanced-gas-refinery-highlights.png",
                    priority = "high",
                    width = 462,
                    height = 657,
                    shift = util.by_pixel(0, -42),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow
            -- ATTN Lovely Santa: These sprites are vertically oriented, so you'll need to either hard-code the vertical offsets, or adapt
            -- the make_4way_animation_from_spritesheet function as done in reskins-library to process vertically oriented spritesheets.
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/advanced-gas-refinery-shadow.png",
                priority = "high",
                vertically_oriented = true, -- This is a custom parameter used by function reskins.lib.make_4way_animation_from_spritesheet
                width = 328,
                height = 229,
                shift = util.by_pixel(48, 9),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/advanced-gas-refinery/hr-advanced-gas-refinery-shadow.png",
                    priority = "high",
                    vertically_oriented = true, -- This is a custom parameter used by function reskins.lib.make_4way_animation_from_spritesheet
                    width = 655,
                    height = 454,
                    shift = util.by_pixel(48.5, 9.5),
                    draw_as_shadow = true,
                    scale = 0.5,
                }
            },
        }
    })

    entity.working_visualisations = {
        -- Flame
        {
            fadeout = true,
            constant_speed = true,
            north_position = util.by_pixel(-89, -136.5),
            east_position = util.by_pixel(34.5, -207.5),
            south_position = util.by_pixel(90.5, -94),
            west_position = util.by_pixel(-16, -35),
            animation = {
                filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
                line_length = 10,
                width = 20,
                height = 40,
                frame_count = 60,
                animation_speed = 0.75,
                draw_as_glow = true,
                hr_version = {
                    filename = "__base__/graphics/entity/oil-refinery/hr-oil-refinery-fire.png",
                    line_length = 10,
                    width = 40,
                    height = 81,
                    frame_count = 60,
                    animation_speed = 0.75,
                    draw_as_glow = true,
                    scale = 0.5,
                },
            },
        },

        -- Light
        {
            fadeout = true,
            north_animation = refinery_lights.north,
            east_animation = refinery_lights.east,
            south_animation = refinery_lights.south,
            west_animation = refinery_lights.west,
        },

        -- Vertical Pipe Shadow Patch
        {
            always_draw = true,
            north_animation = {
                layers = {
                    reskins.lib.vertical_pipe_shadow({-1, -3}),
                    reskins.lib.vertical_pipe_shadow({3, -3}),
                }
            },
            south_animation = {
                layers = {
                    reskins.lib.vertical_pipe_shadow({-3, 3}),
                    reskins.lib.vertical_pipe_shadow({-1, 3}),
                    reskins.lib.vertical_pipe_shadow({1, 3})
                }
            }
        },
    }

    -- Fix drawing box
    entity.drawing_box = {{-3.5, -6.5}, {3.5, 3.5}}

    -- Label to skip to next iteration
    ::continue::
end