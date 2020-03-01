data:extend{
  {
    type = "technology",
    name = "railloader",
    icon_size = 128,
    icon = "__railloader__/graphics/technology/railloader.png",
    effects = {
      {
        type = "unlock-recipe",
        recipe = "railloader",
      },
      {
        type = "unlock-recipe",
        recipe = "railunloader",
      },
    },
    prerequisites = { "railway" },
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30,
    },
    order = "c-g-b",
  }
}