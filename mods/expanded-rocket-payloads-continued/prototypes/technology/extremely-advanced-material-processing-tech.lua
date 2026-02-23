local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "extremely-advanced-material-processing",
      icon_size = 256,
      icon = "__expanded-rocket-payloads-continued__/graphic/imports/techs/advanced-material-processing.png",
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
        ingredients = modutils.full_science_pack(),
        time = 60
      },
    },
})