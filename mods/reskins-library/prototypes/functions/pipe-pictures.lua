-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---@alias PipeMaterials
---| '"iron"'
---| '"brass"'
---| '"bronze"'
---| '"ceramic"'
---| '"copper"'
---| '"copper-tungsten"'
---| '"nitinol"'
---| '"plastic"'
---| '"steel"'
---| '"stone"'
---| '"titanium"'
---| '"tungsten"'
---| '"angels-ceramic"'
---| '"angels-nitinol"'
---| '"angels-titanium"'
---| '"angels-tungsten"'

--- Gets the root path to the location of the pipe pictures for the given `material`.
---@param material PipeMaterials
---@return string, string
local function get_path_to_material(material)
    ---@type string
    local path
    if material == "iron" then
        path = reskins.lib.directory .. "/graphics/entity/common"
    elseif material:find("angels") then
        material = material:gsub("angels%-", "")
        path = reskins.angels.directory .. "/graphics/entity/smelting"
    else
        path = reskins.bobs.directory .. "/graphics/entity/logistics"
    end

    return path, material
end

--- Gets the standard set of pipe pictures for the given `material`.
---@param material PipeMaterials # The material to get pipe pictures for.
---@return data.PipePictures # Pipe pictures for the requested `material`.
function reskins.lib.get_pipe_pictures(material)
    local path_to_root_folder, material_folder = get_path_to_material(material)

    ---@type data.PipePictures
    local pipe_pictures = {
        straight_vertical_single = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-straight-vertical-single.png",
                    priority = "extra-high",
                    width = 80,
                    height = 80,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-straight-vertical-single.png",
                        priority = "extra-high",
                        width = 160,
                        height = 160,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-straight-vertical-single-shadow.png",
                    priority = "extra-high",
                    width = 80,
                    height = 80,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-straight-vertical-single-shadow.png",
                        priority = "extra-high",
                        width = 160,
                        height = 160,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        straight_vertical = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-straight-vertical.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-straight-vertical.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-straight-vertical-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-straight-vertical-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        straight_vertical_window = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-straight-vertical-window.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-straight-vertical-window.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-straight-vertical-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-straight-vertical-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        straight_horizontal_window = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-straight-horizontal-window.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-straight-horizontal-window.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-straight-horizontal-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-straight-horizontal-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        straight_horizontal = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-straight-horizontal.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-straight-horizontal.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-straight-horizontal-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-straight-horizontal-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        corner_up_right = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-corner-up-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-corner-up-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-corner-up-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-corner-up-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        corner_up_left = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-corner-up-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-corner-up-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-corner-up-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-corner-up-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        corner_down_right = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-corner-down-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-corner-down-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-corner-down-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-corner-down-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        corner_down_left = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-corner-down-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-corner-down-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-corner-down-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-corner-down-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        t_up = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-t-up.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-t-up.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-t-up-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-t-up-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        t_down = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-t-down.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-t-down.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-t-down-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-t-down-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        t_right = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-t-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-t-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-t-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-t-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        t_left = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-t-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-t-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-t-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-t-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        cross = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-cross.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-cross.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-cross-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-cross-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        ending_up = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-ending-up.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-ending-up.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-ending-up-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-ending-up-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        ending_down = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-ending-down.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-ending-down.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-ending-down-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-ending-down-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        ending_right = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-ending-right.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-ending-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-ending-right-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-ending-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        ending_left = {
            layers = {
                -- Base
                {
                    filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-ending-left.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-ending-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/pipe-ending-left-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe/shadows/hr-pipe-ending-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        horizontal_window_background = {
            filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-horizontal-window-background.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version = {
                filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-horizontal-window-background.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
            },
        },
        vertical_window_background = {
            filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/pipe-vertical-window-background.png",
            priority = "extra-high",
            width = 64,
            height = 64,
            hr_version = {
                filename = path_to_root_folder .. "/pipe/" .. material_folder .. "/hr-pipe-vertical-window-background.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                scale = 0.5,
            },
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
                scale = 0.5,
            },
        },
        low_temperature_flow = {
            filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18,
        },
        middle_temperature_flow = {
            filename = "__base__/graphics/entity/pipe/fluid-flow-medium-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18,
        },
        high_temperature_flow = {
            filename = "__base__/graphics/entity/pipe/fluid-flow-high-temperature.png",
            priority = "extra-high",
            width = 160,
            height = 18,
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
                direction_count = 1,
            },
        },
    }

    return pipe_pictures
end

--- Gets the standard set of pipe-to-ground pictures for the given `material`.
---@param material PipeMaterials
---@return data.PipeToGroundPictures # Pipe-to-ground pictures for the requested `material`.
function reskins.lib.get_pipe_to_ground_pictures(material)
    local path_to_root_folder, material_folder = get_path_to_material(material)

    ---@type data.PipeToGroundPictures
    local pipe_to_ground_pictures = {
        up = {
            layers = {
                -- Pipe
                {
                    filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/pipe-to-ground-up.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/hr-pipe-to-ground-up.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-up-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-up-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        down = {
            layers = {
                -- Pipe
                {
                    filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/pipe-to-ground-down.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/hr-pipe-to-ground-down.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-down-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-down-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        left = {
            layers = {
                -- Pipe
                {
                    filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/pipe-to-ground-left.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/hr-pipe-to-ground-left.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-left-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-left-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
        right = {
            layers = {
                -- Pipe
                {
                    filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/pipe-to-ground-right.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-to-ground/" .. material_folder .. "/hr-pipe-to-ground-right.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                -- Shadows
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-right-shadow.png",
                    priority = "high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-to-ground/shadows/hr-pipe-to-ground-right-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        draw_as_shadow = true,
                        scale = 0.5,
                    },
                },
            },
        },
    }

    return pipe_to_ground_pictures
end

--- Gets the standard set of pipe cover pictures for the given `material`.
---@param material PipeMaterials
---@return data.Sprite4Way # Pipe cover pictures for the requested `material`.
function reskins.lib.get_pipe_covers(material)
    local path_to_root_folder, material_folder = get_path_to_material(material)

    ---@type data.Sprite4Way
    local pipe_cover_pictures = {
        north = {
            layers = {
                {
                    filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/pipe-cover-north.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/hr-pipe-cover-north.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/pipe-cover-north-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-north-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true,
                    },
                },
            },
        },
        east = {
            layers = {
                {
                    filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/pipe-cover-east.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/hr-pipe-cover-east.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/pipe-cover-east-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-east-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true,
                    },
                },
            },
        },
        south = {
            layers = {
                {
                    filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/pipe-cover-south.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/hr-pipe-cover-south.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/pipe-cover-south-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-south-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true,
                    },
                },
            },
        },
        west = {
            layers = {
                {
                    filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/pipe-cover-west.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    hr_version = {
                        filename = path_to_root_folder .. "/pipe-covers/" .. material_folder .. "/hr-pipe-cover-west.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                    },
                },
                {
                    filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/pipe-cover-west-shadow.png",
                    priority = "extra-high",
                    width = 64,
                    height = 64,
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.lib.directory .. "/graphics/entity/common/pipe-covers/shadows/hr-pipe-cover-west-shadow.png",
                        priority = "extra-high",
                        width = 128,
                        height = 128,
                        scale = 0.5,
                        draw_as_shadow = true,
                    },
                },
            },
        },
    }

    return pipe_cover_pictures
end

---@deprecated
function reskins.lib.pipe_pictures(inputs)
    local material = inputs.material
    if inputs.mod == "angels" and (not material:find("angels-")) then
        material = "angels-" .. inputs.material
    end

    return reskins.lib.get_pipe_pictures(material)
end

---@deprecated
function reskins.lib.underground_pipe_pictures(inputs)
    local material = inputs.material
    if inputs.mod == "angels" and (not material:find("angels-")) then
        material = "angels-" .. inputs.material
    end

    return reskins.lib.get_pipe_to_ground_pictures(material)
end

---@deprecated
function reskins.lib.pipe_covers(inputs)
    local material = inputs.material
    if inputs.mod == "angels" and (not material:find("angels-")) then
        material = "angels-" .. inputs.material
    end

    return reskins.lib.get_pipe_covers(material)
end
