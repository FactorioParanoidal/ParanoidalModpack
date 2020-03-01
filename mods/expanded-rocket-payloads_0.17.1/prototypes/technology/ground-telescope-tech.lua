data:extend({
    {
      type = "technology",
      name = "ground-telescope",
      icon_size = 128,
      order = "y-b",
      icon = "__expanded-rocket-payloads__/graphic/ground-telescope-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "ground-telescope"
        },
        {
          type = "unlock-recipe",
          recipe = "study-the-stars"
        },
        {
          type = "unlock-recipe",
          recipe = "telescope-components"
        },
      },
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 4000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1}
        },
        time = 60
      },
    },
})