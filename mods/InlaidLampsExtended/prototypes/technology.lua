local techname = "flat-lamp"

data:extend({
  {
    type = "technology",
    name = techname,
    icon = "__InlaidLampsExtended__/graphics/icon/flat-lamp-technology.png",
    icon_size = 128,
    icon_mipmaps = 1,
    prerequisites = { "lamp", "automobilism", "concrete" },
    effects = {
      {
        type = "unlock-recipe",
        recipe = INLAID_LAMP_NAMES.small
      },
      {
        type = "unlock-recipe",
        recipe = INLAID_LAMP_NAMES.big
      }
    },
    unit = {
      count = 275,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1}
      },
      time = 30
    },
    order = "a-h-a"
  }
})
