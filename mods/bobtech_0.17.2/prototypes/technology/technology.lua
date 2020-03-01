data:extend(
{
  {
    type = "technology",
    name = "advanced-research",
    icon = "__bobtech__/graphics/icons/research-effectivity.png",
    icon_size = 64,
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
        recipe = "lab-2"
      },
    },
    unit =
    {
      count = 100,
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
    },
  },

  {
    type = "technology",
    name = "advanced-logistic-science-pack",
    icon_size = 128,
    icon = "__bobtech__/graphics/icons/logistic-science-pack-technology.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-logistic-science-pack"
      },
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    prerequisites =
    {
      "logistics-3",
      "robotics"
    },
    order = "c-a"
  },
}
)


