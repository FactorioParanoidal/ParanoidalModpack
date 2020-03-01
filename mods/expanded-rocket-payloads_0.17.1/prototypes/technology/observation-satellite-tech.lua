data:extend({
    {
      type = "technology",
      name = "observation-satellite",
      icon_size = 128,
      icon = "__expanded-rocket-payloads__/graphic/observation-sat-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "observation-satellite"
        },
      },
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 10000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1}
        },
        time = 40
      },
      order = "y-x"
    },
    {
      type = "technology",
      name = "orbital-prospecting-1",
      icon_size = 128,
      icon = "__expanded-rocket-payloads__/graphic/orbital-prospecting.png",
      effects =
      {
        {
          type = "mining-drill-productivity-bonus",
          modifier = 0.02
        }
      },
      prerequisites = {"observation-satellite"},
      unit =
      {
        count_formula = "L",
        ingredients =
        {
          {"planetary-data", 1},
        },
        time = 120
      },
      max_level = "50",
      upgrade = true,
    },
    {
      type = "technology",
      name = "orbital-prospecting-51",
      icon_size = 128,
      order = "y-b",
      icon = "__expanded-rocket-payloads__/graphic/orbital-prospecting.png",
      effects =
      {
        {
          type = "mining-drill-productivity-bonus",
          modifier = 0.02
        }
      },
      prerequisites = {"orbital-prospecting-1"},
      unit =
      {
        count_formula = "2(L-26)",
        ingredients =
        {
          {"planetary-data", 1},
        },
        time = 120
      },
      max_level = "infinite",
      upgrade = true,
    },
})