local Craft_item = {}

Craft_item.metatable = {__index = Craft_item}

function Craft_item.new(Character, name, count)
  local state =
  {
    type = "craft_item",
    character = Character,
    name = name,
    count = count or 1,
    need_new_recipe = true,
    attempted_ingredients = {}
  }
  Character:print("Init craft item state for "..name.." x "..(count or 0))
  return setmetatable(state, Craft_item.metatable)
end

local recipe_products_map = {}

local get_recipes_for_product = function(name)
  if recipe_products_map[name] then
    return recipe_products_map[name]
  end

  recipe_products_map[name] = {}

  for recipe_name, recipe in pairs (game.recipe_prototypes) do
    for k, product in pairs (recipe.products) do
      if product.name == name then
        recipe_products_map[name][recipe_name] = true
        break
      end
    end
  end

  return recipe_products_map[name]

end

function Craft_item:finish()
  self.character:pop_state()
end


function Craft_item:get_next_recipe()
  -- Returns false if we have no more recipes we can use.
  self.character:print("Finding next recipe to use for "..self.name)
  local recipes = get_recipes_for_product(self.name)
  local force_recipes = self.character.entity.force.recipes

  while true do
    self.recipe = next(recipes, self.recipe)

    if self.recipe == nil then
      --We have looped through all of them, none are worthy.
      self.character:print("No worthy recipes ".. serpent.line(recipes))
      return
    end

    if self.character:can_craft_recipe(force_recipes[self.recipe]) then
      --It is a good recipe, lets try to use it.
      self.need_new_recipe = false
      return true
    end

  end
  --no recipes we can use, either tried or none unlocked, so we fail at crafting the item

  return

end

function Craft_item:get_ingredients()
  local recipe = game.recipe_prototypes[self.recipe]
  local to_try = {}
  for k, ingredient in pairs (recipe.ingredients) do


    if self.character:has_item(ingredient.name, ingredient.amount) then
      -- We already have enough of this item.
    elseif self.attempted_ingredients[ingredient.name] then
        --We have already tried to get this ingredient (and failed). giveup.
        self.character:print("Already attempted ingredient "..ingredient.name)
        self.need_new_recipe = true
        return
    else
      table.insert(to_try, ingredient)
    end
  end

  if not next(to_try) then
    -- We have all the items I guess, return false to continue execution of main update
    return
  end

  for k, ingredient in pairs (to_try) do
    self.attempted_ingredients[ingredient.name] = true
    self.character:find_item(ingredient.name, ingredient.amount * self.count)
  end

  return true
end

function Craft_item:update()
  self.character:print("Craft item update "..self.name)

  if self.character:has_item(self.name, self.count) then
    --We already have enough of this item anyway.
    self:finish()
    return
  end

  if self.character.entity.crafting_queue_size > 0 then
    if game.tick % 2 == 0 then
      self.character.entity.direction = (self.character.entity.direction + 1) % (2 * defines.direction.south)
    end
    -- We are already crafting, lets just wait and see what happens.
    return
  end

  if self.need_new_recipe and not self:get_next_recipe() then
    self.character:print("Failed to find a recipe we can use for "..self.name)
    self:finish()
    return
  end

  if self:get_ingredients() then
    -- Returns true when its in the process of getting the ingredients.
    return
  end

  --At this point, we should have a recipe, and possibly the ingredients needed, lets see what the API says:

  if self.character.entity.get_craftable_count(self.recipe) < 1 then
    -- We can't craft any, well, I guess we tried, pick a new recipe next update
    self.need_new_recipe = true
    return
  end
  self.character.entity.begin_crafting{recipe = self.recipe, count = 1}
  self.attempted_ingredients = {}
end

return setmetatable(Craft_item, {__call = function(this, ...) return Craft_item.new(...) end})