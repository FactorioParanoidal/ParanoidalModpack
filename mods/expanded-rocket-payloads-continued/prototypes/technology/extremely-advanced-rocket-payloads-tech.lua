data:extend({
    {
      type = "technology",
      name = "extremely-advanced-rocket-payloads",
      icon_size = 256,
      order = "y-a",    
      icon = "__expanded-rocket-payloads-continued__/graphic/imports/techs/automation.png",
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