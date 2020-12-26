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
    icon_name = "gas-refinery",
    base_entity = "oil-refinery",
    mod = "angels",
    particles = {["big-tint"] = 5, ["medium"] = 2},
    group = "petrochem",
    make_remnants = false,
}

local tier_map = {
    ["gas-refinery-small"] = {tier = 1, prog_tier = 2},
    ["gas-refinery-small-2"] = {tier = 2, prog_tier = 3},
    ["gas-refinery-small-3"] = {tier = 3, prog_tier = 4},
    ["gas-refinery-small-4"] = {tier = 4, prog_tier = 5},
}

-- Create light layer for working visualisation
local refinery_lights = reskins.lib.make_4way_animation_from_spritesheet({
    filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/gas-refinery-light.png",
    priority = "high",
    width = 167,
    height = 278,
    shift = util.by_pixel(-0.5, -47),
    blend_mode = "additive-soft",
    draw_as_glow = true,
    hr_version = {
        filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/hr-gas-refinery-light.png",
        priority = "high",
        width = 334,
        height = 553,
        shift = util.by_pixel(0, -48),
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
                filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/gas-refinery-base.png",
                priority = "high",
                width = 167,
                height = 278,
                shift = util.by_pixel(-0.5, -47),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/hr-gas-refinery-base.png",
                    priority = "high",
                    width = 334,
                    height = 553,
                    shift = util.by_pixel(0, -48),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/gas-refinery-mask.png",
                priority = "high",
                width = 167,
                height = 278,
                shift = util.by_pixel(-0.5, -47),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/hr-gas-refinery-mask.png",
                    priority = "high",
                    width = 334,
                    height = 553,
                    shift = util.by_pixel(0, -48),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/gas-refinery-highlights.png",
                priority = "high",
                width = 167,
                height = 278,
                shift = util.by_pixel(-0.5, -47),
                blend_mode = reskins.lib.blend_mode,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/hr-gas-refinery-highlights.png",
                    priority = "high",
                    width = 334,
                    height = 553,
                    shift = util.by_pixel(0, -48),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5,
                }
            },
            -- Shadow
            {
                filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/gas-refinery-shadow.png",
                priority = "high",
                width = 255,
                height = 171,
                shift = util.by_pixel(44, 7),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/petrochem/gas-refinery/hr-gas-refinery-shadow.png",
                    priority = "high",
                    width = 508,
                    height = 338,
                    shift = util.by_pixel(43.5, 6.5),
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
            north_position = util.by_pixel(-57.5, -152.5),
            east_position = util.by_pixel(49.5, -189.5),
            south_position = util.by_pixel(59, -69),
            west_position = util.by_pixel(-50, -62.5),
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
                    reskins.lib.vertical_pipe_shadow({-2, -2}),
                    reskins.lib.vertical_pipe_shadow({0, -2}),
                    reskins.lib.vertical_pipe_shadow({2, -2})
                }
            },
            south_animation = {
                layers = {
                    reskins.lib.vertical_pipe_shadow({-2, 2}),
                    reskins.lib.vertical_pipe_shadow({0, 2}),
                    reskins.lib.vertical_pipe_shadow({2, 2})
                }
            }
        },
    }

    -- Fix drawing box
    entity.drawing_box = {{-2.5, -5.75}, {2.5, 2.5}}

    -- Label to skip to next iteration
    ::continue::
end