local icons = {
  {
    icon = "__base__/graphics/technology/worker-robots-storage.png",
    icon_size = 256, icon_mipmaps = 4
  },
  {
    icon = "__core__/graphics/icons/technology/constants/constant-battery.png",
    icon_size = 128,
    icon_mipmaps = 3,
    shift = {100, 100}
  }
}

data:extend
({
  {
    type = "technology",
    name = "worker-robot-battery-1",
    icons = icons,
    icon_size = 256, icon_mipmaps = 4,
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.1
      }
    },
    prerequisites = {"robotics"},
    unit =
    {
      count_formula = "100*L",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    upgrade = true,
    max_level = "3",
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robot-battery-4",
    icons = icons,
    icon_size = 256, icon_mipmaps = 4,
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.1
      }
    },
    prerequisites = {"worker-robot-battery-1"},
    unit =
    {
      count_formula = "100*L",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 45
    },
    upgrade = true,
    max_level = "7",
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robot-battery-8",
    icons = icons,
    icon_size = 256, icon_mipmaps = 4,
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.1
      }
    },
    prerequisites = {"worker-robot-battery-4"},
    unit =
    {
      count_formula = "100*L",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 60
    },
    upgrade = true,
    max_level = "11",
    order = "c-k-h-e"
  },
  {
    type = "technology",
    name = "worker-robot-battery-12",
    icons = icons,
    icon_size = 256, icon_mipmaps = 4,
    effects =
    {
      {
        type = "worker-robot-battery",
        modifier = 0.1
      }
    },
    prerequisites = {"worker-robot-battery-8", "space-science-pack"},
    unit =
    {
      count_formula = "2^(L-11)*1000",
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60
    },
    upgrade = true,
    max_level = "infinite",
    order = "c-k-h-e"
  },
})