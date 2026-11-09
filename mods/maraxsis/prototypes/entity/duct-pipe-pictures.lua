local function duct_pipe_pictures()
    local sprite_4_way = {}

    sprite_4_way.west = {
        layers = {
            {
                filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left.png",
                height = 256,
                priority = "high",
                scale = 0.5,
                width = 256,
                shift = {1.25, 0}
            },
            {
                draw_as_shadow = true,
                filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-left-shadow.png",
                height = 256,
                priority = "high",
                scale = 0.5,
                width = 256,
                shift = {1.25, 0}
            },
        },
    }

    sprite_4_way.east = {
        layers = {
            {
                filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right.png",
                height = 256,
                priority = "high",
                scale = 0.5,
                width = 256,
                shift = {-1.25, 0}
            },
            {
                draw_as_shadow = true,
                filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-right-shadow.png",
                height = 256,
                priority = "high",
                scale = 0.5,
                width = 256,
                shift = {-1.25, 0}
            },
        },
    }

    sprite_4_way.south = {
        layers = {
            {
                filename = "__maraxsis__/graphics/entity/hydro-plant/pipe-cover.png",
                height = 128,
                priority = "high",
                scale = 0.5,
                width = 128,
                shift = {0, -0.55}
            },
            {
                draw_as_shadow = true,
                filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-down-shadow.png",
                height = 256,
                priority = "high",
                scale = 0.5,
                width = 256,
                shift = {0, -1.5}
            },
        },
    }

    sprite_4_way.north = {
        layers = {
            {
                filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up.png",
                height = 256,
                priority = "high",
                scale = 0.5,
                width = 256,
                shift = {0, 1.5}
            },
            {
                draw_as_shadow = true,
                filename = "__FluidMustFlow__/graphics/buildings/duct-ground/duct-ground-up-shadow.png",
                height = 256,
                priority = "high",
                scale = 0.5,
                width = 256,
                shift = {0, 1.5}
            },
        },
    }

    return sprite_4_way
end

return duct_pipe_pictures()