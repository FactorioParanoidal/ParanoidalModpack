--update energy weapon
data.raw["technology"]["laser-weapons-damage-7"].unit.count = nil
data.raw["technology"]["laser-weapons-damage-7"].unit.count_formula = settings.startup["Infinite-Formula"].value

--update bot speed 
data.raw["technology"]["worker-robots-speed-6"].unit.count = nil
data.raw["technology"]["worker-robots-speed-6"].unit.count_formula = settings.startup["Infinite-Formula"].value


--#region if space-age override
if mods["space-age"] then

  --update to bot battery
  data.raw["technology"]["worker-robots-battery-8"].max_level = nil
  --update bot capacity
  data.raw["technology"]["worker-robots-storage-8"].max_level = nil
  --update braking
  data.raw["technology"]["braking-force-8"].max_level = nil
  --update inserter capacity
  data.raw["technology"]["inserter-capacity-bonus-8"].max_level = nil
  --update science tech
  data.raw["technology"]["laboratory-productivity-8"].max_level = nil

  -- Template for common technology attributes
  local function create_technology(name, prerequisites, ingredients, modifier, icon, order, time, level)
      return {
          type = "technology",
          name = name,
          icon = icon,
          icon_size = 256,
          prerequisites = prerequisites,
          effects = {
              { type = modifier, modifier = 0.2 }
          },
          unit = {
              count_formula = settings.startup["Infinite-Formula"].value,
              ingredients = ingredients,
              time = time
          },
          upgrade = true,
          order = order,
          max_level = level or nil
      }
  end
  local science1 = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"space-science-pack", 1},
    {"metallurgic-science-pack", 1}
  }
  local science2= {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"space-science-pack", 1},
    {"metallurgic-science-pack", 1},
    {"electromagnetic-science-pack",1}
  }
  local science3= {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"space-science-pack", 1},
    {"metallurgic-science-pack", 1},
    {"electromagnetic-science-pack",1},
    {"agricultural-science-pack",1}
  }
  local science4= {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"space-science-pack", 1},
    {"metallurgic-science-pack", 1},
    {"electromagnetic-science-pack",1},
    {"agricultural-science-pack",1},
    {"cryogenic-science-pack",1}
  }
  local science5 = {
    {"automation-science-pack", 1},
    {"logistic-science-pack", 1},
    {"chemical-science-pack", 1},
    {"production-science-pack", 1},
    {"utility-science-pack", 1},
    {"space-science-pack", 1},
    {"metallurgic-science-pack", 1},
    {"electromagnetic-science-pack",1},
    {"agricultural-science-pack",1},
    {"cryogenic-science-pack",1},
    {"promethium-science-pack",1}
  }
  -- Common properties for icons
  local icon_base = "__All-infinit-tech__/graphics/bot-batterie-tech.png"
  local storage_icon = "__All-infinit-tech__/graphics/bot-storage-tech.png"
  local braking_icon = "__All-infinit-tech__/graphics/braking-tech.png"
  local inserter_icon = "__All-infinit-tech__/graphics/inserter-tech.png"
  local science_icon = "__All-infinit-tech__/graphics/science-prod-tech.png"

  -- Generate the technologies
  data:extend({
      -- Worker robots battery techs
      create_technology("worker-robots-battery-9", {"worker-robots-battery-8", "metallurgic-science-pack"}, science1, "worker-robot-battery", icon_base, "c-k-h-e", 50),
      create_technology("worker-robots-battery-10", {"worker-robots-battery-9", "electromagnetic-science-pack"}, science2, "worker-robot-battery", icon_base, "c-k-h-e", 50),
      create_technology("worker-robots-battery-11", {"worker-robots-battery-10", "agricultural-science-pack"}, science3, "worker-robot-battery", icon_base, "c-k-h-e", 50),
      create_technology("worker-robots-battery-12", {"worker-robots-battery-11", "cryogenic-science-pack"}, science4, "worker-robot-battery", icon_base, "c-k-h-e", 50),
      create_technology("worker-robots-battery-13", {"worker-robots-battery-12", "promethium-science-pack"}, science5, "worker-robot-battery", icon_base, "c-k-h-e", 50, "infinite"),

      -- Worker robots storage techs
      create_technology("worker-robots-storage-9", {"worker-robots-storage-8", "metallurgic-science-pack"}, science1, "worker-robot-storage", storage_icon, "c-k-f-e", 60),
      create_technology("worker-robots-storage-10", {"worker-robots-storage-9", "electromagnetic-science-pack"}, science2, "worker-robot-storage", storage_icon, "c-k-f-e", 60),
      create_technology("worker-robots-storage-11", {"worker-robots-storage-10", "agricultural-science-pack"}, science3, "worker-robot-storage", storage_icon, "c-k-f-e", 60),
      create_technology("worker-robots-storage-12", {"worker-robots-storage-11", "cryogenic-science-pack"}, science4, "worker-robot-storage", storage_icon, "c-k-f-e", 60),
      create_technology("worker-robots-storage-13", {"worker-robots-storage-12", "promethium-science-pack"}, science5, "worker-robot-storage", storage_icon, "c-k-f-e", 60, "infinite"),

      -- Braking force techs
      create_technology("braking-force-9", {"braking-force-8", "metallurgic-science-pack"}, science1, "train-braking-force-bonus", braking_icon, "b-f-h", 60),
      create_technology("braking-force-10", {"braking-force-9", "electromagnetic-science-pack"}, science2, "train-braking-force-bonus", braking_icon, "b-f-h", 60),
      create_technology("braking-force-11", {"braking-force-10", "agricultural-science-pack"}, science3, "train-braking-force-bonus", braking_icon, "b-f-h", 60),
      create_technology("braking-force-12", {"braking-force-11", "cryogenic-science-pack"}, science4, "train-braking-force-bonus", braking_icon, "b-f-h", 60),
      create_technology("braking-force-13", {"braking-force-12", "promethium-science-pack"}, science5, "train-braking-force-bonus", braking_icon, "b-f-h", 60, "infinite"),

      -- Inserter capacity techs
      create_technology("inserter-capacity-bonus-9", {"inserter-capacity-bonus-8", "metallurgic-science-pack"}, science1, "inserter-stack-size-bonus", inserter_icon, "c-k-f-e", 60),
      create_technology("inserter-capacity-bonus-10", {"inserter-capacity-bonus-9", "electromagnetic-science-pack"}, science2, "inserter-stack-size-bonus", inserter_icon, "c-k-f-e", 60),
      create_technology("inserter-capacity-bonus-11", {"inserter-capacity-bonus-10", "agricultural-science-pack"}, science3, "inserter-stack-size-bonus", inserter_icon, "c-k-f-e", 60),
      create_technology("inserter-capacity-bonus-12", {"inserter-capacity-bonus-11", "cryogenic-science-pack"}, science4, "inserter-stack-size-bonus", inserter_icon, "c-k-f-e", 60),
      create_technology("inserter-capacity-bonus-13", {"inserter-capacity-bonus-12", "promethium-science-pack"}, science5, "inserter-stack-size-bonus", inserter_icon, "c-k-f-e", 60, "infinite"),

      -- Laboratory productivity techs
      create_technology("laboratory-productivity-9", {"laboratory-productivity-8", "metallurgic-science-pack"}, science1, "laboratory-productivity", science_icon, "c-k-f-f", 60),
      create_technology("laboratory-productivity-10", {"laboratory-productivity-9", "electromagnetic-science-pack"}, science2, "laboratory-productivity", science_icon, "c-k-f-f", 60),
      create_technology("laboratory-productivity-11", {"laboratory-productivity-10", "agricultural-science-pack"}, science3, "laboratory-productivity", science_icon, "c-k-f-f", 60),
      create_technology("laboratory-productivity-12", {"laboratory-productivity-11", "cryogenic-science-pack"}, science4, "laboratory-productivity", science_icon, "c-k-f-f", 60),
      create_technology("laboratory-productivity-13", {"laboratory-productivity-12", "promethium-science-pack"}, science5, "laboratory-productivity", science_icon, "c-k-f-f", 60, "infinite")
  })

end
--#endregion


--[[ --#region if space exploration override mod change
if mods["space-exploration"] then

  --update artillery science cost
    data.raw["technology"]["artillery-shell-range-6"].unit.count_formula = settings.startup["Infinite-Formula"].value
    data.raw["technology"]["artillery-shell-speed-6"].unit.count_formula = settings.startup["Infinite-Formula"].value



  --worker robots batterie 6,7,8,9,10
    data.raw["technology"]["worker-robots-battery-3"].unit = 
    {
      count_formula = "750",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-battery-4"].unit = 
    {
      count_formula = "1000",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-battery-5"].prerequisites = {"worker-robots-battery-4","production-science-pack","space-science-pack"}
    data.raw["technology"]["worker-robots-battery-5"].unit = 
    {
      count_formula = "1250",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-battery-6"].prerequisites = {"worker-robots-battery-5","utility-science-pack"}
    data.raw["technology"]["worker-robots-battery-6"].unit = 
    {
      count_formula = "1500",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-battery-7"].prerequisites = {"worker-robots-battery-6","se-material-science-pack-1"}
    data.raw["technology"]["worker-robots-battery-7"].unit = 
    {
      count_formula = "250",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-1",1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-battery-8"].prerequisites = {"worker-robots-battery-7","se-material-science-pack-2"}
    data.raw["technology"]["worker-robots-battery-8"].unit = 
    {
      count_formula = "500",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-2",1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-battery-9"].prerequisites = {"worker-robots-battery-8","se-material-science-pack-3"}
    data.raw["technology"]["worker-robots-battery-9"].unit = 
    {
      count_formula = "750",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-3",1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-battery-10"].prerequisites = {"worker-robots-battery-9","se-material-science-pack-4","se-deep-space-science-pack-4"}
    data.raw["technology"]["worker-robots-battery-10"].unit = 
    {
      count_formula = settings.startup["Infinite-Formula"].value,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-4",1},
        {"se-deep-space-science-pack-4",1}
      },
      time = 60
    } 
  

    --worker robots cargo 3--6,7,8,9,10

    data.raw["technology"]["worker-robots-storage-3"].unit = 
    {
      count_formula = "500",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-storage-6"].unit = 
    {
      count_formula = "1500",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-storage-7"].prerequisites = {"worker-robots-storage-6","se-material-science-pack-1"}
    data.raw["technology"]["worker-robots-storage-7"].unit = 
    {
      count_formula = "250",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-1",1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-storage-8"].prerequisites = {"worker-robots-storage-7","se-material-science-pack-2"}
    data.raw["technology"]["worker-robots-storage-8"].unit = 
    {
      count_formula = "500",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-2",1}
      },
      time = 60
    }
    data.raw["technology"]["worker-robots-storage-9"].prerequisites = {"worker-robots-storage-8","se-material-science-pack-3"}
    data.raw["technology"]["worker-robots-storage-9"].unit = 
    {
      count_formula = "750",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-3",1}
      },
      time = 60
    }

    data.raw["technology"]["worker-robots-storage-10"].prerequisites = {"worker-robots-storage-9","se-material-science-pack-4","se-deep-space-science-pack-4"}
    data.raw["technology"]["worker-robots-storage-10"].unit = 
    {
      count_formula = settings.startup["Infinite-Formula"].value,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"se-material-science-pack-4",1},
        {"se-deep-space-science-pack-4",1}
      },
      time = 60
    } 
  

    --production science 5,6,7,8,9,10
    data.raw["technology"]["laboratory-productivity-5"].unit = 
    {
      count_formula = "1250",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"space-science-pack",1}
      },
      time = 60
    }
    data.raw["technology"]["laboratory-productivity-6"].unit = 
    {
      count_formula = "1500",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"space-science-pack",1}
      },
      time = 60
    }
    data.raw["technology"]["laboratory-productivity-7"].prerequisites =  {"laboratory-productivity-6","se-biological-science-pack-1"} 
    data.raw["technology"]["laboratory-productivity-7"].unit = 
    {
      count_formula = "250",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack",1},
        {"space-science-pack",1},
        {"se-biological-science-pack-1",1}
      },
      time = 60
    }
    data.raw["technology"]["laboratory-productivity-8"].prerequisites =  {"laboratory-productivity-7","se-biological-science-pack-2"} 
    data.raw["technology"]["laboratory-productivity-8"].unit = 
    {
      count_formula = "500" ,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack",1},
        {"space-science-pack",1},
        {"se-biological-science-pack-2",1}
      },
      time = 60
    }
    data.raw["technology"]["laboratory-productivity-9"].prerequisites =  {"laboratory-productivity-8","se-biological-science-pack-3"} 
    data.raw["technology"]["laboratory-productivity-9"].unit = 
    {
      count_formula = "750",
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack",1},
        {"space-science-pack",1},
        {"se-biological-science-pack-3",1}
      },
      time = 60
    }
    data.raw["technology"]["laboratory-productivity-10"].prerequisites =  {"laboratory-productivity-9","se-biological-science-pack-4","se-deep-space-science-pack-4"} 
    data.raw["technology"]["laboratory-productivity-10"].unit = 
    {
      count_formula = settings.startup["Infinite-Formula"].value,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack",1},
        {"space-science-pack",1},
        {"se-biological-science-pack-4",1},
        {"se-deep-space-science-pack-4",1}
      },
      time = 60
    } 
  
  
  --lab research speed 6,7,8,9,10
  data.raw["technology"]["research-speed-6"].prerequisites = {
    "research-speed-5",
    "utility-science-pack",
    "production-science-pack"
  }
  data.raw["technology"]["research-speed-6"].unit =  {
    count_formula = "750",
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
    },
    time = 60
  }

  data.raw["technology"]["research-speed-7"].prerequisites = {
    "research-speed-6",
    "se-material-science-pack-1",
    "se-energy-science-pack-1",
    "se-biological-science-pack-1",
    "se-astronomic-science-pack-1"
  }
  data.raw["technology"]["research-speed-7"].unit =  {
    count_formula = "250",
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
      {"se-astronomic-science-pack-1",1},
      {"se-biological-science-pack-1",1},
      {"se-energy-science-pack-1",1},
      {"se-material-science-pack-1",1}
    },
    time = 60
  }
  data.raw["technology"]["research-speed-8"].prerequisites = {
    "research-speed-7",
    "se-material-science-pack-2",
    "se-energy-science-pack-2",
    "se-biological-science-pack-2",
    "se-astronomic-science-pack-2"
  }
  data.raw["technology"]["research-speed-8"].unit =  {
    count_formula = "500",
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
      {"se-astronomic-science-pack-2",1},
      {"se-biological-science-pack-2",1},
      {"se-energy-science-pack-2",1},
      {"se-material-science-pack-2",1}
      },
    time = 60
    }
  data.raw["technology"]["research-speed-9"].prerequisites = {
    "research-speed-8",
    "se-material-science-pack-3",
    "se-energy-science-pack-3",
    "se-biological-science-pack-3",
    "se-astronomic-science-pack-3"
  }
  data.raw["technology"]["research-speed-9"].unit =  {
    count_formula = "750",
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
  }
  data.raw["technology"]["research-speed-10"].prerequisites = {
    "research-speed-9",
    "se-material-science-pack-4",
    "se-energy-science-pack-4",
    "se-biological-science-pack-4",
    "se-astronomic-science-pack-4",
    "se-deep-space-science-pack-4"
  }
  data.raw["technology"]["research-speed-10"].unit =  {
    count_formula = settings.startup["Infinite-Formula"].value ,
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
      {"se-material-science-pack-4",1},
      {"se-deep-space-science-pack-4",1}
      },
    time = 60
  }
  

  
  --braking force 8,9,10
  data.raw["technology"]["braking-force-6"].prerequisites = {"braking-force-5"}
  data.raw["technology"]["braking-force-6"].unit =  {
    count_formula = "500" ,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
      },
    time = 60
  }
  data.raw["technology"]["braking-force-7"].prerequisites = {"braking-force-6","se-material-science-pack-1"}
  data.raw["technology"]["braking-force-7"].unit =  {
    count_formula = "250" ,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
      {"se-material-science-pack-1",1}
      },
    time = 60
  }
  data.raw["technology"]["braking-force-8"].prerequisites = {"braking-force-7","se-material-science-pack-2"}
  data.raw["technology"]["braking-force-8"].unit =  {
    count_formula = "500" ,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
      {"se-material-science-pack-2",1}
      },
    time = 60
  }
  data.raw["technology"]["braking-force-9"].prerequisites = {"braking-force-8","se-material-science-pack-3"}
  data.raw["technology"]["braking-force-9"].unit =  {
    count_formula = "750" ,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
      {"se-material-science-pack-3",1}
      },
    time = 60
  }
  data.raw["technology"]["braking-force-10"].prerequisites = {"braking-force-9","se-material-science-pack-4","se-deep-space-science-pack-4"}
  data.raw["technology"]["braking-force-10"].unit =  {
    count_formula = settings.startup["Infinite-Formula"].value,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"space-science-pack", 1},
      {"se-material-science-pack-4",1},
      {"se-deep-space-science-pack-4",1}
      },
    time = 60
  }


    
end
 ]]

--#endregion

--#region if Krastorio2 override mod change
if mods["Krastorio2"] then
  
  --#region bot battery
  data.raw.technology["worker-robots-battery-1"].enabled = false
  data.raw.technology["worker-robots-battery-1"].hidden = true
  data.raw.technology["worker-robots-battery-2"].enabled = false
  data.raw.technology["worker-robots-battery-2"].hidden = true
  data.raw.technology["worker-robots-battery-3"].enabled = false
  data.raw.technology["worker-robots-battery-3"].hidden = true
  data.raw.technology["worker-robots-battery-4"].enabled = false
  data.raw.technology["worker-robots-battery-4"].hidden = true
  data.raw.technology["worker-robots-battery-5"].enabled = false
  data.raw.technology["worker-robots-battery-5"].hidden = true
  

  data.raw.technology["worker-robots-battery-6"].prerequisites = {"kr-robot-battery-plus"}
  data.raw.technology["worker-robots-battery-6"].unit.ingredients = {
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"kr-matter-tech-card", 1}
  }

  data.raw.technology["worker-robots-battery-7"].prerequisites = {"worker-robots-battery-6"}
  table.insert(data.raw.technology["worker-robots-battery-7"].prerequisites ,"space-science-pack")
  data.raw.technology["worker-robots-battery-7"].unit.ingredients = {
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"kr-matter-tech-card", 1},
        {"space-science-pack", 1},
        {"kr-advanced-tech-card", 1}
  }
  data.raw.technology["worker-robots-battery-8"].prerequisites = {"worker-robots-battery-7","kr-singularity-tech-card"}
    data.raw.technology["worker-robots-battery-8"].unit.ingredients = {
        {"kr-matter-tech-card", 1},
        {"space-science-pack", 1},
        {"kr-advanced-tech-card", 1},
        {"kr-singularity-tech-card",1}
  }
  --#endregion

  --#region bot capacity
  table.insert(data.raw.technology["worker-robots-storage-8"].prerequisites ,"kr-matter-tech-card")
  table.insert(data.raw.technology["worker-robots-storage-8"].prerequisites ,"kr-advanced-tech-card")
  table.insert(data.raw.technology["worker-robots-storage-8"].prerequisites ,"kr-singularity-tech-card")
  data.raw.technology["worker-robots-storage-8"].unit.ingredients = {
    {"kr-matter-tech-card", 1},
    {"space-science-pack", 1},
    {"kr-advanced-tech-card", 1},
    {"kr-singularity-tech-card",1}
  }

  --#endregion

  --#region braking
  table.insert(data.raw.technology["braking-force-8"].prerequisites ,"kr-matter-tech-card")
  table.insert(data.raw.technology["braking-force-8"].prerequisites ,"kr-advanced-tech-card")
  table.insert(data.raw.technology["braking-force-8"].prerequisites ,"kr-singularity-tech-card")
  data.raw.technology["braking-force-8"].unit.ingredients = {
    {"kr-matter-tech-card", 1},
    {"space-science-pack", 1},
    {"kr-advanced-tech-card", 1},
    {"kr-singularity-tech-card",1}
  }
  --#endregion

  --#region inserter
  table.insert(data.raw.technology["inserter-capacity-bonus-8"].prerequisites ,"kr-matter-tech-card")
  table.insert(data.raw.technology["inserter-capacity-bonus-8"].prerequisites ,"kr-advanced-tech-card")
  table.insert(data.raw.technology["inserter-capacity-bonus-8"].prerequisites ,"kr-singularity-tech-card")
  data.raw.technology["inserter-capacity-bonus-8"].unit.ingredients = {
    {"kr-matter-tech-card", 1},  
    {"space-science-pack", 1},
    {"kr-advanced-tech-card", 1},
    {"kr-singularity-tech-card",1}
  }
  --#endregion

end

--#endregion