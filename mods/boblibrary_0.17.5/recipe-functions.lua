if not bobmods.lib.recipe then bobmods.lib.recipe = {} end


function bobmods.lib.recipe.replace_ingredient(recipe, old, new)
  if data.raw.recipe[recipe] and bobmods.lib.item.get_type(new) then

    local amount = 0
    if data.raw.recipe[recipe].ingredients and not data.raw.recipe[recipe].normal and not data.raw.recipe[recipe].expensive then
      for i, ingredient in pairs(data.raw.recipe[recipe].ingredients) do
        local item = bobmods.lib.item.basic_item(ingredient)
        if item.name == old then
          amount = item.amount + amount
        end
      end
      if amount > 0 then
        if bobmods.lib.item.get_type(old) == "fluid" and bobmods.lib.item.get_type(new) == "item" then
          amount = math.ceil(amount / 10)
        end
        if bobmods.lib.item.get_type(old) == "item" and bobmods.lib.item.get_type(new) == "fluid" then
          amount = amount * 10
        end
        bobmods.lib.recipe.remove_ingredient(recipe, old)
        bobmods.lib.recipe.add_ingredient(recipe, {new, amount})
        return true
      else
        return false
      end
    end

    local retval = false
    if data.raw.recipe[recipe].normal then
      amount = 0
      for i, ingredient in pairs(data.raw.recipe[recipe].normal.ingredients) do
        local item = bobmods.lib.item.basic_item(ingredient)
        if item.name == old then
          amount = item.amount + amount
        end
      end
      if amount > 0 then
        if bobmods.lib.item.get_type(old) == "fluid" and bobmods.lib.item.get_type(new) == "item" then
          amount = math.ceil(amount / 10)
        end
        if bobmods.lib.item.get_type(old) == "item" and bobmods.lib.item.get_type(new) == "fluid" then
          amount = amount * 10
        end
        bobmods.lib.recipe.remove_difficulty_ingredient(recipe, "normal", old)
        bobmods.lib.recipe.add_difficulty_ingredient(recipe, "normal", {new, amount})
        retval = true
      end
    end

    if data.raw.recipe[recipe].expensive then
      amount = 0
      for i, ingredient in pairs(data.raw.recipe[recipe].expensive.ingredients) do
        local item = bobmods.lib.item.basic_item(ingredient)
        if item.name == old then
          amount = item.amount + amount
        end
      end
      if amount > 0 then
        if bobmods.lib.item.get_type(old) == "fluid" and bobmods.lib.item.get_type(new) == "item" then
          amount = math.ceil(amount / 10)
        end
        if bobmods.lib.item.get_type(old) == "item" and bobmods.lib.item.get_type(new) == "fluid" then
          amount = amount * 10
        end
        bobmods.lib.recipe.remove_difficulty_ingredient(recipe, "expensive", old)
        bobmods.lib.recipe.add_difficulty_ingredient(recipe, "expensive", {new, amount})
        retval = true
      end
    end

    return retval
  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_type(new) then
      log("Ingredient " .. new .. " does not exist.")
    end
    return false
  end
end


function bobmods.lib.recipe.replace_ingredient_in_all(old, new)
  if bobmods.lib.item.get_basic_type(new) then
    for i, recipe in pairs(data.raw.recipe) do
      bobmods.lib.recipe.replace_ingredient(recipe.name, old, new)
    end
  else
    log("Ingredient " .. new .. " does not exist.")
  end
end


function bobmods.lib.recipe.remove_ingredient(recipe, item)
  if data.raw.recipe[recipe] then

    if data.raw.recipe[recipe].expensive then
      bobmods.lib.item.remove(data.raw.recipe[recipe].expensive.ingredients, item)
    end
    if data.raw.recipe[recipe].normal then
      bobmods.lib.item.remove(data.raw.recipe[recipe].normal.ingredients, item)
    end
    if data.raw.recipe[recipe].ingredients then
      bobmods.lib.item.remove(data.raw.recipe[recipe].ingredients, item)
    end

  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end


function bobmods.lib.recipe.add_new_ingredient(recipe, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      bobmods.lib.item.add_new(data.raw.recipe[recipe].expensive.ingredients, bobmods.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].normal then
      bobmods.lib.item.add_new(data.raw.recipe[recipe].normal.ingredients, bobmods.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].ingredients then
      bobmods.lib.item.add_new(data.raw.recipe[recipe].ingredients, bobmods.lib.item.basic_item(item))
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) then
      log("Ingredient " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end

function bobmods.lib.recipe.add_ingredient(recipe, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      bobmods.lib.item.add(data.raw.recipe[recipe].expensive.ingredients, bobmods.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].normal then
      bobmods.lib.item.add(data.raw.recipe[recipe].normal.ingredients, bobmods.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].ingredients then
      bobmods.lib.item.add(data.raw.recipe[recipe].ingredients, bobmods.lib.item.basic_item(item))
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_basic_type(bobmods.lib.item.basic_item(item).name) then
      log("Ingredient " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end

function bobmods.lib.recipe.set_ingredient(recipe, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      bobmods.lib.item.set(data.raw.recipe[recipe].expensive.ingredients, bobmods.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].normal then
      bobmods.lib.item.set(data.raw.recipe[recipe].normal.ingredients, bobmods.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].ingredients then
      bobmods.lib.item.set(data.raw.recipe[recipe].ingredients, bobmods.lib.item.basic_item(item))
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_basic_type(bobmods.lib.item.basic_item(item).name) then
      log("Ingredient " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end


function bobmods.lib.recipe.add_result(recipe, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      bobmods.lib.result_check(data.raw.recipe[recipe].expensive)
      bobmods.lib.item.add(data.raw.recipe[recipe].expensive.results, item)
    end
    if data.raw.recipe[recipe].normal then
      bobmods.lib.result_check(data.raw.recipe[recipe].normal)
      bobmods.lib.item.add(data.raw.recipe[recipe].normal.results, item)
    end
    if data.raw.recipe[recipe].result or data.raw.recipe[recipe].results then
      bobmods.lib.result_check(data.raw.recipe[recipe])
      bobmods.lib.item.add(data.raw.recipe[recipe].results, item)
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_basic_type(bobmods.lib.item.basic_item(item).name) then
      log("Item " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end

function bobmods.lib.recipe.set_result(recipe, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      bobmods.lib.result_check(data.raw.recipe[recipe].expensive)
      bobmods.lib.item.set(data.raw.recipe[recipe].expensive.results, item)
    end
    if data.raw.recipe[recipe].normal then
      bobmods.lib.result_check(data.raw.recipe[recipe].normal)
      bobmods.lib.item.set(data.raw.recipe[recipe].normal.results, item)
    end
    if data.raw.recipe[recipe].result or data.raw.recipe[recipe].results then
      bobmods.lib.result_check(data.raw.recipe[recipe])
      bobmods.lib.item.set(data.raw.recipe[recipe].results, item)
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_basic_type(bobmods.lib.item.basic_item(item).name) then
      log("Item " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end

function bobmods.lib.recipe.remove_result(recipe, item)
  if data.raw.recipe[recipe] then

    if data.raw.recipe[recipe].expensive then
      bobmods.lib.result_check(data.raw.recipe[recipe].expensive)
      bobmods.lib.item.remove(data.raw.recipe[recipe].expensive.results, item)
    end
    if data.raw.recipe[recipe].normal then
      bobmods.lib.result_check(data.raw.recipe[recipe].normal)
      bobmods.lib.item.remove(data.raw.recipe[recipe].normal.results, item)
    end
    if data.raw.recipe[recipe].result or data.raw.recipe[recipe].results then
      bobmods.lib.result_check(data.raw.recipe[recipe])
      bobmods.lib.item.remove(data.raw.recipe[recipe].results, item)
    end

  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end



local function split_line(recipe, tag)
  if data.raw.recipe[recipe][tag] then
    if not data.raw.recipe[recipe].normal[tag] then
      data.raw.recipe[recipe].normal[tag] = table.deepcopy(data.raw.recipe[recipe][tag])
    end
    if not data.raw.recipe[recipe].expensive[tag] then
      data.raw.recipe[recipe].expensive[tag] = table.deepcopy(data.raw.recipe[recipe][tag])
    end
  end
end

local function split_line_bool(recipe, tag)
  if data.raw.recipe[recipe][tag] == true then
    data.raw.recipe[recipe].normal[tag] = true
    data.raw.recipe[recipe].expensive[tag] = true
  end
  if data.raw.recipe[recipe][tag] == false then
    data.raw.recipe[recipe].normal[tag] = false
    data.raw.recipe[recipe].expensive[tag] = false
  end
end


function bobmods.lib.recipe.difficulty_split(recipe)
  if data.raw.recipe[recipe] then
    if not data.raw.recipe[recipe].normal then 
      data.raw.recipe[recipe].normal = {} 
    end
    if not data.raw.recipe[recipe].expensive then 
      data.raw.recipe[recipe].expensive = {} 
    end

    split_line(recipe, "energy_required")
    split_line(recipe, "ingredients")
    split_line(recipe, "results")
    split_line(recipe, "result")
    split_line(recipe, "result_count")
    split_line(recipe, "main_product")
    split_line(recipe, "emissions_multiplier")
    split_line(recipe, "requester_paste_multiplier")
    split_line(recipe, "overload_multiplier")
    split_line_bool(recipe, "enabled")
    split_line_bool(recipe, "hidden")
    split_line_bool(recipe, "hide_from_stats")
    split_line_bool(recipe, "allow_decomposition")
    split_line_bool(recipe, "allow_as_intermediate")
    split_line_bool(recipe, "allow_intermediates")
    split_line_bool(recipe, "always_show_made_in")
    split_line_bool(recipe, "show_amount_in_title")
    split_line_bool(recipe, "always_show_products")

  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end



function bobmods.lib.recipe.add_new_difficulty_ingredient(recipe, difficulty, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      bobmods.lib.recipe.difficulty_split(recipe)
    end
    bobmods.lib.item.add_new(data.raw.recipe[recipe][difficulty].ingredients, bobmods.lib.item.basic_item(item))

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_type(item) then
      log("Ingredient " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end

function bobmods.lib.recipe.add_difficulty_ingredient(recipe, difficulty, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      bobmods.lib.recipe.difficulty_split(recipe)
    end
    bobmods.lib.item.add(data.raw.recipe[recipe][difficulty].ingredients, bobmods.lib.item.basic_item(item))

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_basic_type(bobmods.lib.item.basic_item(item).name) then
      log("Ingredient " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end

function bobmods.lib.recipe.remove_difficulty_ingredient(recipe, difficulty, item)
  if data.raw.recipe[recipe] and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      bobmods.lib.recipe.difficulty_split(recipe)
    end
    bobmods.lib.item.remove(data.raw.recipe[recipe][difficulty].ingredients, item)

  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end


function bobmods.lib.recipe.add_difficulty_result(recipe, difficulty, item)
  if data.raw.recipe[recipe] and type(item) == "table" and bobmods.lib.item.get_type(bobmods.lib.item.basic_item(item).name) and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      bobmods.lib.recipe.difficulty_split(recipe)
    end
    bobmods.lib.result_check(data.raw.recipe[recipe][difficulty])
    bobmods.lib.item.add(data.raw.recipe[recipe][difficulty].results, item)

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not bobmods.lib.item.get_basic_type(bobmods.lib.item.basic_item(item).name) then
      log("Item " .. bobmods.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
    if not type(item) == "table" then
      log("item should be a table")
    end 
  end
end

function bobmods.lib.recipe.remove_difficulty_result(recipe, difficulty, item)
  if data.raw.recipe[recipe] and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      bobmods.lib.recipe.difficulty_split(recipe)
    end
    bobmods.lib.result_check(data.raw.recipe[recipe][difficulty])
    bobmods.lib.item.remove(data.raw.recipe[recipe][difficulty].results, item)

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
  end
end


function bobmods.lib.recipe.enabled(recipe, bool)
  if data.raw.recipe[recipe] then
    if data.raw.recipe[recipe].normal then
      data.raw.recipe[recipe].normal.enabled = bool or "false"
    end
    if data.raw.recipe[recipe].expensive then
      data.raw.recipe[recipe].expensive.enabled = bool or "false"
    end
    if data.raw.recipe[recipe].ingredients then --should always exist on a recipe that has no difficulty
      data.raw.recipe[recipe].enabled = bool or "false"
    end
  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
  end
end

function bobmods.lib.recipe.difficulty_enabled(recipe, difficulty, bool)
  if data.raw.recipe[recipe] and (difficulty == "normal" or difficulty == "expensive") then
    if not data.raw.recipe[recipe][difficulty] then
      bobmods.lib.recipe.difficulty_split(recipe)
    end
    data.raw.recipe[recipe][difficulty].enabled = bool or "false"
  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
  end
end

