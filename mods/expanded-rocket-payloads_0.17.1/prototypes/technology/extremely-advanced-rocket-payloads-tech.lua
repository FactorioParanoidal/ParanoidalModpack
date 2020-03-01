data:extend({
    {
      type = "technology",
      name = "extremely-advanced-rocket-payloads",
      icon_size = 128,
      order = "y-a",    
      icon = "__base__/graphics/technology/automated-construction.png",
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 10,
        ingredients =
        {
          {"station-science", 1},
          {"planetary-data", 1},
        },
        time = 600
      },
    },
})