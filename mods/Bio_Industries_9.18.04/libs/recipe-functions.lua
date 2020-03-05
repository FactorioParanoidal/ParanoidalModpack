if not thxbob.lib.recipe then thxbob.lib.recipe = {} end


function thxbob.lib.recipe.replace_ingredient(recipe, old, new)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(new) then

    local amount = 0
    if data.raw.recipe[recipe].ingredients and not data.raw.recipe[recipe].normal and not data.raw.recipe[recipe].expensive then
      for i, ingredient in pairs(data.raw.recipe[recipe].ingredients) do
        local item = thxbob.lib.item.basic_item(ingredient)
        if item.name == old then
          amount = item.amount + amount
        end
      end
      if amount > 0 then
        if thxbob.lib.item.get_type(old) == "fluid" and thxbob.lib.item.get_type(new) == "item" then
          amount = math.ceil(amount / 10)
        end
        if thxbob.lib.item.get_type(old) == "item" and thxbob.lib.item.get_type(new) == "fluid" then
          amount = amount * 10
        end
        thxbob.lib.recipe.remove_ingredient(recipe, old)
        thxbob.lib.recipe.add_ingredient(recipe, {new, amount})
        return true
      else
        return false
      end
    end

    local retval = false
    if data.raw.recipe[recipe].normal then
      amount = 0
      for i, ingredient in pairs(data.raw.recipe[recipe].normal.ingredients) do
        local item = thxbob.lib.item.basic_item(ingredient)
        if item.name == old then
          amount = item.amount + amount
        end
      end
      if amount > 0 then
        if thxbob.lib.item.get_type(old) == "fluid" and thxbob.lib.item.get_type(new) == "item" then
          amount = math.ceil(amount / 10)
        end
        if thxbob.lib.item.get_type(old) == "item" and thxbob.lib.item.get_type(new) == "fluid" then
          amount = amount * 10
        end
        thxbob.lib.recipe.remove_difficulty_ingredient(recipe, "normal", old)
        thxbob.lib.recipe.add_difficulty_ingredient(recipe, "normal", {new, amount})
        retval = true
      end
    end

    if data.raw.recipe[recipe].expensive then
      amount = 0
      for i, ingredient in pairs(data.raw.recipe[recipe].expensive.ingredients) do
        local item = thxbob.lib.item.basic_item(ingredient)
        if item.name == old then
          amount = item.amount + amount
        end
      end
      if amount > 0 then
        if thxbob.lib.item.get_type(old) == "fluid" and thxbob.lib.item.get_type(new) == "item" then
          amount = math.ceil(amount / 10)
        end
        if thxbob.lib.item.get_type(old) == "item" and thxbob.lib.item.get_type(new) == "fluid" then
          amount = amount * 10
        end
        thxbob.lib.recipe.remove_difficulty_ingredient(recipe, "expensive", old)
        thxbob.lib.recipe.add_difficulty_ingredient(recipe, "expensive", {new, amount})
        retval = true
      end
    end

    return retval
  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_type(new) then
      log("Ingredient " .. new .. " does not exist.")
    end
    return false
  end
end


function thxbob.lib.recipe.replace_ingredient_in_all(old, new)
  if thxbob.lib.item.get_basic_type(new) then
    for i, recipe in pairs(data.raw.recipe) do
      thxbob.lib.recipe.replace_ingredient(recipe.name, old, new)
    end
  else
    log("Ingredient " .. new .. " does not exist.")
  end
end


function thxbob.lib.recipe.remove_ingredient(recipe, item)
  if data.raw.recipe[recipe] then

    if data.raw.recipe[recipe].expensive then
      thxbob.lib.item.remove(data.raw.recipe[recipe].expensive.ingredients, item)
    end
    if data.raw.recipe[recipe].normal then
      thxbob.lib.item.remove(data.raw.recipe[recipe].normal.ingredients, item)
    end
    if data.raw.recipe[recipe].ingredients then
      thxbob.lib.item.remove(data.raw.recipe[recipe].ingredients, item)
    end

  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end


function thxbob.lib.recipe.add_new_ingredient(recipe, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      thxbob.lib.item.add_new(data.raw.recipe[recipe].expensive.ingredients, thxbob.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].normal then
      thxbob.lib.item.add_new(data.raw.recipe[recipe].normal.ingredients, thxbob.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].ingredients then
      thxbob.lib.item.add_new(data.raw.recipe[recipe].ingredients, thxbob.lib.item.basic_item(item))
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_type(item) then
      log("Ingredient " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
  end
end

function thxbob.lib.recipe.add_ingredient(recipe, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      thxbob.lib.item.add(data.raw.recipe[recipe].expensive.ingredients, thxbob.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].normal then
      thxbob.lib.item.add(data.raw.recipe[recipe].normal.ingredients, thxbob.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].ingredients then
      thxbob.lib.item.add(data.raw.recipe[recipe].ingredients, thxbob.lib.item.basic_item(item))
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_basic_type(thxbob.lib.item.basic_item(item).name) then
      log("Ingredient " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
  end
end

function thxbob.lib.recipe.set_ingredient(recipe, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      thxbob.lib.item.set(data.raw.recipe[recipe].expensive.ingredients, thxbob.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].normal then
      thxbob.lib.item.set(data.raw.recipe[recipe].normal.ingredients, thxbob.lib.item.basic_item(item))
    end
    if data.raw.recipe[recipe].ingredients then
      thxbob.lib.item.set(data.raw.recipe[recipe].ingredients, thxbob.lib.item.basic_item(item))
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_basic_type(thxbob.lib.item.basic_item(item).name) then
      log("Ingredient " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
  end
end


function thxbob.lib.recipe.add_result(recipe, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      thxbob.lib.result_check(data.raw.recipe[recipe].expensive)
      thxbob.lib.item.add(data.raw.recipe[recipe].expensive.results, item)
    end
    if data.raw.recipe[recipe].normal then
      thxbob.lib.result_check(data.raw.recipe[recipe].normal)
      thxbob.lib.item.add(data.raw.recipe[recipe].normal.results, item)
    end
    if data.raw.recipe[recipe].result or data.raw.recipe[recipe].results then
      thxbob.lib.result_check(data.raw.recipe[recipe])
      thxbob.lib.item.add(data.raw.recipe[recipe].results, item)
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_basic_type(thxbob.lib.item.basic_item(item).name) then
      log("Item " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
  end
end

function thxbob.lib.recipe.set_result(recipe, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) then

    if data.raw.recipe[recipe].expensive then
      thxbob.lib.result_check(data.raw.recipe[recipe].expensive)
      thxbob.lib.item.set(data.raw.recipe[recipe].expensive.results, item)
    end
    if data.raw.recipe[recipe].normal then
      thxbob.lib.result_check(data.raw.recipe[recipe].normal)
      thxbob.lib.item.set(data.raw.recipe[recipe].normal.results, item)
    end
    if data.raw.recipe[recipe].result or data.raw.recipe[recipe].results then
      thxbob.lib.result_check(data.raw.recipe[recipe])
      thxbob.lib.item.set(data.raw.recipe[recipe].results, item)
    end

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_basic_type(thxbob.lib.item.basic_item(item).name) then
      log("Item " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
  end
end

function thxbob.lib.recipe.remove_result(recipe, item)
  if data.raw.recipe[recipe] then

    if data.raw.recipe[recipe].expensive then
      thxbob.lib.result_check(data.raw.recipe[recipe].expensive)
      thxbob.lib.item.remove(data.raw.recipe[recipe].expensive.results, item)
    end
    if data.raw.recipe[recipe].normal then
      thxbob.lib.result_check(data.raw.recipe[recipe].normal)
      thxbob.lib.item.remove(data.raw.recipe[recipe].normal.results, item)
    end
    if data.raw.recipe[recipe].result or data.raw.recipe[recipe].results then
      thxbob.lib.result_check(data.raw.recipe[recipe])
      thxbob.lib.item.remove(data.raw.recipe[recipe].results, item)
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


function thxbob.lib.recipe.difficulty_split(recipe)
  if data.raw.recipe[recipe] then
    if not data.raw.recipe[recipe].normal then 
      data.raw.recipe[recipe].normal = {} 
    end
    if not data.raw.recipe[recipe].expensive then 
      data.raw.recipe[recipe].expensive = {} 
    end
    split_line(recipe, "energy_required")
    if data.raw.recipe[recipe].enabled == false then
      if data.raw.recipe[recipe].normal.enabled ~= true then
        data.raw.recipe[recipe].normal.enabled = false
      end
      if data.raw.recipe[recipe].expensive.enabled ~= true then
        data.raw.recipe[recipe].expensive.enabled = false
      end
    end
    split_line(recipe, "ingredients")
    split_line(recipe, "result")
    split_line(recipe, "results")
    split_line(recipe, "result_count")
    split_line(recipe, "requester_paste_multiplier")
  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end



function thxbob.lib.recipe.remove_difficulty_ingredient(recipe, difficulty, item)
  if data.raw.recipe[recipe] and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      thxbob.lib.recipe.difficulty_split(recipe)
    end
    thxbob.lib.item.remove(data.raw.recipe[recipe][difficulty].ingredients, item)

  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end


function thxbob.lib.recipe.add_new_difficulty_ingredient(recipe, difficulty, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      thxbob.lib.recipe.difficulty_split(recipe)
    end
    thxbob.lib.item.add_new(data.raw.recipe[recipe][difficulty].ingredients, thxbob.lib.item.basic_item(item))

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_type(item) then
      log("Ingredient " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
  end
end

function thxbob.lib.recipe.add_difficulty_ingredient(recipe, difficulty, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      thxbob.lib.recipe.difficulty_split(recipe)
    end
    thxbob.lib.item.add(data.raw.recipe[recipe][difficulty].ingredients, thxbob.lib.item.basic_item(item))

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_basic_type(thxbob.lib.item.basic_item(item).name) then
      log("Ingredient " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
  end
end


function thxbob.lib.recipe.add_difficulty_result(recipe, difficulty, item)
  if data.raw.recipe[recipe] and thxbob.lib.item.get_type(thxbob.lib.item.basic_item(item).name) and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      thxbob.lib.recipe.difficulty_split(recipe)
    end
    thxbob.lib.result_check(data.raw.recipe[recipe][difficulty])
    thxbob.lib.item.add(data.raw.recipe[recipe][difficulty].results, item)

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not thxbob.lib.item.get_basic_type(thxbob.lib.item.basic_item(item).name) then
      log("Item " .. thxbob.lib.item.basic_item(item).name .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
  end
end

function thxbob.lib.recipe.remove_difficulty_result(recipe, difficulty, item)
  if data.raw.recipe[recipe] and (difficulty == "normal" or difficulty == "expensive") then

    if not data.raw.recipe[recipe][difficulty] then
      thxbob.lib.recipe.difficulty_split(recipe)
    end
    thxbob.lib.result_check(data.raw.recipe[recipe][difficulty])
    thxbob.lib.item.remove(data.raw.recipe[recipe][difficulty].results, item)

  else
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
    if not (difficulty == "normal" or difficulty == "expensive") then
      log("Difficulty " .. difficulty .. " is invalid.")
    end
  end
end


