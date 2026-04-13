local data_util = {}

data_util.mod_name = "aai-industry"
data_util.mod_path = "__"..data_util.mod_name.."__"
data_util.str_gsub = string.gsub

data_util.char_to_multiplier = {
    m = 0.001,
    c = 0.01,
    d = 0.1,
    h = 100,
    k = 1000,
    M = 1000000,
    G = 1000000000,
    T = 1000000000000,
    P = 1000000000000000,
}

function data_util.string_to_number(str)
    str = ""..str
    local number_string = ""
    local last_char = nil
    for i = 1, #str do
        local c = str:sub(i,i)
        if c == "." or tonumber(c) ~= nil then
            number_string = number_string .. c
        else
            last_char = c
            break
        end
    end
    if last_char and data_util.char_to_multiplier[last_char] then
        return tonumber(number_string) * data_util.char_to_multiplier[last_char]
    end
    return tonumber(number_string)
end

function data_util.remove_recipe_from_effects(effects, recipe)
    local index = 0
    for _,_item in ipairs(effects) do
        if _item.type == "unlock-recipe" and _item.recipe == recipe then
            index = _
            break
        end
    end
    if index > 0 then
        table.remove(effects, index)
    end
end

function data_util.remove_from_table(list, item)
    local index = 0
    for _,_item in ipairs(list) do
        if item == _item then
            index = _
            break
        end
    end
    if index > 0 then
        table.remove(list, index)
    end
end

function data_util.table_contains(table, check)
  for k,v in pairs(table) do if v == check then return true end end
  return false
end

function data_util.conditional_modify (prototype_modifier)
  if data.raw[prototype_modifier.type] and data.raw[prototype_modifier.type][prototype_modifier.name] then
    local prototype = data.raw[prototype_modifier.type][prototype_modifier.name]

    for key, property in pairs(prototype_modifier) do
      prototype[key] = property
    end
  end
end

function data_util.remove_ingredient_sub(recipe, name)
  for i = #recipe.ingredients, 1, -1 do
    if recipe.ingredients[i] then
      for _, value in pairs(recipe.ingredients[i]) do
        if value == name then
          table.remove(recipe.ingredients, i)
        end
      end
    end
  end
end

function data_util.remove_ingredient(recipe, name)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  if not recipe then return end
  if recipe.ingredients then
    data_util.remove_ingredient_sub(recipe, name)
  end
end

function data_util.replace_or_add_ingredient_sub(recipe, old, new, amount, is_fluid)
  -- old can be nil to just add
  local found = false
  if old then
    for i, component in pairs(recipe.ingredients) do
      for _, value in pairs(component) do
        if value == old then
          found = true
          recipe.ingredients[i] = {type=is_fluid and "fluid" or "item", name=new, amount=amount}
          break
        end
      end
    end
  end
  if not found then
    table.insert(recipe.ingredients, {type=is_fluid and "fluid" or "item", name=new, amount=amount})
  end
end

function data_util.replace_or_add_ingredient(recipe, old, new, amount, is_fluid)
  if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
  if not recipe then return end
  if recipe.ingredients then
    data_util.replace_or_add_ingredient_sub(recipe, old, new, amount, is_fluid)
  end
end

function data_util.disable_recipe(recipe_name)
  data_util.conditional_modify({
    type = "recipe",
    name = recipe_name,
    enabled = false,
  })
end

function data_util.enable_recipe(recipe_name)
  data_util.conditional_modify({
    type = "recipe",
    name = recipe_name,
    enabled = true,
  })
  for _, tech in pairs(data.raw.technology) do
      if tech.effects then
          data_util.remove_recipe_from_effects(tech.effects, recipe_name)
      end
  end
end

function data_util.recipe_require_tech(recipe_name, tech_name)
  if data.raw.recipe[recipe_name] and data.raw.technology[tech_name] then
    data_util.disable_recipe(recipe_name)
    for _, tech in pairs(data.raw.technology) do
        if tech.effects then
            data_util.remove_recipe_from_effects(tech.effects, recipe_name)
        end
    end
    local already = false
    data.raw.technology[tech_name].effects = data.raw.technology[tech_name].effects or {}
    for _, effect in pairs(data.raw.technology[tech_name].effects) do
      if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
        already = true
        break
      end
    end
    if not already then
      table.insert(data.raw.technology[tech_name].effects, { type = "unlock-recipe", recipe = recipe_name})
    end
  end
end

function data_util.tech_lock_recipes(tech_name, recipe_names)
  if not data.raw.technology[tech_name] then
    return
  end
  if type(recipe_names) == "string" then recipe_names = {recipe_names} end
  for _, recipe_name in pairs(recipe_names) do
    if data.raw.recipe[recipe_name] then
      data_util.recipe_require_tech(recipe_name, tech_name)
    end
  end
end

function data_util.tech_add_prerequisites(tech_name, require_names)
  if not data.raw.technology[tech_name] then return end
  if type(require_names) == "string" then require_names = {require_names} end
  for _, require_name in pairs(require_names) do
    if data.raw.technology[require_name] then
      data.raw.technology[tech_name].prerequisites = data.raw.technology[tech_name].prerequisites or {}
      local already = false
      for _, prerequisite in pairs(data.raw.technology[tech_name].prerequisites) do
        if prerequisite == require_name then
          already = true
          break
        end
      end
      if not already then
        table.insert(data.raw.technology[tech_name].prerequisites, require_name)
      end
    end
  end
end

function data_util.tech_remove_prerequisites (prototype_name, prerequisites)
  local prototype = data.raw.technology[prototype_name]
  if not prototype then return end
  for _, new_prerequisite in pairs(prerequisites) do
    for i = #prototype.prerequisites, 1, -1 do
      if prototype.prerequisites[i] == new_prerequisite then
        table.remove(prototype.prerequisites, i)
      end
    end
  end
end

function data_util.techs_add_ingredients(prototype_names, ingredients, cascade)
  for _, prototype_name in pairs(prototype_names) do
    data_util.tech_add_ingredients (prototype_name, ingredients, cascade)
  end
end

-- cascade applies to children too
function data_util.tech_add_ingredients(prototype_name, ingredients, cascade)
  --log("tech_add_ingredients: " .. prototype_name)
  local prototype = data.raw.technology[prototype_name]
  if not prototype then return end
  local added = false
  for _, new_ingredient in pairs(ingredients) do
    local found = false
    for _, old_ingredient in pairs(prototype.unit.ingredients) do
      if old_ingredient[1] == new_ingredient then
        found = true break
      end
    end
    if not found then
      table.insert(prototype.unit.ingredients, {new_ingredient, 1})
      added = true
    end
  end
  if added and cascade then
    local child_techs = data_util.tech_find_child_names(prototype_name)
    for _, tech in pairs(child_techs) do
      data_util.tech_add_ingredients(tech, ingredients, cascade)
    end
  end
end

function data_util.tech_remove_ingredients (prototype_name, packs)
  local prototype = data.raw.technology[prototype_name]
  if prototype then
    for _, pack in pairs(packs) do
      for i = #prototype.unit.ingredients, 1, -1 do
        if prototype.unit.ingredients[i] and prototype.unit.ingredients[i][1] == pack then
          table.remove(prototype.unit.ingredients, i)
        end
      end
    end
  end
end

function data_util.replace(str, what, with)
    what = data_util.str_gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = data_util.str_gsub(with, "[%%]", "%%%%") -- escape replacement
    return data_util.str_gsub(str, what, with)
end


function data_util.replace_filenames_recursive(subject, what, with)
  if subject.filename then
    subject.filename = data_util.replace(subject.filename, what, with)
  end
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.replace_filenames_recursive(sub, what, with)
    end
  end
end

function data_util.technology_icon_xx(xx, technology_icon, icon_size)
  local scale = icon_size / 512
  local icons =
  {
    {
      icon = technology_icon,
      icon_size = icon_size,
    },
    {
      icon = "__core__/graphics/icons/technology/constants/" .. xx .. ".png",
      icon_size = 128,
      scale = scale,
      shift = {100 * scale, 100 * scale},
      floating = true,
    }
  }
  return icons
end

function data_util.technology_icon_constant_capacity(technology_icon, icon_size)
  return data_util.technology_icon_xx("constant-capacity", technology_icon, icon_size)
end

-- Puts sub-icon in the top-left of the main icon
-- If multiple sub-icons, they will all overlap if not given a new shift value
function data_util.sub_icons(icon_main, ...)
  local icons_sub = {...}
  local results = {{ icon = icon_main, shift = {2, 0}, icon_size = 64 }}
  for _, icon in pairs(icons_sub) do
    table.insert(results, { icon = icon.icon or icon,
                            scale = icon.scale or 0.25,
                            shift = icon.shift or {-7, -7},
                            icon_size = 64
                          })
  end
  return results
end

function data_util.tint_recursive(subject, tint)
  if not subject then return end
  if subject.filename then
    subject.tint = tint
  end
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      data_util.tint_recursive(sub, tint)
    end
  end
end

function data_util.add_fuel_category(burner, category)
  burner.fuel_categories = burner.fuel_categories or {}
  if not data_util.table_contains(burner.fuel_categories, category) then
    table.insert(burner.fuel_categories, category)
  end
end

function data_util.recipe_set_result_count(recipe_name, count)
  local recipe = data.raw.recipe[recipe_name]
  if not recipe then return end
  if recipe.results and recipe.results[1] then recipe.results[1].amount = count end
end

function data_util.recipe_set_time(recipe_name, time)
  local recipe = data.raw.recipe[recipe_name]
  if not recipe then return end
  recipe.energy_required = time
end

function data_util.recipe_multiply_time(recipe_name, multiplier)
  local recipe = data.raw.recipe[recipe_name]
  if not recipe then return end
  recipe.energy_required = recipe.energy_required * multiplier
end

function data_util.is_ingredient_used(ingredient)
  for _,recipe in pairs(data.raw.recipe) do
    for _,i in pairs(recipe.ingredients) do
      if (i.name or i[1]) == ingredient then
        return true
      end
    end
  end
  return false
end

function data_util.recipe_has_result(recipe, result)
  if recipe.results then
    for _,i in pairs(recipe.results) do
      if (i.name or i[1]) == result then
        return true
      end
    end
  end
end

function data_util.find_recipes_with_result(result)
  local recipes = {}
  for _,recipe in pairs(data.raw.recipe) do
    if (data_util.recipe_has_result(recipe, result)) then
      table.insert(recipes, recipe.name)
    end
  end
  return recipes
end

local function find_and_replace_ingredients_sub(ingredients, replacements)
  for _,ingredient in pairs(ingredients) do
    for from,to in pairs(replacements) do
      if ingredient.name == from then
        ingredient.name = to
      elseif ingredient[1] == from then
        ingredient[1] = to
      end
    end
  end
end

-- Input: {["replace-from"] = "replace-to"}
function data_util.find_and_replace_ingredients(replacements)
  for _,recipe in pairs(data.raw.recipe) do
    find_and_replace_ingredients_sub(recipe.ingredients, replacements)
  end
end

function data_util.remove_recipes_from_technologies(recipes)
  for _,recipe in pairs(recipes) do
    for _,tech in pairs(data.raw.technology) do
      if tech.effects then
        for k,effect in pairs(tech.effects) do
          if effect.recipe == recipe then
            table.remove(tech.effects, k)
            break
          end
        end
      end
    end
  end
end

return data_util
