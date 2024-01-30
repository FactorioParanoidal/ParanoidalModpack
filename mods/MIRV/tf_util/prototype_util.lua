local rename_recipe = function(old, new)
  local recipes = data.raw.recipe
  for k, recipe in pairs (recipes) do
    if recipe.normal then
      for k, v in pairs(recipe.normal) do
        recipe[k] = v
      end
      recipe.normal = nil
      recipe.expensive = nil
    end
    for k, ingredient in pairs (recipe.ingredients) do
      if ingredient.name and ingredient.name == old then
        ingredient.name = new
      end
      if ingredient[1] and ingredient[1] == old then
        ingredient[1] = new
      end
    end
    if recipe.result and recipe.result == old then
      recipe.result = new
    end
    for k, product in pairs (recipe.products or {}) do
      if product.name and product.name == old then
        product.name = new
      end
      if product[1] and product[1] == old then
        product[1] = new
      end
    end
    -- Will have to handle technologies.. so lets do it only when nescessary
    --if recipe.name == old then
    --  recipe.name = new
    --  recipe.localised_name = new
    --  recipes[new] = recipe
    --  recipes[old] = nil
    --end
  end
end

local rename_item = function(old, new)
  local items = data.raw.item
  for k, item in pairs (items) do
    if item.place_result and item.place_result == old then
      item.place_result = new
    end
    if item.name == old then
      item.name = new
      item.localised_name = new
      items[new] = item
      items[old] = nil
      rename_recipe(old, new)
    end
  end
end

local rename_recipe = function(old, new)
  local recipes = data.raw.recipe
  for k, recipe in pairs (recipes) do
    if recipe.normal then
      for k, v in pairs(recipe.normal) do
        recipe[k] = v
      end
      recipe.normal = nil
      recipe.expensive = nil
    end
    for k, ingredient in pairs (recipe.ingredients) do
      if ingredient.name and ingredient.name == old then
        ingredient.name = new
      end
      if ingredient[1] and ingredient[1] == old then
        ingredient[1] = new
      end
    end
    if recipe.result and recipe.result == old then
      recipe.result = new
    end
    for k, product in pairs (recipe.products or {}) do
      if product.name and product.name == old then
        product.name = new
      end
      if product[1] and product[1] == old then
        product[1] = new
      end
    end
    -- Will have to handle technologies.. so lets do it only when nescessary
    --if recipe.name == old then
    --  recipe.name = new
    --  recipe.localised_name = new
    --  recipes[new] = recipe
    --  recipes[old] = nil
    --end
  end
end


local remove_from_recipe = function(recipe, name)
  --log(name)
  if recipe.normal then
    --Screw this half-assed system
    for k, v in pairs (recipe.normal) do
      recipe[k] = v
    end
    recipe.normal = nil
    recipe.expensive = nil
  end

  local result = recipe.result
  if result == name then
    return
  
  end
  local ingredients = recipe.ingredients
  if ingredients then
    for i = #ingredients, 1, -1 do
      if (ingredients[i].name or ingredients[i][1]) == name then
        table.remove(ingredients, i)
      end
    end
    if #ingredients == 0 then
      return
    end
  end
  
  local products = recipe.products
  if products then
    for i = #products, 1, -1 do
      if (products[i].name or products[i][1]) == name then
        table.remove(products, i)
      end
    end
    if #products == 0 then
      return
    end
  end

  if recipe.main_product and recipe.main_product == name then
    recipe.main_product = nil
  end

  return recipe
end

local remove_technology = function(name)
  local technologies = data.raw.technology
  for k, tech in pairs (technologies) do
    local req = tech.prerequisites
    if req then
      for i = #req, 1, -1 do
        if req[i] == name then
          table.remove(req, i)
        end
      end
      if #req == 0 then
        tech.prerequisites = nil
      end
    end
  end
  technologies[name] = nil
end

local remove_item_from_technologies = function(name)
  local technologies = data.raw.technology
  for k, tech in pairs (technologies) do
    local packs = tech.unit.ingredients
    for i = #packs, 1, -1 do
      if (packs[i].name or packs[i][1]) == name then
        table.remove(packs, i)
      end
    end
    if #packs == 0 then
      remove_technology(tech.name)
    end
  end
end

local remove_recipe_from_technologies = function(name)
  --log("Removing recipe from technologies: "..name)
  local technologies = data.raw.technology
  for k, technology in pairs (technologies) do
    local effects = technology.effects
    if effects then
      --log(technology.name.." = "..#effects)
      for i = #effects, 1, -1 do
        --log((effects[i].recipe or "nil").. " == "..name)
        if (effects[i].recipe == name) then
          --log("Removed from: "..k)
          table.remove(effects, i)
        end
      end
      if #effects == 0 then
        remove_technology(technology.name)
      end
    end
  end
end

local remove_item_from_recipes = function(name)
  if type(name) ~= "string" then error("I EXPECT A STRING") end
  --log("Removing item from recipes: "..name)
  local recipes = data.raw.recipe
  for k, recipe in pairs (recipes) do
    local result = remove_from_recipe(recipe, name)
    if not result then
      remove_recipe_from_technologies(recipe.name)
      recipes[k] = nil
    end
  end
end

local remove_from_items = function(name)
  if type(name) ~= "string" then error("I EXPECT A STRING") end
  local items = data.raw.item
  for k, item in pairs (items) do
    if item.place_result == name then
      remove_item_from_recipes(item.name)
      items[k] = nil
      return
    end
    if item.rocket_launch_product == name then
      item.rocket_launch_product = nil
    end
    if item.rocket_launch_products then
      util.remove_from_list(item.rocket_launch_products, name)
    end
  end
  local items = data.raw["item-with-entity-data"]
  for k, item in pairs (items) do
    if item.place_result == name then
      remove_item_from_recipes(item.name)
      items[k] = nil
      return
    end
    if item.rocket_launch_product == name then
      item.rocket_launch_product = nil
    end
    if item.rocket_launch_products then
      util.remove_from_list(item.rocket_launch_products, name)
    end
  end
end

local find_mention
find_mention = function(table, name)
  for k, v in pairs (table) do
    if type(v) == "table" then
      find_mention(v, name)
    elseif k == name or ((type(v) == "string") and (v == name)) then
      return true
    end
  end
end

local remove_from_achievements = function(name)
  for type_name, type in pairs (data.raw) do
    if string.find(type_name, "achievement") then
      for k, achievement in pairs (type) do
        if find_mention(achievement, name) then
          type[k] = nil
        end
      end
    end
  end
end

local remove_entity_prototype = function(ent)
  if not ent then return end
  --So, if we actually delete the prototype, we get some error about traversing old prototypes for migrations or some BS... so we just nuke all items and hide them
  --log(ent.name)
  remove_from_items(ent.name)
  remove_from_achievements(ent.name)
  ent.minable = nil
  ent.order = "Z-DELETED"
  ent.autoplace = nil
end

local remove_from_minable = function(name)
  for k, type in pairs (data.raw) do
    for j, v in pairs (type) do
      if v.minable and v.minable.result == name then
        v.minable = nil
      end
    end
  end
end

local remove_item_prototype = function(item)
  if not item then log("Well item to remove was nil anyway so great job") return end
  remove_item_from_recipes(item.name)
  remove_item_from_technologies(item.name)
  remove_from_minable(item.name)
  data.raw.item[item.name] = nil
  item = nil
end

remove_technology_effect_type = function(dict)
  for k, tech in pairs (data.raw.technology) do
    local effects = tech.effects
    if effects then
      for i = #effects, 1, -1 do
        if dict[effects[i].type] then
          table.remove(effects, i)
        end
      end
      if #effects == 0 then
        remove_technology(tech.name)
      end
    end
  end
end

local lib = {}
lib.rename_item = rename_item
lib.rename_recipe = rename_recipe
lib.remove_from_achievements = remove_from_achievements
lib.remove_from_items = remove_from_items
lib.remove_item_from_recipes = remove_item_from_recipes
lib.remove_item_from_technologies = remove_item_from_technologies
lib.remove_recipe_from_technologies = remove_recipe_from_technologies
lib.remove_entity_prototype = remove_entity_prototype
lib.remove_item_prototype = remove_item_prototype
lib.remove_technology_effect_type = remove_technology_effect_type
lib.remove_technology = remove_technology

return lib
