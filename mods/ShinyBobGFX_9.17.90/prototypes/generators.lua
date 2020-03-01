if data.raw["generator"]["steam-engine-2"] then
	bobicon("steam-engine","generator",1,5,0)
	bobicon("steam-turbine","generator",1,3,0)
    data.raw["generator"]["steam-engine-2"]["horizontal_animation"] = {
        layers = {{
                filename = "__base__/graphics/entity/steam-engine/steam-engine-H.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-H-cap2.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-H-cap2.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
          width = 254,
          height = 80,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(48, 24),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H-shadow.png",
            width = 508,
            height = 160,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(48, 24),
            scale = 0.5
          },
        }
        }
    }
    data.raw["generator"]["steam-engine-2"]["vertical_animation"] = {

        layers = {
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-V.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-V-cap2.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-V-cap2.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
          width = 165,
          height = 153,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(40.5, 9.5),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V-shadow.png",
            width = 330,
            height = 307,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(40.5, 9.25),
            scale = 0.5
          },
        }
        }
    }
end

if data.raw["generator"]["steam-engine-3"] then
    data.raw["generator"]["steam-engine-3"]["horizontal_animation"] = {
        layers = {{
                filename = "__base__/graphics/entity/steam-engine/steam-engine-H.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-H-cap3.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-H-cap3.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
          width = 254,
          height = 80,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(48, 24),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H-shadow.png",
            width = 508,
            height = 160,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(48, 24),
            scale = 0.5
          },
        }
        }
    }
    data.raw["generator"]["steam-engine-3"]["vertical_animation"] = {

        layers = {
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-V.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-V-cap3.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-V-cap3.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
          width = 165,
          height = 153,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(40.5, 9.5),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V-shadow.png",
            width = 330,
            height = 307,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(40.5, 9.25),
            scale = 0.5
          },
        }
        }
    }    
end

if data.raw["generator"]["steam-engine-4"] then
    data.raw["generator"]["steam-engine-4"]["horizontal_animation"] = {
        layers = {{
                filename = "__base__/graphics/entity/steam-engine/steam-engine-H.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-H-cap4.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-H-cap4.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
          width = 254,
          height = 80,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(48, 24),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H-shadow.png",
            width = 508,
            height = 160,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(48, 24),
            scale = 0.5
          },
        }
        }
    }
    data.raw["generator"]["steam-engine-4"]["vertical_animation"] = {

        layers = {
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-V.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-V-cap4.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-V-cap4.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
          width = 165,
          height = 153,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(40.5, 9.5),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V-shadow.png",
            width = 330,
            height = 307,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(40.5, 9.25),
            scale = 0.5
          },
        }
        }
    }    
end


if data.raw["generator"]["steam-engine-5"] then
    data.raw["generator"]["steam-engine-5"]["horizontal_animation"] = {
        layers = {{
                filename = "__base__/graphics/entity/steam-engine/steam-engine-H.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-H-cap5.png",
                width = 176,
                height = 128,
                line_length = 8,
                frame_count = 32,
                shift = util.by_pixel(1, -5),
                hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-H-cap5.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(1, -4.75),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-H-shadow.png",
          width = 254,
          height = 80,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(48, 24),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H-shadow.png",
            width = 508,
            height = 160,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(48, 24),
            scale = 0.5
          },
        }
        }
    }
    data.raw["generator"]["steam-engine-5"]["vertical_animation"] = {

        layers = {
            {
                filename = "__base__/graphics/entity/steam-engine/steam-engine-V.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-V-cap5.png",
				width = 112,
				height = 195,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(5, -6.5),
				hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-V-cap5.png",
                    width = 225,
                    height = 391,
                    line_length = 8,
                    frame_count = 32,
                    shift = util.by_pixel(4.75, -6.25),
                    scale = 0.5
                }
            },
        {
          filename = "__base__/graphics/entity/steam-engine/steam-engine-V-shadow.png",
          width = 165,
          height = 153,
          frame_count = 32,
          line_length = 8,
          draw_as_shadow = true,
          shift = util.by_pixel(40.5, 9.5),
          hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V-shadow.png",
            width = 330,
            height = 307,
            frame_count = 32,
            line_length = 8,
            draw_as_shadow = true,
            shift = util.by_pixel(40.5, 9.25),
            scale = 0.5
          },
        }
        }
    }    
end


if data.raw["generator"]["steam-turbine-2"] then
    data.raw["generator"]["steam-turbine-2"]["horizontal_animation"] = {
        layers = {
		{
		filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/steam-turbine-H-2.png",
        width = 160,
        height = 123,
        frame_count = 8,
        line_length = 4,
        shift = util.by_pixel(0, -2.5),
        hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/hr-steam-turbine-H-2.png",
            width = 320,
            height = 245,
            frame_count = 8,
            line_length = 4,
            shift = util.by_pixel(0, -2.75),
            scale = 0.5
        }
    },{
          filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
          width = 217,
          height = 74,
          repeat_count = 8,
          frame_count = 1,
          line_length = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(28.75, 18),
          hr_version = {
            filename = "__base__/graphics/entity/steam-turbine/hr-steam-turbine-H-shadow.png",
            width = 435,
            height = 150,
            repeat_count = 8,
            frame_count = 1,
            line_length = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(28.5, 18),
            scale = 0.5
          },
        }
	}
}

    data.raw["generator"]["steam-turbine-2"]["vertical_animation"] = {
        layers = {
		{
		filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/steam-turbine-V-2.png",
        width = 108,
        height = 173,
        frame_count = 8,
        line_length = 4,
        shift = util.by_pixel(5, 6.5),
        hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/hr-steam-turbine-V-2.png",
            width = 217,
            height = 347,
            frame_count = 8,
            line_length = 4,
            shift = util.by_pixel(4.75, 6.75),
            scale = 0.5
			}
        },
        {
          filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
          width = 151,
          height = 131,
          repeat_count = 8,
          frame_count = 1,
          line_length = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(39.5, 24.5),
          hr_version = {
            filename = "__base__/graphics/entity/steam-turbine/hr-steam-turbine-V-shadow.png",
            width = 302,
            height = 260,
            repeat_count = 8,
            frame_count = 1,
            line_length = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(39.5, 24.5),
            scale = 0.5
          },
        }
    }
}
end

if data.raw["generator"]["steam-turbine-3"] then
    data.raw["generator"]["steam-turbine-3"]["horizontal_animation"] = {
        layers = {
		{
		filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/steam-turbine-H-3.png",
        width = 160,
        height = 123,
        frame_count = 8,
        line_length = 4,
        shift = util.by_pixel(0, -2.5),
        hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/hr-steam-turbine-H-3.png",
            width = 320,
            height = 245,
            frame_count = 8,
            line_length = 4,
            shift = util.by_pixel(0, -2.75),
            scale = 0.5
        }
    },{
          filename = "__base__/graphics/entity/steam-turbine/steam-turbine-H-shadow.png",
          width = 217,
          height = 74,
          repeat_count = 8,
          frame_count = 1,
          line_length = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(28.75, 18),
          hr_version = {
            filename = "__base__/graphics/entity/steam-turbine/hr-steam-turbine-H-shadow.png",
            width = 435,
            height = 150,
            repeat_count = 8,
            frame_count = 1,
            line_length = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(28.5, 18),
            scale = 0.5
          },
        }
	}
}

    data.raw["generator"]["steam-turbine-3"]["vertical_animation"] = {
        layers = {
		{
		filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/steam-turbine-V-3.png",
        width = 108,
        height = 173,
        frame_count = 8,
        line_length = 4,
        shift = util.by_pixel(5, 6.5),
        hr_version = {
            filename = "__ShinyBobGFX__/graphics/entity/steam-turbine/hr-steam-turbine-V-3.png",
            width = 217,
            height = 347,
            frame_count = 8,
            line_length = 4,
            shift = util.by_pixel(4.75, 6.75),
            scale = 0.5
			}
        },
        {
          filename = "__base__/graphics/entity/steam-turbine/steam-turbine-V-shadow.png",
          width = 151,
          height = 131,
          repeat_count = 8,
          frame_count = 1,
          line_length = 1,
          draw_as_shadow = true,
          shift = util.by_pixel(39.5, 24.5),
          hr_version = {
            filename = "__base__/graphics/entity/steam-turbine/hr-steam-turbine-V-shadow.png",
            width = 302,
            height = 260,
            repeat_count = 8,
            frame_count = 1,
            line_length = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(39.5, 24.5),
            scale = 0.5
          },
        }
    }
}
end

--[[
if data.raw["generator"]["steam-engine"] then
    data.raw["generator"]["steam-engine"].icon = "__ShinyBobGFX__/graphics/entity/steam-engines/icon/steam-engine-1b.png"
    data.raw["item"]["steam-engine"].icon = "__ShinyBobGFX__/graphics/entity/steam-engines/icon/steam-engine-1b.png"
    data.raw["generator"]["steam-engine"]["horizontal_animation"] = {
        layers = {{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-horizontal-1.png",
                width = 246,
                height = 137,
                line_length = 8,
                frame_count = 32,
                shift = {1.34, -0.05},
                hr_version = {
                    filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-H.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = {0.032, -0.15},
                    scale = 0.5
                }},{
                filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-horizontal-1.png",
                width = 246,
                height = 137,
                line_length = 8,
                frame_count = 32,
                shift = {1.34, -0.05},
                tint = {r=0.71, g=0.65, b=0.26, a=0.9},
                hr_version = {
                    filename = "__ShinyBobGFX__/graphics/entity/steam-engines/hr-steam-engine-H-cap2.png",
                    width = 352,
                    height = 257,
                    line_length = 8,
                    frame_count = 32,
                    shift = {0.032, -0.15},
                    scale = 0.5
                }
    }}}

    data.raw["generator"]["steam-engine"]["vertical_animation"] = {
        filename = "__ShinyBobGFX__/graphics/entity/steam-engines/steam-engine-vertical-1.png",
        width = 155,
        height = 186,
        line_length = 8,
        frame_count = 32,
        shift = {0.8, 0.03},
        hr_version = {
            filename = "__base__/graphics/entity/steam-engine/hr-steam-engine-V.png",
            width = 225,
            height = 391,
            line_length = 8,
            frame_count = 32,
            shift = {0.14, -0.2},
            scale = 0.5
        }
    }
end
--]]
