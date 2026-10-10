-- Paranoidal: Recycler 1 has no technology (recipe enabled from the start).
-- Recycler 4 stays on the existing Quality "recycling" technology (see data-updates.lua).

data:extend({

  {
    type = "technology",
    name = "recycler-2",
    localised_description = {"technology-description.recycler-2"},
    icon = "__recycler-progression__/graphics/icons/recycler-2.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "recycler-2"},
    },
    prerequisites = {"automation-2"},
    unit = {
      count = 75,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 15,
    },
  },

  {
    type = "technology",
    name = "recycler-3",
    localised_description = {"technology-description.recycler-3"},
    icon = "__recycler-progression__/graphics/icons/recycler-3.png",
    icon_size = 64,
    effects = {
      {type = "unlock-recipe", recipe = "recycler-3"},
    },
    prerequisites = {"recycler-2", "electric-engine", "chemical-science-pack"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 15,
    },
  },

})
