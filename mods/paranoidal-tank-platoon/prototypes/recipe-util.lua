-- Builds a 2.0 recipe from compact Beta 8 data: ingredients {name, amount[, "fluid"]}.
return function(spec)
  local ingredients = {}
  for _, ingredient in pairs(spec.ingredients) do
    table.insert(ingredients, {type = ingredient[3] or "item", name = ingredient[1], amount = ingredient[2]})
  end
  return {
    type = "recipe",
    name = spec.name,
    category = spec.category,
    enabled = false,
    energy_required = spec.time,
    ingredients = ingredients,
    results = {{type = "item", name = spec.result or spec.name, amount = spec.count or 1}}
  }
end
