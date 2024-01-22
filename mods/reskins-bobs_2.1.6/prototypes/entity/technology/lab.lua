-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.technology.entities) then return end

-- Set input parameters
local inputs =
{
    type = "lab",
    root_name = "lab",
    base_entity_name = "lab",
    mod = "bobs",
    group = "technology",
    -- particles = {["big"] = 3}
}

local function reskin_lab(name)
    -- Fetch Entity
    local entity = data.raw["lab"][name]

    if not entity then return end

    entity.on_animation =
    {
        layers =
        {
            {
                filename = reskins.bobs.directory .. "/graphics/entity/technology/lab/" .. name .. ".png",
                width = 98,
                height = 87,
                frame_count = 33,
                line_length = 11,
                animation_speed = 1 / 3,
                shift = util.by_pixel(0, 1.5),
                hr_version =
                {
                    filename = reskins.bobs.directory .. "/graphics/entity/technology/lab/hr-" .. name .. ".png",
                    width = 194,
                    height = 174,
                    frame_count = 33,
                    line_length = 11,
                    animation_speed = 1 / 3,
                    shift = util.by_pixel(0, 1.5),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/lab/lab-integration.png",
                width = 122,
                height = 81,
                frame_count = 1,
                line_length = 1,
                repeat_count = 33,
                animation_speed = 1 / 3,
                shift = util.by_pixel(0, 15.5),
                hr_version =
                {
                    filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
                    width = 242,
                    height = 162,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 33,
                    animation_speed = 1 / 3,
                    shift = util.by_pixel(0, 15.5),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/lab/lab-shadow.png",
                width = 122,
                height = 68,
                frame_count = 1,
                line_length = 1,
                repeat_count = 33,
                animation_speed = 1 / 3,
                shift = util.by_pixel(13, 11),
                draw_as_shadow = true,
                hr_version =
                {
                    filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
                    width = 242,
                    height = 136,
                    frame_count = 1,
                    line_length = 1,
                    repeat_count = 33,
                    animation_speed = 1 / 3,
                    shift = util.by_pixel(13, 11),
                    scale = 0.5,
                    draw_as_shadow = true
                }
            }
        }
    }

    entity.off_animation =
    {
        layers =
        {
            {
                filename = reskins.bobs.directory .. "/graphics/entity/technology/lab/" .. name .. ".png",
                width = 98,
                height = 87,
                frame_count = 1,
                shift = util.by_pixel(0, 1.5),
                hr_version =
                {
                    filename = reskins.bobs.directory .. "/graphics/entity/technology/lab/hr-" .. name .. ".png",
                    width = 194,
                    height = 174,
                    frame_count = 1,
                    shift = util.by_pixel(0, 1.5),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/lab/lab-integration.png",
                width = 122,
                height = 81,
                frame_count = 1,
                shift = util.by_pixel(0, 15.5),
                hr_version =
                {
                    filename = "__base__/graphics/entity/lab/hr-lab-integration.png",
                    width = 242,
                    height = 162,
                    frame_count = 1,
                    shift = util.by_pixel(0, 15.5),
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/lab/lab-shadow.png",
                width = 122,
                height = 68,
                frame_count = 1,
                shift = util.by_pixel(13, 11),
                draw_as_shadow = true,
                hr_version =
                {
                    filename = "__base__/graphics/entity/lab/hr-lab-shadow.png",
                    width = 242,
                    height = 136,
                    frame_count = 1,
                    shift = util.by_pixel(13, 11),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    }
end

reskin_lab("lab-2")
reskin_lab("lab-alien")

-- lab
-- lab-2
-- lab-alien
-- burner-lab

-- Check to see if reskinning needs to be done.
if not mods["bobmodules"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmodules") == false then return end

-- lab-module
