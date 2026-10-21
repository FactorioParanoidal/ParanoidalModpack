data:extend(
{
  {
    type = "technology",
    name = "fluid-level-indicator-st-bobs-tungsten",
    icon_size = 256,
    icon = "__Fluid-level-indicator__/graphics/icons/tech_icon_blackscreenbck_MK4.png",
    hidden = false,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "fluid-level-indicator-st-bobs-tungsten"
      }
    },
    prerequisites = {"lamp", "tungsten-processing", "titanium-processing", "fluid-level-indicator"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "e-d-f"
  },
  {
    type = "technology",
    name = "fluid-level-indicator-st-bobs-coppertungsten",
    icon_size = 256,
    icon = "__Fluid-level-indicator__/graphics/icons/tech_icon_blackscreenbck_MK5.png",
    hidden = false,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "fluid-level-indicator-st-bobs-coppertungsten"
      }
    },
    prerequisites = {"lamp", "tungsten-alloy-processing", "nitinol-processing","fluid-level-indicator"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 30
    },
    order = "e-d-g"
  }
})