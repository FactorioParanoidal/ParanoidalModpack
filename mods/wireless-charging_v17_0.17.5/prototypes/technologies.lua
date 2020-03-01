data:extend
{
  {
    type = "technology",
    name = "wireless-charging-induction",
    icon = "__wireless-charging_v17__/graphics/technology/induction.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "wireless-charging-lo-power-induction-coil",
      },
      {
        type = "unlock-recipe",
        recipe = "wireless-charging-lo-power-induction-rail",
      },
      {
        type = "unlock-recipe",
        recipe = "wireless-charging-lo-power-induction-station",
      },
    },
    prerequisites = {"advanced-electronics-2", "electric-energy-distribution-1", "modular-armor"},
    unit =
    {
      count = 150,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 40,
    },
    order = "c-e-d",
  },
  {
    type = "technology",
    name = "wireless-charging-high-power-induction",
    icon = "__wireless-charging_v17__/graphics/technology/high-power-induction.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "wireless-charging-hi-power-induction-coil",
      },
      {
        type = "unlock-recipe",
        recipe = "wireless-charging-hi-power-induction-rail",
      },
      {
        type = "unlock-recipe",
        recipe = "wireless-charging-hi-power-induction-station",
      },
    },
    prerequisites = {"wireless-charging-induction", "electric-energy-distribution-2", "speed-module-2"},
    unit =
    {
      count = 200,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 60,
    },
    order = "c-e-e",
  },
}
