data:extend(
{
  {
    type = "technology",
    name = "angels-ironworks-1",
    icons ={
      { icon="__angels-smelting-extended__/graphics/icons/casting-machine-tech.png", icon_size = 128,},
      { icon="__base__/graphics/icons/iron-gear-wheel.png",icon_size=64,shift={25,-25}}
    },
    upgrade = true,
    prerequisites =
    {
      "angels-iron-smelting-1",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "angels-iron-gear-wheel-casting"
      },
      {
        type = "unlock-recipe",
        recipe = "angels-iron-pipe-casting"
      },
      {
        type = "unlock-recipe",
        recipe = "angels-iron-pipe-to-ground-casting"
      },
    },
    unit =
    {
      count = 150,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30
    },
    order = "c-a"
  },
})
--if bobs metals
if mods["bobplates"] then
  data:extend({
    {
      type = "technology",
      name = "angels-alloys-smelting-1",
      icon = "__angelssmelting__/graphics/technology/casting-bronze-tech.png",
      icon_size = 256,
      upgrade = true,
      prerequisites =
      {
        "angels-copper-smelting-1",
        "angels-tin-smelting-1",
        "angels-zinc-smelting-1",
        "alloy-processing",
      },
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "angels-bronze-smelting-1"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-plate-bronze"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-brass-smelting-1"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-plate-brass"
        },
      },
      unit =
      {
        count = 100,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
        },
        time = 30
      },
      order = "c-a"
    },
    {
      type = "technology",
      name = "angels-alloys-smelting-2",
      icon = "__angelssmelting__/graphics/technology/casting-gunmetal-tech.png",
      icon_size = 256,
      upgrade = true,
      prerequisites =
      {
        "angels-alloys-smelting-1",
        "angels-steel-smelting-1",
        "angels-cobalt-smelting-1",
        "angels-nickel-smelting-1",
      },
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "angels-gunmetal-smelting-1"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-plate-gunmetal"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-invar-smelting-1"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-plate-invar"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-plate-cobalt-steel-1"
        },
      },
      unit =
      {
        count = 150,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
        },
        time = 30
      },
      order = "c-a"
    },
    {
      type = "technology",
      name = "angels-alloys-smelting-3",
      icon = "__angelssmelting__/graphics/technology/casting-cobalt-steel-tech.png",
      icon_size = 256,
      upgrade = true,
      prerequisites =
      {
        "angels-alloys-smelting-2",
        "angels-gold-smelting-1",
        "angels-silver-smelting-1",
        "angels-titanium-smelting-1",
      },
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "angels-nitinol-smelting-1"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-plate-nitinol"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-plate-cobalt-steel-2"
        },
      },
      unit =
      {
        count = 300,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
        },
        time = 30
      },
      order = "c-a"
    },
  })
  --if bobs metals and not angels industries components
  if mods["angelsindustries"] and angelsmods.industries.components then
  else
    data:extend({
      {
        type = "technology",
        name = "angels-ironworks-2",
        icon = "__bobplates__/graphics/icons/brass-gear-wheel.png",
        icon_size = 32,
        upgrade = true,
        prerequisites =
        {
          "angels-steel-smelting-1",
          "angels-ironworks-1",
        },
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "angels-steel-gear-wheel-casting"
          },
          {
            type = "unlock-recipe",
            recipe = "angels-cobalt-steel-gear-wheel-casting"
          },
          {
            type = "unlock-recipe",
            recipe = "angels-brass-gear-wheel-casting"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-sand-die"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-iron-gear-casting-expendable"
          },
        },
        unit =
        {
          count = 300,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
          },
          time = 30
        },
        order = "c-a"
      },
      {
        type = "technology",
        name = "angels-ironworks-3",
        icon = "__bobplates__/graphics/icons/titanium-gear-wheel.png",
        icon_size = 32,
        upgrade = true,
        prerequisites =
        {
          "angels-titanium-smelting-1",
          "angels-ironworks-2",
          "angels-steel-smelting-2"
        },
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "angels-titanium-gear-wheel-casting"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-brass-gear-casting-expendable"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-cobalt-steel-gear-casting-expendable"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-steel-gear-casting-expendable"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-metal-die"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-metal-die-wash"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-iron-gear-casting-advanced"
          },
        },
        unit =
        {
          count = 300,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
          },
          time = 30
        },
        order = "c-a"
      },
      {
        type = "technology",
        name = "angels-ironworks-4",
        icon = "__bobplates__/graphics/icons/tungsten-gear-wheel.png",
        icon_size = 32,
        upgrade = true,
        prerequisites =
        {
          "angels-nitinol-smelting-1",
          "angels-tungsten-smelting-1",
          "angels-ironworks-3",
          "angels-zinc-smelting-3"
        },
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "angels-tungsten-gear-wheel-casting"
          },
          {
            type = "unlock-recipe",
            recipe = "angels-nitinol-gear-wheel-casting"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-titanium-gear-casting-expendable"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-brass-gear-casting-advanced"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-steel-gear-casting-advanced"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-cobalt-steel-gear-casting-advanced"
          },
        },
        unit =
        {
          count = 300,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
          },
          time = 30
        },
        order = "c-a"
      },
      {
        type = "technology",
        name = "angels-ironworks-5",
        icon = "__bobplates__/graphics/icons/nitinol-gear-wheel.png",
        icon_size = 32,
        upgrade = true,
        prerequisites =
        {
          "nitinol-processing",
          "tungsten-processing",
          "angels-ironworks-4"
        },
        effects =
        {
          {
            type = "unlock-recipe",
            recipe = "ASE-tungsten-gear-casting-expendable"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-nitinol-gear-casting-expendable"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-titanium-gear-casting-advanced"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-tungsten-gear-casting-advanced"
          },
          {
            type = "unlock-recipe",
            recipe = "ASE-nitinol-gear-casting-advanced"
          },
        },
        unit =
        {
          count = 300,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack",1},
          },
          time = 30
        },
        order = "c-a"
      },
    })
  end --if angels components
end
if mods["angelsindustries"] and angelsmods.industries.components then
  data:extend({
    {
      type = "technology",
      name = "angels-ironworks-2",
      icons ={
        { icon="__angelsindustries__/graphics/technology/components-tech.png", icon_size = 64,},
      },
      upgrade = true,
      prerequisites =
      {
        "angels-steel-smelting-1",
        --"angels-alloys-smelting-1",
        "angels-ironworks-1",
      },
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "ASE-sand-die"
        },
        {
          type = "unlock-recipe",
          recipe = "ASE-iron-gear-casting-expendable"
        },
        {
          type = "unlock-recipe",
          recipe = "ASE-metal-die"
        },
        {
          type = "unlock-recipe",
          recipe = "ASE-metal-die-wash"
        },
        {
          type = "unlock-recipe",
          recipe = "ASE-iron-gear-casting-advanced"
        },
      },
      unit =
      {
        count = 300,
        ingredients = {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
        },
        time = 30
      },
      order = "c-a"
    },
  })
end
