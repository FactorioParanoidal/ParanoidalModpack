local researchCost = settings.startup["SpaceX-research"].value
if researchCost == nil then
	researchCost = 1
end

local marathon_adj
local ignoreMult = settings.startup["SpaceX-ignore-tech-multiplier"].value
if ignoreMult == nil then
	marathon_adj = 1
elseif ignoreMult == true then
	marathon_adj = 4
else	
	marathon_adj = 1
end

local noSpace = settings.startup["SpaceX-no-space-sci"].value

data:extend(
{
  {
    type = "technology",
    name = "space-assembly",
    icon = "__SpaceMod__/graphics/technology/space-assembly.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "assembly-robot"
        },
        {
            type = "unlock-recipe",
            recipe = "spacex-combinator"
        },
      },
    prerequisites = {"rocket-silo"},
    unit =
    {
      count = 6000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1}
      },
      time = 60
    },
    order = "k-b"
  },
  {
    type = "technology",
    name = "space-construction",
    icon = "__SpaceMod__/graphics/technology/space-construction.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "drydock-assembly"
        },
        {
            type = "unlock-recipe",
            recipe = "drydock-structural"
        },		
      },	
    prerequisites = {"space-assembly"},
    unit =
    {
      count = 12000  * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1}
      },
      time = 60
    },
	order = "k-c"
  },
  {
    type = "technology",
    name = "space-casings",
    icon = "__SpaceMod__/graphics/technology/space-casings.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "hull-component"
        },
      },	
    prerequisites = {"space-construction"},
    unit =
    {
      count = 12000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1}
      },
      time = 60
    },
	order = "k-d"
  }, 
  {
    type = "technology",
    name = "protection-fields",
    icon = "__SpaceMod__/graphics/technology/protection-fields.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "protection-field"
        },
      },	
    prerequisites = {"space-construction"},
    unit =
    {
      count = 12000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"military-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 60
    },
	order = "k-e"
  },
  {
    type = "technology",
    name = "fusion-reactor",
    icon = "__SpaceMod__/graphics/technology/fusion-reactor.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "fusion-reactor"
        },
      },	
    prerequisites = {"space-construction"},
    unit =
    {
      count = 12000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"military-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 60
    },
	order = "k-f"
  }, 
  {
    type = "technology",
    name = "space-thrusters",
    icon = "__SpaceMod__/graphics/technology/space-thrusters.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "space-thruster"
        },
      },
    prerequisites = {"space-construction"},
    unit =
    {
      count = 6000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1}
      },
      time = 60
    },
	order = "k-g"
  },   
  {
    type = "technology",
    name = "fuel-cells",
    icon = "__SpaceMod__/graphics/technology/fuel-cells.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "fuel-cell"
        },
      },	
    prerequisites = {"space-construction"},
    unit =
    {
      count = 6000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 60
    },
	order = "k-h"
  }, 
  {
    type = "technology",
    name = "habitation",
    icon = "__SpaceMod__/graphics/technology/habitation.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "habitation"
        },
      },		
    prerequisites = {"space-construction"},
    unit =
    {
      count = 12000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 60
    },
	order = "k-i"
  }, 
  {
    type = "technology",
    name = "life-support-systems",
    icon = "__SpaceMod__/graphics/technology/life-support.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "life-support"
        },
      },		
    prerequisites = {"space-construction"},
    unit =
    {
      count = 12000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 60
    },
	order = "k-j"
  },  
  {
    type = "technology",
    name = "spaceship-command",
    icon = "__SpaceMod__/graphics/technology/command.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "command"
        },
      },		
    prerequisites = {"space-construction"},
    unit =
    {
      count = 24000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 60
    },
	order = "k-k"
  }, 
  {
    type = "technology",
    name = "astrometrics",
    icon = "__SpaceMod__/graphics/technology/astrometrics.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "astrometrics"
        },
      },		
    prerequisites = {"space-construction"},
    unit =
    {
      count = 14000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1},
		{"space-science-pack", 1}
      },
      time = 60
    },
	order = "k-l"
  }, 
  {
    type = "technology",
    name = "ftl-theory-A",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
	icon_size = 128,
    prerequisites = {"space-construction"},
    unit =
    {
      count = 200000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
      },
      time = 60
    },
	order = "k-m"
  },
  {
    type = "technology",
    name = "ftl-theory-B",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
	icon_size = 128,
    prerequisites = {"ftl-theory-A"},
    unit =
    {
      count = 200000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 60
    },
	order = "k-n"
  },
  {
    type = "technology",
    name = "ftl-theory-C",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
	icon_size = 128,
    prerequisites = {"ftl-theory-B"},
    unit =
    {
      count = 200000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		    {"chemical-science-pack", 1},
      },
      time = 60
    },
	order = "k-o"
  },
  {
    type = "technology",
    name = "ftl-theory-D1",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
	icon_size = 128,
    prerequisites = {"ftl-theory-C"},
    unit =
    {
      count = 200000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 60
    },
	order = "k-o"
  }, 
  {
    type = "technology",
    name = "ftl-theory-D2",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
	icon_size = 128,
    prerequisites = {"ftl-theory-C"},
    unit =
    {
      count = 200000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 60
    },
	order = "k-o"
  }, 
  {
    type = "technology",
    name = "ftl-propulsion",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
	icon_size = 128,
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "ftl-drive"
        },
      },
    prerequisites = {"ftl-theory-D1",
                     "ftl-theory-D2"},
    unit =
    {
      count = 200000 * researchCost / marathon_adj,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1},
		{"space-science-pack", 1},
      },
      time = 60
    },
	order = "k-p"
  }    
 }
 )
 
 if noSpace == true then
	local fix = data.raw.technology["ftl-propulsion"]
    fix.unit.ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1},
      }
end