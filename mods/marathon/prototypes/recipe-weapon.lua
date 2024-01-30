data:extend({
  {
    type = "recipe",
    name = "pistol",

    energy_required = 1,
    ingredients = {
      {"copper-plate", 25},
      {"iron-plate", 25},
    },
    result = "pistol",
  },
  {
    type = "recipe",
    name = "submachine-gun",
    enabled = false,

    energy_required = 3,
    ingredients = {
      {"iron-gear-wheel", 25},
      {"copper-plate", 25},
      {"iron-plate", 25},
    },
    result = "submachine-gun",
  },
  {
    type = "recipe",
    name = "shotgun",
    enabled = false,

    energy_required = 4,
    ingredients = {
      {"iron-plate", 25},
      {"iron-gear-wheel", 10},
      {"copper-plate", 50},
      {"wood", 5},
    },
    result = "shotgun",
  },
  {
    type = "recipe",
    name = "combat-shotgun",
    enabled = false,

    energy_required = 8,
    ingredients = {
      {"steel-plate", 15},
      {"iron-gear-wheel", 10},
      {"copper-plate", 50},
      {"wood", 10},
    },
    result = "combat-shotgun",
  },
})
