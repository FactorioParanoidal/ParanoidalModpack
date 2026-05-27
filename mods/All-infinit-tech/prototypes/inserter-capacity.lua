data:extend(
  {
    {
      type = "technology",
      name = "inserter-capacity-bonus-8",
      icon = "__All-infinit-tech__/graphics/inserter-tech.png",
      prerequisites = {"inserter-capacity-bonus-7", "space-science-pack"},
      icon_size = 256,
      effects =
      {
        {
        type = "inserter-stack-size-bonus",
        modifier = 1
        },
        {
          type = "bulk-inserter-capacity-bonus",
          modifier = 2
        },
      },
      unit =
      {
        count_formula = settings.startup["Infinite-Formula"].value,
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
      upgrade = true,
      order = "c-k-f-e",
      max_level = "infinite"
    }
  }
)
