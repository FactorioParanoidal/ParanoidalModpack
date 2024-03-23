-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Prepare standard pipe sprites
function reskins.lib.pipe_pictures(inputs)
    return
    {
        straight_vertical_single = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-straight-vertical-single.png",
                    priority = "extra-high",
                    width = 80,
                    height = 80,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-straight-vertical-single.png",
                        priority = "extra-high",
                        width = 160,
                        height = 160,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-straight-vertical-single-shadow.png",
                    priority = "extra-high",
                    width = 80,
                    height = 80,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-straight-vertical-single-shadow.png",
                        priority = "extra-high",
                        width = 160,
                        height = 160,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        straight_vertical = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-straight-vertical.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-straight-vertical.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-straight-vertical-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-straight-vertical-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        straight_vertical_window = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-straight-vertical-window.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-straight-vertical-window.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-straight-vertical-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-straight-vertical-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        straight_horizontal_window = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-straight-horizontal-window.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-straight-horizontal-window.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-straight-horizontal-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-straight-horizontal-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        straight_horizontal = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-straight-horizontal.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-straight-horizontal.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-straight-horizontal-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-straight-horizontal-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        corner_up_right = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-corner-up-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-corner-up-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-corner-up-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-corner-up-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        corner_up_left = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-corner-up-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-corner-up-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-corner-up-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-corner-up-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        corner_down_right = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-corner-down-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-corner-down-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-corner-down-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-corner-down-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        corner_down_left = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-corner-down-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-corner-down-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-corner-down-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-corner-down-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        t_up = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-t-up.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-t-up.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-t-up-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-t-up-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        t_down = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-t-down.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-t-down.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-t-down-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-t-down-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        t_right = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-t-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-t-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-t-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-t-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        t_left = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-t-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-t-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-t-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-t-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        cross = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-cross.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-cross.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-cross-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-cross-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        ending_up = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-ending-up.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-ending-up.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-ending-up-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-ending-up-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        ending_down = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-ending-down.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-ending-down.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-ending-down-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-ending-down-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        ending_right = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-ending-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-ending-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-ending-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-ending-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        ending_left = {
            layers = {
                -- Base
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-ending-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-ending-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/pipe-ending-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe/shadows/hr-pipe-ending-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            },
        },
        horizontal_window_background = {
            filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-horizontal-window-background.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version = {
                filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-horizontal-window-background.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        vertical_window_background = {
            filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/pipe-vertical-window-background.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version = {
                filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe/"..inputs.material.."/hr-pipe-vertical-window-background.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        fluid_background = {
            filename = "__base__/graphics/entity/pipe/fluid-background.png",
            priority = "extra-high",
            width = 32,
            height = 20,
            hr_version = {
                filename = "__base__/graphics/entity/pipe/hr-fluid-background.png",
                priority = "extra-high",
                width = 64,
                height = 40,
                scale = 0.5
            }
        },
        low_temperature_flow = {
            filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18
        },
        middle_temperature_flow = {
            filename = "__base__/graphics/entity/pipe/fluid-flow-medium-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18
        },
        high_temperature_flow = {
            filename = "__base__/graphics/entity/pipe/fluid-flow-high-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18
        },
        gas_flow = {
            filename = "__base__/graphics/entity/pipe/steam.png",
            priority = "extra-high",
            line_length = 10,
            width = 24,
            height = 15,
            frame_count = 60,
            axially_symmetrical = false,
            direction_count = 1,
            hr_version = {
                filename = "__base__/graphics/entity/pipe/hr-steam.png",
                priority = "extra-high",
                line_length = 10,
                width = 48,
                height = 30,
                frame_count = 60,
                axially_symmetrical = false,
                direction_count = 1
            }
        }
    }
end

-- Prepare underground pipe sprites
function reskins.lib.underground_pipe_pictures(inputs)
    return
    {
        up = {
            layers = {
                -- Pipe
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/pipe-to-ground-up.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/hr-pipe-to-ground-up.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-up-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-up-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            }
        },
        down = {
            layers = {
                -- Pipe
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/pipe-to-ground-down.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/hr-pipe-to-ground-down.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-down-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-down-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            }
        },
        left = {
            layers = {
                -- Pipe
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/pipe-to-ground-left.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/hr-pipe-to-ground-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-left-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            }
        },
        right = {
            layers = {
                -- Pipe
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/pipe-to-ground-right.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-to-ground/"..inputs.material.."/hr-pipe-to-ground-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                -- Shadows
                {
                    filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-right-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                },
            }
        },
    }
end

-- Prepare pipe covers
function reskins.lib.pipe_covers(inputs)
    return
    {
        north = {
            layers = {
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/pipe-cover-north.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/hr-pipe-cover-north.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/pipe-cover-north-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-north-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        east = {
            layers = {
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/pipe-cover-east.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/hr-pipe-cover-east.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/pipe-cover-east-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-east-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        south = {
            layers = {
                {
                    filename =reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/pipe-cover-south.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename =reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/hr-pipe-cover-south.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/pipe-cover-south-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-south-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        },
        west = {
            layers = {
                {
                    filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/pipe-cover-west.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = reskins[inputs.mod].directory.."/graphics/entity/"..inputs.group.."/pipe-covers/"..inputs.material.."/hr-pipe-cover-west.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/pipe-cover-west-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename =  reskins.lib.directory.."/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-west-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                }
            }
        }
    }
end