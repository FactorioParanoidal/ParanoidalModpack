-- Стоимость резины из дерева (в 2.0 резина расщеплена на resin (BI) + bob-resin): дорого и единообразно.
local function wood_cost(recipe, amount)
  local r = data.raw.recipe[recipe]
  if r then r.ingredients = { { type = "item", name = "wood", amount = amount } } end
end

wood_cost("bi-resin-wood", 10)
