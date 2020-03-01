if settings.startup["bobmods-power-nuclear"].value == true then

bobmods.lib.tech.add_prerequisite ("nuclear-power", "bob-heat-pipe-1")

data:extend(
{
  {
    type = "technology",
    name = "bob-nuclear-power-2",
    icon_size = 128,
    icon = "__base__/graphics/technology/nuclear-power.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "nuclear-reactor-2"
      },
    },
    prerequisites =
    {
      "nuclear-power",
      "advanced-electronics-2",
      "production-science-pack",
      "bob-heat-pipe-2"
    },
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
      },
      time = 30,
      count = 800
    },
    order = "e-p-b-d"
  },
  {
    type = "technology",
    name = "bob-nuclear-power-3",
    icon_size = 128,
    icon = "__base__/graphics/technology/nuclear-power.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "nuclear-reactor-3"
      },
    },
    prerequisites =
    {
      "bob-nuclear-power-2",
      "utility-science-pack",
      "bob-heat-pipe-3"
    },
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
      },
      time = 30,
      count = 800
    },
    order = "e-p-b-e"
  },
}
)

end

