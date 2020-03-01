data:extend({
    {
      type = "technology",
      name = "improved-space-program-theory",
      icon_size = 128,
      icon = "__base__/graphics/technology/logistics.png",
      prerequisites = {"space-science-pack"},
      order = "y-b",
      unit =
      {
        count = 2000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1}
          },
        time = 60
      },
    },
})