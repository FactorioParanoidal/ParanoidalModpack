data:extend({
    {
        type = "recipe",
        name = "repurpose-space-shuttle",
        energy_required = 1600,
        enabled = false,
        ingredients =
        {
          {"space-shuttle", 1},
        },
        results=
        {
          {"satellite-thruster", 20},
          {"shuttle-hull", 1},
          {"space-lab-payload", 1},
        },
        icon = "__expanded-rocket-payloads__/graphic/repurpose-space-shuttle-32.png",
        icon_size = 32,
        subgroup = "shuttle-processies",
        order = "c",
        category = "satellite-crafting",
    },
    {
        type = "recipe",
        name = "repurpose-spy-shuttle",
        energy_required = 1600,
        enabled = false,
        ingredients =
        {
          {"spy-shuttle", 1},
        },
        results=
        {
          {"satellite-thruster", 20},
          {"shuttle-hull", 1},
          {"telescope-components", 3},
        },
        icon = "__expanded-rocket-payloads__/graphic/repurpose-spy-shuttle-32.png",
        icon_size = 32,
        subgroup = "shuttle-processies",
        order = "c",
        category = "satellite-crafting",
    },
    {
        type = "recipe",
        name = "repurpose-mining-shuttle",
        energy_required = 1600,
        enabled = false,
        ingredients =
        {
          {"mining-shuttle", 1},
        },
        results=
        {
          {"autonomous-space-mining-drone", 5},
          {"satellite-thruster", 30},
          {"shuttle-hull", 1},
        },
        icon = "__expanded-rocket-payloads__/graphic/repurpose-mining-shuttle-32.png",
        icon_size = 32,
        subgroup = "shuttle-processies",
        order = "c",
        category = "satellite-crafting",
    },
    {
      type = "recipe",
      name = "repurpose-fabricator-shuttle",
      energy_required = 1600,
      enabled = false,
      ingredients =
      {
        {"fabricator-shuttle", 1},
      },
      results=
      {
        {"orbital-fabricator-component", 1},
        {"satellite-thruster", 50},
        {"shuttle-hull", 1},
      },
      icon = "__expanded-rocket-payloads__/graphic/repurpose-fabricator-shuttle-32.png",
      icon_size = 32,
      subgroup = "shuttle-processies",
      order = "c",
      category = "satellite-crafting",
  },
})