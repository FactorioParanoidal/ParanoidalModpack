data:extend({
  {
    type = "recipe-category",
    name = "crafting-air-filter"
  },
  {
    type = "recipe",
    name = "air-filter-machine",
    icon = "__air-filtering__/graphics/icons/air-filter-machine.png",
    icon_size = 32,
    energy_required = 10.0,
    enabled = false,
    ingredients =
    {
      {type="item", name="assembling-machine-2", amount=1},
      {type="item", name="electronic-circuit", amount=5},
      {type="item", name="steel-plate", amount=10}
    },
    results = {{type="item", name="air-filter-machine", amount=1}}
  },
  {
    type = "recipe",
    name = "air-filter-machine-mk2",
    icon = "__air-filtering__/graphics/icons/air-filter-machine-mk2.png",
    icon_size = 32,
    energy_required = 10.0,
    enabled = false,
    ingredients =
    {
      {type="item", name="air-filter-machine", amount=2},
      {type="item", name="advanced-circuit", amount=10}
    },
    results = {{type="item", name="air-filter-machine-mk2", amount=1}}
  },
  {
    type = "recipe",
    name = "air-filter-machine-mk3",
    icon = "__air-filtering__/graphics/icons/air-filter-machine-mk3.png",
    icon_size = 32,
    energy_required = 10.0,
    enabled = false,
    ingredients =
    {
      {type="item", name="air-filter-machine-mk2", amount=2},
      {type="item", name="processing-unit", amount=10}
    },
    results = {{type="item", name="air-filter-machine-mk3", amount=1}}
  },
  {
    type = "recipe",
    name = "unused-air-filter",
    icon = "__air-filtering__/graphics/icons/unused-air-filter.png",
    icon_size = 32,
    category = "crafting",
    subgroup = "intermediate-product",
    order = "f[plastic-bar]-f[unused-air-filter]",
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {type="item", name="coal", amount=10},
      {type="item", name="plastic-bar", amount=4},
      {type="item", name="steel-plate", amount=2}
    },
    results = {{type="item", name="unused-air-filter", amount=1}}
  },
  {
    type = "recipe",
    name = "filter-air",
    icon = "__air-filtering__/graphics/icons/filter-air.png",
    icon_size = 32,
    category = "crafting-air-filter",
    order = "f[plastic-bar]-f[filter-air]",
    energy_required = 100,
    enabled = false,
    ingredients =
    {
      {type="item", name="unused-air-filter", amount=1}
    },
    results = {{type="item", name="used-air-filter", amount=1}}
  },
  {
    type = "recipe",
    name = "air-filter-recycling",
    icon = "__air-filtering__/graphics/icons/air-filter-recycling.png",
    icon_size = 32,
    category = "crafting",
    subgroup = "intermediate-product",
    order = "f[unused-air-filter]-f[air-filter-recycling]",
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {type="item", name="used-air-filter", amount=1},
      {type="item", name="coal", amount=5}
    },
    results = {{type="item", name="unused-air-filter", amount=1}}
  }
})
