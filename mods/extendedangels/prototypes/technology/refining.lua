if not mods["Clowns-Extended-Minerals"] then
  local prerequisite = data.raw.technology["angels-water-washing-2"]
  if prerequisite then
    data:extend({
      -- Water washing 3
      {
        type = "technology",
        name = "angels-water-washing-3",
        icons = util.copy(prerequisite.icons),
        icon = util.copy(prerequisite.icon),
        icon_size = util.copy(prerequisite.icon_size),
        prerequisites = {
          "chemical-science-pack",
          "angels-water-washing-2",
          "angels-aluminium-smelting-1",
          "angels-stone-smelting-2",
          "production-science-pack",
        },
        effects = {
          {
            type = "unlock-recipe",
            recipe = "angels-washing-plant-3",
          },
        },
        unit = {
          count = 100,
          ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 },
            { "production-science-pack", 1 },
          },
          time = 15,
        },
        order = "c-a",
      },
    })
  end
end

if not mods["Clowns-Processing"] then
  local prerequisite = data.raw.technology["angels-water-treatment-4"]
  if prerequisite then
    data:extend({
      {
        type = "technology",
        name = "angels-water-treatment-5",
        icons = util.copy(prerequisite.icons),
        icon = util.copy(prerequisite.icon),
        icon_size = util.copy(prerequisite.icon_size),
        prerequisites = {
          "angels-stone-smelting-4",
          "angels-water-treatment-4",
          "utility-science-pack",          
          
        },
        effects = {
          {
            type = "unlock-recipe",
            recipe = "angels-salination-plant-3",
          },
        },
        unit = {
          count = 100,
          ingredients = {
            { "automation-science-pack", 1 },
            { "logistic-science-pack", 1 },
            { "chemical-science-pack", 1 },
            { "production-science-pack", 1 },
            { "utility-science-pack", 1 },
          },
          time = 15,
        },
        order = "c-a",
      },
    })
  end
end

local prerequisite = data.raw.technology["angels-water-washing-3"]
if prerequisite then
  data:extend({
    -- Water washing 4
    {
      type = "technology",
      name = "angels-water-washing-4",
      icons = util.copy(prerequisite.icons),
      icon = util.copy(prerequisite.icon),
      icon_size = util.copy(prerequisite.icon_size),
      prerequisites = {
        "angels-water-washing-3",
        "processing-unit",
        "angels-stone-smelting-3",
      },
      effects = {
        {
          type = "unlock-recipe",
          recipe = "angels-washing-plant-4",
        },
      },
      unit = {
        count = 150,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack", 1 },
          { "chemical-science-pack", 1 },
          { "production-science-pack", 1 },
        },
        time = 15,
      },
      order = "c-a",
    },
  })
end

local prerequisite = data.raw.technology["angels-advanced-ore-refining-4"]
if prerequisite then
  data:extend({
    -- Advanced ore refining 5
    {
      type = "technology",
      name = "angels-advanced-ore-refining-5",
      icons = util.copy(prerequisite.icons),
      icon = util.copy(prerequisite.icon),
      icon_size = util.copy(prerequisite.icon_size),
      prerequisites = {
        "angels-advanced-ore-refining-4",
      },
      effects = {
        {
          type = "unlock-recipe",
          recipe = "angels-ore-leaching-plant-4",
        },
        {
          type = "unlock-recipe",
          recipe = "angels-ore-refinery-3",
        },
      },
      unit = {
        count = 150,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack", 1 },
          { "chemical-science-pack", 1 },
          { "production-science-pack", 1 },
          { "utility-science-pack", 1 },
        },
        time = 15,
      },
      order = "c-a",
    },
  })
end
