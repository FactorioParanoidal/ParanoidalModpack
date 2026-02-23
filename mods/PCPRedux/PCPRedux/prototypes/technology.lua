data:extend({
  {
    type = "technology",
    name = "plastic-abs",
    icon = "__base__/graphics/technology/plastics.png",
    icon_size = 256,
    icon_mipmaps = 4,
    prerequisites =
    {
      "angels-plastic-3",
      "angels-nitrogen-processing-2",
      "angels-advanced-chemistry-5"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "liquid-plastic-abs"
      }
    },
    unit =
    {
      count = 75,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
        { "chemical-science-pack",   1 },
        { "production-science-pack", 1 },
        { "utility-science-pack",    1 },
        --{"alien-science-pack", 1}
      },
      time = 30
    },
    --order = ""
  },
  {
    type = "technology",
    name = "plastic-pvc",
    icon = "__base__/graphics/technology/plastics.png",
    icon_size = 256,
    icon_mipmaps = 4,
    prerequisites =
    {
      "angels-plastic-2",
      "angels-chlorine-processing-2"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "liquid-plastic-pvc"
      },
    },
    unit =
    {
      count = 75,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
        { "chemical-science-pack",   1 }
      },
      time = 30
    },
    --order = ""
  },
  {
    type = "technology",
    name = "plastic-pmma",
    icon = "__base__/graphics/technology/plastics.png",
    icon_size = 256,
    icon_mipmaps = 4,
    prerequisites =
    {
      "angels-nitrogen-processing-2",
      "angels-advanced-chemistry-2"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "pmma-synthesis"
      },
      {
        type = "unlock-recipe",
        recipe = "liquid-plastic-pmma"
      },
      --	   {
      --	     type = "unlock-recipe",
      --		 recipe = "pmma-glass"
      --	   }
    },
    unit =
    {
      count = 100,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
        { "chemical-science-pack",   1 },
        { "production-science-pack", 1 },
        { "utility-science-pack",    1 },
        --{"alien-science-pack", 1}
      },
      time = 30
    },
    --order = ""
  },
  {
    type = "technology",
    name = "plastic-pc",
    icon = "__base__/graphics/technology/plastics.png",
    icon_size = 256,
    icon_mipmaps = 4,
    prerequisites =
    {
      "angels-advanced-chemistry-5",
      "angels-chlorine-processing-1"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "pc-synthesis"
      },
      {
        type = "unlock-recipe",
        recipe = "liquid-plastic-pc"
      },
      --	   {
      --	     type = "unlock-recipe",
      --		 recipe = "pc-glass"
      --	   }
    },
    unit =
    {
      count = 75,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
        { "chemical-science-pack",   1 },
        { "production-science-pack", 1 },
        { "utility-science-pack",    1 },
        --{"alien-science-pack", 1}
      },
      time = 30
    },
    --order = ""
  },
  {
    type = "technology",
    name = "flask",
    icon = "__PCPRedux__/graphics/technology/flask.png",
    icon_size = 256,
    icon_mipmaps = 4,
    prerequisites =
    {
      "angels-chlorine-processing-1",
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "flask"
      },
    },
    unit =
    {
      count = 75,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 },
      },
      time = 30
    },
    --order = ""
  },
  --[[{
    type = "technology",
    name = "nitrous-oxide-processing",
    icon = "__PCPedux__/graphics/icons/technology-nitrous-oxide.png",
  icon_size = 128,
  prerequisites =
    {
    "angels-nitrogen-processing-2",
    "angels-sulfur-processing-1"
    },
    effects =
    {
    {
        type = "unlock-recipe",
        recipe = "nitrous-oxide-synthesis-1"
      },
    {
        type = "unlock-recipe",
        recipe = "nitrous-oxide-synthesis-2"
      },
    {
        type = "unlock-recipe",
        recipe = "sodium-nitrate-synthesis"
      },
    },
    unit =
    {
      count = 50,
      ingredients = {
    {"automation-science-pack", 1},
		{"logistic-science-pack", 1}
  },
      time = 30
    },
    order = ""
    },]]
  --[[{
    type = "technology",
    name = "k-angels-advanced-chemistry-5",
    icon = "__angelspetrochemgraphics__/graphics/technology/advanced-chemical-plant-tech.png",
    icon_size = 128,
    prerequisites =
    {
      "angels-advanced-chemistry-4",
      "angels-nitrogen-processing-2"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "nitrous-oxide-synthesis-1"
      },
      {
        type = "unlock-recipe",
        recipe = "nitrous-oxide-synthesis-2"
      },
      {
        type = "unlock-recipe",
        recipe = "sodium-nitrate-synthesis"
      },
      {
        type = "unlock-recipe",
        recipe = "acrylonitrile-synthesis"
      },
    },
    unit =
    {
      count = 50,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack",   1 }
      },
      time = 30
    },
    order = ""
  },]]
  --[[{
    type = "technology",
    name = "advanced-phenol",
    icon = "",
  icon_size = 128,
  prerequisites =
    {
    "nitrous-oxide-processing",
    "angels-advanced-chemistry-4"
    },
    effects =
    {
    {
        type = "unlock-recipe",
        recipe = "liquid-phenol-catalyst"
      },
    },
    unit =
    {
      count = 150,
      ingredients = {
    {"automation-science-pack", 1},
		{"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"alien-science-pack", 1}
    },
      time = 30
    },
    order = ""
    },]]
})
