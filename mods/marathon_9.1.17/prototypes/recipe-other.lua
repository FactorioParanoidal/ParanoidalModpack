data:extend({
  {
    type = "recipe",
    name = "radar",

    ingredients = {
      {"electronic-circuit", 5},
      {"iron-gear-wheel", 5},
      {"iron-plate", 25},
    },
    result = "radar",
  },
  {
    type = "recipe",
    name = "small-lamp",
    enabled = false,

    ingredients = {
      {"electronic-circuit", 2},
      {"iron-stick", 4},
      {"iron-plate", 2},
    },
    result = "small-lamp",
  },
  {
    type = "recipe",
    name = "gun-turret",
    enabled = false,

    energy_required = 10,
    ingredients = {
      {"iron-gear-wheel", 50},
      {"copper-plate", 50},
      {"iron-plate", 50},
    },
    result = "gun-turret",
  },
})
