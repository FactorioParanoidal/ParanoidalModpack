local TECHPATH = "__Aircraft-space-age__/graphics/technology/"

local function unlock(recipe)
  return {
    type = "unlock-recipe",
    recipe = recipe
  }
end

data:extend({
  { -- Advanced Aerodynamics (base tech)
    type = "technology",
    name = "advanced-aerodynamics",
    icon = TECHPATH .. "advanced_aerodynamics_tech.png",
    icon_size = 256,
    prerequisites = {"automobilism", "robotics"},
    -- unit = {
    --   count = 350,
    --   ingredients = {
    --     {"automation-science-pack", 1},
    --     {"logistic-science-pack", 1},
    --     {"chemical-science-pack", 1}
    --   },
    --   time = 45
    -- },
    research_trigger =
    {
      type = "craft-item",
      item = "flying-robot-frame",
      count = 100
    },
    order = "c-h-b"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Gunship
    type = "technology",
    name = "gunships",
    icon = TECHPATH .. "gunships.png",
    icon_size = 256,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "gunship"
      }
    },
    prerequisites = {"military-3", "advanced-aerodynamics", "rocketry"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 60
    },
    order = "c-h-c"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Cargo Plane
    type = "technology",
    name = "cargo-planes",
    icon = TECHPATH .. "cargo-planes.png",
    icon_size = 256,
    effects = { 
      {
        type = "unlock-recipe",
        recipe="cargo-plane"
      }
    },
    prerequisites = {"advanced-aerodynamics"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "c-h-d"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Jet
    type = "technology",
    name = "jets",
    icon = TECHPATH .. "jets.png",
    icon_size = 256,
    effects = {
      {
        type = "unlock-recipe",
        recipe="jet"
      }
    },

      
       
    prerequisites = {"gunships", "explosive-rocketry", "military-4"},
    unit = {
      count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 75
    },
    order = "c-h-e"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Flying Fortress
    type = "technology",
    name = "flying-fortress",
    icon = TECHPATH .. "flying-fortress.png",
    icon_size = 256,
    effects = { 
      {
        type = "unlock-recipe",
        recipe="flying-fortress"
      }
      },
    prerequisites = {"gunships", "cargo-planes", "jets", "artillery", "space-science-pack"},
    unit = {
      count = 3000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"production-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 120
    },
    order = "c-h-f"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- High Explosive Cannon Shells
    type = "technology",
    name = "high-explosive-cannon-shells",
    icon = TECHPATH .. "high_explosive_shell_tech.png",
    icon_size = 256,
    effects = { 
      {
        type = "unlock-recipe",
        recipe="high-explosive-cannon-shell"
      }
        },
    prerequisites = {"artillery"},
    unit = {
      count = 350,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 45
    },
    order = "c-h-g"
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Napalm
    type = "technology",
    name = "napalm",
    icon = TECHPATH .. "napalm_tech.png",
    icon_size = 256,
    effects = { 
      {
        type = "unlock-recipe",
        recipe="napalm"
      }
        },
    prerequisites = {"flammables", "jets"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
      },
      time = 20,
    },
    order = "c-h-h",
  },
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Afterburner
    type = "technology",
    name = "afterburner",
    icon = TECHPATH .. "aircraft_afterburner_tech.png",
    icon_size = 256,
    effects = { 
      {
        type = "unlock-recipe",
        recipe="aircraft-afterburner"
      }
        },
    prerequisites = {"advanced-aerodynamics"},
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 45,
    },
    order = "c-h-h",
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  { -- Aircraft Energy Shield
    type = "technology",
    name = "aircraft-energy-shield",
    icon = TECHPATH .. "aircraft_energy_shield_tech.png",
    icon_size = 256,
    effects = { 
      
      {
        type = "unlock-recipe",
        recipe="aircraft-energy-shield"
      }
        },
    --prerequisites = {"advanced-aerodynamics", "energy-shield-mk2-equipment"},\
    prerequisites = {"gunships", "energy-shield-mk2-equipment"},
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 45,
    },
    order = "c-h-i",
    --Hey,   ^^^^^   a lil' easter egg for ya
  },
})

--Space age technology changes.
--Locks some recipes behind space sciences
if mods["space-age"] then
  data.raw["technology"]["aircraft-energy-shield"].unit = {
    count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1},
        {"electromagnetic-science-pack", 1},
      },
      time = 45,
  }
  data.raw["technology"]["aircraft-energy-shield"].prerequisites = {"gunships", "energy-shield-mk2-equipment"}
    
  
  -- if settings.startup["space-age-easy-mode"].value==false then 
  --   -- data.raw["technology"]["jets"].unit = {
  --   --   count = 1000,
  --   --     ingredients = {
  --   --       {"automation-science-pack", 1},
  --   --       {"logistic-science-pack", 1},
  --   --       {"chemical-science-pack", 1},
  --   --       {"military-science-pack", 1},
  --   --       {"production-science-pack", 1},
  --   --       {"space-science-pack", 1},
  --   --       {"agricultural-science-pack", 1},
  --   --     },
  --   --     time = 75
  --   -- }

  -- else
  --   data.raw["technology"]["jets"].unit = {
  --     count = 1000,
  --       ingredients = {
  --         {"automation-science-pack", 1},
  --         {"logistic-science-pack", 1},
  --         {"chemical-science-pack", 1},
  --         {"military-science-pack", 1},
  --         {"production-science-pack", 1},
  --         {"space-science-pack", 1},
  --       },
  --       time = 75
  --   }
  -- end
  
  --data.raw["technology"]["jets"].prerequisites = {"gunships", "explosive-rocketry", "military-4","space-science-pack","carbon-fiber"}
  

  -- data.raw["technology"]["flying-fortress"].unit = {
  --   count = 3000,
  --     ingredients = {
  --       {"automation-science-pack", 1},
  --       {"logistic-science-pack", 1},
  --       {"chemical-science-pack", 1},
  --       {"military-science-pack", 1},
  --       {"utility-science-pack", 1},
  --       {"production-science-pack", 1},
  --       {"space-science-pack", 1},
  --       {"metallurgic-science-pack", 1},
  --       {"agricultural-science-pack", 1},
  --     },
  --     time = 120
  -- }
  --data.raw["technology"]["flying-fortress"].prerequisites = {"gunships", "cargo-planes", "jets", "artillery", "space-science-pack","metallurgic-science-pack","carbon-fiber"}
  --table.insert(data.raw["technology"]["flying-fortress"].prerequisites,"metallurgic-science-pack") = {"gunships", "cargo-planes", "jets", "artillery", "space-science-pack","metallurgic-science-pack","carbon-fiber"}
  table.insert(data.raw["technology"]["flying-fortress"].unit.ingredients,{"metallurgic-science-pack", 1})
  data.raw["technology"]["afterburner"].unit = {
    count = 400,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        --{"utility-science-pack", 1},
        {"space-science-pack", 1},
       -- {"agricultural-science-pack", 1},
      },
      time = 45,
  }
  --table.insert(data.raw["technology"]["afterburner"].prerequisites,"space-platform-thruster")

  --table.insert(data.raw["technology"]["afterburner"].prerequisites,"carbon-fiber")

  -- data.raw["technology"]["high-explosive-cannon-shells"].unit = {
   
  --     count = 350,
  --     ingredients = {
  --       {"automation-science-pack", 1},
  --       {"logistic-science-pack", 1},
  --       {"chemical-science-pack", 1},
  --       {"military-science-pack", 1},
  --       {"space-science-pack", 1},
  --       {"metallurgic-science-pack", 1},
  --       {"utility-science-pack", 1},
  --     },
  --     time = 45
    
  -- }
  
  --Adds "cargo planes" technology to rocket silo rereqs
  -- Reasoning: It makes sense for the progression to go from aircraft to spacecraft to me.
  if settings.startup["aircraft-change-vanilla-tech-tree"].value == true then
    table.insert(data.raw["technology"]["rocket-silo"].prerequisites,"cargo-planes")
    table.insert(data.raw["technology"]["space-platform-thruster"].prerequisites,"afterburner")
  end
  

  -- if settings.startup["experimental-features"].value==true then 
  -- --   data:extend({
  -- --     { -- Blimp
  -- --   type = "technology",
  -- --   name = "blimps",
  -- --   icon = TECHPATH .. "flying_fortress.png",
  -- --   icon_size = 256,
  -- --   effects = { 
  -- --     {
  -- --       type = "unlock-recipe",
  -- --       recipe="flying-fortress"
  -- --     }
  -- --     },
  -- --   prerequisites = {"gunships", "cargo-planes", "jets", "artillery", "space-science-pack"},
  -- --   unit = {
  -- --     count = 3000,
  -- --     ingredients = {
  -- --       {"automation-science-pack", 1},
  -- --       {"logistic-science-pack", 1},
  -- --       {"chemical-science-pack", 1},
  -- --       {"military-science-pack", 1},
  -- --       {"utility-science-pack", 1},
  -- --       {"production-science-pack", 1},
  -- --       {"space-science-pack", 1}
  -- --     },
  -- --     time = 120
  -- --   },
  -- --   order = "c-h-f"
  -- -- },
  -- --   })
  -- end
  -- if settings.startup["carbon-fiber-aircraft"].value==true then 
  --   --Aircraft_List
    
  -- end
  
end

