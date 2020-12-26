-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["classic-mining-drill"] then return end
if not mods["bobmining"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmining") == false then return end

-- Set input parameters
local inputs = {
    type = "mining-drill",
    icon_name = "electric-mining-drill",
    base_entity = "electric-mining-drill",
    mod = "bobs",
    group = "compatibility",
    subgroup = "classic-mining-drill",
    particles = {["medium-long"] = 3},
    make_remnants = false,
}

local tier_map = {
    ["electric-mining-drill"] = {1, 1},
    ["bob-mining-drill-1"] = {2, 2},
    ["bob-mining-drill-2"] = {3, 3},
    ["bob-mining-drill-3"] = {4, 4},
    ["bob-mining-drill-4"] = {5, 5},
    ["bob-area-mining-drill-1"] = {1, 2},
    ["bob-area-mining-drill-2"] = {2, 3},
    ["bob-area-mining-drill-3"] = {3, 4},
    ["bob-area-mining-drill-4"] = {4, 5},
}

-- Iterate through an object and edit every animation_speed; function from Bobmeister
local function set_animation_speed(object, animation_speed)
    if object.animation_speed then
        object.animation_speed = animation_speed
    end
    for index, value in pairs(object) do
        if type(value) == "table" then
            set_animation_speed(value, animation_speed)
        end
    end
end

-- Animations
local function drill_animations(inputs)
    return
    {
        north = {
            layers = {
                -- Base
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-N.png",
                    line_length = 8,
                    width = 98,
                    height = 113,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(0, -8.5),
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-N.png",
                        line_length = 8,
                        width = 196,
                        height = 226,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(0, -8),
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-N-mask.png",
                    line_length = 8,
                    width = 98,
                    height = 113,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(0, -8.5),
                    run_mode = "forward-then-backward",
                    tint = inputs.tint,
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-N-mask.png",
                        line_length = 8,
                        width = 196,
                        height = 226,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(0, -8),
                        run_mode = "forward-then-backward",
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-N-highlights.png",
                    line_length = 8,
                    width = 98,
                    height = 113,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(0, -8.5),
                    run_mode = "forward-then-backward",
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-N-highlights.png",
                        line_length = 8,
                        width = 196,
                        height = 226,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(0, -8),
                        run_mode = "forward-then-backward",
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-N-drill-shadow.png",
                    flags = { "shadow" },
                    line_length = 8,
                    width = 101,
                    height = 111,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(1.5, -7.5),
                    draw_as_shadow = true,
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-N-drill-shadow.png",
                        flags = { "shadow" },
                        line_length = 8,
                        width = 201,
                        height = 223,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(1.25, -7.25),
                        draw_as_shadow = true,
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                }
            }
        },
        east = {
            layers = {
                -- Base
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-E.png",
                    line_length = 8,
                    width = 105,
                    height = 98,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(3.5, -1),
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-E.png",
                        line_length = 8,
                        width = 211,
                        height = 197,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(3.75, -1.25),
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-E-mask.png",
                    line_length = 8,
                    width = 105,
                    height = 98,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(3.5, -1),
                    tint = inputs.tint,
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-E-mask.png",
                        line_length = 8,
                        width = 211,
                        height = 197,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(3.75, -1.25),
                        tint = inputs.tint,
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-E-highlights.png",
                    line_length = 8,
                    width = 105,
                    height = 98,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(3.5, -1),
                    run_mode = "forward-then-backward",
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-E-highlights.png",
                        line_length = 8,
                        width = 211,
                        height = 197,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(3.75, -1.25),
                        run_mode = "forward-then-backward",
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-E-drill-shadow.png",
                    flags = { "shadow" },
                    line_length = 8,
                    width = 110,
                    height = 97,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(6, -0.5),
                    draw_as_shadow = true,
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-E-drill-shadow.png",
                        flags = { "shadow" },
                        line_length = 8,
                        width = 221,
                        height = 195,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(6.25, -0.25),
                        draw_as_shadow = true,
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                }
            }
        },
        south = {
            layers = {
                -- Base
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-S.png",
                    line_length = 8,
                    width = 98,
                    height = 109,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(0, -1.5),
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-S.png",
                        line_length = 8,
                        width = 196,
                        height = 219,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(0, -1.25),
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-S-mask.png",
                    line_length = 8,
                    width = 98,
                    height = 109,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(0, -1.5),
                    run_mode = "forward-then-backward",
                    tint = inputs.tint,
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-S-mask.png",
                        line_length = 8,
                        width = 196,
                        height = 219,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(0, -1.25),
                        run_mode = "forward-then-backward",
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-S-highlights.png",
                    line_length = 8,
                    width = 98,
                    height = 109,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(0, -1.5),
                    run_mode = "forward-then-backward",
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-S-highlights.png",
                        line_length = 8,
                        width = 196,
                        height = 219,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(0, -1.25),
                        run_mode = "forward-then-backward",
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-S-drill-shadow.png",
                    flags = { "shadow" },
                    line_length = 8,
                    width = 100,
                    height = 103,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(1, 2.5),
                    draw_as_shadow = true,
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-S-drill-shadow.png",
                        flags = { "shadow" },
                        line_length = 8,
                        width = 200,
                        height = 206,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(1, 2.5),
                        draw_as_shadow = true,
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                }
            }
        },
        west = {
            layers = {
                -- Base
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-W.png",
                    line_length = 8,
                    width = 105,
                    height = 98,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(-3.5, -1),
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-W.png",
                        line_length = 8,
                        width = 211,
                        height = 197,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(-3.75, -0.75),
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-W-mask.png",
                    line_length = 8,
                    width = 105,
                    height = 98,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(-3.5, -1),
                    run_mode = "forward-then-backward",
                    tint = inputs.tint,
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-W-mask.png",
                        line_length = 8,
                        width = 211,
                        height = 197,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(-3.75, -0.75),
                        run_mode = "forward-then-backward",
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    priority = "high",
                    filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//mining-drill-W-highlights.png",
                    line_length = 8,
                    width = 105,
                    height = 98,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(-3.5, -1),
                    run_mode = "forward-then-backward",
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        priority = "high",
                        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill//hr-mining-drill-W-highlights.png",
                        line_length = 8,
                        width = 211,
                        height = 197,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(-3.75, -0.75),
                        run_mode = "forward-then-backward",
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                {
                    priority = "high",
                    filename = "__classic-mining-drill__/graphics/entity/mining-drill/electric-mining-drill-W-drill-shadow.png",
                    flags = { "shadow" },
                    line_length = 8,
                    width = 114,
                    height = 97,
                    frame_count = 64,
                    animation_speed = 0.5,
                    direction_count = 1,
                    shift = util.by_pixel(1, -0.5),
                    draw_as_shadow = true,
                    run_mode = "forward-then-backward",
                    hr_version = {
                        priority = "high",
                        filename = "__classic-mining-drill__/graphics/entity/mining-drill/hr-electric-mining-drill-W-drill-shadow.png",
                        flags = { "shadow" },
                        line_length = 8,
                        width = 229,
                        height = 195,
                        frame_count = 64,
                        animation_speed = 0.5,
                        direction_count = 1,
                        shift = util.by_pixel(1.25, -0.25),
                        draw_as_shadow = true,
                        run_mode = "forward-then-backward",
                        scale = 0.5
                    }
                }
            }
        }
    }
end

local area_drill_animations = {
    north = {
        priority = "high",
        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/area-drill-N.png",
        line_length = 8,
        width = 98,
        height = 113,
        frame_count = 64,
        animation_speed = 0.5,
        direction_count = 1,
        shift = util.by_pixel(0, -8.5),
        run_mode = "forward-then-backward",
        hr_version = {
            priority = "high",
            filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/hr-area-drill-N.png",
            line_length = 8,
            width = 196,
            height = 226,
            frame_count = 64,
            animation_speed = 0.5,
            direction_count = 1,
            shift = util.by_pixel(0, -8),
            run_mode = "forward-then-backward",
            scale = 0.5
        }
    },
    east = {
        priority = "high",
        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/area-drill-E.png",
        line_length = 8,
        width = 105,
        height = 98,
        frame_count = 64,
        animation_speed = 0.5,
        direction_count = 1,
        shift = util.by_pixel(3.5, -1),
        run_mode = "forward-then-backward",
        hr_version = {
            priority = "high",
            filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/hr-area-drill-E.png",
            line_length = 8,
            width = 211,
            height = 197,
            frame_count = 64,
            animation_speed = 0.5,
            direction_count = 1,
            shift = util.by_pixel(3.75, -1.25),
            run_mode = "forward-then-backward",
            scale = 0.5
        }
    },
    south = {
        priority = "high",
        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/area-drill-S.png",
        line_length = 8,
        width = 98,
        height = 109,
        frame_count = 64,
        animation_speed = 0.5,
        direction_count = 1,
        shift = util.by_pixel(0, -1.5),
        run_mode = "forward-then-backward",
        hr_version = {
            priority = "high",
            filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/hr-area-drill-S.png",
            line_length = 8,
            width = 196,
            height = 219,
            frame_count = 64,
            animation_speed = 0.5,
            direction_count = 1,
            shift = util.by_pixel(0, -1.25),
            run_mode = "forward-then-backward",
            scale = 0.5
        }
    },
    west = {
        priority = "high",
        filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/area-drill-W.png",
        line_length = 8,
        width = 105,
        height = 98,
        frame_count = 64,
        animation_speed = 0.5,
        direction_count = 1,
        shift = util.by_pixel(-3.5, -1),
        run_mode = "forward-then-backward",
        hr_version = {
            priority = "high",
            filename = reskins.bobs.directory.."/graphics/entity/compatibility/classic-mining-drill/electric-mining-drill/area-end/hr-area-drill-W.png",
            line_length = 8,
            width = 211,
            height = 197,
            frame_count = 64,
            animation_speed = 0.5,
            direction_count = 1,
            shift = util.by_pixel(-3.75, -0.75),
            run_mode = "forward-then-backward",
            scale = 0.5
        }
    }
}

-- Rescale mining drill animation playback speed to something visually appealing
local max_playback = 2   -- Maximum animation playback speed
local min_playback = 0.5 -- Minimum animation playback speed

local mining_speeds = {}
local index = 1

-- Loop through all the drills, figure out the mining speeds
for name, tier in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Fetch mining speed
    mining_speeds[index] = data.raw[inputs.type][name].mining_speed
    index = index + 1

    -- Label to skip to next iteration
    ::continue::
end

-- Determine max and min mining speeds
table.sort(mining_speeds)
local max_speed = mining_speeds[#mining_speeds]
local min_speed = mining_speeds[1]

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    -- Handle icon base
    if string.find(name, "area") then
        inputs.icon_base = "large-area-electric-mining-drill"
         inputs.icon_extras = {
            -- Type indicator
            {
                icon = reskins.bobs.directory.."/graphics/icons/mining/electric-mining-drill/area-drill-symbol.png"
            },
            {
                icon = reskins.bobs.directory.."/graphics/icons/mining/electric-mining-drill/area-drill-symbol.png",
                tint = reskins.lib.adjust_alpha(reskins.lib.tint_index["tier-"..tier], 0.75)
            }
        }
    else
        inputs.icon_base = "electric-mining-drill"
        inputs.icon_extras = nil
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Calculate new animation playback speed
    local playback_speed
    if max_speed - min_speed == 0 then
        playback_speed = entity.mining_speed
    else
        playback_speed = ((entity.mining_speed/(max_speed-min_speed)) - (min_speed/(max_speed-min_speed)))*max_playback
                          + ((max_speed/(max_speed-min_speed)) - (entity.mining_speed/(max_speed-min_speed)))*min_playback
    end

    -- Reskin entities
    entity.graphics_set.animation = drill_animations(inputs)
    entity.wet_mining_graphics_set.animation = drill_animations(inputs)

    -- Reskin the ore output when working with area drills
    if string.find(name, "area") then
        table.insert(entity.graphics_set.animation.north.layers, 2, area_drill_animations.north)
        table.insert(entity.graphics_set.animation.east.layers, 2, area_drill_animations.east)
        table.insert(entity.graphics_set.animation.south.layers, 2, area_drill_animations.south)
        table.insert(entity.graphics_set.animation.west.layers, 2, area_drill_animations.west)

        table.insert(entity.wet_mining_graphics_set.animation.north.layers, 2, area_drill_animations.north)
        table.insert(entity.wet_mining_graphics_set.animation.east.layers, 2, area_drill_animations.east)
        table.insert(entity.wet_mining_graphics_set.animation.south.layers, 2, area_drill_animations.south)
        table.insert(entity.wet_mining_graphics_set.animation.west.layers, 2, area_drill_animations.west)
    end

    -- Set animation speed for each drill
    set_animation_speed(entity, playback_speed)

    -- Label to skip to next iteration
    ::continue::
end