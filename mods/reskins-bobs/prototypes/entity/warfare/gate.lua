-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then return end

-- Make sure the gate exists
local entity = data.raw["gate"]["reinforced-gate"]
if not entity then return end

-- Set input parameters
local inputs = {
    type = "gate",
    base_entity_name = "gate",
    mod = "bobs",
    particles = {["big"] = 1, ["medium"] = 2},
}

inputs.icon_filename = reskins.bobs.directory.."/graphics/icons/warfare/reinforced-gate/gate.png"

local reinforced_tint_index = {
    ["big"] = util.color("6f647d"),
    ["medium"] = util.color("a695ba"),
}

-- Parse inputs
reskins.lib.parse_inputs(inputs)

-- Create particles and explosions
reskins.lib.create_explosion("reinforced-gate", inputs)

for particle, key in pairs(inputs.particles) do
    reskins.lib.create_particle("reinforced-gate", inputs.base_entity_name, reskins.lib.particle_index[particle], key, reinforced_tint_index[particle])
end

-- Create remnants
reskins.lib.create_remnant("reinforced-gate", inputs)

-- Create icons
reskins.lib.construct_icon("reinforced-gate", 0,  inputs)

-- Reskin the gate
local remnant = data.raw["corpse"]["reinforced-gate-remnants"]

-- Reskin remnants
remnant.animation = {
    {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/remnants/reinforced-gate-remnants-var-1.png",
        line_length = 1,
        width = 44,
        height = 42,
        frame_count = 1,
        variation_count = 1,
        axially_symmetrical = false,
        direction_count = 4,
        shift = util.by_pixel(0, 1),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/remnants/hr-reinforced-gate-remnants-var-1.png",
            line_length = 1,
            width = 86,
            height = 82,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 4,
            shift = util.by_pixel(0, 1),
            scale = 0.5
        }
    },
    {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/remnants/reinforced-gate-remnants-var-2.png",
        line_length = 1,
        width = 42,
        height = 42,
        frame_count = 1,
        variation_count = 1,
        axially_symmetrical = false,
        direction_count = 4,
        shift = util.by_pixel(-1, 0),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/remnants/hr-reinforced-gate-remnants-var-2.png",
            line_length = 1,
            width = 84,
            height = 82,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 4,
            shift = util.by_pixel(-0.5, 0),
            scale = 0.5
        }
    },
    {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/remnants/reinforced-gate-remnants-var-3.png",
        line_length = 1,
        width = 42,
        height = 42,
        frame_count = 1,
        variation_count = 1,
        axially_symmetrical = false,
        direction_count = 4,
        shift = util.by_pixel(0, 0),
        hr_version = {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/remnants/hr-reinforced-gate-remnants-var-3.png",
            line_length = 1,
            width = 82,
            height = 84,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 4,
            shift = util.by_pixel(0, 0.5),
            scale = 0.5
        }
    }
}

-- Reskin entity
entity.vertical_animation = {
    layers = {
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-vertical.png",
            line_length = 8,
            width = 38,
            height = 62,
            frame_count = 16,
            shift = util.by_pixel(0, -14),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-vertical.png",
                line_length = 8,
                width = 78,
                height = 120,
                frame_count = 16,
                shift = util.by_pixel(-1, -13),
                scale = 0.5
            }
        },
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/reinforced-gate-vertical-shadow.png",
            line_length = 8,
            width = 40,
            height = 54,
            frame_count = 16,
            shift = util.by_pixel(10, 8),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/hr-reinforced-gate-vertical-shadow.png",
                line_length = 8,
                width = 82,
                height = 104,
                frame_count = 16,
                shift = util.by_pixel(9, 9),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

entity.horizontal_animation = {
    layers = {
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-horizontal.png",
            line_length = 8,
            width = 34,
            height = 48,
            frame_count = 16,
            shift = util.by_pixel(0, -4),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-horizontal.png",
                line_length = 8,
                width = 66,
                height = 90,
                frame_count = 16,
                shift = util.by_pixel(0, -3),
                scale = 0.5
            }
        },
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/reinforced-gate-horizontal-shadow.png",
            line_length = 8,
            width = 62,
            height = 30,
            frame_count = 16,
            shift = util.by_pixel(12, 10),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/hr-reinforced-gate-horizontal-shadow.png",
                line_length = 8,
                width = 122,
                height = 60,
                frame_count = 16,
                shift = util.by_pixel(12, 10),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

entity.horizontal_rail_animation_left = {
  layers = {
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-rail-horizontal-left.png",
            line_length = 8,
            width = 34,
            height = 40,
            frame_count = 16,
            shift = util.by_pixel(0, -8),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-rail-horizontal-left.png",
                line_length = 8,
                width = 66,
                height = 74,
                frame_count = 16,
                shift = util.by_pixel(0, -7),
                scale = 0.5
            }
        },
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/reinforced-gate-rail-horizontal-shadow-left.png",
            line_length = 8,
            width = 62,
            height = 30,
            frame_count = 16,
            shift = util.by_pixel(12, 10),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/hr-reinforced-gate-rail-horizontal-shadow-left.png",
                line_length = 8,
                width = 122,
                height = 60,
                frame_count = 16,
                shift = util.by_pixel(12, 10),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

entity.horizontal_rail_animation_right = {
    layers = {
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-rail-horizontal-right.png",
            line_length = 8,
            width = 34,
            height = 40,
            frame_count = 16,
            shift = util.by_pixel(0, -8),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-rail-horizontal-right.png",
                line_length = 8,
                width = 66,
                height = 74,
                frame_count = 16,
                shift = util.by_pixel(0, -7),
                scale = 0.5
            }
        },
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/reinforced-gate-rail-horizontal-shadow-right.png",
            line_length = 8,
            width = 62,
            height = 30,
            frame_count = 16,
            shift = util.by_pixel(12, 10),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/hr-reinforced-gate-rail-horizontal-shadow-right.png",
                line_length = 8,
                width = 122,
                height = 58,
                frame_count = 16,
                shift = util.by_pixel(12, 11),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

entity.vertical_rail_animation_left = {
    layers = {
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-rail-vertical-left.png",
            line_length = 8,
            width = 22,
            height = 62,
            frame_count = 16,
            shift = util.by_pixel(0, -14),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-rail-vertical-left.png",
                line_length = 8,
                width = 42,
                height = 118,
                frame_count = 16,
                shift = util.by_pixel(0, -13),
                scale = 0.5
            }
        },
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/reinforced-gate-rail-vertical-shadow-left.png",
            line_length = 8,
            width = 44,
            height = 54,
            frame_count = 16,
            shift = util.by_pixel(8, 8),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/hr-reinforced-gate-rail-vertical-shadow-left.png",
                line_length = 8,
                width = 82,
                height = 104,
                frame_count = 16,
                shift = util.by_pixel(9, 9),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

entity.vertical_rail_animation_right = {
    layers = {
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-rail-vertical-right.png",
            line_length = 8,
            width = 22,
            height = 62,
            frame_count = 16,
            shift = util.by_pixel(0, -14),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-rail-vertical-right.png",
                line_length = 8,
                width = 42,
                height = 118,
                frame_count = 16,
                shift = util.by_pixel(0, -13),
                scale = 0.5
            }
        },
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/reinforced-gate-rail-vertical-shadow-right.png",
            line_length = 8,
            width = 44,
            height = 54,
            frame_count = 16,
            shift = util.by_pixel(8, 8),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/hr-reinforced-gate-rail-vertical-shadow-right.png",
                line_length = 8,
                width = 82,
                height = 104,
                frame_count = 16,
                shift = util.by_pixel(9, 9),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}

entity.vertical_rail_base = {
    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-rail-base-vertical.png",
    line_length = 8,
    width = 68,
    height = 66,
    frame_count = 16,
    shift = util.by_pixel(0, 0),
    hr_version = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-rail-base-vertical.png",
        line_length = 8,
        width = 138,
        height = 130,
        frame_count = 16,
        shift = util.by_pixel(-1, 0),
        scale = 0.5
    }
}

entity.horizontal_rail_base = {
    filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-rail-base-horizontal.png",
    line_length = 8,
    width = 66,
    height = 54,
    frame_count = 16,
    shift = util.by_pixel(0, 2),
    hr_version = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-rail-base-horizontal.png",
        line_length = 8,
        width = 130,
        height = 104,
        frame_count = 16,
        shift = util.by_pixel(0, 3),
        scale = 0.5
    }
}

entity.wall_patch = {
    layers = {
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/reinforced-gate-wall-patch.png",
            line_length = 8,
            width = 34,
            height = 48,
            frame_count = 16,
            shift = util.by_pixel(0, 12),
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/hr-reinforced-gate-wall-patch.png",
                line_length = 8,
                width = 70,
                height = 94,
                frame_count = 16,
                shift = util.by_pixel(-1, 13),
                scale = 0.5
            }
        },
        {
            filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/reinforced-gate-wall-patch-shadow.png",
            line_length = 8,
            width = 44,
            height = 38,
            frame_count = 16,
            shift = util.by_pixel(8, 32),
            draw_as_shadow = true,
            hr_version = {
                filename = reskins.bobs.directory.."/graphics/entity/warfare/reinforced-gate/shadows/hr-reinforced-gate-wall-patch-shadow.png",
                line_length = 8,
                width = 82,
                height = 72,
                frame_count = 16,
                shift = util.by_pixel(9, 33),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}