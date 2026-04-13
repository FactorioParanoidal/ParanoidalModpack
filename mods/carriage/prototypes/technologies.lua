data:extend({
  {
    type = "technology",
    name = "carriage_transport",
    icon = GRAPHICSPATH .. "technology/carriage.png",
    icon_size = 256,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "carriage"
      },
      {
        type = "unlock-recipe",
        recipe = "waypoint"
      },
    },
    prerequisites = { "logistics" },
    unit = {
      count = 20,
      ingredients = {
        { "automation-science-pack", 1 },
      },
      time = 10
    },
    order = "c-g-a",
  },
})
