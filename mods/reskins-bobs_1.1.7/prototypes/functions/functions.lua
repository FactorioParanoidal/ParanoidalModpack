-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Add this mod to the reskins function host.
reskins.bobs.directory = "__reskins-bobs__"

-- CONSTANTS
reskins.bobs.module_color_map = {
    ["blue"] = {primary = util.color("70b6ff"), secondary = util.color("30d2ff")},
    ["brown"] = {primary = util.color("9c7c60"), secondary = util.color("fff0d9")},
    ["cyan"] = {primary = util.color("70f1ff"), secondary = util.color("30ffd2")},
    ["deep-red"] = {primary = util.color("cb302a"), secondary = util.color("ff7a66")},
    ["gray"] = {primary = util.color("b7b7b7"), secondary = util.color("d5d5d5")},
    ["green"] = {primary = util.color("95e26c"), secondary = util.color("2bff2b")},
    ["orange"] = {primary = util.color("ffa345"), secondary = util.color("ffbf96")},
    ["pine"] = {primary = util.color("7a9e96"), secondary = util.color("bfffd2")},
    ["pink"] = {primary = util.color("f96bcd"), secondary = util.color("ffbfe9")},
    ["purple"] = {primary = util.color("9c70ff"), secondary = util.color("ac6eff")},
    ["red"] = {primary = util.color("f27c52"), secondary = util.color("ff9999")},
    ["vanilla-red"] = {primary = util.color("f27c52"), secondary = util.color("ffe27c")},
    ["yellow"] = {primary = util.color("ffdd45"), secondary = util.color("ffed66")},
}

-- ROBOT PARTICLE AND DEATH ANIMATIONS
local function adjust_animation(animation, shift)

    local animation = util.copy(animation)
    local layers = animation.layers or {animation}

    for k, layer in pairs (layers) do

        layer.frame_count = layer.direction_count
        layer.direction_count = 0
        layer.animation_speed = 1
        layer.shift = util.add_shift(layer.shift, shift)

        if layer.hr_version then
            layer.hr_version.frame_count = layer.hr_version.direction_count
            layer.hr_version.direction_count = 0
            layer.hr_version.animation_speed = 1
            layer.hr_version.shift = util.add_shift(layer.hr_version.shift, shift)
        end

    end

    return animation
end

local function reverse_animation(animation)
    local animation = util.copy(animation)
    local layers = animation.layers or {animation}

    for k, layer in pairs (layers) do
        layer.run_mode = "backward"
        if layer.hr_version then
            layer.hr_version.run_mode = "backward"
        end
    end

    return animation
end

function reskins.bobs.make_robot_particle(prototype)
    local shadow_shift = {-0.75, -0.40}
    local animation_shift = {0, 0}

    local particle_name = prototype.name.."-dying-particle"

    local animation = adjust_animation(prototype.in_motion, animation_shift)
    local shadow_animation = adjust_animation(prototype.shadow_in_motion, shadow_shift)

    local particle = {
        type = "optimized-particle",
        name = particle_name,
        pictures = {animation, reverse_animation(animation)},
        shadows = {shadow_animation, reverse_animation(shadow_animation)},
        movement_modifier = 0.95,
        life_time = 1000,
        regular_trigger_effect_frequency = 2,
        regular_trigger_effect = {
            {
                type = "create-trivial-smoke",
                smoke_name = "smoke-fast",
                starting_frame_deviation = 5,
                probability = 0.5
            },
            {
                type = "create-particle",
                particle_name = "spark-particle",
                tail_length = 10,
                tail_length_deviation = 5,
                tail_width = 5,
                probability = 0.2,
                initial_height = 0.2,
                initial_vertical_speed = 0.15,
                initial_vertical_speed_deviation = 0.05,
                speed_from_center = 0.1,
                speed_from_center_deviation = 0.05,
                offset_deviation = {{-0.25, -0.25},{0.25, 0.25}}
            }
        },
        ended_on_ground_trigger_effect = {
            type = "create-entity",
            entity_name = prototype.name.."-remnants",
            offsets = {{0, 0}}
        }
    }

    data:extend{particle}

    prototype.dying_trigger_effect = {
        {
            type = "create-particle",
            particle_name = particle_name,
            initial_height = 1.8,
            initial_vertical_speed = 0,
            frame_speed = 1,
            frame_speed_deviation = 0.5,
            speed_from_center = 0,
            speed_from_center_deviation = 0.2,
            offset_deviation = {{-0.01, -0.01},{0.01, 0.01}},
            offsets = {{0, 0.5}}
        }
    }

    if prototype.type == "construction-robot" or prototype.type == "logistic-robot" then return end

    prototype.destroy_action = {
        type = "direct",
        action_delivery = {
            type = "instant",
            source_effects = {
                type = "create-particle",
                particle_name = particle_name,
                initial_height = 1.8,
                initial_vertical_speed = 0,
                frame_speed = 0.5,
                frame_speed_deviation = 0.5,
                speed_from_center = 0,
                speed_from_center_deviation = 0.1,
                offset_deviation = {{-0.01, -0.01},{0.01, 0.01}},
                offsets = {{0, 0.5}}
            }
        }
    }
end

-- DEPRECATED; belt tints have been broken out into a separate belt_tint_index
-- Determine belt-related entity tints with special handling for basic belt entity types
-- function reskins.bobs.belt_tint_handling(name, tier)
--     local tint
--     if string.find(name, "basic") then
--         tint = reskins.lib.belt_mask_tint(reskins.bobs.basic_belt_tint)
--     else
--         tint = reskins.lib.belt_mask_tint(reskins.lib.tint_index[tier])
--     end

--     return tint
-- end

-- PIPE-RELATED PICTURE AND COVER GENERATION
-- Prepare assembly-machine-style pipe pictures
function reskins.bobs.assembly_pipe_pictures(tint)
    return
    {
        north = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-N-base.png",
                    priority = "extra-high",
                    width = 35,
                    height = 18,
                    shift = util.by_pixel(2.5, 14),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-N-base.png",
                        priority = "extra-high",
                        width = 71,
                        height = 38,
                        shift = util.by_pixel(2.25, 13.5),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-N-mask.png",
                    priority = "extra-high",
                    width = 35,
                    height = 18,
                    shift = util.by_pixel(2.5, 14),
                    tint = tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-N-mask.png",
                        priority = "extra-high",
                        width = 71,
                        height = 38,
                        shift = util.by_pixel(2.25, 13.5),
                        tint = tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-N-highlights.png",
                    priority = "extra-high",
                    width = 35,
                    height = 18,
                    shift = util.by_pixel(2.5, 14),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-N-highlights.png",
                        priority = "extra-high",
                        width = 71,
                        height = 38,
                        shift = util.by_pixel(2.25, 13.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                }
            }
        },
        east = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-E-base.png",
                    priority = "extra-high",
                    width = 20,
                    height = 38,
                    shift = util.by_pixel(-25, 1),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-E-base.png",
                        priority = "extra-high",
                        width = 42,
                        height = 76,
                        shift = util.by_pixel(-24.5, 1),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-E-mask.png",
                    priority = "extra-high",
                    width = 20,
                    height = 38,
                    shift = util.by_pixel(-25, 1),
                    tint = tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-E-mask.png",
                        priority = "extra-high",
                        width = 42,
                        height = 76,
                        shift = util.by_pixel(-24.5, 1),
                        tint = tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-E-highlights.png",
                    priority = "extra-high",
                    width = 20,
                    height = 38,
                    shift = util.by_pixel(-25, 1),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-E-highlights.png",
                        priority = "extra-high",
                        width = 42,
                        height = 76,
                        shift = util.by_pixel(-24.5, 1),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                }
            }
        },
        south = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-S-base.png",
                    priority = "extra-high",
                    width = 44,
                    height = 31,
                    shift = util.by_pixel(0, -31.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-S-base.png",
                        priority = "extra-high",
                        width = 88,
                        height = 61,
                        shift = util.by_pixel(0, -31.25),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-S-mask.png",
                    priority = "extra-high",
                    width = 44,
                    height = 31,
                    shift = util.by_pixel(0, -31.5),
                    tint = tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-S-mask.png",
                        priority = "extra-high",
                        width = 88,
                        height = 61,
                        shift = util.by_pixel(0, -31.25),
                        tint = tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-S-highlights.png",
                    priority = "extra-high",
                    width = 44,
                    height = 31,
                    shift = util.by_pixel(0, -31.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-S-highlights.png",
                        priority = "extra-high",
                        width = 88,
                        height = 61,
                        shift = util.by_pixel(0, -31.25),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                }
            }
        },
        west = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-W-base.png",
                    priority = "extra-high",
                    width = 19,
                    height = 37,
                    shift = util.by_pixel(25.5, 1.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-W-base.png",
                        priority = "extra-high",
                        width = 39,
                        height = 73,
                        shift = util.by_pixel(25.75, 1.25),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-W-mask.png",
                    priority = "extra-high",
                    width = 19,
                    height = 37,
                    shift = util.by_pixel(25.5, 1.5),
                    tint = tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-W-mask.png",
                        priority = "extra-high",
                        width = 39,
                        height = 73,
                        shift = util.by_pixel(25.75, 1.25),
                        tint = tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/assembling-machine-pipe-W-highlights.png",
                    priority = "extra-high",
                    width = 19,
                    height = 37,
                    shift = util.by_pixel(25.5, 1.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/assembling-machine/pipes/hr-assembling-machine-pipe-W-highlights.png",
                        priority = "extra-high",
                        width = 39,
                        height = 73,
                        shift = util.by_pixel(25.75, 1.25),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                }
            }
        }
    }
end

-- Prepare chemical-electric-furnace-style pipe pictures
function reskins.bobs.furnace_pipe_pictures(tint)
    return
    {
        north = {
            filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-N-base.png",
            priority = "extra-high",
            width = 35,
            height = 13,
            shift = util.by_pixel(2.5, 10),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-N-base.png",
                priority = "extra-high",
                width = 70,
                height = 26,
                shift = util.by_pixel(2.5, 10),
                scale = 0.5
            }
        },
        east = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-E-base.png",
                    priority = "extra-high",
                    width = 15,
                    height = 35,
                    shift = util.by_pixel(-20.5, 3),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-E-base.png",
                        priority = "extra-high",
                        width = 30,
                        height = 70,
                        shift = util.by_pixel(-20.5, 3),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-E-mask.png",
                    priority = "extra-high",
                    width = 15,
                    height = 35,
                    shift = util.by_pixel(-20.5, 3),
                    tint = tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-E-mask.png",
                        priority = "extra-high",
                        width = 30,
                        height = 70,
                        shift = util.by_pixel(-20.5, 3),
                        tint = tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-E-highlights.png",
                    priority = "extra-high",
                    width = 15,
                    height = 35,
                    shift = util.by_pixel(-20.5, 3),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-E-highlights.png",
                        priority = "extra-high",
                        width = 30,
                        height = 70,
                        shift = util.by_pixel(-20.5, 3),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                }
            }
        },
        south = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-S-base.png",
                    priority = "extra-high",
                    width = 38,
                    height = 29,
                    shift = util.by_pixel(0.5, -30.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-S-base.png",
                        priority = "extra-high",
                        width = 76,
                        height = 58,
                        shift = util.by_pixel(0.5, -30.5),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-S-mask.png",
                    priority = "extra-high",
                    width = 38,
                    height = 29,
                    shift = util.by_pixel(0.5, -30.5),
                    tint = tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-S-mask.png",
                        priority = "extra-high",
                        width = 76,
                        height = 58,
                        shift = util.by_pixel(0.5, -30.5),
                        tint = tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-S-highlights.png",
                    priority = "extra-high",
                    width = 38,
                    height = 29,
                    shift = util.by_pixel(0.5, -30.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-S-highlights.png",
                        priority = "extra-high",
                        width = 76,
                        height = 58,
                        shift = util.by_pixel(0.5, -30.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                }
            }
        },
        west = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-W-base.png",
                    priority = "extra-high",
                    width = 11,
                    height = 34,
                    shift = util.by_pixel(21.5, 2),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-W-base.png",
                        priority = "extra-high",
                        width = 22,
                        height = 68,
                        shift = util.by_pixel(21.5, 2),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-W-mask.png",
                    priority = "extra-high",
                    width = 11,
                    height = 34,
                    shift = util.by_pixel(21.5, 2),
                    tint = tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-W-mask.png",
                        priority = "extra-high",
                        width = 22,
                        height = 68,
                        shift = util.by_pixel(21.5, 2),
                        tint = tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/electric-furnace-pipe-W-highlights.png",
                    priority = "extra-high",
                    width = 11,
                    height = 34,
                    shift = util.by_pixel(21.5, 2),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/assembly/electric-furnace/pipes/hr-electric-furnace-pipe-W-highlights.png",
                        priority = "extra-high",
                        width = 22,
                        height = 68,
                        shift = util.by_pixel(21.5, 2),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                }
            }
        }
    }
end

-- MINING DRILL FUNCTIONS
-- Apparently relying on vanilla globals can be dangerous when other mods break them
function reskins.bobs.electric_mining_drill_smoke()
    return
    {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-smoke.png",
        line_length = 6,
        width = 24,
        height = 38,
        frame_count = 30,
        animation_speed = 0.4,
        direction_count = 1,
        shift = util.by_pixel(0, 2),
        hr_version = {
            priority = "high",
            filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-smoke.png",
            line_length = 6,
            width = 48,
            height = 72,
            frame_count = 30,
            animation_speed = 0.4,
            direction_count = 1,
            shift = util.by_pixel(0, 3),
            scale = 0.5,
        }
    }
end

function reskins.bobs.electric_mining_drill_smoke_front()
    return
    {
        priority = "high",
        filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-smoke-front.png",
        line_length = 6,
        width = 76,
        height = 68,
        frame_count = 30,
        animation_speed = 0.4,
        direction_count = 1,
        shift = util.by_pixel(-4, 8),
        hr_version = {
            priority = "high",
            filename = "__base__/graphics/entity/electric-mining-drill/hr-electric-mining-drill-smoke-front.png",
            line_length = 6,
            width = 148,
            height = 132,
            frame_count = 30,
            animation_speed = 0.4,
            direction_count = 1,
            shift = util.by_pixel(-3, 9),
            scale = 0.5,
        }
    }
end

reskins.bobs.electric_drill_animation_sequence = {
    1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
    21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1
}

reskins.bobs.electric_drill_animation_shadow_sequence = {
    1, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21,
    21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1
}

local function electric_mining_drill_add_light_offsets(t)
    t.north_position = { 0.8, -1.5}
    t.east_position =  { 1.2, -1}
    t.south_position = { 0.8,  0.8}
    t.west_position =  {-1.2, -1}
    return t
end

reskins.bobs.electric_mining_drill_primary_light = electric_mining_drill_add_light_offsets({
    light = { intensity = 1, size = 3, color={r=1, g=1, b=1}, minimum_darkness = 0.1 }
})

reskins.bobs.electric_mining_drill_secondary_light = electric_mining_drill_add_light_offsets({
    always_draw = true,
    apply_tint = "status",
    light = { intensity = 0.8, size = 1.5, color={r=1, g=1, b=1}, minimum_darkness = 0.1 }
})