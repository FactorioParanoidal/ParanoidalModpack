data:extend(
{
  {
    type = "technology",
    name = "reinforced-wall",
    icon = "__base__/graphics/technology/stone-walls.png",
    icon_size = 128,
    prerequisites = {"gates"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "reinforced-wall"
      },
      {
        type = "unlock-recipe",
        recipe = "reinforced-gate"
      },
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 10
    },
    order = "a-k-b"
  },
}
)

