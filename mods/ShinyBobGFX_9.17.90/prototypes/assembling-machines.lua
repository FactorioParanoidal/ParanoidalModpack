if settings.startup["replace-assemblycolors"].value == false then
if powerbar == 1 then
if data.raw["assembling-machine"]["assembling-machine-6"] then
bobiconNA("assembling-machine","assembling-machine",1,6,1)
end
end
end

if settings.startup["replace-assemblycolors"].value == true then
    if data.raw["assembling-machine"]["assembling-machine-6"] then
	bobicon("assembling-machine","assembling-machine",1,6,1)
	end	
	if data.raw["assembling-machine"]["assembling-machine-2"] then
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
