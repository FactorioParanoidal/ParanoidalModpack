data:extend({
    {
      type = "technology",
      name = "extremely-advanced-material-processing",
      icon_size = 128,
      icon = "__base__/graphics/technology/advanced-material-processing.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "radioisotope-thermoelectric-generator"
        },
        {
          type = "unlock-recipe",
          recipe = "satellite-battery"
        },
        {
          type = "unlock-recipe",
          recipe = "satellite-bus"
        },
        {
          type = "unlock-recipe",
          recipe = "satellite-communications"
        },
        {
          type = "unlock-recipe",
          recipe = "satellite-flight-computer"
        },
        {
          type = "unlock-recipe",
          recipe = "satellite-radar"
        },
        {
          type = "unlock-recipe",
          recipe = "satellite-solar-array"
        },
        {
          type = "unlock-recipe",
          recipe = "satellite-thruster"
        },
        {
          type = "unlock-recipe",
          recipe = "space-lab-payload"
        },
      },
      prerequisites = {"advanced-machining"},
      order = "y-b",
      unit =
      {
        count = 5000,
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
    },
})