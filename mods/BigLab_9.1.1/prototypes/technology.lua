data:extend(
{
  {
    type = "technology",
    name = "big-lab",
    icon = "__BigLab__/graphics/tech/big-lab.png",
    icon_size = 128,
    order = "c-k-m-a",
    prerequisites =
    {
      "advanced-research",
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
      count = 250,
      time = 60,
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
    name = "hyper-lab",
    icon = "__BigLab__/graphics/tech/hyper-lab.png",
    icon_size = 128,
    order = "c-k-m-b",
    prerequisites =
    {
      "big-lab",
	  "space-science-pack"
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