data:extend(
  {
    {
      type = "technology",
      name = "research-speed-7",
      icon = "__All-infinit-tech__/graphics/science-speed-tech.png",
      icon_size = 256,
      prerequisites = {"research-speed-6"},
      effects =
      {
        {icon_size = 256,
          type = "laboratory-speed",
          modifier = 1.1
        }
      },

      unit =
      {
         count_formula = "1750",
        ingredients = 	{
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1}
        },
        time = 45
      },
      upgrade = true,
      order = "c-m-d"
    },
    {
        type = "technology",
        name = "research-speed-8",
        icon = "__All-infinit-tech__/graphics/science-speed-tech.png",
        icon_size = 256,
        prerequisites = {"research-speed-7"},
        effects =
        {
          {icon_size = 256,
            type = "laboratory-speed",
            modifier = 1.1
          }
        },
     
        unit =
        {
           count_formula = settings.startup["Infinite-Formula"].value,
          ingredients = 	{
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1}
          },
          time = 60
        },
        upgrade = true,
        order = "c-m-d",        
        max_level = "infinite"
      },

})


--[[ --check if mod space-exploration exist and add 2 tier to research speed
if mods["space-exploration"] then
  
  data.raw["technology"]["research-speed-8"].max_level = "8"
  
  
  data:extend
  {
    {
      type = "technology",
      name = "research-speed-9",
      icon = "__All-infinit-tech__/graphics/science-speed-tech.png",
      icon_size = 256,
      prerequisites = {
        "research-speed-8",
        "se-material-science-pack-3",
        "se-energy-science-pack-3",
        "se-biological-science-pack-3",
        "se-astronomic-science-pack-3"
      },
      effects =
      {
        {icon_size = 256,
          type = "laboratory-speed",
          modifier = 1.1
        }
      },
   
      unit =
      {
        count_formula = "1250",
         ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1},
          {"se-astronomic-science-pack-3",1},
          {"se-biological-science-pack-3",1},
          {"se-energy-science-pack-3",1},
          {"se-material-science-pack-3",1}
          },
        time = 60
      },
      upgrade = true,
      order = "c-m-d"      
    },
    {
      type = "technology",
      name = "research-speed-10",
      icon = "__All-infinit-tech__/graphics/science-speed-tech.png",
      icon_size = 256,
      prerequisites = {
        "research-speed-9",
        "se-material-science-pack-4",
        "se-energy-science-pack-4",
        "se-biological-science-pack-4",
        "se-astronomic-science-pack-4"
      },
      effects =
      {
        {icon_size = 256,
          type = "laboratory-speed",
          modifier = 1.1
        }
      },
   
      unit =
      {
        count_formula = settings.startup["Infinite-Formula"].value,
         ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1},
          {"se-astronomic-science-pack-4",1},
          {"se-biological-science-pack-4",1},
          {"se-energy-science-pack-4",1},
          {"se-material-science-pack-4",1}
          },
        time = 60
      },
      upgrade = true,
      order = "c-m-d",        
      max_level = "infinite"
    },
  }
end ]]








data:extend({
    {
        type = "technology",
        name = "laboratory-productivity-1",
        icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
        tint = {r=1,g=0.4,b=0.4,a=0.5},
        icon_size = 256,
        prerequisites = {"automation-2"},
        effects =
        {
          {
            type = "laboratory-productivity",
            modifier = 0.5
          }
        },
        unit =
        {
          count_formula = "250",
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
          },
          time = 60
        },
        upgrade = true,
        order = "c-k-f-f"
    },
    {
      type = "technology",
      name = "laboratory-productivity-2",
      icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
      tint = {r=1,g=0.4,b=0.4,a=0.5},
      icon_size = 256,
      prerequisites = {"laboratory-productivity-1"},
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.5
        }
      },
      unit =
      {
        count_formula = "500",
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1}
        },
        time = 60
      },
      upgrade = true,
      order = "c-k-f-f"
    },
    {
      type = "technology",
      name = "laboratory-productivity-3",
      icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
      tint = {r=1,g=0.4,b=0.4,a=0.5},
      icon_size = 256,
      prerequisites = {"laboratory-productivity-2","chemical-science-pack"},
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.5
        }
      },
      unit =
      {
        count_formula = "750",
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1}
        },
        time = 60
      },
    },
    {
      type = "technology",
      name = "laboratory-productivity-4",
      icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
      tint = {r=1,g=0.4,b=0.4,a=0.5},
      icon_size = 256,
      prerequisites = {"laboratory-productivity-3"},
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.5
        }
      },
      unit =
      {
        count_formula = "1000",
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1}
        },
        time = 60
      },
      upgrade = true,
      order = "c-k-f-f"
    },
    {
      type = "technology",
      name = "laboratory-productivity-5",
      icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
      tint = {r=1,g=0.4,b=0.4,a=0.5},
      icon_size = 256,
      prerequisites = {"laboratory-productivity-4","production-science-pack"},
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.5
        }
      },
      unit =
      {
        count_formula = "1250",
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1}
        },
        time = 60
      },
      upgrade = true,
      order = "c-k-f-f"
    },      
    {
      type = "technology",
      name = "laboratory-productivity-6",
      icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
      tint = {r=1,g=0.4,b=0.4,a=0.5},
      icon_size = 256,
      prerequisites = {"laboratory-productivity-5"},
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.5
        }
      },
      unit =
      {
        count_formula = "1500",
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1}
        },
        time = 60
      },
      upgrade = true,
      order = "c-k-f-f"
    },    
    {
      type = "technology",
      name = "laboratory-productivity-7",
      icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
      tint = {r=1,g=0.4,b=0.4,a=0.5},
      icon_size = 256,
      prerequisites = {"laboratory-productivity-6","utility-science-pack"},
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.5
        }
      },
      unit =
      {
        count_formula = "1750",
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1}
        },
        time = 60
      },
      upgrade = true,
      order = "c-k-f-f"
    },    
    {
      type = "technology",
      name = "laboratory-productivity-8",
      icon = "__All-infinit-tech__/graphics/science-prod-tech.png",
      tint = {r=1,g=0.4,b=0.4,a=0.5},
      icon_size = 256,
      prerequisites = {"laboratory-productivity-7","space-science-pack"},
      effects =
      {
        {
          type = "laboratory-productivity",
          modifier = 0.5
        }
      },
      unit =
      {
        count_formula = settings.startup["Infinite-Formula"].value,
        ingredients =  {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"production-science-pack", 1},
          {"utility-science-pack", 1},
          {"space-science-pack", 1}
        },
        time = 60
      },
      upgrade = true,
      order = "c-k-f-f",
      max_level = "infinite",
    }
})
