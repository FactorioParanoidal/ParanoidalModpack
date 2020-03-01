data:extend({
  {
    type = "technology",
    name = "air-filtering",
    icon = "__air-filtering-patched__/graphics/technology/air-filtering-mk1.png",
    icon_size = "64",
    prerequisites = {"steel-processing", "electronics", "automation"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-mk1"
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
      count = 200,
      ingredients = {
        {"automation-science-pack", 1}
      },
      time = 30
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filtering-mk2",
    icon = "__air-filtering-patched__/graphics/technology/air-filtering-mk2.png",
    icon_size = "64",
    prerequisites = {"air-filtering", "automation-2"},
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
        {"logistic-science-pack", 1}
      },
      time = 60
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filtering-mk3",
    icon = "__air-filtering-patched__/graphics/technology/air-filtering-mk3.png",
    icon_size = "64",
    prerequisites = {"air-filtering-mk2", "automation-3"},
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
        {"chemical-science-pack", 1},
      },
      time = 60
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filtering-mk4",
    icon = "__air-filtering-patched__/graphics/technology/air-filtering-mk4.png",
    icon_size = "64",
    prerequisites = {"air-filtering-mk3"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-mk4"
      }
    },
    unit =
    {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 2}
      },
      time = 75
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filtering-mk5",
    icon = "__air-filtering-patched__/graphics/technology/air-filtering-mk5.png",
    icon_size = "64",
    prerequisites = {"air-filtering-mk4"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-mk5"
      }
    },
    unit =
    {
      count = 2000,
      ingredients = {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 2},
        {"chemical-science-pack", 2},
        {"production-science-pack", 2},
		{"utility-science-pack", 1}
      },
      time = 90
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filtering-mk6",
    icon = "__air-filtering-patched__/graphics/technology/air-filtering-mk6.png",
    icon_size = "64",
    prerequisites = {"air-filtering-mk5"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "air-filter-machine-mk6"
      }
    },
    unit =
    {
      count = 2500,
      ingredients = {
        {"automation-science-pack", 5},
        {"logistic-science-pack", 5},
        {"chemical-science-pack", 5},
        {"production-science-pack", 3},
		{"utility-science-pack", 2},
		{"space-science-pack", 1}
      },
      time = 180
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "air-filter-recycling",
    icon = "__air-filtering-patched__/graphics/technology/air-filter-recycling.png",
    icon_size = "64",
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
      count = 400,
      ingredients = {
        {"automation-science-pack", 1}
      },
      time = 30
    },
    order = "d-a-a"
  },
  {
    type = "technology",
    name = "advanced-air-filter-recycling",
    icon = "__air-filtering-patched__/graphics/technology/advanced-air-filter-recycling.png",
    icon_size = "64",
    prerequisites = {"air-filter-recycling"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-air-filter-recycling"
      }
    },
    unit =
    {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 60
    },
    order = "d-a-a"
  },
  
   {
    type = "technology",
    name = "advanced-air-filter-recycling-2",
    icon = "__air-filtering-patched__/graphics/technology/advanced-air-filter-recycling-2.png",
    icon_size = "64",
    prerequisites = {"advanced-air-filter-recycling", "air-filtering-mk2"},
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-air-filter-recycling-2"
      }
    },
    unit =
    {
      count = 500,
      ingredients = {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 2},
		{"chemical-science-pack", 1},
      },
      time = 90
    },
    order = "d-a-a"
	
	
	
	
	
  }
})
