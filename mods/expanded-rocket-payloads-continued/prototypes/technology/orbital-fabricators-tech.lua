local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "technology",
    name = "space-assembler-theory",
    icon_size = 128,
    icon = "__expanded-rocket-payloads-continued__/graphic/space-fabricator-basic-128.png",
    prerequisites = { "asteroid-mining" },
    unit =
    {
      count = 50000,
      ingredients = modutils.full_science_pack(),
      time = 120
    },
  },
  {
    type = "technology",
    name = "vacuum-smelting",
    icon_size = 128,
    icon = "__expanded-rocket-payloads-continued__/graphic/space-smelting.png",
    prerequisites = { "space-assembler-theory" },
    unit =
    {
      count = 1000,
      ingredients =
      {
        { "station-science", 1 },
      },
      time = 240
    },
  },
  {
    type = "technology",
    name = "orbital-assembler-power-problem",
    icon_size = 128,
    icon = "__expanded-rocket-payloads-continued__/graphic/power-problem-128.png",
    prerequisites = { "space-assembler-theory" },
    unit =
    {
      count = 75000,
      ingredients = modutils.full_science_pack(),
      time = 100
    },
  },
  {
    type = "technology",
    name = "orbital-autonomous-fabricators",
    icon_size = 128,
    icon = "__expanded-rocket-payloads-continued__/graphic/space-fabricator-advanced-128.png",
    prerequisites = { "vacuum-smelting", "orbital-assembler-power-problem" },
    effects = modutils.select_any(
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
          recipe = "coal-delivery",
        },
        {
          type = "unlock-recipe",
          recipe = "repurpose-fabricator-shuttle",
        },
      }, nil, modutils.unlock_recipes({
        "tungsten-plate-delivery",
        "tungsten-carbide-delivery",
        "calcite-delivery",
        "holmium-ore-delivery",
        "carbon-fiber-delivery",
        "lithium-plate-delivery",
      })
    ),
    order = "y-b",
    unit =
    {
      count = 225000,
      ingredients = modutils.full_science_pack(),
      time = 100
    },
  },
})
