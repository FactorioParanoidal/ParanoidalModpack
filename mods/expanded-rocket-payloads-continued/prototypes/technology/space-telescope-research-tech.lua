data:extend({
    {
        type = "technology",
        name = "space-telescope-research-1",
        icon_size = 128,
        order = "y-a",    
        icon = "__expanded-rocket-payloads-continued__/graphic/Andromeda128.png",
        effects =
        {
          {
            type = "laboratory-speed",
            modifier = 0.1
          }
        },
        prerequisites = {"space-telescope"},
        unit =
        {
          count_formula = "1",
          ingredients =
          {
            {"planetary-data", 1},
  
          },
          time = 60
        },
        max_level = 10,
      },
      {
        type = "technology",
        name = "space-telescope-research-11",
        icon_size = 128,
        order = "y-a",    
        icon = "__expanded-rocket-payloads-continued__/graphic/Andromeda128.png",
        effects =
        {
          {
            type = "laboratory-speed",
            modifier = 0.1
          }
        },
        prerequisites = {"space-telescope-research-1"},
        unit =
        {
          count_formula = "L",
          ingredients =
          {
            {"planetary-data", 1},
  
          },
          time = 120
        },
        max_level = 20,
      },
      {
        type = "technology",
        name = "space-telescope-research-21",
        icon_size = 128,
        order = "y-a",    
        icon = "__expanded-rocket-payloads-continued__/graphic/Andromeda128.png",
        effects =
        {
          {
            type = "laboratory-speed",
            modifier = 0.1
          }
        },
        prerequisites = {"space-telescope-research-11"},
        unit =
        {
          count_formula = "2(L-11)",
          ingredients =
          {
            {"planetary-data", 1},
  
          },
          time = 240
        },
        max_level = "infinite",
      },
})

