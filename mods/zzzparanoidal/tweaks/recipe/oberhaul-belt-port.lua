-- Порт belt-рецептов из мода Oberhaul (1.1: beltrecipes.lua). Значения — дамп 1.1.

local function set_ingredients(recipe_name, ingredients)
  local recipe = data.raw.recipe[recipe_name]
  if not recipe then return end
  for _, ing in ipairs(ingredients) do
    if not (data.raw.item[ing.name] or data.raw.fluid[ing.name]) then return end
  end
  recipe.ingredients = ingredients
end

set_ingredients("fast-underground-belt", {
  { type = "item", name = "underground-belt", amount = 4 },
  { type = "item", name = "bob-bronze-alloy", amount = 10 },
  { type = "item", name = "bob-steel-gear-wheel", amount = 20 },
})
set_ingredients("express-transport-belt", {
  { type = "item", name = "fast-transport-belt", amount = 2 },
  { type = "item", name = "bob-titanium-gear-wheel", amount = 2 },
  { type = "item", name = "bob-titanium-bearing", amount = 1 },
})
set_ingredients("express-underground-belt", {
  { type = "item", name = "fast-underground-belt", amount = 3 },
  { type = "item", name = "bob-titanium-gear-wheel", amount = 20 },
  { type = "item", name = "bob-titanium-bearing", amount = 10 },
})
set_ingredients("express-splitter", {
  { type = "item", name = "fast-splitter", amount = 2 },
  { type = "item", name = "bob-titanium-gear-wheel", amount = 10 },
  { type = "item", name = "advanced-circuit", amount = 10 },
  { type = "item", name = "bob-titanium-bearing", amount = 2 },
})
set_ingredients("turbo-transport-belt", {
  { type = "item", name = "express-transport-belt", amount = 2 },
  { type = "item", name = "bob-cobalt-steel-bearing", amount = 1 },
  { type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 2 },
})
set_ingredients("turbo-underground-belt", {
  { type = "item", name = "express-underground-belt", amount = 4 },
  { type = "item", name = "bob-cobalt-steel-bearing", amount = 10 },
  { type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 20 },
})
set_ingredients("turbo-splitter", {
  { type = "item", name = "express-splitter", amount = 2 },
  { type = "item", name = "processing-unit", amount = 10 },
  { type = "item", name = "bob-cobalt-steel-bearing", amount = 4 },
  { type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 10 },
})
