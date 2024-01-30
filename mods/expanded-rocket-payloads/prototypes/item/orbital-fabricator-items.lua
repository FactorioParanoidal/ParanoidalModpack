data:extend({
    {
      type = "item",
      name = "orbital-fabricator-component",
      icon = "__expanded-rocket-payloads__/graphic/space-fabricator-32.png",
      icon_size = 32,
      subgroup = "buildings",
      order = "n",
      stack_size = 1
    },
    {
      type = "item",
      name = "ground-fabricator-component",
      icon = "__expanded-rocket-payloads__/graphic/ground-fabricator-component-32.png",
      icon_size = 32,
      subgroup = "buildings",
      order = "n",
      stack_size = 4
    },
    {
      type = "item",
      name = "fabricator-shuttle",
      icon = "__expanded-rocket-payloads__/graphic/fabricator-shuttle-32.png",
      icon_size = 32,
      subgroup = "Space-Shuttles",
      stack_size = 1,
      rocket_launch_product = {"landed-fabricator-shuttle", 1},
    },
    {
      type = "item",
      name = "landed-fabricator-shuttle",
      icon = "__expanded-rocket-payloads__/graphic/landed-fabricator-shuttle-32.png",
      icon_size = 32,
      subgroup = "shuttle-processies",
      order = "a",
      stack_size = 1,
    },
    {
      type = "item",
      name = "ground-auto-fabricator",
      icon = "__expanded-rocket-payloads__/graphic/auto-fabricator-32.png",
      icon_size = 32,
      subgroup = "buildings",
      order = "mS",
      stack_size = 1,
      place_result = "ground-auto-fabricator",
    },
})