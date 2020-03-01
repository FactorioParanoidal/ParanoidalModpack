data:extend(
{
  {
    type = "item",
    name = "check-valve",
    icon = "__Flow Control__/graphics/icon/check-valve.png",
    icon_size = 32,
    subgroup = "energy-pipe-distribution",
    order = "b[pipe]-c[pump]a",
    place_result = "check-valve",
    stack_size = 50
  },
  {
    type = "item",
    name = "overflow-valve",
    icon = "__Flow Control__/graphics/icon/overflow-valve.png",
    icon_size = 32,
    subgroup = "energy-pipe-distribution",
    order = "b[pipe]-c[pump]b",
    place_result = "overflow-valve",
    stack_size = 50
  },
  {
    type = "item",
    name = "underflow-valve",
    icon = "__Flow Control__/graphics/icon/underflow-valve.png",
    icon_size = 32,
    subgroup = "energy-pipe-distribution",
    order = "b[pipe]-c[pump]bb",
    place_result = "underflow-valve",
    stack_size = 50
  },
  {
    type = "item",
    name = "pipe-elbow",
    icon = "__Flow Control__/graphics/icon/pipe-elbow.png",
    icon_size = 32,
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-a[pipe]a",
    place_result = "pipe-elbow",
    stack_size = 50
  },
  {
    type = "item",
    name = "pipe-junction",
    icon = "__Flow Control__/graphics/icon/pipe-junction.png",
    icon_size = 32,
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-a[pipe]b",
    place_result = "pipe-junction",
    stack_size = 50
  },
  {
    type = "item",
    name = "pipe-straight",
    icon = "__Flow Control__/graphics/icon/pipe-straight.png",
    icon_size = 32,
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-a[pipe]c",
    place_result = "pipe-straight",
    stack_size = 50
  }
})