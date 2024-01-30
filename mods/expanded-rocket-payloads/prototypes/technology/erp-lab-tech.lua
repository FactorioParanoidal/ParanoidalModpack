data:extend({
    {
      type = "technology",
      name = "erp-lab",
      icon_size = 128,
      order = "y-b",
      icon = "__expanded-rocket-payloads__/graphic/advanced-chemistry.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "erp-lab"
        },
      },
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 2000,
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