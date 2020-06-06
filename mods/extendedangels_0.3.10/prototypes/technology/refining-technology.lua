if not mods["Clowns-Extended-Minerals"] then 

    data:extend(
        {

    {
        type = "technology",
        name = "water-washing-3",
        icon = "__angelsrefining__/graphics/technology/washing-plant-tech.png",
        icon_size = 128,
        prerequisites =
        {
        "water-washing-2",       
        },
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "washing-plant-3"
          },
        },
        unit =
        {
          count = 100,
          ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},          
          },
          time = 15
        },
        order = "c-a"
        },

    }
)

end

if not mods["Clowns-Processing"] then 

data:extend(
  {
    {
        type = "technology",
        name = "water-treatment-5",
        icon = "__angelsrefining__/graphics/technology/water-treatment.png",
        icon_size = 128,
        prerequisites =
        {
        "water-treatment-4",
        },
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "hydro-plant-4"
          },
          {
            type = "unlock-recipe",
            recipe = "salination-plant-3"
          },                   
        },
        unit =
        {
          count = 100,
          ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          },
          time = 15
        },
        order = "c-a"
        },
  }
)

end

  data:extend(
    {
    	{
            type = "technology",
            name = "water-washing-4",
            icon = "__angelsrefining__/graphics/technology/washing-plant-tech.png",
            icon_size = 128,
            prerequisites =
            {
            "water-washing-3",           
            },
            effects =
            {
              {
                type = "unlock-recipe",
                recipe = "washing-plant-4"
              },
            },
            unit =
            {
              count = 150,
              ingredients = {
              {"automation-science-pack", 1},
              {"logistic-science-pack", 1},
              {"chemical-science-pack", 1},
              {"production-science-pack", 1},
              {"utility-science-pack", 1},
              },
              time = 15
            },
            order = "c-a"
            },    
            {
              type = "technology",
              name = "advanced-ore-refining-5",
              icon = "__angelsrefining__/graphics/technology/ore-sorting.png",
            icon_size = 128,
            prerequisites =
              {
            "advanced-ore-refining-4",
              },
              effects =
              {
                {
                  type = "unlock-recipe",
                  recipe = "ore-crusher-4"
                },
                {
                  type = "unlock-recipe",
                  recipe = "ore-floatation-cell-4"
                },
                {
                  type = "unlock-recipe",
                  recipe = "ore-leaching-plant-4"
                },
                {
                  type = "unlock-recipe",
                  recipe = "ore-refinery-3"
                },
              },
              unit =
              {
                count = 150,
                ingredients = {
              {"automation-science-pack", 1},
              {"logistic-science-pack", 1},
              {"chemical-science-pack", 1},
              {"production-science-pack", 1},
              {"utility-science-pack", 1},
              },
                time = 15
              },
              order = "c-a"
              },             
            }

)

