data:extend({
    {
        type = "recipe",
        name = "refurbish-space-shuttle",
        energy_required = 800,
        enabled = false,
        ingredients =
        {
          {type="fluid", name="water", amount=20000},
          {"landed-shuttle", 1},
          {"rocket-fuel", 500},
          {"stone-brick", 500},
          {"space-lab-payload", 1},
        },
        results=
        {
          {"station-science", 2},
          {"space-shuttle", 1},
        },
        icon = "__expanded-rocket-payloads__/graphic/landed-shuttle-32.png",
        icon_size = 32,
        subgroup = "shuttle-processies",
        order = "b",
        category = "satellite-crafting",
    },
    {
      type = "recipe",
      name = "refurbish-spy-shuttle",
      energy_required = 800,
      enabled = false,
      ingredients =
      {
        {type="fluid", name="water", amount=20000},
        {"landed-spy-shuttle", 1},
        {"rocket-fuel", 500},
        {"stone-brick", 1000},
      },
      results=
      {
        {"spy-shuttle", 1},
        {"planetary-data", 2},
      },
      icon = "__expanded-rocket-payloads__/graphic/landed-shuttle-32.png",
      icon_size = 32,
      subgroup = "shuttle-processies",
      order = "b",
      category = "satellite-crafting",
  },
})