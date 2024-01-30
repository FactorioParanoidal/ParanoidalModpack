local burner_assembling_machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
burner_assembling_machine.name = "burner-assembling-machine"
burner_assembling_machine.icon = "__aai-industry__/graphics/icons/burner-assembling-machine.png"
burner_assembling_machine.icon_size = 64
burner_assembling_machine.icon_mipmaps = 1
burner_assembling_machine.minable.result = "burner-assembling-machine"
burner_assembling_machine.next_upgrade = "assembling-machine-1"
burner_assembling_machine.energy_source = {
  type = "burner",
  fuel_category = "chemical",
  effectivity = 0.9,
  fuel_inventory_size = 1,
  emissions_per_minute = 4,
  light_flicker =
  {
    minimum_light_size = 1,
    light_intensity_to_size_coefficient = 0.2,
    color = {1,0.6,0},
    minimum_intensity = 0.05,
    maximum_intensity = 0.2
  },
  smoke =
  {
    {
      name = "smoke",
      deviation = {0.1, 0.1},
      position = {0.5, -1.5},
      frequency = 3
    }
  }
}
burner_assembling_machine.animation.layers[1] = {
  filename = "__aai-industry__/graphics/entity/burner-assembling-machine/burner-assembling-machine.png",
  priority="high",
  width = 107,
  height = 113,
  frame_count = 32,
  line_length = 8,
  shift = util.by_pixel(0, 2),
  hr_version = {
    filename = "__aai-industry__/graphics/entity/burner-assembling-machine/hr-burner-assembling-machine.png",
    priority="high",
    width = 214,
    height = 226,
    frame_count = 32,
    line_length = 8,
    shift = util.by_pixel(0, 2),
    scale = 0.5
  }
}
burner_assembling_machine.working_visualisations =
{
  {
    draw_as_glow = true,
    fadeout = true,
    animation =
    {
      filename = "__aai-industry__/graphics/entity/burner-assembling-machine/burner-assembling-machine-light.png",
      priority = "high",
      width = 214/2,
      height = 226/2,
      frame_count = 1,
      animation_speed = 1,
      shift = util.by_pixel(0, 2),
      draw_as_glow = true,
      blend_mode = "additive",
      hr_version = {
        filename = "__aai-industry__/graphics/entity/burner-assembling-machine/hr-burner-assembling-machine-light.png",
        priority = "high",
        width = 214,
        height = 226,
        frame_count = 1,
        animation_speed = 1,
        shift = util.by_pixel(0, 2),
        scale = 0.5,
        draw_as_glow = true,
        blend_mode = "additive",
      }
    }
  },
  --{
  --  effect = "uranium-glow", -- changes alpha based on energy source light intensity
  --  light = {intensity = 0.1, size = 18, shift = {0.0, 1}, color = {r = 1, g = 0.4, b = 0.1}}
  --},
}

data:extend({ burner_assembling_machine })
