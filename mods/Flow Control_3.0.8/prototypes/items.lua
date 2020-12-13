local pipe_subgroup = "energy-pipe-distribution"

if settings.startup["flow-control-new-group"].value then
  data:extend({
    {
      type = "item-subgroup",
      name = "pipe-distribution",
      group = "logistics",
      order = "da"
    }
  })
  pipe_subgroup = "pipe-distribution"
  data.raw.item["pipe"].subgroup = "pipe-distribution"
  data.raw.item["pipe-to-ground"].subgroup = "pipe-distribution"
  data.raw.item["pump"].subgroup = "pipe-distribution"
end

data:extend({
  {
    type = "item",
    name = "check-valve",
    icon = "__Flow Control__/graphics/icon/check-valve.png",
    icon_size = 32,
    subgroup = pipe_subgroup,
    order = "b[pipe]-c[pump]a",
    place_result = "check-valve",
    stack_size = 50
  },
  {
    type = "item",
    name = "overflow-valve",
    icon = "__Flow Control__/graphics/icon/overflow-valve.png",
    icon_size = 32,
    subgroup = pipe_subgroup,
    order = "b[pipe]-c[pump]b",
    place_result = "overflow-valve",
    stack_size = 50
  },
  {
    type = "item",
    name = "underflow-valve",
    icon = "__Flow Control__/graphics/icon/underflow-valve.png",
    icon_size = 32,
    subgroup = pipe_subgroup,
    order = "b[pipe]-c[pump]c",
    place_result = "underflow-valve",
    stack_size = 50
  },
  {
    type = "item",
    name = "pipe-elbow",
    icon = "__Flow Control__/graphics/icon/pipe-elbow.png",
    icon_size = 32,
    subgroup = pipe_subgroup,
    order = "b[pipe]-a[pipe]e",
    place_result = "pipe-elbow",
    stack_size = 50
  },
  {
    type = "item",
    name = "pipe-junction",
    icon = "__Flow Control__/graphics/icon/pipe-junction.png",
    icon_size = 32,
    subgroup = pipe_subgroup,
    order = "b[pipe]-a[pipe]c",
    place_result = "pipe-junction",
    stack_size = 50
  },
  {
    type = "item",
    name = "pipe-straight",
    icon = "__Flow Control__/graphics/icon/pipe-straight.png",
    icon_size = 32,
    subgroup = pipe_subgroup,
    order = "b[pipe]-a[pipe]d",
    place_result = "pipe-straight",
    stack_size = 50
  }
})