data.raw.lab.lab.fast_replaceable_group = "lab"
local burner_lab = table.deepcopy(data.raw.lab.lab)
burner_lab.name = "burner-lab"
burner_lab.minable.result = "burner-lab"
burner_lab.energy_source = {
  type = "burner",
  fuel_category = "chemical",
  effectivity = 0.9,
  fuel_inventory_size = 1,
  emissions = 0.05,
  smoke =
  {
    {
      name = "smoke",
      deviation = {0.1, 0.1},
      position = {0.0, -0.9},
      frequency = 4
    }
  }
}
burner_lab.icon = "__aai-industry__/graphics/icons/burner-lab.png"
burner_lab.on_animation =
{
  layers =
  {
    {
      filename = "__aai-industry__/graphics/entity/burner-lab/burner-lab.png",
      width = 97,
      height = 87,
      frame_count = 33,
      line_length = 11,
      animation_speed = 1 / 3,
      shift = util.by_pixel(0, 1.5),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/burner-lab/hr-burner-lab.png",
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
      hr_version = {
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
      hr_version = {
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
burner_lab.off_animation =
{
  layers =
  {
    {
      filename = "__aai-industry__/graphics/entity/burner-lab/burner-lab.png",
      width = 97,
      height = 87,
      frame_count = 1,
      shift = util.by_pixel(0, 1.5),
      hr_version = {
        filename = "__aai-industry__/graphics/entity/burner-lab/hr-burner-lab.png",
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
      hr_version = {
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
      hr_version = {
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
burner_lab.module_specification = nil

data:extend({ burner_lab })
