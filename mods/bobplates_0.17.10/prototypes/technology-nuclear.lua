if data.raw.item["thorium-ore"] then

data:extend(
{
  {
    type = "technology",
    name = "thorium-processing",
    icon = "__bobplates__/graphics/icons/technology/thorium-processing.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "thorium-processing"
      },
      {
        type = "unlock-recipe",
        recipe = "thorium-fuel-cell"
      },
    },
    prerequisites =
    {
      "nuclear-power"
    },
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30,
      count = 200
    },
    order = "e-p-b-d1"
  },
  {
    type = "technology",
    name = "thorium-fuel-reprocessing",
    icon = "__bobplates__/graphics/icons/technology/thorium-nuclear-fuel-reprocessing.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "thorium-fuel-reprocessing"
      },
      {
        type = "unlock-recipe",
        recipe = "thorium-plutonium-fuel-cell"
      },
    },
    prerequisites =
    {
      "thorium-processing",
      "production-science-pack"
    },
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 30,
      count = 50
    },
    order = "e-p-b-d2"
  },
  {
    type = "technology",
    name = "bobingabout-enrichment-process",
    icon_size = 128,
    icon = "__bobplates__/graphics/icons/technology/bobingabout-enrichment-process.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "bobingabout-enrichment-process"
      },
    },
    prerequisites =
    {
      "thorium-fuel-reprocessing",
      "kovarex-enrichment-process"
    },
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 30,
      count = 500
    },
    order = "e-p-b-d3"
  },
}
)

end

data:extend(
{
  {
    type = "technology",
    name = "heavy-water-processing",
    icon = "__bobplates__/graphics/icons/technology/heavy-water.png",
    icon_size = 128,
    order = "e-p-b-e1",
    prerequisites =
    {
      "sulfur-processing",
      "production-science-pack"
    },
    unit =
    {
      count = 350,
      time = 30,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "bob-heavy-water"
      },
    },
  },
  {
    type = "technology",
    name = "deuterium-processing",
    icon = "__bobplates__/graphics/icons/technology/deuterium.png",
    icon_size = 128,
    order = "e-p-b-e2",
    prerequisites =
    {
      "heavy-water-processing",
      "electrolysis-1",
      "nuclear-power"
    },
    unit =
    {
      count = 350,
      time = 30,
      ingredients = 
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "heavy-water-electrolysis"
      },
      {
        type = "unlock-recipe",
        recipe = "deuterium-fuel-cell"
      },
    },
  },

  {
    type = "technology",
    name = "deuterium-fuel-reprocessing",
    icon = "__bobplates__/graphics/icons/technology/deuterium-nuclear-fuel-reprocessing.png",
    icon_size = 128,
    order = "e-p-b-e3",
    prerequisites =
    {
      "deuterium-processing",
    },
    unit =
    {
      count = 50,
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "deuterium-fuel-reprocessing"
      },
    },
  },
}
)

if settings.startup["bobmods-plates-bluedeuterium"].value == true then
  data.raw.technology["deuterium-fuel-reprocessing"].icon = "__bobplates__/graphics/icons/technology/deuterium-nuclear-fuel-reprocessing-blue.png"
end
