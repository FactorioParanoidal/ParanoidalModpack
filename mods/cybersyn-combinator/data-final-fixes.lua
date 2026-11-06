local constants = require "scripts.constants"
local recipe = data.raw.recipe[constants.ENTITY_NAME]
local item = data.raw.item[constants.ENTITY_NAME]

if mods["cybersyn"] and data.raw.technology["cybersyn-train-network"] then
  table.insert(
    data.raw.technology["cybersyn-train-network"].effects,
    { type = "unlock-recipe", recipe = constants.ENTITY_NAME })
else
  table.insert(data.raw.technology["circuit-network"].effects, { type = "unlock-recipe", recipe = constants.ENTITY_NAME })
end

if settings.startup[constants.SETTINGS.UPGRADEABLE].value == true then
  data.raw["constant-combinator"]["constant-combinator"].next_upgrade = constants.ENTITY_NAME
end

data.raw["constant-combinator"]["constant-combinator"].fast_replaceable_group = "constant-combinator"

if mods["nullius"] then
  recipe.subgroup = data.raw["train-stop"]["train-stop"].subgroup
  item.subgroup = data.raw.item["train-stop"].subgroup
end
