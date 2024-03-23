-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then return end

-- Set input parameters
local inputs = {
    type = "unit",
    icon_name = "drone",
    base_entity_name = "tank",
    mod = "bobs",
    group = "warfare",
    particles = {["medium"] = 2},
}

---Expands a single frame into an n-by-m stripes table
---@param filename string [Types/FileName](https://wiki.factorio.com/Types/FileName)
---@param n integer
---@param m? integer
---@return table stripes #Table of [Types/Stripe](https://wiki.factorio.com/Types/Stripe)
local function expand_to_stripes(filename, n, m)
    local m = m or 1
    local stripe = {filename = filename, width_in_frames = 1, height_in_frames = 1}
    local stripes = {}

    for i = 1, n do
        stripes[i] = stripe
    end

    if m >= 2 then
        stripes = util.multiplystripes(m, stripes)
    end

    return stripes
end

---Returns an appropriately scaled and tinted robot drone unit sprite definition
---@param scale number
---@param tint table #[Types/Color](https://wiki.factorio.com/Types/Color)
---@return table #[Types/RotatedAnimation](https://wiki.factorio.com/Types/RotatedAnimation)
local function build_drone_animation(scale, tint)
    local make_hr_version = true
    if scale <= 0.5 then make_hr_version = nil end -- At 0.5 and below, the normal resolution sprites are equivalent to hr sprites

    local animation_speed = 8

    local animation = {
        layers = {
            -- Base
            {
                width = 136,
                height = 106,
                frame_count = 2,
                direction_count = 64,
                shift = util.by_pixel(0, -10),
                animation_speed = animation_speed,
                max_advance = 1,
                stripes = {
                    { filename = "__base__/graphics/entity/tank/tank-base-1.png", width_in_frames = 2, height_in_frames = 16 },
                    { filename = "__base__/graphics/entity/tank/tank-base-2.png", width_in_frames = 2, height_in_frames = 16 },
                    { filename = "__base__/graphics/entity/tank/tank-base-3.png", width_in_frames = 2, height_in_frames = 16 },
                    { filename = "__base__/graphics/entity/tank/tank-base-4.png", width_in_frames = 2, height_in_frames = 16 },
                },
                hr_version = make_hr_version and {
                    width = 270,
                    height = 212,
                    frame_count = 2,
                    direction_count = 64,
                    shift = util.by_pixel(0, -10),
                    animation_speed = animation_speed,
                    max_advance = 1,
                    stripes = {
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-1.png", width_in_frames = 2, height_in_frames = 16 },
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-2.png", width_in_frames = 2, height_in_frames = 16 },
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-3.png", width_in_frames = 2, height_in_frames = 16 },
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-4.png", width_in_frames = 2, height_in_frames = 16 },
                    },
                    scale = 0.5,
                }
            },

            -- Mask
            {
                width = 136,
                height = 106,
                frame_count = 2,
                direction_count = 64,
                shift = util.by_pixel(0, -10),
                max_advance = 1,
                -- line_length = 2,
                tint = tint,
                stripes = util.multiplystripes(2, {
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-mask_01.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-mask_02.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-mask_03.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-mask_04.png", width_in_frames = 1, height_in_frames = 16 },
                }),
                hr_version = make_hr_version and {
                    width = 270,
                    height = 212,
                    frame_count = 2,
                    direction_count = 64,
                    shift = util.by_pixel(0, -10),
                    max_advance = 1,
                    -- line_length = 2,
                    tint = tint,
                    stripes = util.multiplystripes(2, {
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-mask_01.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-mask_02.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-mask_03.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-mask_04.png", width_in_frames = 1, height_in_frames = 16 },
                    }),
                    scale = 0.5,
                }
            },

            -- Highlights
            {
                width = 136,
                height = 106,
                frame_count = 2,
                direction_count = 64,
                shift = util.by_pixel(0, -10),
                max_advance = 1,
                -- line_length = 2,
                blend_mode = reskins.lib.blend_mode,
                stripes = util.multiplystripes(2, {
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-highlights_01.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-highlights_02.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-highlights_03.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-highlights_04.png", width_in_frames = 1, height_in_frames = 16 }
                }),
                hr_version = make_hr_version and {
                    width = 270,
                    height = 212,
                    frame_count = 2,
                    direction_count = 64,
                    shift = util.by_pixel(0, -10),
                    max_advance = 1,
                    -- line_length = 2,
                    blend_mode = reskins.lib.blend_mode,
                    stripes = util.multiplystripes(2, {
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-highlights_01.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-highlights_02.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-highlights_03.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-highlights_04.png", width_in_frames = 1, height_in_frames = 16 },
                    }),
                    scale = 0.5,
                }
            },

            -- Drone Top
            {
                stripes = expand_to_stripes(reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-top.png", 64, 2),
                width = 49,
                height = 83,
                frame_count = 2,
                direction_count = 64,
                shift = util.by_pixel(0, -10),
                max_advance = 1,
                -- line_length = 2,
                hr_version = make_hr_version and {
                    stripes = expand_to_stripes(reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-top.png", 64, 2),
                    width = 98,
                    height = 166,
                    frame_count = 2,
                    direction_count = 64,
                    shift = util.by_pixel(0, -10),
                    max_advance = 1,
                    -- line_length = 2,
                    scale = 0.5,
                }
            },

            -- Drone Light
            {
                stripes = expand_to_stripes(reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-top-light.png", 64, 2),
                width = 49,
                height = 83,
                frame_count = 2,
                direction_count = 64,
                shift = util.by_pixel(0, -10),
                tint = tint,
                draw_as_glow = true,
                max_advance = 1,
                -- line_length = 2,
                hr_version = make_hr_version and {
                    stripes = expand_to_stripes(reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-top-light.png", 64, 2),
                    width = 98,
                    height = 166,
                    frame_count = 2,
                    direction_count = 64,
                    shift = util.by_pixel(0, -10),
                    tint = tint,
                    draw_as_glow = true,
                    max_advance = 1,
                    -- line_length = 2,
                    scale = 0.5,
                }
            },

            -- Drone Light Core
            {
                stripes = expand_to_stripes(reskins.bobs.directory.."/graphics/entity/warfare/drone/drone-top-light-core.png", 64, 2),
                width = 49,
                height = 83,
                frame_count = 2,
                direction_count = 64,
                shift = util.by_pixel(0, -10),
                draw_as_glow = true,
                blend_mode = "additive-soft",
                max_advance = 1,
                -- line_length = 2,
                hr_version = make_hr_version and {
                    stripes = expand_to_stripes(reskins.bobs.directory.."/graphics/entity/warfare/drone/hr-drone-top-light-core.png", 64, 2),
                    width = 98,
                    height = 166,
                    frame_count = 2,
                    direction_count = 64,
                    shift = util.by_pixel(0, -10),
                    draw_as_glow = true,
                    blend_mode = "additive-soft",
                    max_advance = 1,
                    -- line_length = 2,
                    scale = 0.5,
                }
            },

            -- Shadow
            {
                width = 151,
                height = 98,
                frame_count = 2,
                draw_as_shadow = true,
                direction_count = 64,
                shift = util.by_pixel(22.5, 7),
                max_advance = 1,
                stripes = util.multiplystripes(2, {
                    { filename = "__base__/graphics/entity/tank/tank-base-shadow-1.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = "__base__/graphics/entity/tank/tank-base-shadow-2.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = "__base__/graphics/entity/tank/tank-base-shadow-3.png", width_in_frames = 1, height_in_frames = 16 },
                    { filename = "__base__/graphics/entity/tank/tank-base-shadow-4.png", width_in_frames = 1, height_in_frames = 16 },
                }),
                hr_version = make_hr_version and {
                    width = 302,
                    height = 194,
                    frame_count = 2,
                    draw_as_shadow = true,
                    direction_count = 64,
                    shift = util.by_pixel(22.5, 7),
                    max_advance = 1,
                    stripes = util.multiplystripes(2, {
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-shadow-1.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-shadow-2.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-shadow-3.png", width_in_frames = 1, height_in_frames = 16 },
                        { filename = "__base__/graphics/entity/tank/hr-tank-base-shadow-4.png", width_in_frames = 1, height_in_frames = 16 },
                    }),
                scale = 0.5,
                }
            }
        }
    }

    reskins.lib.rescale_entity(animation, scale)

    return animation
end

---Returns an appropriately scaled and tinted robot drone corpse sprite definition
---@param scale number
---@param tint table #[Types/Color](https://wiki.factorio.com/Types/Color)
---@return table #[Types/RotatedAnimation](https://wiki.factorio.com/Types/RotatedAnimation)
local function build_drone_remnants(scale, tint)
    local make_hr_version = true
    if scale <= 0.5 then make_hr_version = nil end -- At 0.5 and below, the normal resolution sprites are equivalent to hr sprites

    local animation = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/remnants/drone-remnants.png",
                line_length = 1,
                width = 207,
                height = 190,
                frame_count = 1,
                direction_count = 4,
                shift = util.by_pixel(4, 0.5),
                hr_version = make_hr_version and {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/remnants/hr-drone-remnants.png",
                    line_length = 1,
                    width = 414,
                    height = 380,
                    frame_count = 1,
                    direction_count = 4,
                    shift = util.by_pixel(4, 0.5),
                    scale = 0.5
                }
            },

            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/remnants/drone-remnants-mask.png",
                line_length = 1,
                width = 207,
                height = 190,
                frame_count = 1,
                direction_count = 4,
                shift = util.by_pixel(4, 0.5),
                tint = tint,
                hr_version = make_hr_version and {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/remnants/hr-drone-remnants-mask.png",
                    line_length = 1,
                    width = 414,
                    height = 380,
                    frame_count = 1,
                    direction_count = 4,
                    shift = util.by_pixel(4, 0.5),
                    tint = tint,
                    scale = 0.5
                }
            },

            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/remnants/drone-remnants-highlights.png",
                line_length = 1,
                width = 207,
                height = 190,
                frame_count = 1,
                direction_count = 4,
                shift = util.by_pixel(4, 0.5),
                blend_mode = reskins.lib.blend_mode,
                hr_version = make_hr_version and {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/drone/remnants/hr-drone-remnants-highlights.png",
                    line_length = 1,
                    width = 414,
                    height = 380,
                    frame_count = 1,
                    direction_count = 4,
                    shift = util.by_pixel(4, 0.5),
                    blend_mode = reskins.lib.blend_mode,
                    scale = 0.5
                }
            },
        }
    }

    reskins.lib.rescale_entity(animation, scale)

    return animation
end

local drones = {
    ["gun-drone"] = {tint = util.color("f2f230"), scale = 0.5, rotation_speed = 0.015, attack_parameters = {projectile_center = {0, 5}, projectile_creation_distance = 0.2}}, -- Yellow tint, sat 80%
    ["laser-drone"] = {tint = util.color("30f271"), scale = 0.5, rotation_speed = 0.015, attack_parameters = {source_offset = {0, -0.5}}}, -- Green/teal
    ["flamethrower-drone"] = {tint = util.color("f25730"), scale = 0.5, rotation_speed = 0.015, attack_parameters = {gun_center_shift = {0, -0.5}}}, -- Orange
    ["plasma-drone"] = {tint = util.color("30a5f2"), scale = 0.75, rotation_speed = 0.007, attack_parameters = {projectile_center = {0, -0.5}, projectile_creation_distance = 0}},
}

-- Reskin entities, create and assign extra details
for drone, map in pairs(drones) do
    -- Fetch entity
    local name = "bob-robot-"..drone
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = map.tint

    reskins.lib.setup_standard_entity(name, 0, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = build_drone_remnants(map.scale, map.tint)

    -- Reskin entity
    entity.attack_parameters = util.merge({entity.attack_parameters, map.attack_parameters})
    entity.attack_parameters.animation = build_drone_animation(map.scale, map.tint)
    entity.run_animation = build_drone_animation(map.scale, map.tint)
    entity.rotation_speed = map.rotation_speed

    -- Label to skip to next iteration
    ::continue::
end
