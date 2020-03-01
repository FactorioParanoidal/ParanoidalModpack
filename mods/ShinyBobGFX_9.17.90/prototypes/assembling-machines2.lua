if settings.startup["replace-assemblycolors"].value == true then
    if data.raw["assembling-machine"]["assembling-machine-1"] then
        data.raw["item"]["assembling-machine-1"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-1.png"
        data.raw["assembling-machine"]["assembling-machine-1"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-1.png"
    end

    if data.raw["assembling-machine"]["assembling-machine-2"] then
        data.raw["item"]["assembling-machine-2"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-2.png"
        data.raw["assembling-machine"]["assembling-machine-2"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-2.png"
        data.raw["assembling-machine"]["assembling-machine-2"]["animation"] = {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2.png",
                        priority = "high",
                        width = 214,
                        height = 218,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, 4),
                        scale = 0.5
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-2-cap.png",
                        priority = "high",
                        width = 214,
                        height = 218,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, 4),
                        scale = 0.5
                    }
                    },{
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-noshad-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    draw_as_shadow = true,
                    shift = {0.4, -0.22},
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-shadow.png",
                        priority = "high",
                        width = 196,
                        height = 163,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(12, 4.75),
                        scale = 0.5
                    }
                },
        }}
    end

    if data.raw["assembling-machine"]["assembling-machine-3"] then
        data.raw["item"]["assembling-machine-3"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-3.png"
        data.raw["assembling-machine"]["assembling-machine-3"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-3.png"
        data.raw["assembling-machine"]["assembling-machine-3"]["animation"] = {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-3.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.85, -0.15},
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-3.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.85, -0.15},
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-3-cap.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                    },{
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-noshad-3.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.85, -0.15},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
                        priority = "high",
                        width = 260,
                        height = 162,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(28, 4),
                        scale = 0.5
                    }
                },
        }}
    end

    if data.raw["assembling-machine"]["assembling-machine-4"] then
        data.raw["item"]["assembling-machine-4"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-4.png"
        data.raw["assembling-machine"]["assembling-machine-4"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-4.png"
        data.raw["assembling-machine"]["assembling-machine-4"]["animation"] = {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-4.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-4.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-4-cap.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                    },{
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-noshad-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
                        priority = "high",
                        width = 260,
                        height = 162,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(28, 4),
                        scale = 0.5
                    }
                },
        }}
    end

    if data.raw["assembling-machine"]["assembling-machine-5"] then
        data.raw["item"]["assembling-machine-5"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-5.png"
        data.raw["assembling-machine"]["assembling-machine-5"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-5.png"
        data.raw["assembling-machine"]["assembling-machine-5"]["animation"] = {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-5.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-5.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-5-cap.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                    },{
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-noshad-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
                        priority = "high",
                        width = 260,
                        height = 162,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(28, 4),
                        scale = 0.5
                    }
                },
        }}
    end

    if data.raw["assembling-machine"]["assembling-machine-6"] then
        data.raw["item"]["assembling-machine-6"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-6.png"
        data.raw["assembling-machine"]["assembling-machine-6"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-6.png"
        data.raw["assembling-machine"]["assembling-machine-6"]["animation"] = {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-6.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.85, -0.15},
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-6.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.85, -0.15},
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-6-cap.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.5
                    }
                    },{
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-noshad-3.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.85, -0.15},
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
                        priority = "high",
                        width = 260,
                        height = 162,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(28, 4),
                        scale = 0.5
                    }
                },
        }}
    end
end

    --[[
    if data.raw["assembling-machine"]["assembling-machine-1"] then
        data.raw["item"]["assembling-machine-1"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-1.png"
        data.raw["assembling-machine"]["assembling-machine-1"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-1.png"
        data.raw["assembling-machine"]["assembling-machine-1"]["animation"] = {
            priority = "extra-high",
            width = 99,
            height = 102,
            line_length = 8,
            shift = {0, 0},
            filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-1.png",
            frame_count = 32,
            animation_speed = 0.5,
            hr_version = {
                priority = "extra-high",
                width = 214,
                height = 226,
                line_length = 8,
                shift = {0, 0},
                filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-1.png",
                frame_count = 32,
                animation_speed = 0.5,
                scale = 0.5
            },
        }
    end

    if data.raw["assembling-machine"]["assembling-machine-2"] then
        data.raw["item"]["assembling-machine-2"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-2.png"
        data.raw["assembling-machine"]["assembling-machine-2"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-2.png"
        data.raw["assembling-machine"]["assembling-machine-2"]["animation"] = {
            priority = "extra-high",
            width = 113,
            height = 99,
            line_length = 8,
            shift = {0.4, -0.1},
            filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-2.png",
            frame_count = 32,
            animation_speed = 0.75,
            hr_version = {
                priority = "extra-high",
                width = 214,
                height = 218,
                line_length = 8,
                shift = {0, 0.1},
                filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-2b.png",
                frame_count = 32,
                animation_speed = 0.75,
                scale = 0.5
            },
        }
    end

    if data.raw["assembling-machine"]["assembling-machine-3"] then
        data.raw["item"]["assembling-machine-3"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-3.png"
        data.raw["assembling-machine"]["assembling-machine-3"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-3.png"
        data.raw["assembling-machine"]["assembling-machine-3"]["animation"] = {
            priority = "extra-high",
            width = 142,
            height = 113,
            line_length = 8,
            shift = {0.84, -0.16},
            filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-3.png",
            frame_count = 32,
            animation_speed = 1.25,
            hr_version = {
                priority = "extra-high",
                width = 214,
                height = 237,
                line_length = 8,
                shift = {0, -0.05},
                filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-3b.png",
                frame_count = 32,
                animation_speed = 1.25,
                scale = 0.5
            },
        }
    end

    if data.raw["assembling-machine"]["assembling-machine-4"] then
        data.raw["item"]["assembling-machine-4"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-4.png"
        data.raw["assembling-machine"]["assembling-machine-4"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-4.png"
        data.raw["assembling-machine"]["assembling-machine-4"]["animation"] = {
            priority = "extra-high",
            width = 113,
            height = 99,
            line_length = 8,
            shift = {0.4, -0.1},
            filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-4.png",
            frame_count = 32,
            animation_speed = 2,
            hr_version = {
                priority = "extra-high",
                width = 214,
                height = 237,
                line_length = 8,
                shift = {0, -0.05},
                filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-4.png",
                frame_count = 32,
                animation_speed = 2,
                scale = 0.5
            },
        }
    end

    if data.raw["assembling-machine"]["assembling-machine-5"] then
        data.raw["item"]["assembling-machine-5"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-5.png"
        data.raw["assembling-machine"]["assembling-machine-5"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-5.png"
        data.raw["assembling-machine"]["assembling-machine-5"]["animation"] = {
            priority = "extra-high",
            width = 113,
            height = 99,
            line_length = 8,
            shift = {0.4, -0.1},
            filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-5.png",
            frame_count = 32,
            animation_speed = 2.75,
            hr_version = {
                priority = "extra-high",
                width = 214,
                height = 237,
                line_length = 8,
                shift = {0, -0.05},
                filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-5.png",
                frame_count = 32,
                animation_speed = 2.75,
                scale = 0.5
            },
        }
    end

    if data.raw["assembling-machine"]["assembling-machine-6"] then
        data.raw["item"]["assembling-machine-6"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-6.png"
        data.raw["assembling-machine"]["assembling-machine-6"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/assembling-machine-6.png"
        data.raw["assembling-machine"]["assembling-machine-6"]["animation"] = {
            priority = "extra-high",
            width = 142,
            height = 113,
            line_length = 8,
            shift = {0.84, -0.16},
            filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-6.png",
            frame_count = 32,
            animation_speed = 3.5,
            hr_version = {
                priority = "extra-high",
                width = 214,
                height = 237,
                line_length = 8,
                shift = {0, -0.05},
                filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-6.png",
                frame_count = 32,
                animation_speed = 3.5,
                scale = 0.5
            },
        }
    end
    --]]
