data:extend({
      {
        type = "technology",
        name = "advanced-fan-research-1",
        icon_size = 128,
        icon = "__expanded-rocket-payloads-continued__/graphic/mir-128.png",
        effects =
        {
          {
            type = "worker-robot-storage",
            modifier = 1
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
        order = "y-a",
        max_level = 10,
      },
      {
        type = "technology",
        name = "advanced-fan-research-11",
        icon_size = 128,
        icon = "__expanded-rocket-payloads-continued__/graphic/mir-128.png",
        effects =
        {
          {
            type = "worker-robot-storage",
            modifier = 1
          }
        },
        prerequisites = {"advanced-fan-research-1"},
        unit =
        {
          count_formula = "L",
          ingredients =
          {
            {"station-science", 1},
          },
          time = 120
        },
        order = "y-a",
        max_level = 20,
      },
      {
        type = "technology",
        name = "advanced-fan-research-21",
        icon_size = 128,

        icon = "__expanded-rocket-payloads-continued__/graphic/mir-128.png",
        effects =
        {
          {
            type = "worker-robot-storage",
            modifier = 1
          }
        },
        prerequisites = {"advanced-fan-research-11"},
        unit =
        {
          count_formula = "2(L-11)",
          ingredients =
          {
            {"station-science", 1},
          },
          time = 240
        },
        order = "y-a",
        max_level = "infinite",
      },
})