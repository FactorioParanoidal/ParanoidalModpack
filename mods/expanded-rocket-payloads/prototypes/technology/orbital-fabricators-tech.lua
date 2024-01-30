data:extend({
    {
      type = "technology",
      name = "space-assembler-theory",
      icon_size = 128,
      icon = "__expanded-rocket-payloads__/graphic/space-fabricator-basic-128.png",
      prerequisites = {"asteroid-mining"},
      unit =
      {
        count = 50000,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1}
          },
        time = 120
      },
    },
    {
        type = "technology",
        name = "vacuum-smelting",
        icon_size = 128,
        icon = "__expanded-rocket-payloads__/graphic/space-smelting.png",
        prerequisites = {"space-assembler-theory"},
        unit =
        {
          count = 1000,
          ingredients =
          {
            {"station-science", 1},
          },
          time = 240
        },
      },
      {
        type = "technology",
        name = "orbital-assembler-power-problem",
        icon_size = 128,
        icon = "__expanded-rocket-payloads__/graphic/power-problem-128.png",
        prerequisites = {"space-assembler-theory"},
        unit =
        {
          count = 75000,
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1}
          },
          time = 100
        },
      },
      {
        type = "technology",
        name = "orbital-autonomous-fabricators",
        icon_size = 128,
        icon = "__expanded-rocket-payloads__/graphic/space-fabricator-advanced-128.png",
        prerequisites = {"vacuum-smelting", "orbital-assembler-power-problem"},
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "orbital-fabricator-component",
          },
          {
            type = "unlock-recipe",
            recipe = "fabricator-shuttle",
          },
          {
            type = "unlock-recipe",
            recipe = "refurbish-fabricator-shuttle",
          },
          {
            type = "unlock-recipe",
            recipe = "ground-auto-fabricator",
          },
          {
            type = "unlock-recipe",
            recipe = "iron-delivery",
          },
          {
            type = "unlock-recipe",
            recipe = "copper-delivery",
          },
          {
            type = "unlock-recipe",
            recipe = "steel-delivery",
          },
          {
            type = "unlock-recipe",
            recipe = "stone-delivery",
          },
          {
            type = "unlock-recipe",
            recipe = "uranium-delivery",
          },
          {
            type = "unlock-recipe",
            recipe = "repurpose-fabricator-shuttle",
          },
        },
        order = "y-b",
        unit =
        {
          count = 225000,
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1}
          },
          time = 100
        },
      },
})
