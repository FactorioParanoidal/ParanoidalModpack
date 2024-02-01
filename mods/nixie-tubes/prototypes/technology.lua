data:extend({
  {
  	type = "technology",
  	name = "cathodes",
    icon = "__nixie-tubes__/graphics/nixie-technology-icon.png",
    icon_size = 128,
  	unit = {
  		count=20,
      time=10,
      ingredients = {
          {"automation-science-pack", 1,},
          {"logistic-science-pack", 1,},
        },
    },
    prerequisites = {"advanced-electronics"},
    effects = {
      {
        type = "unlock-recipe",
        recipe = "nixie-tube",
      },
      {
        type = "unlock-recipe",
        recipe = "nixie-tube-alpha",
      },
      {
        type = "unlock-recipe",
        recipe = "nixie-tube-small",
      },
    },
    order = "a-d-e",
  },
})
