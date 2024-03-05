data:extend({
  {
    type = "recipe",
    name = "iron-gear-wheel",

    energy_required = 1.5,
    ingredients = {{"iron-plate", 3}},
    result = "iron-gear-wheel",
  },
  {
    type = "recipe",
    name = "iron-stick",

    ingredients = {{"iron-plate", 5}},
    result = "iron-stick",
    result_count = 2,
  },
  {
    type = "recipe",
    -- category = "crafting",
    name = "low-density-structure",
    enabled = false,

    energy_required = 45,
    ingredients = {
      {"steel-plate", 15},
      {"copper-plate", 30},
      {"plastic-bar", 15},
    },
    result= "low-density-structure",
  },
})
