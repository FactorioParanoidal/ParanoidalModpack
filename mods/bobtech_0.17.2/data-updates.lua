require("prototypes.recipe.recipe-updates")
require("prototypes.productivity-limitations")
require("prototypes.technology.technology-updates")

if settings.startup["bobmods-tech-colorupdate"].value == true then
  data.raw.tool["automation-science-pack"].icon = "__base__/graphics/icons/utility-science-pack.png"
  data.raw.tool["logistic-science-pack"].icon = "__base__/graphics/icons/automation-science-pack.png"
  data.raw.tool["utility-science-pack"].icon = "__base__/graphics/icons/logistic-science-pack.png"

  data.raw.tool["automation-science-pack"].icon_size = 32
  data.raw.tool["logistic-science-pack"].icon_size = 32
  data.raw.tool["utility-science-pack"].icon_size = 32

  data.raw.technology["logistic-science-pack"].icon = "__bobtech__/graphics/icons/red-science-pack-technology.png"
  data.raw.technology["logistic-science-pack"].icon_size = 128
  data.raw.technology["utility-science-pack"].icon = "__base__/graphics/technology/logistic-science-pack.png"
  data.raw.technology["utility-science-pack"].icon_size = 128
end
