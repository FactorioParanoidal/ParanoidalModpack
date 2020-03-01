--[[
-- Author: Mooncat
-- Refactored: Optera 2019
--]]

-- Add color mask to base game fluid wagon
-- Mods should copy this prototype afterwards if they wish to get a color mask
local fluid_wagon = data.raw["fluid-wagon"]["fluid-wagon"]
fluid_wagon.color = fluid_wagon.color or {r = 0, g = 0, b = 0, a = 0}
table.insert(fluid_wagon.pictures.layers,
  {
    flags = {"mask"},
    priority = "very-low",
    width = 208,
    height = 210,
    back_equals_front = true,
    apply_runtime_tint = true,
    allow_low_quality_rotation = true,
    direction_count = 128,
    filenames =
    {
      "__WagonColors__/graphics/fluid-wagon/fluid-wagon-1-color-mask.png",
      "__WagonColors__/graphics/fluid-wagon/fluid-wagon-2-color-mask.png",
      "__WagonColors__/graphics/fluid-wagon/fluid-wagon-3-color-mask.png",
      "__WagonColors__/graphics/fluid-wagon/fluid-wagon-4-color-mask.png"
    },
    line_length = 4,
    lines_per_file = 8,
    shift = {0 + 0.013, -1 + 0.077},
    hr_version =
    {
      flags = {"mask"},
        priority = "very-low",
      width = 416,
      height = 419,
      back_equals_front = true,
      apply_runtime_tint = true,
      allow_low_quality_rotation = true,
      direction_count = 128,
      filenames =
      {
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-1-color-mask.png",
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-2-color-mask.png",
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-3-color-mask.png",
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-4-color-mask.png",
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-5-color-mask.png",
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-6-color-mask.png",
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-7-color-mask.png",
        "__WagonColors__/graphics/fluid-wagon/hr-fluid-wagon-8-color-mask.png"
      },
      line_length = 4,
      lines_per_file = 4,
      shift = {0 + 0.013, -1 + 0.077},
      scale = 0.5
    }
  })

