-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["classic-beacon"] then return end
if not mods["bobmodules"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmodules") == false then return end

-- Set input parameters
local inputs = {
    type = "beacon",
    icon_name = "beacon",
    base_entity = "beacon",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "compatibility",
    subgroup = "classic-beacon",
    particles = {["small"] = 3},
    make_remnants = false,
}

local tier_map = {
    ["beacon"] = {1, 3},
    ["beacon-2"] = {2, 4},
    ["beacon-3"] = {3, 5},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Fix order shenanigans
    if name == "beacon" then
        data.raw["item"][name].order = "a[beacon]-1"
        entity.order = "z-a[beacon]-1"
    end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.corpse = "medium-remnants"
    entity.graphics_set = {
        module_icons_suppressed = false,

        animation_list = {
            -- Beacon Base
            {
                render_layer = "lower-object-above-shadow",
                always_draw = true,
                animation = {
                    layers = {
                        -- Base
                        {
                            filename = "__classic-beacon__/graphics/entity/beacon/beacon-base.png",
                            width = 116,
                            height = 93,
                            shift = util.by_pixel(11, 1.5),
                        },
                        -- Mask
                        {
                            filename = inputs.directory.."/graphics/entity/compatibility/classic-beacon/beacon/beacon-mask.png",
                            width = 116,
                            height = 93,
                            shift = util.by_pixel(11, 1.5),
                            tint = inputs.tint,
                        },
                        -- Highlights
                        {
                            filename = inputs.directory.."/graphics/entity/compatibility/classic-beacon/beacon/beacon-highlights.png",
                            width = 116,
                            height = 93,
                            shift = util.by_pixel(11, 1.5),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                        },
                        -- Shadow
                        {
                            filename = "__classic-beacon__/graphics/entity/beacon/beacon-base-shadow.png",
                            width = 116,
                            height = 93,
                            shift = util.by_pixel(11, 1.5),
                            draw_as_shadow = true,
                        }
                    }
                }
            },
            -- Beacon Antenna
            {
                render_layer = "object",
                always_draw = true,
                animation = {
                    layers = {
                        -- Base
                        {
                            filename = "__classic-beacon__/graphics/entity/beacon/beacon-antenna.png",
                            width = 54,
                            height = 50,
                            line_length = 8,
                            frame_count = 32,
                            animation_speed = 0.5,
                            shift = util.by_pixel(-1, -55),
                        },
                        -- Shadow
                        {
                            filename = "__classic-beacon__/graphics/entity/beacon/beacon-antenna-shadow.png",
                            width = 63,
                            height = 49,
                            line_length = 8,
                            frame_count = 32,
                            animation_speed = 0.5,
                            shift = util.by_pixel(100.5, 15.5),
                            draw_as_shadow = true,
                        }
                    }
                }
            }
        }
    }

    if reskins.lib.setting("classic-beacon-do-high-res") == true then
        -- Beacon Base
        entity.graphics_set.animation_list[1].animation.layers[1].hr_version = {
            filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-base.png",
            width = 232,
            height = 186,
            shift = util.by_pixel(11, 1.5),
            scale = 0.5,
        }
        -- Beacon Mask
        entity.graphics_set.animation_list[1].animation.layers[2].hr_version = {
            filename = inputs.directory.."/graphics/entity/compatibility/classic-beacon/beacon/hr-beacon-mask.png",
            width = 232,
            height = 186,
            shift = util.by_pixel(11, 1.5),
            tint = inputs.tint,
            scale = 0.5,
        }
        -- Beacon Highlights
        entity.graphics_set.animation_list[1].animation.layers[3].hr_version = {
            filename = inputs.directory.."/graphics/entity/compatibility/classic-beacon/beacon/hr-beacon-highlights.png",
            width = 232,
            height = 186,
            shift = util.by_pixel(11, 1.5),
            blend_mode = reskins.lib.blend_mode, -- "additive",
            scale = 0.5,
        }
        -- Beacon Base Shadow
        entity.graphics_set.animation_list[1].animation.layers[4].hr_version = {
            filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-base-shadow.png",
            width = 232,
            height = 186,
            shift = util.by_pixel(11, 1.5),
            draw_as_shadow = true,
            scale = 0.5,
        }
        -- Beacon Antenna Base
        entity.graphics_set.animation_list[2].animation.layers[1].hr_version = {
            filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-antenna.png",
            width = 108,
            height = 100,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(-1, -55),
            scale = 0.5,
        }
        -- Beacon Antenna Shadow
        entity.graphics_set.animation_list[2].animation.layers[2].hr_version = {
            filename = "__classic-beacon__/graphics/entity/beacon/hr-beacon-antenna-shadow.png",
            width = 126,
            height = 98,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(100.5, 15.5),
            draw_as_shadow = true,
            scale = 0.5,
        }
    end

    entity.water_reflection = {
        pictures = {
            filename = "__classic-beacon__/graphics/entity/beacon/beacon-reflection.png",
            priority = "extra-high",
            width = 24,
            height = 28,
            shift = util.by_pixel(0, 55),
            variation_count = 1,
            scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
    }

    -- Label to skip to next iteration
    ::continue::
end