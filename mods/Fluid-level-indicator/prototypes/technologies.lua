data:extend(
{
  {
    type = "technology",
    name = "fluid-level-indicator",
    icon_size = 256,
    icon = "__Fluid-level-indicator__/graphics/icons/tech_icon_blackscreenbck.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "fluid-level-indicator"
      },
      {
        type = "unlock-recipe",
        recipe = "fluid-level-indicator-straight"
      }
    },
    prerequisites = {"lamp"},
    unit =
    {
      count = 10,
      ingredients =
      {
        {"automation-science-pack", 1}
      },
      time = 60
    },
    order = "e-d-e"
  },    
})

