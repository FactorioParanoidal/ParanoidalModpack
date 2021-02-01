-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobwarfare"] then return end
if reskins.lib.setting("reskins-bobs-do-bobwarfare") == false then return end

-- Make sure the wall exists
local entity = data.raw["wall"]["reinforced-wall"]
if not entity then return end

-- Set input parameters
local inputs = {
    type = "wall",
    base_entity = "wall",
    mod = "bobs",
    particles = {["tiny-stone"] = 3, ["small-stone"] = 2, ["medium-stone"] = 1},
}

if mods["NauvisDay"] then
    inputs.make_explosions = false
end

inputs.icon_filename = reskins.bobs.directory.."/graphics/icons/warfare/reinforced-wall/wall.png"

local reinforced_tint_index = {
    ["tiny-stone"] = util.color("a793bf"),
    ["small-stone"] = util.color("a793bf"),
    ["medium-stone"] = util.color("9584ab")
}

-- Parse inputs
reskins.lib.parse_inputs(inputs)

-- Create particles and explosions
reskins.lib.create_explosion("reinforced-wall", inputs)

for particle, key in pairs(inputs.particles) do
    reskins.lib.create_particle("reinforced-wall", inputs.base_entity, reskins.lib.particle_index[particle], key, reinforced_tint_index[particle])
end

-- Create remnants
reskins.lib.create_remnant("reinforced-wall", inputs)

-- Create icons
reskins.lib.construct_icon("reinforced-wall", 0, inputs)

-- Reskin the gate
local remnant = data.raw["corpse"]["reinforced-wall-remnants"]

-- Reskin remnants
remnant.animation = make_rotated_animation_variations_from_sheet(4, {
    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/remnants/reinforced-wall-remnants.png",
    width = 60,
    height = 58,
    line_length = 1,
    frame_count = 1,
    direction_count = 2,
    shift = util.by_pixel(3, 7.5),
    hr_version = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/remnants/hr-reinforced-wall-remnants.png",
        width = 118,
        height = 114,
        line_length = 1,
        frame_count = 1,
        direction_count = 2,
        shift = util.by_pixel(3, 7.5),
        scale = 0.5,
    },
})

-- Reskin entity
entity.pictures = {
    single = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-single.png",
                priority = "extra-high",
                width = 32,
                height = 46,
                variation_count = 2,
                line_length = 2,
                shift = util.by_pixel(0, -6),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-single.png",
                    priority = "extra-high",
                    width = 64,
                    height = 86,
                    variation_count = 2,
                    line_length = 2,
                    shift = util.by_pixel(0, -5),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-single-shadow.png",
                priority = "extra-high",
                width = 50,
                height = 32,
                repeat_count = 2,
                shift = util.by_pixel(10, 16),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-single-shadow.png",
                    priority = "extra-high",
                    width = 98,
                    height = 60,
                    repeat_count = 2,
                    shift = util.by_pixel(10, 17),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    straight_vertical = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-vertical.png",
                priority = "extra-high",
                width = 32,
                height = 68,
                variation_count = 5,
                line_length = 5,
                shift = util.by_pixel(0, 8),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-vertical.png",
                    priority = "extra-high",
                    width = 64,
                    height = 134,
                    variation_count = 5,
                    line_length = 5,
                    shift = util.by_pixel(0, 8),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-vertical-shadow.png",
                priority = "extra-high",
                width = 50,
                height = 58,
                repeat_count = 5,
                shift = util.by_pixel(10, 28),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-vertical-shadow.png",
                    priority = "extra-high",
                    width = 98,
                    height = 110,
                    repeat_count = 5,
                    shift = util.by_pixel(10, 29),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    straight_horizontal = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-horizontal.png",
                priority = "extra-high",
                width = 32,
                height = 50,
                variation_count = 6,
                line_length = 6,
                shift = util.by_pixel(0, -4),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-horizontal.png",
                    priority = "extra-high",
                    width = 64,
                    height = 92,
                    variation_count = 6,
                    line_length = 6,
                    shift = util.by_pixel(0, -2),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-horizontal-shadow.png",
                priority = "extra-high",
                width = 62,
                height = 36,
                repeat_count = 6,
                shift = util.by_pixel(14, 14),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-horizontal-shadow.png",
                    priority = "extra-high",
                    width = 124,
                    height = 68,
                    repeat_count = 6,
                    shift = util.by_pixel(14, 15),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    corner_right_down = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-corner-right.png",
                priority = "extra-high",
                width = 32,
                height = 64,
                variation_count = 2,
                line_length = 2,
                shift = util.by_pixel(0, 6),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-corner-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 128,
                    variation_count = 2,
                    line_length = 2,
                    shift = util.by_pixel(0, 7),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-corner-right-shadow.png",
                priority = "extra-high",
                width = 62,
                height = 60,
                repeat_count = 2,
                shift = util.by_pixel(14, 28),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-corner-right-shadow.png",
                    priority = "extra-high",
                    width = 124,
                    height = 120,
                    repeat_count = 2,
                    shift = util.by_pixel(17, 28),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    corner_left_down = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-corner-left.png",
                priority = "extra-high",
                width = 32,
                height = 68,
                variation_count = 2,
                line_length = 2,
                shift = util.by_pixel(0, 6),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-corner-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 134,
                    variation_count = 2,
                    line_length = 2,
                    shift = util.by_pixel(0, 7),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-corner-left-shadow.png",
                priority = "extra-high",
                width = 54,
                height = 60,
                repeat_count = 2,
                shift = util.by_pixel(8, 28),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-corner-left-shadow.png",
                    priority = "extra-high",
                    width = 102,
                    height = 120,
                    repeat_count = 2,
                    shift = util.by_pixel(9, 28),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    t_up = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-t.png",
                priority = "extra-high",
                width = 32,
                height = 68,
                variation_count = 4,
                line_length = 4,
                shift = util.by_pixel(0, 6),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-t.png",
                    priority = "extra-high",
                    width = 64,
                    height = 134,
                    variation_count = 4,
                    line_length = 4,
                    shift = util.by_pixel(0, 7),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-t-shadow.png",
                priority = "extra-high",
                width = 62,
                height = 60,
                repeat_count = 4,
                shift = util.by_pixel(14, 28),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-t-shadow.png",
                    priority = "extra-high",
                    width = 124,
                    height = 120,
                    repeat_count = 4,
                    shift = util.by_pixel(14, 28),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    ending_right = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-ending-right.png",
                priority = "extra-high",
                width = 32,
                height = 48,
                variation_count = 2,
                line_length = 2,
                shift = util.by_pixel(0, -4),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-ending-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 92,
                    variation_count = 2,
                    line_length = 2,
                    shift = util.by_pixel(0, -3),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-ending-right-shadow.png",
                priority = "extra-high",
                width = 62,
                height = 36,
                repeat_count = 2,
                shift = util.by_pixel(14, 14),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-ending-right-shadow.png",
                    priority = "extra-high",
                    width = 124,
                    height = 68,
                    repeat_count = 2,
                    shift = util.by_pixel(17, 15),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    ending_left = {
        layers = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-ending-left.png",
                priority = "extra-high",
                width = 32,
                height = 48,
                variation_count = 2,
                line_length = 2,
                shift = util.by_pixel(0, -4),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-ending-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 92,
                    variation_count = 2,
                    line_length = 2,
                    shift = util.by_pixel(0, -3),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-ending-left-shadow.png",
                priority = "extra-high",
                width = 54,
                height = 36,
                repeat_count = 2,
                shift = util.by_pixel(8, 14),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-ending-left-shadow.png",
                    priority = "extra-high",
                    width = 102,
                    height = 68,
                    repeat_count = 2,
                    shift = util.by_pixel(9, 15),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    filling = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-filling.png",
        priority = "extra-high",
        width = 24,
        height = 30,
        variation_count = 8,
        line_length = 8,
        shift = util.by_pixel(0, -2),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-filling.png",
            priority = "extra-high",
            width = 48,
            height = 56,
            variation_count = 8,
            line_length = 8,
            shift = util.by_pixel(0, -1),
            scale = 0.5
        }
    },
    water_connection_patch = {
        sheets = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-patch.png",
                priority = "extra-high",
                width = 58,
                height = 64,
                shift = util.by_pixel(0, -2),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-patch.png",
                    priority = "extra-high",
                    width = 116,
                    height = 128,
                    shift = util.by_pixel(0, -2),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-patch-shadow.png",
                priority = "extra-high",
                width = 74,
                height = 52,
                shift = util.by_pixel(8, 14),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-patch-shadow.png",
                    priority = "extra-high",
                    width = 144,
                    height = 100,
                    shift = util.by_pixel(9, 15),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    },
    gate_connection_patch = {
        sheets = {
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/reinforced-wall-gate.png",
                priority = "extra-high",
                width = 42,
                height = 56,
                shift = util.by_pixel(0, -8),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/hr-reinforced-wall-gate.png",
                    priority = "extra-high",
                    width = 82,
                    height = 108,
                    shift = util.by_pixel(0, -7),
                    scale = 0.5
                }
            },
            {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/reinforced-wall-gate-shadow.png",
                priority = "extra-high",
                width = 66,
                height = 40,
                shift = util.by_pixel(14, 18),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-wall/shadows/hr-reinforced-wall-gate-shadow.png",
                    priority = "extra-high",
                    width = 130,
                    height = 78,
                    shift = util.by_pixel(14, 18),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    }
}