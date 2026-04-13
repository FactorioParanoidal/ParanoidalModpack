data:extend({
    {
        type = "technology",
        name = "Space-Lab-Research-1",
        icon_size = 256,
        order = "z-z",    
        icon = "__base__/graphics/technology/research-speed.png",
        effects =
        {
          {
            type = "laboratory-productivity",
            modifier = 0.01
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
          time = 120
        },
        max_level = 20,
        upgrade = true,
    },  
    {
      type = "technology",
      name = "Space-Lab-Research-21",
      icon_size = 256,
      order = "z-z",    
      icon = "__base__/graphics/technology/research-speed.png",
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.01
        }
      },
      prerequisites = {"Space-Lab-Research-1"},
      unit =
      {
        count_formula = "2",
        ingredients =
        {
          {"station-science", 1},
        },
        time = 120
      },
      max_level = 40,
      upgrade = true,
    },  
    {
      type = "technology",
      name = "Space-Lab-Research-41",
      icon_size = 256,
      order = "zzzz",    
      icon = "__base__/graphics/technology/research-speed.png",
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.01
        }
      },
      prerequisites = {"Space-Lab-Research-21"},
      unit =
      {
        count_formula = "6",
        ingredients =
        {
          {"station-science", 1},
        },
        time = 240
      },
      max_level = 60,
      upgrade = true,
    },  
    {
      type = "technology",
      name = "Space-Lab-Research-61",
      icon_size = 256,
      order = "zzzz",    
      icon = "__base__/graphics/technology/research-speed.png",
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.01
        }
      },
      prerequisites = {"Space-Lab-Research-41"},
      unit =
      {
        count_formula = "2(L-51)",
        ingredients =
        {
          {"station-science", 1},
        },
        time = 240
      },
      max_level = "infinite",
      upgrade = true,
    },  
})