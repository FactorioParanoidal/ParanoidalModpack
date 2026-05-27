data:extend
({
  {
    type = "technology",
    name = "worker-robots-battery-1",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"robotics"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "250",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robots-battery-2",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"worker-robots-battery-1"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "500",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robots-battery-3",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"worker-robots-battery-2","production-science-pack"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
      }
    },
    unit =
    {
      count_formula = "750",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robots-battery-4",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"worker-robots-battery-3"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
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
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robots-battery-5",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"worker-robots-battery-4"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
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
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robots-battery-6",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"worker-robots-battery-5","utility-science-pack"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
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
        {"utility-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robots-battery-7",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"worker-robots-battery-6"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
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
        {"utility-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robots-battery-8",
    icon = "__All-infinit-tech__/graphics/bot-batterie-tech.png",
    icon_size = 256,
    prerequisites = {"worker-robots-battery-7", "space-science-pack"},
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.2
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
        {"space-science-pack", 1},
      },
      time = 50
    },
    upgrade = true,
    order = "c-k-h-e",
    max_level = "infinite"
  },
})