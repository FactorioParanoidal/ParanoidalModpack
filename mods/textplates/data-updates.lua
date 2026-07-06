textplates = require("textplates")
require("prototype.technology")
require("prototype.recipe.recipe")
if data.raw.item["gold-plate"] then
  data.raw.recipe["textplate-small-gold"].ingredients = {{type = "item", name = "gold-plate", amount = 1}}
  data.raw.recipe["textplate-large-gold"].ingredients = {{type = "item", name = "gold-plate", amount = 4}}
end
if data.raw.item["glass"] then
  data.raw.recipe["textplate-small-glass"].ingredients = {{type = "item", name = "glass", amount = 1}}
  data.raw.recipe["textplate-large-glass"].ingredients = {{type = "item", name = "glass", amount = 4}}
end
if data.raw["item-group"]["dectorio"] then
  data.raw["item-subgroup"]["textplates"].group = "dectorio"
end
