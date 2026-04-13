data:extend({
      {
        type = "technology",
        name = "robot-global-positioning-system-1",
        icon_size = 128,
        icon = "__expanded-rocket-payloads-continued__/graphic/gps.png",
        effects =
        {
          {
            type = "worker-robot-speed",
            modifier = 0.1
          }
        },
        prerequisites = {"observation-satellite"},
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
        order = "z-z",    
      },
      {
        type = "technology",
        name = "robot-global-positioning-system-11",
        icon_size = 128,
        order = "z-z",    
        icon = "__expanded-rocket-payloads-continued__/graphic/gps.png",
        effects =
        {
          {
            type = "worker-robot-speed",
            modifier = 0.1
          }
        },
        prerequisites = {"robot-global-positioning-system-1"},
        unit =
        {
          count_formula = "L",
          ingredients =
          {
            {"planetary-data", 1},
  
          },
          time = 240
        },
        max_level = 20,
      },
        {
          type = "technology",
          name = "robot-global-positioning-system-21",
          icon_size = 128,
          order = "z-z",    
          icon = "__expanded-rocket-payloads-continued__/graphic/gps.png",
          effects =
          {
            {
              type = "worker-robot-speed",
              modifier = 0.1
            }
          },
          prerequisites = {"robot-global-positioning-system-11"},
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