data:extend
({
  {
    type = "technology",
    name = "worker-robots-storage-4",
    icon = "__base__/graphics/technology/worker-robots-storage.png",
    icon_size = 128,
    prerequisites = {"worker-robots-storage-3", "space-science-pack"},
    effects =
    {
      {
        type = "worker-robot-storage",
        modifier = 1
      }
    },
    unit =
    {
      count_formula = "2^(L-4)*1000",
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
    max_level = "infinite",
    upgrade = true,
    order = "c-k-f-e"
  },
})