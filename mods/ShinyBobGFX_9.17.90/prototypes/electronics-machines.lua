if settings.startup["replace-assemblycolors"].value == false then
if powerbar == 1 then
if data.raw["assembling-machine"]["assembling-machine-6"] then
bobiconNA("electronics-machine","assembling-machine",1,1,0)
bobiconNA("electronics-machine","assembling-machine",2,2,-1)
bobiconNA("electronics-machine","assembling-machine",3,3,-2)
end
end
end


if settings.startup["replace-assemblycolors"].value == true then
    if data.raw["assembling-machine"]["electronics-machine-1"] then
		bobicon("electronics-machine","assembling-machine",1,1,0)
		bobicon("electronics-machine","assembling-machine",2,2,-1)
		bobicon("electronics-machine","assembling-machine",3,3,-2)
        data.raw["assembling-machine"]["electronics-machine-1"]["animation"] = {
            layers =
            {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.28, -0.1},
                    scale = 0.66,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2.png",
                        priority = "high",
                        width = 214,
                        height = 218,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, 4),
                        scale = 0.33
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.28, -0.1},
                    scale = 0.66,
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-2-cap.png",
                        priority = "high",
                        width = 214,
                        height = 218,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, 4),
                        scale = 0.33
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-noshad-2.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.4, -0.22},
                    draw_as_shadow = true,
                    scale = 0.66,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-shadow.png",
                        priority = "high",
                        width = 196,
                        height = 163,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(10, 4.75),
                        scale = 0.33
                    }
                },
        }}
    end

    if data.raw["assembling-machine"]["electronics-machine-2"] then
        data.raw["assembling-machine"]["electronics-machine-2"]["animation"] = {
            layers = {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-4.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.28, -0.1},
                    scale = 0.66,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.33
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-4.png",
                    priority = "high",
                    width = 113,
                    height = 99,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.28, -0.1},
                    scale = 0.66,
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-4-cap.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.33
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
                    scale = 0.66,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
                        priority = "high",
                        width = 260,
                        height = 162,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(18, 4),
                        scale = 0.33
                    },
        }}}
    end

    if data.raw["assembling-machine"]["electronics-machine-3"] then
        data.raw["assembling-machine"]["electronics-machine-3"]["animation"] = {
            layers = {
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-6.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.56, -0.16},
                    scale = 0.66,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.33
                    }
                },
                {
                    filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/assembling-machine-6.png",
                    priority = "high",
                    width = 142,
                    height = 113,
                    frame_count = 32,
                    line_length = 8,
                    shift = {0.56, -0.16},
                    scale = 0.66,
                    hr_version = {
                        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-6-cap.png",
                        priority = "high",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        line_length = 8,
                        shift = util.by_pixel(0, -0.75),
                        scale = 0.33
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
                    scale = 0.66,
                    hr_version = {
                        filename = "__base__/graphics/entity/assembling-machine-3/hr-assembling-machine-3-shadow.png",
                        priority = "high",
                        width = 260,
                        height = 162,
                        frame_count = 32,
                        line_length = 8,
                        draw_as_shadow = true,
                        shift = util.by_pixel(18, 4),
                        scale = 0.33
                    },
        }}}
    end
end

--[[
if data.raw["assembling-machine"]["electronics-machine-1"] then
    data.raw["item"]["electronics-machine-1"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/electronics-machine-1.png"
    data.raw["assembling-machine"]["electronics-machine-1"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/electronics-machine-1.png"
    data.raw["assembling-machine"]["electronics-machine-1"]["animation"] = {
        priority = "extra-high",
        width = 214,
        height = 218,
        line_length = 8,
        shift = {0, 0},
        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-2b.png",
        frame_count = 32,
        animation_speed = 1,
        scale = 0.33
    }
end

if data.raw["assembling-machine"]["electronics-machine-2"] then
    data.raw["item"]["electronics-machine-2"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/electronics-machine-2.png"
    data.raw["assembling-machine"]["electronics-machine-2"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/electronics-machine-2.png"
    data.raw["assembling-machine"]["electronics-machine-2"]["animation"] = {
        priority = "extra-high",
        width = 214,
        height = 237,
        line_length = 8,
        shift = {0, 0},
        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-4.png",
        frame_count = 32,
        animation_speed = 1,
        scale = 0.33
    }
end

if data.raw["assembling-machine"]["electronics-machine-3"] then
    data.raw["item"]["electronics-machine-3"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/electronics-machine-3.png"
    data.raw["assembling-machine"]["electronics-machine-3"].icon = "__ShinyBobGFX__/graphics/entity/assembling-machines/icon/electronics-machine-3.png"
    data.raw["assembling-machine"]["electronics-machine-3"]["animation"] = {
        priority = "extra-high",
        width = 214,
        height = 237,
        line_length = 8,
        shift = {0, 0},
        filename = "__ShinyBobGFX__/graphics/entity/assembling-machines/hr-assembling-machine-6.png",
        frame_count = 32,
        animation_speed = 1,
        scale = 0.33
    }
end
--]]
