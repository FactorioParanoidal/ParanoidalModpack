data:extend({
    {
      type = "recipe-category",
      name = "ground-telescope"
    },
    {
      type = "recipe-category",
      name = "space-telescope"
    },
    {
      type = "recipe",
      name = "study-the-stars",
      enabled = false,
      icon = "__expanded-rocket-payloads__/graphic/ground-telescope-32.png",
      icon_size = 32,
      ingredients = {},
      result = "space-science-pack",
      result_count = 5,
      energy_required = 60,
      category = "ground-telescope",
      subgroup = "building-recipies",
    },
    {
      type = "recipe",
      name = "space-study-the-stars",
      enabled = false,
      icon = "__expanded-rocket-payloads__/graphic/tess-32.png",
      icon_size = 32,
      ingredients = {},
      result = "space-science-pack",
      result_count = 50,
      energy_required = 60,
      category = "space-telescope",
      subgroup = "building-recipies",
    },
    {
      type = "recipe",
      name = "study-the-planet",
      enabled = false,
      icon = "__expanded-rocket-payloads__/graphic/planet32.png",
      icon_size = 32,
      ingredients = {},
      result = "planetary-data", amount=1,
      energy_required = 240,
      category = "space-telescope",
      subgroup = "building-recipies",
    },
})