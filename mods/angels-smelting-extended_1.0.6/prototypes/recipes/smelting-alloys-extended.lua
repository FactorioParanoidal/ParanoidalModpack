if mods["bobplates"] then
  data:extend(
  {
      --ALLOYS CASTING This needs serious balancing
      --Look at having the triple fluid recipes being really high yield
      --[[{
      type = "recipe",
      name = "angels-bronze-smelting-1",
      category = "induction-smelting",
    subgroup = "angels-alloys-casting",
      energy_required = 4,
    enabled = "false",
      ingredients ={
        {type="item", name="ingot-tin", amount=12},
        {type="item", name="ingot-copper", amount=24},
    },
      results=
      {
        {type="fluid", name="liquid-molten-bronze", amount=240},
      },
      order = "xa",
      },
      {
      type = "recipe",
      name = "angels-plate-bronze",
      category = "casting",
    subgroup = "angels-alloys-casting",
      energy_required = 15,
    enabled = "false",
      ingredients ={
        {type="fluid", name="liquid-molten-bronze", amount=40},
    },
      results=
      {
        {type="item", name="angels-plate-bronze", amount=4},
      },
      order = "ya",
      },
      {
      type = "recipe",
      name = "angels-brass-smelting-1",
      category = "induction-smelting",
    subgroup = "angels-alloys-casting",
      energy_required = 4,
    enabled = "false",
      ingredients ={
        {type="item", name="ingot-zinc", amount=12},
        {type="item", name="ingot-copper", amount=24},
    },
      results=
      {
        {type="fluid", name="liquid-molten-brass", amount=240},
      },
      order = "xb",
      },
      {
      type = "recipe",
      name = "angels-plate-brass",
      category = "casting",
    subgroup = "angels-alloys-casting",
      energy_required = 15,
    enabled = "false",
      ingredients ={
        {type="fluid", name="liquid-molten-brass", amount=40},
    },
      results=
      {
        {type="item", name="angels-plate-brass", amount=4},
      },
      order = "yb",
      },
      {
      type = "recipe",
      name = "angels-gunmetal-smelting-1",
      category = "induction-smelting",
    subgroup = "angels-alloys-casting",
      energy_required = 4,
    enabled = "false",
      ingredients ={
        {type="item", name="ingot-tin", amount=12},
        {type="item", name="ingot-zinc", amount=12},
        {type="item", name="ingot-copper", amount=24},
    },
      results=
      {
        {type="fluid", name="liquid-molten-gunmetal", amount=240},
      },
      order = "xc",
      },
      {
      type = "recipe",
      name = "angels-plate-gunmetal",
      category = "casting",
    subgroup = "angels-alloys-casting",
      energy_required = 30,
    enabled = "false",
      ingredients ={
        {type="fluid", name="liquid-molten-gunmetal", amount=40},
    },
      results=
      {
        {type="item", name="angels-plate-gunmetal", amount=4},
      },
      order = "yc",
      },
      {
      type = "recipe",
      name = "angels-invar-smelting-1",
      category = "induction-smelting",
    subgroup = "angels-alloys-casting",
      energy_required = 4,
    enabled = "false",
      ingredients ={
        {type="item", name="ingot-iron", amount=24},
        {type="item", name="ingot-nickel", amount=12},
    },
      results=
      {
        {type="fluid", name="liquid-molten-invar", amount=240},
      },
      order = "xd",
      },
      {
      type = "recipe",
      name = "angels-plate-invar",
      category = "casting",
    subgroup = "angels-alloys-casting",
      energy_required = 15,
    enabled = "false",
      ingredients ={
        {type="fluid", name="liquid-molten-invar", amount=40},
    },
      results=
      {
        {type="item", name="angels-plate-invar", amount=4},
      },
      order = "yd",
      },
      {
      type = "recipe",
      name = "angels-nitinol-smelting-1",
      category = "induction-smelting",
    subgroup = "angels-alloys-casting",
      energy_required = 4,
    enabled = "false",
      ingredients ={
        {type="item", name="ingot-nickel", amount=24},
        {type="item", name="ingot-titanium", amount=12},
    },
      results=
      {
        {type="fluid", name="liquid-molten-nitinol", amount=240},
      },
      order = "xf",
      },
      {
      type = "recipe",
      name = "angels-plate-nitinol",
      category = "casting",
    subgroup = "angels-alloys-casting",
      energy_required = 15,
    enabled = "false",
      ingredients ={
        {type="fluid", name="liquid-molten-nitinol", amount=40},
    },
      results=
      {
        {type="item", name="angels-plate-nitinol", amount=4},
      },
      order = "yf",
    },]]
      {
      type = "recipe",
      name = "angels-plate-cobalt-steel-1",
      category = "casting",
    subgroup = "angels-cobalt-steel-casting",
      energy_required = 30,
    enabled = "false",
      ingredients ={
        {type="fluid", name="liquid-molten-iron", amount=140},
        {type="fluid", name="liquid-molten-cobalt", amount=10},
    },
      results=
      {
        {type="item", name="angels-plate-cobalt-steel", amount=10},
      },
      order = "l",
      },
      {
      type = "recipe",
      name = "angels-plate-cobalt-steel-2",
      category = "casting",
    subgroup = "angels-cobalt-steel-casting",
      energy_required = 30,
    enabled = "false",
      ingredients ={
        {type="fluid", name="liquid-molten-steel", amount=35},
        {type="fluid", name="liquid-molten-cobalt", amount=10},
    },
      results=
      {
        {type="item", name="angels-plate-cobalt-steel", amount=10},
      },
      order = "m",
      },
  }
  )
end