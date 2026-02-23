local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "technology",
    name = "satellite-tracking",
    icon_size = 120,
    order = "y-a",    
    icon = "__expanded-rocket-payloads-continued__/graphic/ground-reciver.png",
    prerequisites = {"extremely-advanced-material-processing"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
  }
})