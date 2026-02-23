data:extend({
      {
        type = "technology",
        name = "advanced-battery-research-1",
        icon_size = 128,
        icon = "__expanded-rocket-payloads-continued__/graphic/iss-128.png",
        effects =
        {
          {
            type = "worker-robot-battery",
            modifier = 0.1
          }
        },
        prerequisites = {"space-lab"},
        unit =
        {
          count_formula = "1",
          ingredients =
          {
            {"station-science", 1},
          },
          time = 60
        },
        max_level = 10,
        order = "y-a"
      },
      {
        type = "technology",
        name = "advanced-battery-research-11",
        icon_size = 128,
        icon = "__expanded-rocket-payloads-continued__/graphic/iss-128.png",
        effects =
        {
          {
            type = "worker-robot-battery",
            modifier = 0.1
          }
        },
        prerequisites = {"advanced-battery-research-1"},
        unit =
        {
          count_formula = "L",
          ingredients =
          {
            {"station-science", 1},
          },
          time = 120
        },
        max_level = 20,
        order = "y-a"
      },
      {
        type = "technology",
        name = "advanced-battery-research-21",
        icon_size = 128,
        icon = "__expanded-rocket-payloads-continued__/graphic/iss-128.png",
        effects =
        {
          {
            type = "worker-robot-battery",
            modifier = 0.1
          }
        },
        prerequisites = {"advanced-battery-research-11"},
        unit =
        {
          count_formula = "5(L-17)",
          ingredients =
          {
            {"station-science", 1},
          },
          time = 240
        },
        max_level = "infinite",
        order = "y-a"
      },
})