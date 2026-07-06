data:extend(
{
  {
    type = "technology",
    name = "fluid-level-indicator-k2",
    icon_size = 256,
    icon = "__Fluid-level-indicator__/graphics/icons/tech_icon_blackscreenbck_ss.png",
    hidden = false,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "fluid-level-indicator-k2"
      },
      {
        type = "unlock-recipe",
        recipe = "fluid-level-indicator-straight-k2"
      }
    },
    prerequisites = {"lamp", "kr-steel-fluid-handling"},
    unit =
    {
      count = 75,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    order = "e-d-f"
  }
})