PClib_log("Entered file " .. debug.getinfo(1).source)

return function(mod_args)
  local common = _ENV[mod_args.mod_shortname]

  --~ common.entered_file()

  --~ AD_lib.item = AD_lib.item or {}
  local item_stuff = {}

  --~ local item_types = {
    --~ "ammo",
    --~ "armor",
    --~ "capsule",
    --~ "fluid",
    --~ "gun",
    --~ "item",
    --~ "mining-tool",
    --~ "module",
    --~ "tool",
    --~ "item-with-entity-data"
  --~ }
  local item_types = defines.prototypes.item
common.show("item_types", item_types)

  -- We add '[item_name] = item_type' whenever we've checked an item!
  local types_by_item = {}
  local fluids = {}

  -- Get item name from string or table in data.raw[type] or LuaItemPrototype
  local function get_name(name_or_item)
    common.entered_function({name_or_item})
    local t = type(name_or_item)
    -- As of Factorio 2.0, type of LuaObjects will be "userdata"!
    local name
    if (t == "string") then
      name = name_or_item
    elseif (data and t == "table") or (t == "userdata" and name_or_item.valid) then
      name = name_or_item.name
    end
    return name
  end


  item_stuff.get_type = function(name_or_item)
    common.entered_function({name_or_item})

    local name = get_name(name_or_item)
    local item_type

    if types_by_item[name] then
      item_type = types_by_item[name]
    else
      if data then
        for t, type_name in pairs(item_types) do
          if data.raw[type_name][name] then
            item_type = type_name
            break
          end
        end
      elseif game then
        item_type = game.item_prototypes[name] and game.item_prototypes[name].type
      end
      types_by_item[name] = item_type
    end

    common.entered_function("leave")
    return item_type
  end


  item_stuff.get_basic_type = function(name_or_item)
    common.entered_function({name_or_item})

    local name = get_name(name_or_item)
    local basic_type
    if types_by_item[name] then
      basic_type = "item"
    elseif fluids[name] then
      basic_type = "fluid"
    else
      if (data and data.raw.fluid[name]) or
          (game and game.fluid_prototypes[name]) then
        fluids[name] = true
        basic_type = "fluid"
      end
    end

    --~ return data.raw.fluid[name] and "fluid" or "item"
    common.entered_function("leave")
    return basic_type
  end


  -- Returns basic item/fluid (name, amount, type)
  item_stuff.basic_item = function(inputs)
    common.entered_function({inputs})

    common.assert(inputs, "table", "table with fields 'name' and 'amount'")
    local item = {
      name = inputs.name or inputs[1],
      amount = inputs.amount or inputs[2],
    }

    if not item.amount then
      -- Only for results!
      if inputs.amount_min or inputs.amount_max then
        if inputs.amount_min and inputs.amount_max then
          item.amount = math.floor(0.5 + (inputs.amount_min + inputs.amount_max) / 2)
        else
          item.amount = inputs.amount_min or inputs.amount_max
        end
      -- Ingredients don't have amount_min/amount_max!
      else
        item.amount = 1
      end
    end

    item.type = inputs.type or item_stuff.get_basic_type(item.name)

    -- Amount of "item" must be an integer because there can be no fractional
    -- items in the player's inventory!
    if item.type == "item" then
      if item.amount > 0 and item.amount < 1 then
        item.amount = 1
      else
        item.amount = math.floor(item.amount)
      end
    end

    common.entered_function("leave")
    return item
  end


  item_stuff.item = function(inputs)
    common.entered_function({inputs})

    common.assert(inputs, table, "table with item/fluid data")


    local item = {
      name = inputs.name or inputs[1],
      amount = inputs.amount or inputs[2],
    }
    item.type = inputs.type or item_stuff.get_basic_type(item.name)

    -- Only for results, and only if named keys are used!
    if inputs.name and (not item.amount) then
      item.amount_min = inputs.amount_min or inputs.amount_max
      item.amount_max = inputs.amount_max or inputs.amount_min

      -- Only keep amount_min/amount_max if they have reasonable values!
      if item.amount_min and (item.amount_max <= item.amount_min) then
        item.amount = item.amount_min
        item.amount_min, item.amount_max = nil, nil
      end
    end

    -- Results and ingredients:
    item.catalyst_amount = inputs.catalyst_amount

    -- Results:
    item.probability = inputs.probability
    item.show_details_in_recipe_tooltip = inputs.show_details_in_recipe_tooltip

    -- Fluids only!
    if item.type == "fluid" then
      -- Results and ingredients:
      item.temperature = inputs.temperature
      item.fluidbox_index = inputs.fluidbox_index

      -- Ingredients:
      if not item.temperature and
          (inputs.minimum_temperature or inputs.maximum_temperature) then

        -- These will always be nil for results!
        item.minimum_temperature = inputs.minimum_temperature or inputs.maximum_temperature
        item.maximum_temperature = inputs.maximum_temperature or inputs.minimum_temperature

        -- Use temperature if minimum/maximum temperature set no reasonable range!
        if item.minimum_temperature and item.maximum_temperature and
            item.maximum_temperature <= item.minimum_temperature then

          item.temperature = item.minimum_temperature
          item.minimum_temperature, item.maximum_temperature = nil, nil
        end
      end
    end

    -- Custom BI-property needed for calculating fuel_values
    item.amount_per_sec = inputs.amount_per_sec

    common.entered_function("leave")
    return item
  end


  item_stuff.combine = function(item1_in, item2_in)
    common.entered_function({item1_in, item2_in})
    local item = {}
    local item1 = item_stuff.item(item1_in)
    local item2 = item_stuff.item(item2_in)

    item.name = item1.name
    item.type = item1.type

    if item1.amount and item2.amount then
      item.amount = item1.amount + item2.amount
    elseif item1.amount_min and item1.amount_max and item2.amount_min and item2.amount_max then
      item.amount_min = item1.amount_min + item2.amount_min
      item.amount_max = item1.amount_max + item2.amount_max
    else
      if item1.amount_min and item1.amount_max and item2.amount then
        item.amount_min = item1.amount_min + item2.amount
        item.amount_max = item1.amount_max + item2.amount
      elseif item1.amount and item2.amount_min and item2.amount_max then
        item.amount_min = item1.amount + item2.amount_min
        item.amount_max = item1.amount + item2.amount_max
      end
    end

    if item1.probability and item2.probability then
      item.probability = (item1.probability + item2.probability) / 2
    elseif item1.probability then
      item.probability = (item1.probability + 1) / 2
    elseif item2.probability then
      item.probability = (item2.probability + 1) / 2
    end

    common.entered_function("leave")
    return item
  end


  -- Modified by Pi-C
  item_stuff.add = function(list, item_in) --increments amount if exists
    common.entered_function({list, item_in})
    local item = item_stuff.item(item_in)

    local addit = true
    for o, object in pairs(list or common.EMPTY_TAB) do
      if object[1] == item.name or object.name == item.name then
        addit = false
        list[o] = item_stuff.combine(object, item)
      end
    end
    if addit then
      table.insert(list, item)
    end

    common.entered_function("leave")
    return addit
  end

  -- Modified by Pi-C
  item_stuff.add_new = function(list, item_in) --ignores if exists
    common.entered_function({list, item_in})

    local item = item_stuff.item(item_in)
    local addit = true
    for o, object in pairs(list or common.EMPTY_TAB) do
      if item.name == item_stuff.basic_item(object).name then
        addit = false
        break
      end
    end
    if addit then
      table.insert(list, item)
    end

    common.entered_function("leave")
    return addit
  end

  -- Modified by Pi-C
  --~ item_stuff.remove = function(list, item)
    --~ common.entered_function({list, item})

    --~ local name = type(item) == "string" and item or
                  --~ type(item) == "table" and item.name or
                  --~ error(string.format("\"%s\" is not a valid item or item name!", item))
    --~ local removed_it = false
    --~ local run_again
    --~ -- Removing an element from a list in a for-loop may lead to wrong results!
    --~ repeat
      --~ run_again = false
      --~ for i, object in ipairs(list or AD.EMPTY_TAB) do
        --~ if object[1] == name or object.name == name then
          --~ table.remove(list, i)
          --~ removed_it = true
          --~ run_again = true
          --~ break
        --~ end
      --~ end
    --~ until not run_again

    --~ return removed_it
  --~ end
  item_stuff.remove = function(list, name_or_item)
    common.entered_function({list, name_or_item})

    local name = get_name(name_or_item)
    local removed_it = false
    --~ local run_again

    -- Removing an element from a list in a for-loop may lead to wrong results!
    if list and next(list) then
      for i = #list, 1, -1 do
        if list[i][1] == name or list[i].name == name then
          table.remove(list, i)
          removed_it = true
          break
        end
      end
    end

    common.entered_function("leave")
    return removed_it
  end


  -- Modified by Pi-C
  item_stuff.set = function(list, item_in)
    common.entered_function({list, item_in})

    local item = item_stuff.item(item_in)
    local set_it = false

    for o, object in pairs(list or common.EMPTY_TAB) do
      if object[1] == item.name or object.name == item.name then
        list[o] = item
        set_it = true
        break
      end
    end

    return set_it
  end


  ------------------------------------------------------------------------------------
  PClib_log("Leaving file "..debug.getinfo(1).source)
  return item_stuff
end
