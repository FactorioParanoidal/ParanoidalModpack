data:extend(
  {
  
    {
      type = "technology",
      name = "worker-robots-storage-4",
      icon = "__All-infinit-tech__/graphics/bot-storage-tech.png",
      icon_size = 256,
      prerequisites = {"worker-robots-storage-3"},
      effects =
      {
        {
          type = "worker-robot-storage",
          modifier = 1
        }
      },
      unit =
      {
        count_formula = "1000",
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1}
        },
        time =30
      },
      upgrade = true,
      order = "c-k-f-e"
    },
    {
      type = "technology",
      name = "worker-robots-storage-5",
      icon = "__All-infinit-tech__/graphics/bot-storage-tech.png",
      icon_size = 256,
      prerequisites = {"worker-robots-storage-4"},
      effects =
      {
        {
          type = "worker-robot-storage",
          modifier = 1
        }
      },
      unit =
      {
        count_formula = "1250",
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1}
        },
        time =30
      },
      upgrade = true,
      order = "c-k-f-e"
    },
    {
      type = "technology",
      name = "worker-robots-storage-6",
      icon = "__All-infinit-tech__/graphics/bot-storage-tech.png",
      icon_size = 256,
      prerequisites = {"worker-robots-storage-5"},
      effects =
      {
        {
          type = "worker-robot-storage",
          modifier = 1
        }
      },
      unit =
      {
        count_formula = "1500",
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1}
        },
        time =30
      },
      upgrade = true,
      order = "c-k-f-e"
    },
    {
      type = "technology",
      name = "worker-robots-storage-7",
      icon = "__All-infinit-tech__/graphics/bot-storage-tech.png",
      icon_size = 256,
      prerequisites = {"worker-robots-storage-6"},
      effects =
      {
        {
          type = "worker-robot-storage",
          modifier = 1
        }
      },
      unit =
      {
        count_formula = "1750",
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1}
        },
        time =30
      },
      upgrade = true,
      order = "c-k-f-e"
    },
    {
      type = "technology",
      name = "worker-robots-storage-8",
      icon = "__All-infinit-tech__/graphics/bot-storage-tech.png",
      icon_size = 256,
      prerequisites = {"worker-robots-storage-7", "space-science-pack"},
      effects =
      {
        {
          type = "worker-robot-storage",
          modifier = 2
        }
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
    },
  }
)
