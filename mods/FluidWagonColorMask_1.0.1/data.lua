--[[
-- Author: Mooncat
-- Refactored: Optera 2019
-- Tweaked: yeahtoast, 2020
--]]

-- Add color mask to base game fluid wagon
local fluid_wagon = data.raw["fluid-wagon"]["fluid-wagon"]
fluid_wagon.color = {r = 200, g = 200, b = 200, a = 128} --color mimics blank wagon
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
      "__FluidWagonColorMask__/graphics/fluid-wagon/fluid-wagon-mask-1.png",
      "__FluidWagonColorMask__/graphics/fluid-wagon/fluid-wagon-mask-2.png",
      "__FluidWagonColorMask__/graphics/fluid-wagon/fluid-wagon-mask-3.png",
      "__FluidWagonColorMask__/graphics/fluid-wagon/fluid-wagon-mask-4.png"
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
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-1.png",
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-2.png",
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-3.png",
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-4.png",
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-5.png",
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-6.png",
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-7.png",
        "__FluidWagonColorMask__/graphics/fluid-wagon/hr-fluid-wagon-mask-8.png"
      },
      line_length = 4,
      lines_per_file = 4,
      shift = {0 + 0.013, -1 + 0.077},
      scale = 0.5
    }
  })