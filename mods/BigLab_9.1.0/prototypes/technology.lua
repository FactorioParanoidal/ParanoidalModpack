data:extend(
{
  {
    type = "technology",
    name = "biglab",
    icon = "__BigLab__/graphics/tech/biglab.png",
    icon_size = 128,
    order = "c-k-m-a",
    prerequisites =
    {
      "advanced-electronics",
      "logistics-3",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "big-lab"
      },
    },
    unit =
    {
      count = 100,
      time = 60,
      ingredients =
      {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 2},
        {"chemical-science-pack", 2}
      },
    },
  },

  {
    type = "technology",
    name = "hyperlab",
    icon = "__BigLab__/graphics/tech/hyperlab.png",
    icon_size = 128,
    order = "c-k-m-b",
    prerequisites =
    {
      "biglab"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "hyper-lab"
      },
    },
    unit =
    {
      count = 1000,
      time = 120,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 2},
        {"utility-science-pack", 2},
        {"advanced-logistic-science-pack", 2},
        {"space-science-pack", 1}
      },
    },
  },
  
}
)