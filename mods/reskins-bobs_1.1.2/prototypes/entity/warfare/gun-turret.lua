-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobwarfare"] then return end
if reskins.lib.setting("reskins-bobs-do-bobwarfare") == false then return end

-- Set input parameters
local inputs = {
    type = "ammo-turret",
    icon_name = "gun-turret",
    base_entity = "gun-turret",
    mod = "bobs",
    group = "warfare",
    particles = {["medium"] = 2},
}

local tier_map = {
    ["gun-turret"] = 1,
    ["bob-gun-turret-2"] = 2,
    ["bob-gun-turret-3"] = 3,
    ["bob-gun-turret-4"] = 4,
    ["bob-gun-turret-5"] = 5
}

-- Image layer functions
local function turret_extension(inputs, parameters)
    return
    {
        filename = "__base__/graphics/entity/gun-turret/gun-turret-raising.png",
        priority = "medium",
        width = 66,
        height = 64,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -26),
        axially_symmetrical = false,
        hr_version = {
            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-raising.png",
            priority = "medium",
            width = 130,
            height = 126,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -26.5),
            axially_symmetrical = false,
            scale = 0.5
        }
    }
end

local function turret_extension_tint(inputs, parameters)
    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-raising-mask.png",
        priority = "medium",
        width = 66,
        height = 64,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -26),
        tint = inputs.tint,
        axially_symmetrical = false,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-raising-mask.png",
            priority = "medium",
            width = 130,
            height = 126,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -26.5),
            tint = inputs.tint,
            axially_symmetrical = false,
            scale = 0.5
        }
    }
end

local function turret_extension_highlights(inputs, parameters)
    return
    {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-raising-highlights.png",
        priority = "medium",
        width = 66,
        height = 64,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -26),
        blend_mode = reskins.lib.blend_mode, -- "additive",
        axially_symmetrical = false,
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-raising-highlights.png",
            priority = "medium",
            width = 130,
            height = 126,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -26.5),
            blend_mode = reskins.lib.blend_mode, -- "additive",
            axially_symmetrical = false,
            scale = 0.5
        }
    }
end

local function turret_extension_mask(inputs, parameters)
    return
    {
        filename = "__base__/graphics/entity/gun-turret/gun-turret-raising-mask.png",
        inputs = { "mask" },
        width = 24,
        height = 32,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(0, -28),
        axially_symmetrical = false,
        apply_runtime_tint = true,
        hr_version = {
            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-raising-mask.png",
            inputs = { "mask" },
            width = 48,
            height = 62,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(0, -28),
            axially_symmetrical = false,
            apply_runtime_tint = true,
            scale = 0.5
        }
    }
end

local function turret_extension_shadow(inputs, parameters)
    return
    {
        filename = "__base__/graphics/entity/gun-turret/gun-turret-raising-shadow.png",
        width = 126,
        height = 62,
        direction_count = 4,
        frame_count = parameters.frame_count or 5,
        line_length = parameters.line_length or 0,
        run_mode = parameters.run_mode or "forward",
        shift = util.by_pixel(19, 2),
        axially_symmetrical = false,
        draw_as_shadow = true,
        hr_version = {
            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-raising-shadow.png",
            width = 250,
            height = 124,
            direction_count = 4,
            frame_count = parameters.frame_count or 5,
            line_length = parameters.line_length or 0,
            run_mode = parameters.run_mode or "forward",
            shift = util.by_pixel(19, 2.5),
            axially_symmetrical = false,
            draw_as_shadow = true,
            scale = 0.5
        }
    }
end

local function turret_attack(inputs, parameters)
    return
    {
        layers = {
            -- Base
            {
                width = 66,
                height = 66,
                frame_count = parameters.frame_count or 2,
                axially_symmetrical = false,
                direction_count = 64,
                shift = util.by_pixel(0, -27),
                stripes = {
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-1.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-2.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-3.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-4.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    }
                },
                hr_version = {
                    width = 132,
                    height = 130,
                    frame_count = parameters.frame_count and parameters.frame_count or 2,
                    axially_symmetrical = false,
                    direction_count = 64,
                    shift = util.by_pixel(0, -27.5),
                    stripes = {
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-1.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-2.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-3.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-4.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        }
                    },
                    scale = 0.5
                }
            },
            -- Mask
            {
                width = 66,
                height = 66,
                frame_count = parameters.frame_count or 2,
                axially_symmetrical = false,
                direction_count = 64,
                shift = util.by_pixel(0, -27),
                tint = inputs.tint,
                stripes = {
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-1-mask.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-2-mask.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-3-mask.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-4-mask.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    }
                },
                hr_version = {
                    width = 132,
                    height = 130,
                    frame_count = parameters.frame_count and parameters.frame_count or 2,
                    axially_symmetrical = false,
                    direction_count = 64,
                    shift = util.by_pixel(0, -27.5),
                    tint = inputs.tint,
                    stripes = {
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-1-mask.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-2-mask.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-3-mask.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-4-mask.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        }
                    },
                    scale = 0.5
                }
            },
            -- Highlights
            {
                width = 66,
                height = 66,
                frame_count = parameters.frame_count or 2,
                axially_symmetrical = false,
                direction_count = 64,
                shift = util.by_pixel(0, -27),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                stripes = {
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-1-highlights.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-2-highlights.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-3-highlights.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/gun-turret-shooting-4-highlights.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    }
                },
                hr_version = {
                    width = 132,
                    height = 130,
                    frame_count = parameters.frame_count and parameters.frame_count or 2,
                    axially_symmetrical = false,
                    direction_count = 64,
                    shift = util.by_pixel(0, -27.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    stripes = {
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-1-highlights.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-2-highlights.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-3-highlights.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/hr-gun-turret-shooting-4-highlights.png",
                            width_in_frames = parameters.frame_count or 2,
                            height_in_frames = 16
                        }
                    },
                    scale = 0.5
                }
            },
            -- Runtime Mask
            {
                inputs = { "mask" },
                line_length = parameters.frame_count or 2,
                width = 30,
                height = 28,
                frame_count = parameters.frame_count or 2,
                axially_symmetrical = false,
                direction_count = 64,
                shift = util.by_pixel(0, -32),
                apply_runtime_tint = true,
                stripes = {
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-1.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-2.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-3.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    },
                    {
                        filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-mask-4.png",
                        width_in_frames = parameters.frame_count or 2,
                        height_in_frames = 16
                    }
                },
                hr_version = {
                    inputs = { "mask" },
                    line_length = parameters.frame_count or 2,
                    width = 58,
                    height = 54,
                    frame_count = parameters.frame_count or 2,
                    axially_symmetrical = false,
                    direction_count = 64,
                    shift = util.by_pixel(0, -32.5),
                    apply_runtime_tint = true,
                    stripes = {
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-mask-1.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-mask-2.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-mask-3.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-mask-4.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        }
                    },
                    scale = 0.5
                }
            },
            -- Shadow
            {
                width = 126,
                height = 62,
                frame_count = parameters.frame_count and parameters.frame_count or 2,
                axially_symmetrical = false,
                direction_count = 64,
                shift = util.by_pixel(23, 2),
                draw_as_shadow = true,
                stripes = {
                    {
                    filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-1.png",
                    width_in_frames = parameters.frame_count or 2,
                    height_in_frames = 16
                    },
                    {
                    filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-2.png",
                    width_in_frames = parameters.frame_count or 2,
                    height_in_frames = 16
                    },
                    {
                    filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-3.png",
                    width_in_frames = parameters.frame_count or 2,
                    height_in_frames = 16
                    },
                    {
                    filename = "__base__/graphics/entity/gun-turret/gun-turret-shooting-shadow-4.png",
                    width_in_frames = parameters.frame_count or 2,
                    height_in_frames = 16
                    }
                },
                hr_version = {
                    width = 250,
                    height = 124,
                    frame_count = parameters.frame_count and parameters.frame_count or 2,
                    axially_symmetrical = false,
                    direction_count = 64,
                    shift = util.by_pixel(22, 2.5),
                    draw_as_shadow = true,
                    stripes = {
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-shadow-1.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-shadow-2.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-shadow-3.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        },
                        {
                            filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-shooting-shadow-4.png",
                            width_in_frames = parameters.frame_count and parameters.frame_count or 2,
                            height_in_frames = 16
                        }
                    },
                    scale = 0.5
                }
            }
        }
    }
end

-- Reskin entities, create and assign extra details
for name, tier in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet (3, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/gun-turret/remnants/gun-turret-remnants.png",
                line_length = 1,
                width = 126,
                height = 122,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(3, -1),
                hr_version = {
                    filename = "__base__/graphics/entity/gun-turret/remnants/hr-gun-turret-remnants.png",
                    line_length = 1,
                    width = 252,
                    height = 242,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(3, -1.5),
                    scale = 0.5,
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/remnants/gun-turret-remnants-mask.png",
                line_length = 1,
                width = 126,
                height = 122,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(3, -1),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/remnants/hr-gun-turret-remnants-mask.png",
                    line_length = 1,
                    width = 252,
                    height = 242,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(3, -1.5),
                    tint = inputs.tint,
                    scale = 0.5,
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/remnants/gun-turret-remnants-highlights.png",
                line_length = 1,
                width = 126,
                height = 122,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(3, -1),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/gun-turret/remnants/hr-gun-turret-remnants-highlights.png",
                    line_length = 1,
                    width = 252,
                    height = 242,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(3, -1.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5,
                }
            },
            -- Runtime Mask
            {
                priority = "low",
                filename = "__base__/graphics/entity/gun-turret/remnants/mask/gun-turret-remnants-mask.png",
                width = 34,
                height = 32,
                frame_count = 1,
                apply_runtime_tint = true,
                direction_count = 1,
                shift = util.by_pixel(-1, -11),
                hr_version = {
                    priority = "low",
                    filename = "__base__/graphics/entity/gun-turret/remnants/mask/hr-gun-turret-remnants-mask.png",
                    width = 68,
                    height = 64,
                    frame_count = 1,
                    apply_runtime_tint = true,
                    direction_count = 1,
                    shift = util.by_pixel(-1, -11),
                    scale = 0.5,
                }
            }
        }
    })

    -- Reskin entities
    entity.folded_animation = {
        layers = {
            turret_extension(inputs, {frame_count = 1, line_length = 1}),
            turret_extension_tint(inputs, {frame_count = 1, line_length = 1}),
            turret_extension_highlights(inputs, {frame_count = 1, line_length = 1}),
            turret_extension_mask(inputs, {frame_count = 1, line_length = 1}),
            turret_extension_shadow(inputs, {frame_count = 1, line_length = 1})
        }
    }
    entity.preparing_animation = {
        layers = {
            turret_extension(inputs, {}),
            turret_extension_tint(inputs, {}),
            turret_extension_highlights(inputs, {}),
            turret_extension_mask(inputs, {}),
            turret_extension_shadow(inputs, {})
        }
    }
    entity.prepared_animation = turret_attack(inputs, {frame_count = 1})
    entity.attacking_animation = turret_attack(inputs, {})
    entity.folding_animation = {
        layers = {
            turret_extension(inputs, {run_mode = "backward"}),
            turret_extension_tint(inputs, {run_mode = "backward"}),
            turret_extension_highlights(inputs, {run_mode = "backward"}),
            turret_extension_mask(inputs, {run_mode = "backward"}),
            turret_extension_shadow(inputs, {run_mode = "backward"})
        }
    }
    entity.base_picture = {
        layers = {
            {
                filename = "__base__/graphics/entity/gun-turret/gun-turret-base.png",
                priority = "high",
                width = 76,
                height = 60,
                axially_symmetrical = false,
                direction_count = 1,
                frame_count = 1,
                shift = util.by_pixel(1, -1),
                hr_version = {
                    filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base.png",
                    priority = "high",
                    width = 150,
                    height = 118,
                    axially_symmetrical = false,
                    direction_count = 1,
                    frame_count = 1,
                    shift = util.by_pixel(0.5, -1),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/gun-turret/gun-turret-base-mask.png",
                inputs = { "mask", "low-object" },
                line_length = 1,
                width = 62,
                height = 52,
                axially_symmetrical = false,
                direction_count = 1,
                frame_count = 1,
                shift = util.by_pixel(0, -4),
                apply_runtime_tint = true,
                hr_version = {
                    filename = "__base__/graphics/entity/gun-turret/hr-gun-turret-base-mask.png",
                    inputs = { "mask", "low-object" },
                    line_length = 1,
                    width = 122,
                    height = 102,
                    axially_symmetrical = false,
                    direction_count = 1,
                    frame_count = 1,
                    shift = util.by_pixel(0, -4.5),
                    apply_runtime_tint = true,
                    scale = 0.5
                }
            }
        }
    }

    if name ~= "gun-turret" then
        entity.water_reflection = util.copy(data.raw[inputs.type]["gun-turret"].water_reflection)
    end

    -- Label to skip to next iteration
    ::continue::
end