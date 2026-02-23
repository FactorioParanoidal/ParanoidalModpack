data:extend({
  {
    type = "item",
    name = "orbital-fabricator-component",
    icon = "__expanded-rocket-payloads-continued__/graphic/space-fabricator-32.png",
    icon_size = 32,
    subgroup = "buildings",
    order = "n",
    stack_size = 1
  },
  {
    type = "item",
    name = "ground-fabricator-component",
    icon = "__expanded-rocket-payloads-continued__/graphic/ground-fabricator-component-32.png",
    icon_size = 32,
    subgroup = "buildings",
    order = "n",
    stack_size = 4
  },
  {
    type = "item",
    name = "fabricator-shuttle",
    icon = "__expanded-rocket-payloads-continued__/graphic/fabricator-shuttle-32.png",
    icon_size = 32,
    subgroup = "Space-Shuttles",
    stack_size = 1,
    rocket_launch_products = { { type = "item", name = "landed-fabricator-shuttle", amount = 1 } },
    weight = 1000,
    send_to_orbit_mode = "automated"

  },
  {
    type = "item",
    name = "landed-fabricator-shuttle",
    icon = "__expanded-rocket-payloads-continued__/graphic/landed-fabricator-shuttle-32.png",
    icon_size = 32,
    subgroup = "shuttle-processies",
    order = "a",
    stack_size = 1,
  },
  {
    type = "item",
    name = "ground-auto-fabricator",
    icon = "__expanded-rocket-payloads-continued__/graphic/auto-fabricator-32.png",
    icon_size = 32,
    subgroup = "buildings",
    order = "mS",
    stack_size = 1,
    place_result = "ground-auto-fabricator",
  },
})
