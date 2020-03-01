--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

data:extend({
  {
    type = "technology",
    name = "improved-trains",
    icon = "__TrainOverhaul__/graphics/icons/improved-trains.png",
    icon_size = 64,
    prerequisites = {"braking-force-2"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "heavy-locomotive"
      },
      {
        type = "unlock-recipe",
        recipe = "express-locomotive"
      },
      {
        type = "unlock-recipe",
        recipe = "heavy-cargo-wagon"
      },
      {
        type = "unlock-recipe",
        recipe = "express-cargo-wagon"
      },
      {
        type = "unlock-recipe",
        recipe = "heavy-fluid-wagon"
      },
      {
        type = "unlock-recipe",
        recipe = "express-fluid-wagon"
      },
    },
    unit =
    {
      count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    order = "c-g-c"
  },
  {
    type = "technology",
    name = "nuclear-locomotive",
    icon = "__TrainOverhaul__/graphics/icons/tech-nuclear-locomotive.png",
    icon_size = 64,
    prerequisites = {"improved-trains", "nuclear-power"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "heavy-nuclear-locomotive"
      },
      {
        type = "unlock-recipe",
        recipe = "express-nuclear-locomotive"
      }
    },
    unit =
    {
      count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    order = "c-g-c"
  },
})