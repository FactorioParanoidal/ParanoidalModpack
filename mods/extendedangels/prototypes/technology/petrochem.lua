data:extend({
  -- Sodium processing 2
  {
    type = "technology",
    name = "angels-sodium-processing-3",
    icon = "__angelspetrochemgraphics__/graphics/technology/sodium-tech.png",
    icon_size = 128,
    prerequisites = {
      "angels-advanced-chemistry-5",
      "angels-lead-smelting-3",
      "angels-sodium-processing-2",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "angels-solid-sodium-fluoride-1",
      },
      {
        type = "unlock-recipe",
        recipe = "angels-solid-sodium-fluoride-2",
      },
    },
    unit = {
      count = 100,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "production-science-pack", 1 },
        { "utility-science-pack", 1 },
      },
      time = 15,
    },
    order = "c-a",
  },
})
