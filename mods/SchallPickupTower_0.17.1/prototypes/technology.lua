local pickup_tower_icon_path = {icon = "__SchallPickupTower__/graphics/technology/pickup-tower.png"}



data:extend(
{
  {
    type = "technology",
    name = "Schall-pickup-tower-1",
    icon_size = 128,
    icons = { pickup_tower_icon_path },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-pickup-tower-R32"
      }
    },
    prerequisites = {"electric-energy-distribution-2"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "c-e-c"
  },
  {
    type = "technology",
    name = "Schall-pickup-tower-2",
    icon_size = 128,
    icons = { pickup_tower_icon_path },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "Schall-pickup-tower-R64"
      }
    },
    prerequisites = {"Schall-pickup-tower-1"},
    unit =
    {
      count = 200,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "c-e-c"
  },

}
)
