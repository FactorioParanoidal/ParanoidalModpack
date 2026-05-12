local frame_count = 32
local scale = 0.5
local animation_speed = 0.5

local space_platform_entity_build_animations = mods["space-age"] and require("__space-age__/graphics/entity/space-platform-build-anim/entity-build-animations") or {
    back_left =
    {
        top =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/back-L-top", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        },
        body =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/back-L", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                }),
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/back-L-shadow", {
                    draw_as_shadow = true,
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        }
    },
    back_right =
    {
        top =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/back-R-top", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        },
        body =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/back-R", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                }),
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/back-R-shadow", {
                    draw_as_shadow = true,
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        }
    },
    front_left =
    {
        top =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/front-L-top", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        },
        body =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/front-L", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                }),
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/front-L-shadow", {
                    draw_as_shadow = true,
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        }
    },
    front_right =
    {
        top =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/front-R-top", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        },
        body =
        {
            layers =
            {
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/front-R", {
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                }),
                util.sprite_load("__factorissimo-2-notnotmelon__/graphics/space-platform-build-anim/front-R-shadow", {
                    draw_as_shadow = true,
                    frame_count = frame_count,
                    scale = scale,
                    animation_speed = animation_speed
                })
            }
        }
    }
}

-- https://mods.factorio.com/mod/platform-construction-only-no-construction-robots
local function make_animation_prototype(a, b)
    local animation = table.deepcopy(space_platform_entity_build_animations[a][b])
    animation.type = "animation"
    animation.name = string.format("platform_entity_build_animations-%s-%s", a, b)
    data:extend {animation}
end

make_animation_prototype("back_left", "top")
make_animation_prototype("back_left", "body")

make_animation_prototype("back_right", "top")
make_animation_prototype("back_right", "body")

make_animation_prototype("front_left", "top")
make_animation_prototype("front_left", "body")

make_animation_prototype("front_right", "top")
make_animation_prototype("front_right", "body")
