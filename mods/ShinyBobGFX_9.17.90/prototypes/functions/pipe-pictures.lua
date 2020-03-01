--- For working with pipes
--@module Pipes

local Pipes = {}

function Pipes.shinypipepictures(ptype)
    return {
        straight_vertical_single =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-straight-vertical-single.png",
            priority = "extra-high",
            width = 80,
            height = 80,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-straight-vertical-single.png",
                priority = "extra-high",
                width = 160,
                height = 160,
                scale = 0.5
            }
        },
        straight_vertical =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-straight-vertical.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-straight-vertical.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        straight_vertical_window =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-straight-vertical-window.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-straight-vertical-window.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        straight_horizontal_window =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-straight-horizontal-window.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-straight-horizontal-window.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        straight_horizontal =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-straight-horizontal.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-straight-horizontal.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        corner_up_right =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-corner-up-right.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-corner-up-right.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        corner_up_left =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-corner-up-left.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-corner-up-left.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        corner_down_right =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-corner-down-right.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-corner-down-right.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        corner_down_left =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-corner-down-left.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-corner-down-left.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        t_up =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-t-up.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-t-up.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        t_down =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-t-down.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-t-down.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        t_right =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-t-right.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-t-right.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        t_left =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-t-left.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-t-left.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        cross =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-cross.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-cross.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        ending_up =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-ending-up.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-ending-up.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        ending_down =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-ending-down.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-ending-down.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        ending_right =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-ending-right.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-ending-right.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        ending_left =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-ending-left.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-ending-left.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        horizontal_window_background =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-horizontal-window-background.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-horizontal-window-background.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        vertical_window_background =
        {
            filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-vertical-window-background.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version =
            {
                filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-vertical-window-background.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5
            }
        },
        fluid_background =
        {
            filename = "__base__/graphics/entity/pipe/fluid-background.png",
            priority = "extra-high",
            width = 32,
            height = 20,
            hr_version =
            {
                filename = "__base__/graphics/entity/pipe/hr-fluid-background.png",
                priority = "extra-high",
                width = 64,
                height = 40,
                scale = 0.5
            }
        },
        low_temperature_flow =
        {
            filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18
        },
        middle_temperature_flow =
        {
            filename = "__base__/graphics/entity/pipe/fluid-flow-medium-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18
        },
        high_temperature_flow =
        {
            filename = "__base__/graphics/entity/pipe/fluid-flow-high-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18
        },
        gas_flow =
        {
            filename = "__base__/graphics/entity/pipe/steam.png",
            priority = "extra-high",
            line_length = 10,
            width = 24,
            height = 15,
            frame_count = 60,
            axially_symmetrical = false,
            direction_count = 1,
            hr_version =
            {
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

function Pipes.shinycoverpictures(ptype)

    return {
        north =
        {
            layers = {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-cover-north.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version =
                    {
                        filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-cover-north.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-north-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version =
                    {
                        filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-north-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                },
            },
        },
        east =
        {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-cover-east.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version =
                    {
                        filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-cover-east.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-east-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version =
                    {
                        filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-east-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                },
            },
        },
        south =
        {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-cover-south.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version =
                    {
                        filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-cover-south.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-south-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version =
                    {
                        filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-south-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                },
            },
        },
        west =
        {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/pipe-cover-west.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version =
                    {
                        filename = "__ShinyBobGFX__/graphics/entity/pipe/" .. ptype .. "/hr-pipe-cover-west.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5
                    }
                },
                {
                    filename = "__base__/graphics/entity/pipe-covers/pipe-cover-west-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version =
                    {
                        filename = "__base__/graphics/entity/pipe-covers/hr-pipe-cover-west-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true
                    }
                },
            },
        }
    }
end


shinycoverpictures = Pipes.shinycoverpictures
shinypipepictures = Pipes.shinypipepictures

return Pipes
