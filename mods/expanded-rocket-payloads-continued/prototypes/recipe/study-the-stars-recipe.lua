--This sets up recipe categories and recipes for both space and ground telescopes.

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
    icon = "__expanded-rocket-payloads-continued__/graphic/ground-telescope-32.png",
    icon_size = 32,
    ingredients = {},
    results = { { type = "item", name = "space-science-pack", amount = 5 } },
    energy_required = 60,
    category = "ground-telescope",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "space-study-the-stars",
    enabled = false,
    icon = "__expanded-rocket-payloads-continued__/graphic/tess-32.png",
    icon_size = 32,
    ingredients = {},
    results = { { type = "item", name = "space-science-pack", amount = 50 } },
    energy_required = 60,
    category = "space-telescope",
    subgroup = "building-recipies",
  },
  {
    type = "recipe",
    name = "study-the-planet",
    enabled = false,
    icon = "__expanded-rocket-payloads-continued__/graphic/planet32.png",
    icon_size = 32,
    ingredients = {},
    results = { { type = "item", name = "planetary-data", amount = 1 } },
    energy_required = 240,
    category = "space-telescope",
    subgroup = "building-recipies",
  },
})
