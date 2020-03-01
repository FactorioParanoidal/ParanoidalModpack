data:extend({
    {
      type = "technology",
      name = "space-lab",
      icon_size = 128,
      icon = "__expanded-rocket-payloads__/graphic/skylab-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "space-lab"
        },
      },
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 5000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1}
        },
        time = 30
      },
      order = "y-a"
    },
})