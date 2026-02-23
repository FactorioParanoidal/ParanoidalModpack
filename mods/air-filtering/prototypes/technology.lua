data:extend({
  {
    type = "technology",
    name = "air-filtering",
    icon = "__air-filtering__/graphics/technology/air-filtering.png",
    icon_size = 64,
    prerequisites = {"plastics", "steel-processing", "advanced-circuit"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine"
      },
      {
        type = "unlock-recipe",
        recipe = "filter-air"
      },
      {
        type = "unlock-recipe",
        recipe = "unused-air-filter"
      }
    },
    unit =
    {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filtering-mk2",
    icon = "__air-filtering__/graphics/technology/air-filtering-mk2.png",
    icon_size = 64,
    prerequisites = {"air-filtering"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-mk2"
      }
    },
    unit =
    {
      count = 300,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 60
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filtering-mk3",
    icon = "__air-filtering__/graphics/technology/air-filtering-mk3.png",
    icon_size = 64,
    prerequisites = {"air-filtering-mk2"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-mk3"
      }
    },
    unit =
    {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 2},
        {"production-science-pack", 1}
      },
      time = 60
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filter-recycling",
    icon = "__air-filtering__/graphics/technology/air-filter-recycling.png",
    icon_size = 64,
    prerequisites = {"air-filtering"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-recycling"
      }
    },
    unit =
    {
      count = 150,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "d-a-a"
  }
})
