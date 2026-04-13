PClib_log("Entered file " .. debug.getinfo(1).source)

return function(mod_args)
  local common = _ENV[mod_args.mod_shortname]

  --~ AD_lib.recipe = AD_lib.recipe or {}
  local recipe_stuff = {}

  -- We need the item functions for the recipe functions are used!
  --~ common.item_functions = common.item_functions or
                          --~ common.import_from_file(common[file], lib)
  do
    local lib = "item_functions"
    if not common[lib] then
      common[lib] = {}
      common.import_from_file(common[lib], "__Pi-C_lib__.libs."..lib)
    end
  end
  local item_stuff = common.item_functions

  -- Added by Pi-C
  ------------------------------------------------------------------------------------
  --          Generate functions to change individual properties of recipes         --
  ------------------------------------------------------------------------------------
  -- List of all recipe properties
  -- (We must copy them when creating difficulties, we also need them to generate
  --  the functions for setting individual properties!)
  local recipe_properties = {
    -- Boolean values
    allow_as_intermediate = "boolean",
    allow_decomposition = "boolean",
    allow_inserter_overload = "boolean",
    allow_intermediates = "boolean",
    always_show_made_in = "boolean",
    always_show_products = "boolean",
    enabled = "boolean",
    hidden = "boolean",
    hide_from_player_crafting = "boolean",
    hide_from_stats = "boolean",
    show_amount_in_title = "boolean",
    unlock_results = "boolean",
    -- Numeric values
    emissions_multiplier = "double",
    energy_required = "double",
    overload_multiplier = "integer",
    requester_paste_multiplier = "integer",
    result_count = "integer",
    -- String values
    main_product = "string",
    result = "string",
    -- Table values!
    ingredients = "table",
    results = "table",
  }


  ------------------------------------------------------------------------------------
  --                           Check recipe and difficulty                          --
  ------------------------------------------------------------------------------------
  -- Make sure we've got a valid difficulty name!
  local function check_difficulty(difficulty)
    if difficulty ~= "" and difficulty ~= "normal" and difficulty ~= "expensive" then
      error(string.format("%s is not a valid difficulty!", difficulty))
    end
  end

  -- Get actual recipe data
  local function check_recipe(recipe_or_name)
    local ret

    local t = type(recipe_or_name)
    if data then
      ret = (t == "table" and recipe_or_name.type == "recipe" and recipe_or_name) or
            data.raw.recipe[recipe_or_name]
    elseif game then
      if (t == "table" or t == "userdata") and
          recipe_or_name.object_name == "LuaRecipePrototype" then
        ret = recipe_or_name
      elseif t == "string" then
        ret = game.recipe_prototypes[recipe_or_name]
      end
    end

    return ret
  end


  ------------------------------------------------------------------------------------
  --                           Set properties of a recipe                           --
  ------------------------------------------------------------------------------------
  local function recipe_set_difficulty_property_value(recipe_in, property, difficulty, value)
    common.entered_function({recipe_in, property, difficulty, value})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    if not recipe_properties[property] then
      error(string.format("%s is not a valid recipe property!", property))
    end
    if
      (recipe_properties[property] == "boolean" and type(value) ~= "boolean") or
      (recipe_properties[property] == "double" and type(value) ~= "number") or
      (recipe_properties[property] == "integer" and
        type(value) ~= "number" or
        (type(value) == "number" and value ~= math.floor(value))
      ) or
      (recipe_properties[property] == "string" and type(value) ~= "string") or
      (recipe_properties[property] == "table" and type(value) ~= "table")
    then
      error(string.format("%s is not a %s value!", value, recipe_properties[property]))
    end

    -- Set value
    if recipe then
      if difficulty == "" then
        recipe[property] = value
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe.name)
        end
        recipe[difficulty][property] = value
      end
    end

    common.entered_function("leave")
  end

  -- Generate functions!
  -- Set property for one difficulty ("" is the property in the recipe root):
  -- recipe_stuff.recipe_set_difficulty_X(recipe, difficulty, item_in)
  --
  -- Set property for all difficulties, including no difficulty (directly in the recipe root):
  -- recipe_stuff.set_X(recipe, value)
  for property, p in pairs(recipe_properties) do
    if p == "boolean" then
      -- Usage: recipe -- name (string) or recipe data (table)
      recipe_stuff["set_difficulty_"..property] = function(recipe, difficulty, value)
        recipe_set_difficulty_property_value(recipe, property, difficulty, value)
      end

      -- Usage: recipe -- name (string) or recipe data (table)
      recipe_stuff["set_"..property] = function(recipe, value)
        recipe_stuff["set_difficulty_"..property](recipe, "", value)
        recipe_stuff["set_difficulty_"..property](recipe, "normal", value)
        recipe_stuff["set_difficulty_"..property](recipe, "expensive", value)
      end

    end
  end


  -- Modified by Pi-C
  ------------------------------------------------------------------------------------
  --                           Create recipe difficulties                           --
  ------------------------------------------------------------------------------------
  -- Copy recipe properties from recipe root to recipe difficulties
  local function split_line(recipe_in, tag)
    --~ common.entered_function({recipe_in, tag})

    -- Sanitize arguments
    local recipe = check_recipe(recipe_in)

    if recipe then
      -- Checking for nil explicitely because Boolean properties set to "false" will
      -- mess things up!
      if recipe[tag] ~= nil then
        recipe.normal[tag] = recipe.normal[tag] ~= nil and recipe.normal[tag] or
                                table.deepcopy(recipe[tag])
        recipe.expensive[tag] = recipe.expensive[tag] ~= nil and recipe.expensive[tag] or
                                table.deepcopy(recipe[tag])
      -- Only recipe.normal exists
      elseif recipe.normal[tag] ~= nil and recipe.expensive[tag] == nil then
        recipe.expensive[tag] = table.deepcopy(recipe.normal[tag])
      -- Only recipe.expensive exists
      elseif recipe.expensive[tag] ~= nil and recipe.normal[tag] == nil then
        recipe.normal[tag] = table.deepcopy(recipe.expensive[tag])
      end
    end

    --~ common.entered_function("leave")
  end

  -- Modified by Pi-C
  -- Make sure the difficulties exist
  recipe_stuff.difficulty_split = function(recipe_in)
    common.entered_function({recipe_in})

    local recipe = check_recipe(recipe_in)

    if recipe then
      recipe.normal = recipe.normal or {}
      recipe.expensive = recipe.expensive or {}

      for property, p in pairs(recipe_properties) do
        split_line(recipe, property)
      end
    else
      common.writeDebug("Recipe %s does not exist.", {recipe_in})
    end

    common.entered_function("leave")
  end



  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  --                            Functions for ingredients                           --
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------


  ------------------------------------------------------------------------------------
  --                                 Add ingredients                                --
  ------------------------------------------------------------------------------------
  -- Modified by Pi-C
  -- Add new item to ingredients. If it already is an ingredient, add to its amount.
  recipe_stuff.add_difficulty_ingredient = function(recipe_in, difficulty, item_in)
    common.entered_function({recipe_in, difficulty, item_in})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)
    local item = item_stuff.item(item_in)

    local ret

    if recipe and item and item_stuff.get_type(item.name) then
      if difficulty == "" then
        recipe.ingredients = recipe.ingredients or {}
        item_stuff.add(recipe.ingredients, item)
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe)
        end
        recipe[difficulty].ingredients = recipe[difficulty].ingredients or {}
        ret = item_stuff.add(recipe[difficulty].ingredients, item)
      end

    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
      if not item_stuff.get_basic_type(item.name) then
        common.writeDebug("Ingredient %s does not exist.", {item_in})
      end
    end

    common.entered_function("leave")
    return ret
  end


  -- Modified by Pi-C
  recipe_stuff.add_ingredient = function(recipe, item)
    common.entered_function(recipe, item)

    if recipe and item  then
      recipe_stuff.add_difficulty_ingredient(recipe, "", item)
      recipe_stuff.add_difficulty_ingredient(recipe, "normal", item)
      recipe_stuff.add_difficulty_ingredient(recipe, "expensive", item)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item then
        common.writeDebug("No ingredient!")
      end
    end

    common.entered_function("leave")
  end


  -- Modified by Pi-C
  -- Only add this item if it's not yet an ingredient in this recipe!
  recipe_stuff.add_new_difficulty_ingredient = function(recipe_in, difficulty, item_in)
    common.entered_function({recipe_in, difficulty, item_in})

    -- Sanitizing arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)
    local item = item_stuff.item(item_in)

    local ret

    if recipe and item and item_stuff.get_type(item.name) then
      if difficulty == "" then
        recipe.ingredients = recipe.ingredients or {}
        ret = item_stuff.add_new(recipe.ingredients, item)
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe)
        end
        recipe[difficulty].ingredients = recipe[difficulty].ingredients or {}
        ret = item_stuff.add_new(recipe[difficulty].ingredients, item)
      end

    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
      if not item then
        common.writeDebug("Ingredient %s does not exist.", {item_in})
      end
    end

    common.entered_function("leave")
    return ret
  end


  -- Modified by Pi-C
  recipe_stuff.add_new_ingredient = function(recipe, item)
    common.entered_function({recipe, item})

    if recipe and item  then
      recipe_stuff.add_new_difficulty_ingredient(recipe, "", item)
      recipe_stuff.add_new_difficulty_ingredient(recipe, "normal", item)
      recipe_stuff.add_new_difficulty_ingredient(recipe, "expensive", item)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item then
        common.writeDebug("No ingredient!")
      end
    end

    common.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  --                               Remove ingredients                               --
  ------------------------------------------------------------------------------------
  -- Modified by Pi-C
  recipe_stuff.remove_difficulty_ingredient = function(recipe_in, difficulty, item_name)
    common.entered_function({recipe_in, difficulty, item_name})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    item_name = type(item_name) == "string" and item_name or
                type(item_name) == "table" and item_name.name or
                common.arg_err(item_name, "item name or item")

    local ret

    if recipe and item_name then
      if difficulty == "" then
        ret = item_stuff.remove(recipe.ingredients, item_name)
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe)
        end
        ret = item_stuff.remove(recipe[difficulty].ingredients, item_name)
      end
    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
    end

    common.entered_function("leave")
    return ret
  end


  -- Modified by Pi-C
  recipe_stuff.remove_ingredient = function(recipe, item)
    common.entered_function({recipe, item})

    if recipe and item  then
      recipe_stuff.remove_difficulty_ingredient(recipe, "", item)
      recipe_stuff.remove_difficulty_ingredient(recipe, "normal", item)
      recipe_stuff.remove_difficulty_ingredient(recipe, "expensive", item)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item then
        common.writeDebug("No ingredient!")
      end
    end

    common.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  --                               Replace ingredients                              --
  ------------------------------------------------------------------------------------
  -- Added by Pi-C
  -- If the old item is an ingredient, remove it and add the new item instead.
  recipe_stuff.replace_difficulty_ingredient = function(recipe_in, difficulty, old, new)
    common.entered_function({recipe_in, difficulty, old, new})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    if type(old) ~= "string" and (type(old) ~= "table" or not old.name and old.type) then
      error(string.format("\"%s\" is not a valid item name or item!", old))
    end
    if type(new) ~= "string" and (type(new) ~= "table" or not new.name and new.type) then
      error(string.format("\"%s\" is not a valid item name or item!", new))
    end

    local retval = false

    -- Recipe must exist
    if recipe then
      local ingredient, ingredients
      local new_item, new_name, new_type, old_name, old_type

      old_name = (type(old) == "string" and old) or (type(old) == "table" and old.name)


      --~ ingredients = BI_Functions.lib.get_difficulty_recipe_ingredients(recipe, difficulty)
      ingredients = recipe_stuff.get_difficulty_recipe_ingredients(recipe, difficulty)

      -- We only need to do this if the old item is among the recipe ingredients
      if ingredients and ingredients[old_name] then

        ingredient = ingredients[old_name]
        new_name = type(new) == "string" and new or type(new) == "table" and new.name
        new_type = item_stuff.get_basic_type(new)
        old_type = ingredient.type

        -- "new" was just a name, use data from old item!
        if type(new) == "string" then
          new_item = {
            name = new_name,
            type = new_type,
            amount = ingredient.amount,
            catalyst_amount = ingredient.catalyst_amount
          }
          -- Add data for fluid ingredients, if necessary
          if new_type == "fluid" then
            new_item.temperature = ingredient.temperature
            new_item.minimum_temperature = ingredient.minimum_temperature
            new_item.maximum_temperature = ingredient.maximum_temperature
            new_item.fluidbox_index = ingredient.fluidbox_index
          end

          -- Switch from fluid to item?
          if old_type == "fluid" and new_type == "item" then
            common.writeDebug("Switching from fluid (%s) to item (%s)!",
                          {common.enquote(old_name), common.enquote(new_name)})
            new_item.amount = math.ceil(new_item.amount * 0.1)
            new_item.catalyst_amount = math.ceil(new_item.catalyst_amount * 0.1)
            new_item.minimum_temperature = nil
            new_item.maximum_temperature = nil

          -- Switch from item to fluid
          elseif old_type == "item" and new_type == "fluid" then
            common.writeDebug("Switching from item (%s) to fluid (%s)!",
                          {common.enquote(old_name), common.enquote(new_name)})
            new_item.amount = new_item.amount * 10
            new_item.catalyst_amount = new_item.catalyst_amount * 10

          -- Same item
          else
            common.writeDebug("Type of %s and %s is the same (%s)!",
                  {common.enquote(old_name), common.enquote(new_name), common.enquote(old_type)})
          end

          new_item.catalyst_amount = new_item.catalyst_amount > 0 and
                                      new_item.catalyst_amount or
                                      nil

        -- "new" was an item specification, use that!
        else
          new_item = item_stuff.item(new)
        end

        -- Remove old ingredient
        recipe_stuff.remove_difficulty_ingredient(recipe, difficulty, old)
        -- Add new ingredient
        recipe_stuff.add_difficulty_ingredient(recipe, difficulty, new_item)

        retval = true
      end

    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
      --~ if not new_type then
        --~ common.writeDebug("Ingredient %s does not exist.", {new})
      --~ end
    end

    common.entered_function("leave")
    return retval
  end


  -- Modified by Pi-C
  recipe_stuff.replace_ingredient = function(recipe, old, new)
    common.entered_function({recipe, old, new})

    if recipe and old and new then
      recipe_stuff.replace_difficulty_ingredient(recipe, "", old, new)
      recipe_stuff.replace_difficulty_ingredient(recipe, "normal", old, new)
      recipe_stuff.replace_difficulty_ingredient(recipe, "expensive", old, new)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not old then
        common.writeDebug("No old ingredient to replace!")
      end
      if not new then
        common.writeDebug("No new ingredient!")
      end
    end

    common.entered_function("leave")
  end


  -- Modified by Pi-C
  recipe_stuff.replace_ingredient_in_all = function(old, new)
    common.entered_function({old, new})

    if new and item_stuff.get_basic_type(new) then
      for r, recipe in pairs(data.raw.recipe) do
        common.writeDebug("Recipe \"%s\": Trying to replace ingredient \"%s\" with \"%s\"",
                        {r, old and old.name or old or "nil", new and new.name or new or "nil"})
        recipe_stuff.replace_ingredient(recipe.name, old, new)
      end
    else
      common.writeDebug("%s is not a valid ingredient!", {new})
    end

    common.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  --                                 Set ingredients                                --
  ------------------------------------------------------------------------------------
  -- If the item is used in the recipe, it will be overwritten (new amount)
  -- Added by Pi-C
  recipe_stuff.set_difficulty_ingredient = function(recipe_in, difficulty, item_in)
    common.entered_function({recipe_in, difficulty, item_in})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)
    local item = item_stuff.item(item_in)

    local ret

    if recipe and item and item_stuff.get_type(item.name) then
      if difficulty == "" then
        ret = item_stuff.set(recipe.ingredients, item)
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe.name)
        end
        ret = item_stuff.set(recipe[difficulty].ingredients, item)
      end

    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
      if not item_stuff.get_basic_type(item.name) then
        common.writeDebug("%s is not a valid ingredient.", {item_in})
      end
    end

    common.entered_function("leave")
    return ret
  end

  -- Modified by Pi-C
  recipe_stuff.set_ingredient = function(recipe, item)
    common.entered_function({recipe, item})

    if recipe and item then
      recipe_stuff.set_difficulty_ingredient(recipe, "", item)
      recipe_stuff.set_difficulty_ingredient(recipe, "normal", item)
      recipe_stuff.set_difficulty_ingredient(recipe, "expensive", item)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item then
        common.writeDebug("No ingredient!")
      end
    end

    common.entered_function("leave")
  end



  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------
  --                              Functions for results                             --
  ------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------


  ------------------------------------------------------------------------------------
  --                                   Add result                                   --
  ------------------------------------------------------------------------------------
  -- Modified by Pi-C
  -- TODO: Check whether main_product must be set (#results > 1 and no subgroup)
  recipe_stuff.add_difficulty_result = function(recipe_in, difficulty, item_in)
    common.entered_function({recipe_in, difficulty, item_in})
    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)
    local item = item_stuff.item(item_in)

    local ret

    if recipe and item and item_stuff.get_type(item.name) then
      if difficulty == "" then
        recipe_stuff.result_check(recipe)
        ret = item_stuff.add(recipe.results, item)
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe)
        end
        recipe_stuff.result_check(recipe[difficulty])
        ret = item_stuff.add(recipe[difficulty].results, item)
      end
    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
      if not item_stuff.get_basic_type(item.name) then
        common.writeDebug("Item %s does not exist.", {item_in})
      end
    end

    common.entered_function("leave")
    return ret
  end


  -- Modified by Pi-C
  recipe_stuff.add_result = function(recipe, item)
    common.entered_function({recipe, item})

    if recipe and item then
      recipe_stuff.add_difficulty_result(recipe, "", item)
      recipe_stuff.add_difficulty_result(recipe, "normal", item)
      recipe_stuff.add_difficulty_result(recipe, "expensive", item)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item then
        common.writeDebug("No ingredient!")
      end
    end

    common.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  --                                 Replace results                                --
  ------------------------------------------------------------------------------------
  -- Added by Pi-C
  -- If the old item is a result, remove it and add the new item instead.
  recipe_stuff.replace_difficulty_result = function(recipe_in, difficulty, old, new)
    common.entered_function({recipe_in, difficulty, old, new})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    local old_name = (type(old) == "string") and old or
                      (type(old) == "table") and old.name or
                      error(string.format("\"%s\" is not a valid value for old result!", old))
    local new_name = (type(new) == "string") and new or
                      (type(new) == "table") and new.name or
                      error(string.format("\"%s\" is not a valid value for new result!", old))

    -- Will be "item" or "fluid"
    local new_type = item_stuff.get_basic_type(new_name)
    local old_type

    --~ local result, results, main_product, diff_results
    local result, results
    local retval = false

    if recipe and old_name and new_name then
      --~ results = BI_Functions.lib.get_difficulty_recipe_results(recipe_in, difficulty)
      results = recipe_stuff.get_difficulty_recipe_results(recipe_in, difficulty)

      -- Check whether recipe has old result
      if results and results[old_name] then

        old_type = results[old_name].type

        -- Set main_product, if necessary
        if difficulty == "" and recipe.main_product == old_name then
          recipe.main_product = new_name
        elseif difficulty ~= "" and recipe[difficulty].main_product == old_name then
          recipe[difficulty].main_product = new_name
        end

        -- Remove old result
        recipe_stuff.remove_difficulty_result(recipe, difficulty, old_name)

        -- Add new result
        result = table.deepcopy(results[old_name])
        result.name = new_name
        result.type = new_type

        -- Result "new" is just a string, use data from old result!
        if (type(new) == "string") then
          -- Switch from "fluid" to "item"
          if old_type == "fluid" and new_type == "item" then
            result.amount = result.amount and math.ceil(result.amount * 0.1)
            result.amount_min = result.amount_min and math.ceil(result.amount_min * 0.1)
            result.amount_max = result.amount_max and math.ceil(result.amount_max * 0.1)
            result.catalyst_amount = result.catalyst_amount and math.ceil(result.catalyst_amount * 0.1)

            result.temperature = nil
            result.fluidbox_index = nil

          -- Switch from "item" to "fluid"
          elseif old_type == "item" and new_type == "fluid" then
            result.amount = result.amount and math.ceil(result.amount * 10)
            result.amount_min = result.amount_min and math.ceil(result.amount_min * 10)
            result.amount_max = result.amount_max and math.ceil(result.amount_max * 10)
            result.catalyst_amount = result.catalyst_amount and math.ceil(result.catalyst_amount * 10)
          end

        -- Result "new" is an item
        else
          result.type = new_type
          result.amount = new.amount
          result.amount_min = new.amount_min
          result.amount_max = new.amount_max
          result.catalyst_amount = new.catalyst_amount
          result.probability = new.probability
          result.temperature = new.temperature
          result.fluidbox_index = new.fluidbox_index
        end

        -- Add new result!
        recipe_stuff.add_difficulty_result(recipe, difficulty, result)
        retval = true
      end
    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
      if not new_type then
        common.writeDebug("Result %s does not exist.", {new})
      end
    end

    common.entered_function("leave")
    return retval
  end


  -- Added by Pi-C
  recipe_stuff.replace_result = function(recipe, old, new)
    common.entered_function({recipe, old, new})

    recipe = type(recipe) == "table" and recipe.type == "recipe" and recipe or data.raw.recipe[recipe]

    if recipe and old and new then
      recipe_stuff.replace_difficulty_result(recipe, "", old, new)
      recipe_stuff.replace_difficulty_result(recipe, "normal", old, new)
      recipe_stuff.replace_difficulty_result(recipe, "expensive", old, new)

    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not old then
        common.writeDebug("No old result to replace!")
      end
      if not new then
        common.writeDebug("No new result!")
      end
    end

    common.entered_function("leave")
  end


  -- Added by Pi-C
  recipe_stuff.replace_result_in_all = function(old, new)
    common.entered_function({old, new})

    --~ if new and item_stuff.get_basic_type(new) then
    if old and new and item_stuff.get_basic_type(new) then
      for i, recipe in pairs(data.raw.recipe) do
        recipe_stuff.replace_result(recipe, old, new)
      end
    else
      common.writeDebug("%s is not a valid result!", {new})
    end

    common.entered_function("leave")
  end



  ------------------------------------------------------------------------------------
  --                                  Remove result                                 --
  ------------------------------------------------------------------------------------
  -- Modified by Pi-C
  -- TODO: Check whether a new main_product is needed!
  recipe_stuff.remove_difficulty_result = function(recipe_in, difficulty, item_name)
    common.entered_function({recipe_in, difficulty, item_name})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    local ret

    if recipe and item_name then
      if difficulty == "" then
        recipe_stuff.result_check(recipe)
        ret = item_stuff.remove(recipe.results, item_name)
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe)
        end
        recipe_stuff.result_check(recipe[difficulty])
        ret = item_stuff.remove(recipe[difficulty].results, item_name)
      end
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item_name then
        common.writeDebug("No item name!")
      end
    end

    common.entered_function("leave")
    return ret
  end

  -- Modified by Pi-C
  recipe_stuff.remove_result = function(recipe, item)
    common.entered_function({recipe, item})

    if recipe and item then
      recipe_stuff.remove_difficulty_result(recipe, "", item)
      recipe_stuff.remove_difficulty_result(recipe, "normal", item)
      recipe_stuff.remove_difficulty_result(recipe, "expensive", item)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item then
        common.writeDebug("No item!")
      end
    end

    common.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  --                                   Set result                                   --
  ------------------------------------------------------------------------------------
  -- If the item is used in the recipe, it will be overwritten (new amount)
  -- Added by Pi-C
  recipe_stuff.set_difficulty_result = function(recipe_in, difficulty, item_in)
    common.entered_function({recipe_in, difficulty, item_in})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)
    local item = item_stuff.item(item_in)

    local ret

    if recipe and item and item_stuff.get_type(item.name) then
      if difficulty == "" then
        recipe_stuff.result_check(recipe)
        ret = item_stuff.set(recipe.results, item)
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe.name)
        end
        recipe_stuff.result_check(recipe[difficulty])
        ret = item_stuff.set(recipe[difficulty].results, item)
      end

    else
      if not recipe then
        common.writeDebug("Recipe %s does not exist.", {recipe_in})
      end
      if not item_stuff.get_basic_type(item.name) then
        common.writeDebug("%s is not a valid result.", {item_in})
      end
    end

    common.entered_function("leave")
    return ret
  end


  -- Modified by Pi-C
  recipe_stuff.set_result = function(recipe, item)
    common.entered_function({recipe, item})

    if recipe and item then
      recipe_stuff.set_difficulty_result(recipe, "", item)
      recipe_stuff.set_difficulty_result(recipe, "normal", item)
      recipe_stuff.set_difficulty_result(recipe, "expensive", item)
    else
      if not recipe then
        common.writeDebug("No recipe!")
      end
      if not item then
        common.writeDebug("No item!")
      end
    end

    common.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  --                                   Get result                                   --
  ------------------------------------------------------------------------------------
  -- Returns table with all results for a difficulty, or nil
  recipe_stuff.get_difficulty_recipe_results = function(recipe_in, difficulty)
    common.entered_function({recipe_in, difficulty})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    local ret = {}

    if recipe then
      --~ local name, amount, amount_min, amount_max, catalyst_amount, probability
      local name, amount, amount_min, amount_max
      local results, crafting_time

      -- Get results for difficulty
      if difficulty == "" then
        recipe_stuff.result_check(recipe)
        results = recipe.results
        crafting_time = recipe.energy_required or 0.5
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe)
        end
        recipe_stuff.result_check(recipe[difficulty])
        results = recipe[difficulty].results
        crafting_time = recipe[difficulty].energy_required or 0.5
      end

      -- Cumulate results in case the same result is used several times
      for r, result in ipairs(results) do
        name = result[1] or result.name
        amount = result[2] or result.amount

        if name then
          ret[name] = ret[name] or {
            name                          = name,
            type                          = result.type or "item",
            amount                        = 0,
            amount_min                    = 0,
            amount_max                    = 0,
            catalyst_amount               = 0,
            probability                   = 0,

            -- We'll need this to calculate average values
            cnt                   = 0,
            min_max_cnt           = 0
          }

          -- amount has precedence over amount_min/amount_max!
          if amount and amount > 0 then
            ret[name].amount                = ret[name].amount + amount
          -- amount_max must be >= amount_min!
          else
            amount_min = result.amount_min
            amount_max = result.amount_max

            if amount_min or amount_max then
              ret[name].min_max_cnt = ret[name].min_max_cnt + 1

              if (not amount_max or amount_max < amount_min) then
                amount_max =  amount_min
              elseif not amount_min then
                amount_min = amount_max
              end
  common.writeDebug("Result: %s\nname: %s\tamount: %s\tamount_min: %s\tamount_max: %s",
                    {result, name, amount or "nil", amount_min or "nil", amount_max or "nil"})

              ret[name].amount_min      = amount_min and (ret[name].amount_min + amount_min) or
                                                          ret[name].amount_min
              ret[name].amount_max      = amount_max and ret[name].amount_max + amount_max or
                                                          ret[name].amount_max
            end
          end
          ret[name].catalyst_amount   = ret[name].catalyst_amount + (tonumber(result.catalyst_amount) or 0)
          ret[name].probability       = ret[name].probability + (tonumber(result.probability) or 1)

          -- We only need this if it differs from the default value
          if result.show_details_in_recipe_tooltip == false then
            ret[name].show_details_in_recipe_tooltip = false
          end

          ret[name].cnt               = ret[name].cnt + 1
        end
      end

      -- Prepare the final list
      for r, result in pairs(ret) do

        -- Multiplication is faster than division!
        result.cnt = result.cnt > 0 and 1/result.cnt or 1
        result.min_max_cnt = result.min_max_cnt > 0 and 1/result.min_max_cnt

        result.amount             = tonumber(result.amount) and (result.amount > 0) and
                                      result.amount or nil
        -- Round up to next full number for values with x > y.5
        -- (Either both or none of amount_min and amount_max exist!)
        result.amount_min         = result.min_max_cnt and
                                      math.floor(0.5 + (result.amount_min * result.min_max_cnt)) or
                                      nil
        result.amount_max         = result.min_max_cnt and
                                      math.floor(0.5 + (result.amount_max * result.min_max_cnt)) or
                                      nil

        result.catalyst_amount    = result.catalyst_amount > 0 and
                                      math.floor(0.5 + (result.catalyst_amount * result.cnt)) or nil
        result.probability        = result.probability > 0 and result.probability ~= 1 and
                                      math.floor(0.5 + (result.probability * result.cnt)) or nil

        result.min_max_cnt = nil
        result.cnt = nil

        result.amount_per_sec = result.amount and (result.amount / crafting_time) or
                                ((result.amount_min or 0) + (result.amount_max or 0)) * 0.5 / crafting_time
      end
    end
common.show("ret", ret)

    common.entered_function("leave")
    return ret
  end


  -- Returns table with all results for "normal", "expensive", or no difficulty
  -- (in that order) or nil
  recipe_stuff.get_recipe_results = function(recipe_in)
    common.entered_function({recipe_in})

    local recipe = check_recipe(recipe_in)

    local ret
    common.writeDebug("Get results for recipe %s",
                      {recipe and recipe.name or "nil"})
    if recipe then
      -- If difficulty doesn't exist, it will be created from the raw recipe, so we don't
      -- need to check recipe.results!
      ret = recipe_stuff.get_difficulty_recipe_results(recipe, "normal") or
            recipe_stuff.get_difficulty_recipe_results(recipe, "expensive")
    end

    common.entered_function("leave")
    return ret
  end


  ------------------------------------------------------------------------------------
  --                        Check whether recipe has a result                       --
  ------------------------------------------------------------------------------------
  -- Returns table with accumulated amount data for requested result or nil
  recipe_stuff.recipe_has_difficulty_result = function(recipe_in, difficulty, result_name)
    common.entered_function({recipe_in, difficulty, result_name})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    if type(result_name) ~= "string" then
      error(string.format("%s is not a valid result name!", result_name))
    end

    local ret

    if recipe then
      ret = recipe_stuff.get_difficulty_recipe_results(recipe, difficulty)
    end

    common.entered_function("leave")
    return ret and ret[result_name]
  end


  -- Returns table with accumulated amount data for requested result or nil
  recipe_stuff.recipe_has_result = function(recipe_in, result_name)
    common.entered_function({recipe_in, result_name})

    local recipe = check_recipe(recipe_in)

    if type(result_name) ~= "string" then
      error(string.format("%s is not a valid result name!", result_name))
    end

    local ret

    if recipe then
      ret = recipe_stuff.get_recipe_results(recipe)
    end

    common.entered_function("leave")
    return ret and ret[result_name]
  end


  ------------------------------------------------------------------------------------
  --                                 Get ingredients                                --
  ------------------------------------------------------------------------------------
  recipe_stuff.get_difficulty_recipe_ingredients = function(recipe_in, difficulty)
    common.entered_function({recipe_in, difficulty})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)

    local ret = {}
    local ingredients

    if recipe then
      if difficulty == "" then
        ingredients = recipe.ingredients
      else
        if not recipe[difficulty] then
          recipe_stuff.difficulty_split(recipe)
        end
        ingredients = recipe[difficulty].ingredients
      end

      local name, amount, t_min, t_max
      for i, ingredient in ipairs(ingredients or common.EMPTY_TAB) do

        name = ingredient.name or ingredient[1]
        amount = ingredient.amount or ingredient[2]
        if not (name and amount) then
          error(string.format("%s is not a valid recipe ingredient specification!",
                                serpent.line(ingredient)))
        end

        ret[name] = ret[name] or {
          name = name,
          type = ingredient.type or "item",
          amount = 0,
          catalyst_amount = 0,
          temperature = (ingredient.type == "fluid") and 0 or nil,
          minimum_temperature = (ingredient.type == "fluid") and 0 or nil,
          maximum_temperature = (ingredient.type == "fluid") and 0 or nil,
          cnt = 0,
          min_max_cnt = 0,
        }
        ret[name].amount = ret[name].amount + amount
        ret[name].catalyst_amount = ret[name].catalyst_amount + (ingredient.catalyst_amount or 0)
        ret[name].cnt = ret[name].cnt + 1

        -- Only for fluids!
        if ingredient.type == "fluid" then
          -- temperature will overwrite minimum_temperature/maximum_temperature
          if ingredient.temperature then
            ret[name].temperature = ret[name].temperature + ingredient.temperature

          -- No minimum temperature without maximum temperature (and vice versa)!
          elseif ingredient.minimum_temperature or ingredient.maximum_temperature then
            t_min = ingredient.minimum_temperature or ingredient.maximum_temperature
            t_max = ingredient.maximum_temperature or ingredient.minimum_temperature

            if t_min then
             if (t_max <= t_min) then
              ret[name].temperature = ret[name].temperature + t_min
              else
                ret[name].minimum_temperature = ret[name].minimum_temperature + t_min
                ret[name].maximum_temperature = ret[name].maximum_temperature + t_max
                ret[name].min_max_cnt = ret[name].min_max_cnt + 1
              end
            end
          end
          -- Use the first fluidbox_index we find!
          ret[name].fluidbox_index = ret[name].fluidbox_index or ingredient.fluidbox_index
        end
      end

      -- Prepare the final list
      for i_name, i_data in pairs(ret) do
        -- We only need to do this if there are any temperatures!
        if i_data.temperature or i_data.minimum_temperature then

          if (i_data.cnt > 0) then
            -- Average temperature
            i_data.temperature = i_data.temperature and i_data.temperature / i_data.cnt

            -- Only necessary if there are minimum/maximum temperatures
            if i_data.min_max_cnt > 0 then

              -- Average minimum/maximum temperatures
              i_data.min_max_cnt = (i_data.min_max_cnt > 0) and (1/i_data.min_max_cnt) or 1

              i_data.minimum_temperature = i_data.minimum_temperature * i_data.min_max_count
              i_data.maximum_temperature = i_data.maximum_temperature * i_data.min_max_count

              -- No temperature yet, keep minumum/maximum temperature?
              if not i_data.temperature then
                if i_data.maximum_temperature <= i_data.minimum_temperature then

                  i_data.temperature = i_data.minimum_temperature
                  i_data.minimum_temperature = nil
                  i_data.maximum_temperature = nil
                end
              -- Temperature already exists, add average of minimum/maximum temperature!
              elseif i_data.minimum_temperature then
                -- Account for unreasonable values
                if i_data.minimum_temperature and i_data.maximum_temperature and
                    i_data.maximum_temperature <= i_data.minimum_temperature then
                  i_data.temperature = i_data.temperature + i_data.minimum_temperature
                -- Add average
                else
                  i_data.temperature = (i_data.minimum_temperature + i_data.maximum_temperature) * 0.5
                end
                i_data.minimum_temperature = nil
                i_data.maximum_temperature = nil
              end
            end
          end
        end

        -- Remove counters
        i_data.cnt = nil
        i_data.min_max_cnt = nil
      end
    end
common.show("ret", ret)

  --~ common.entered_function("leave")
    return next(ret) and ret
  end


  recipe_stuff.get_recipe_ingredients = function(recipe_in)
    common.entered_function({recipe_in})

    local recipe = check_recipe(recipe_in)

    local ret
    if recipe then
      -- If difficulty doesn't exist, it will be created from the raw recipe, so we don't
      -- need to check recipe.ingredients!
      ret = recipe_stuff.get_difficulty_recipe_ingredients(recipe, "normal") or
            recipe_stuff.get_difficulty_recipe_ingredients(recipe, "expensive")
    end

    --~ common.entered_function("leave")
    return ret
  end


  ------------------------------------------------------------------------------------
  --               Check whether recipe is using a certain ingredient               --
  ------------------------------------------------------------------------------------
  recipe_stuff.recipe_has_difficulty_ingredient = function(recipe_in, difficulty, ingredient)
    common.entered_function({recipe_in, difficulty, ingredient})

    -- Sanitize arguments
    check_difficulty(difficulty)
    local recipe = check_recipe(recipe_in)
    if type(ingredient) ~= "string" then
      error(string.format("%s is not a valid ingredient name!", ingredient))
    end

    local ret, ingredients
    if recipe then
      ingredients = recipe_stuff.get_difficulty_recipe_ingredients(recipe_in, difficulty)
      ret = ingredients and ingredients[ingredient]
    end

    common.entered_function("leave")
    return ret
  end


  recipe_stuff.recipe_has_ingredient = function(recipe_in, ingredient)
    common.entered_function({recipe_in, ingredient})

    local recipe = check_recipe(recipe_in)

    if type(ingredient) ~= "string" then
      error(string.format("%s is not a valid ingredient name!", ingredient))
    end

    local ret, ingredients

    if recipe then
      ingredients = recipe_stuff.get_recipe_ingredients(recipe.ingredients)
      ret = ingredients and ingredients[ingredient]
    end
  --~ common.show("Return", ret)

    common.entered_function("leave")
    return ret
  end


  ------------------------------------------------------------------------------------
  --                    Convert recipe.result to recipe.results!                    --
  ------------------------------------------------------------------------------------
  recipe_stuff.result_check = function(object)
    common.entered_function({object})

    if object then
      object.results = object.results or {}

      if object.result then
        local item = item_stuff.basic_item({name = object.result})

        if object.result_count then
          item.amount = object.result_count
          object.result_count = nil
        end

        item_stuff.add_new(object.results, item)

        if object.ingredients then  -- It's a recipe
          if not object.main_product then
            -- If we already have one, add the rest
            if object.icon or object.subgroup or object.order or item.type ~= "item" then
              if (not object.icon) and data.raw[item.type][item.name] and
                                        data.raw[item.type][item.name].icon then
                object.icon = data.raw[item.type][item.name].icon
                object.icon_size = data.raw[item.type][item.name].icon_size

              -- Make sure objects also have an icons definition
              elseif not object.icons and data.raw[item.type][item.name] and
                                            data.raw[item.type][item.name].icons and
                                            -- Don't assume that an icon already exists,
                                            -- it could be set later on!
                                            data.raw[item.type][item.name].icon then
                object.icons = {
                  {
                    icon = data.raw[item.type][item.name].icon,
                    icon_size = 64,
                    --~ icon_mipmaps = data.raw[item.type][item.name].icon_mipmaps
                  }
                }
              end
              if not object.subgroup and data.raw[item.type][item.name] and
                                          data.raw[item.type][item.name].subgroup then
                object.subgroup = data.raw[item.type][item.name].subgroup
              end
              if not object.order and data.raw[item.type][item.name] and
                                        data.raw[item.type][item.name].order then
                object.order = data.raw[item.type][item.name].order
              end

              if data.raw[item.type][item.name] and
                  data.raw[item.type][item.name].main_product then
                object.main_product = data.raw[item.type][item.name].main_product
              end

            -- Otherwise just use main_product as a cheap way to set them all.
            else
              object.main_product = object.result
            end
          end
        end
        object.result = nil
      end

    else
      common.writeDebug("%s does not exist.", {object})
    end

    common.entered_function("leave")
  end


  ------------------------------------------------------------------------------------
  PClib_log("Leaving file "..debug.getinfo(1).source)
  return recipe_stuff
end
