data:extend(
{
  {
    type = "technology",
    name = "bob-tanks-2",
    icon = "__base__/graphics/technology/tanks.png",
    icon_size = 128,
    prerequisites =
    {
      "tanks",
      "artillery",
      "advanced-electronics-2"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "bob-tank-2"
      },
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 30
    },
    order = "e-c-c2",
  },

  {
    type = "technology",
    name = "bob-tanks-3",
    icon = "__base__/graphics/technology/tanks.png",
    icon_size = 128,
    prerequisites =
    {
      "bob-tanks-2",
      "utility-science-pack",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "bob-tank-3"
      },
    },
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 45
    },
    order = "e-c-c3",
  },
}
)

