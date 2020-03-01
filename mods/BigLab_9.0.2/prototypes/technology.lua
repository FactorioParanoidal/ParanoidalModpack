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
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 2},
        {"chemical-science-pack", 2}
      },
    },
  },
}
)