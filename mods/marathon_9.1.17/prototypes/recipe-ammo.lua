data:extend({
  {
    type = "recipe",
    name = "firearm-magazine",

    energy_required = 2,
    ingredients = {{"iron-plate", 5}},
    result = "firearm-magazine",
    result_count = 1,
  },
  {
    type = "recipe",
    name = "piercing-rounds-magazine",
    enabled = false,

    energy_required = 3,
    ingredients = {
      {"copper-plate", 25},
      {"steel-plate", 1},
    },
    result = "piercing-rounds-magazine",
  },
  {
    type = "recipe",
    name = "rocket",
    enabled = false,

    energy_required = 8,
    ingredients = {
      {"electronic-circuit", 1},
      {"explosives", 2},
      {"iron-plate", 10},
    },
    result = "rocket",
  },
  {
    type = "recipe",
    name = "shotgun-shell",
    enabled = false,

    energy_required = 3,
    ingredients = {
      {"copper-plate", 10},
      {"iron-plate", 10},
    },
    result = "shotgun-shell",
  },
  {
    type = "recipe",
    name = "piercing-shotgun-shell",
    enabled = false,

    energy_required = 8,
    ingredients = {
      {"copper-plate", 10},
      {"steel-plate", 2},
    },
    result = "piercing-shotgun-shell",
  },
})
