data:extend({
    {
      type = "technology",
      name = "shuttle-repurposing",
      icon_size = 128,
      icon = "__expanded-rocket-payloads__/graphic/shuttle-repurposeing-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "repurpose-space-shuttle"
        },
        {
          type = "unlock-recipe",
          recipe = "repurpose-spy-shuttle"
        },
        {
          type = "unlock-recipe",
          recipe = "repurpose-mining-shuttle"
        },
      },
      prerequisites = {"spy-shuttle"},
      unit =
      {
        count = 40000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1}
        },
        time = 80,
        order = "y-b"
      },
    },
  })