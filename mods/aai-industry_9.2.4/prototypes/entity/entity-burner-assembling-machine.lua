local burner_assembling_machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
burner_assembling_machine.name = "burner-assembling-machine"
burner_assembling_machine.icon = "__aai-industry__/graphics/icons/burner-assembling-machine.png"
burner_assembling_machine.minable.result = "burner-assembling-machine"
burner_assembling_machine.ingredient_count = 4
burner_assembling_machine.energy_source = {
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
data:extend({ burner_assembling_machine })
