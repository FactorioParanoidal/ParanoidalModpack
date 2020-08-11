local Recipe = require "prototypes.recipe.Recipe"

local possible_ingredients = {
  -- xander-mod
  {
    {"rail", 3},
    {"mechanism-1", 2},
    {"concrete", 20},
    {"electronic-circuit", 2},
  },
  -- base
  {
    {"rail", 3},
    {"iron-gear-wheel", 8},
    {"iron-plate", 40},
    {"electronic-circuit", 2},
  },
}

data:extend{
  {
    type = "recipe",
    name = "railunloader",
    enabled = false,
    energy_required = 1,
    ingredients = Recipe.select_ingredients(possible_ingredients),
    result = "railunloader",
  },
}