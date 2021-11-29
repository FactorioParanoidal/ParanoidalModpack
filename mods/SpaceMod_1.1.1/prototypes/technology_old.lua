data:extend(
{
  {
    type = "technology",
    name = "space-assembly",
    icon = "__SpaceMod__/graphics/technology/space-assembly.png",
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "assembly-robot"
        },
      },
    prerequisites = {"rocket-silo"},
    unit =
    {
      count = 6000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
    order = "k-b"
  },
  {
    type = "technology",
    name = "space-construction",
    icon = "__SpaceMod__/graphics/technology/space-construction.png",
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
      count = 12000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-c"
  },
  {
    type = "technology",
    name = "space-casings",
    icon = "__SpaceMod__/graphics/technology/space-casings.png",
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
      count = 12000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-d"
  }, 
  {
    type = "technology",
    name = "protection-fields",
    icon = "__SpaceMod__/graphics/technology/protection-fields.png",
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
      count = 12000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-e"
  },
  {
    type = "technology",
    name = "fusion-reactor",
    icon = "__SpaceMod__/graphics/technology/fusion-reactor.png",
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
      count = 12000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-f"
  }, 
  {
    type = "technology",
    name = "space-thrusters",
    icon = "__SpaceMod__/graphics/technology/space-thrusters.png",
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
      count = 6000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-g"
  },   
  {
    type = "technology",
    name = "fuel-cells",
    icon = "__SpaceMod__/graphics/technology/fuel-cells.png",
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
      count = 6000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-h"
  }, 
  {
    type = "technology",
    name = "habitation",
    icon = "__SpaceMod__/graphics/technology/habitation.png",
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
      count = 12000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-i"
  }, 
  {
    type = "technology",
    name = "life-support-systems",
    icon = "__SpaceMod__/graphics/technology/life-support.png",
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
      count = 12000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-j"
  },  
  {
    type = "technology",
    name = "spaceship-command",
    icon = "__SpaceMod__/graphics/technology/command.png",
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
      count = 24000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-k"
  }, 
  {
    type = "technology",
    name = "astrometrics",
    icon = "__SpaceMod__/graphics/technology/astrometrics.png",
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
      count = 12000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-l"
  }, 
  {
    type = "technology",
    name = "ftl-theory-A",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
    prerequisites = {"space-construction"},
    unit =
    {
      count = 250000,
      ingredients =
      {
        {"science-pack-1", 1},
      },
      time = 60
    },
	order = "k-m"
  },   
  {
    type = "technology",
    name = "ftl-theory-B",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
    prerequisites = {"ftl-theory-A"},
    unit =
    {
      count = 250000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
      },
      time = 60
    },
	order = "k-n"
  },
  {
    type = "technology",
    name = "ftl-theory-C",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
    prerequisites = {"ftl-theory-B"},
    unit =
    {
      count = 250000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
      },
      time = 60
    },
	order = "k-o"
  }, 
  {
    type = "technology",
    name = "ftl-propulsion",
    icon = "__SpaceMod__/graphics/technology/ftl.png",
	effects =
      {
        {
            type = "unlock-recipe",
            recipe = "ftl-drive"
        },
      },		
    prerequisites = {"ftl-theory-C"},
    unit =
    {
      count = 250000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1},
		{"alien-science-pack", 1}
      },
      time = 60
    },
	order = "k-p"
  }    
 }
 )