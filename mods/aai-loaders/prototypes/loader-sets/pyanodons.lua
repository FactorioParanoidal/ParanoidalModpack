local cost_multiplier = settings.startup["aai-loaders-mode"].value == "lubricated" and 2 or 16
local base_recipes = {
  [1] = data.raw.recipe["inserter"],
  [2] = data.raw.recipe["fast-inserter"],
  [3] = data.raw.recipe["bulk-inserter"]
}
local belt_map = {"transport-belt", "fast-transport-belt", "express-transport-belt"}
local ingredient_sets = {}

-- Extract the inserter ingredients
for i, recipe in pairs(base_recipes) do
  ingredient_sets[i] = table.deepcopy(recipe.ingredients or { })
end

-- Multiply ingredient amounts by `cost_multiplier`
for i, ingredients in pairs(ingredient_sets) do
  for _, ingredient in pairs(ingredients) do
    if ingredient[2] then
      ingredient[2] = ingredient[2] * cost_multiplier
    elseif ingredient.amount then
      ingredient.amount = ingredient.amount * cost_multiplier
    end
  end

  -- Add equivalent tier belt
  table.insert(ingredients, 1, {type="item", name=belt_map[i], amount=1})
end

local loader_recipes = {
  data.raw.recipe["aai-loader"],
  data.raw.recipe["aai-fast-loader"],
  data.raw.recipe["aai-express-loader"]
}

-- Update loader recipe ingredients
for i, recipe in pairs(loader_recipes) do
  if ingredient_sets[i] then
    recipe.ingredients = ingredient_sets[i]
  end
end
