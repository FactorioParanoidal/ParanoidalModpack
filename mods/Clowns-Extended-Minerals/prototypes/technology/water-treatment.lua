if not clowns.special_vanilla then
  data:extend(
  {
    {
      type = "technology",
      name = "angels-water-washing-3",
      icon_size = 128,
      icon = "__angelsrefininggraphics__/graphics/technology/washing-plant-tech.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "clowns-resource1-sluicing-advanced"
        },
      },
      prerequisites = {"angels-water-washing-2", "production-science-pack"},
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
        count = 30
      },
      order = "e"
    }
  }
  )
end