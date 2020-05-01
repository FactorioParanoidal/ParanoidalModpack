if not bobmods.lib.tech then bobmods.lib.tech = {} end


function bobmods.lib.tech.replace_science_pack(technology, old, new)
  if
    type(technology) == "string" and
    type(old) == "string" and
    type(new) == "string" and
    data.raw.technology[technology] and
--    data.raw.tool[old] and
    data.raw.tool[new]
  then
    local doit = false
    local amount = 0
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == old then
        doit = true
        amount = ingredient[2] + amount
      end
      if ingredient.name == old then
        doit = true
        amount = ingredient.amount + amount
      end
    end
    if doit then
      bobmods.lib.tech.remove_science_pack(technology, old)
      bobmods.lib.tech.add_science_pack(technology, new, amount)
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.item_of_type(old, "tool", "Old science pack")
    bobmods.lib.error.item_of_type(new, "tool", "New science pack")
  end
end

function bobmods.lib.tech.add_new_science_pack(technology, pack, amount)
  if
    type(technology) == "string" and
    type(pack) == "string" and
    type(amount) == "number" and
    data.raw.technology[technology] and
    data.raw.tool[pack]
  then
    local addit = true
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == pack or ingredient.name == pack then addit = false end
    end
    if addit then table.insert(data.raw.technology[technology].unit.ingredients,{pack, amount}) end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.item_of_type(pack, "tool", "Science pack")
  end
end

function bobmods.lib.tech.add_science_pack(technology, pack, amount)
  if
    type(technology) == "string" and
    type(pack) == "string" and
    type(amount) == "number" and
    data.raw.technology[technology] and
    data.raw.tool[pack]
  then
    local addit = true
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == pack then
        addit = false
        ingredient[2] = ingredient[2] + amount
      end
      if ingredient.name == pack then
        addit = false
        ingredient.amount = ingredient.amount + amount
      end
    end
    if addit then table.insert(data.raw.technology[technology].unit.ingredients,{pack, amount}) end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.item_of_type(pack, "tool", "Science pack")
  end
end

function bobmods.lib.tech.remove_science_pack(technology, pack)
  if
    type(technology) == "string" and
    type(pack) == "string" and
    data.raw.technology[technology]
  then
    local done_it = false
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == pack or ingredient.name == pack then
        table.remove(data.raw.technology[technology].unit.ingredients, i)
        done_it = true
      end
    end
    if not done_it then
--      log("Technology " .. technology .. " does not have a Science pack " .. pack .. " to remove")
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
  end
end


function bobmods.lib.tech.add_recipe_unlock(technology, recipe)
  if
    type(technology) == "string" and
    type(recipe) == "string" and
    data.raw.technology[technology] and
    data.raw.recipe[recipe]
  then
    local addit = true
    if not data.raw.technology[technology].effects then
      data.raw.technology[technology].effects = {}
    end
    for i, effect in pairs(data.raw.technology[technology].effects) do
      if effect.type == "unlock-recipe" and effect.recipe == recipe then addit = false end
    end
    if addit then table.insert(data.raw.technology[technology].effects,{type = "unlock-recipe", recipe = recipe}) end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.recipe(recipe)
  end
end

function bobmods.lib.tech.remove_recipe_unlock(technology, recipe)
  if
    type(technology) == "string" and
    type(recipe) == "string" and
    data.raw.technology[technology]
--    data.raw.recipe[recipe] --don't check to see if something we're removing exists.
  then
    local done_it = false
    if data.raw.technology[technology].effects then
      for i, effect in pairs(data.raw.technology[technology].effects) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe then
          table.remove(data.raw.technology[technology].effects,i)
          done_it = true
        end
      end
    end
    if not done_it then
--      log("Technology " .. technology .. " does not have a Recipe unlock of " .. recipe .. " to remove")
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.recipe(recipe)
  end
end


function bobmods.lib.tech.has_prerequisite(technology, prerequisite)
  if
    type(technology) == "string" and
    type(prerequisite) == "string" and
    data.raw.technology[technology] and
    data.raw.technology[prerequisite]
  then
    if data.raw.technology[technology].prerequisites then
      for i, check in pairs(data.raw.technology[technology].prerequisites) do
        if check == prerequisite then
          return true
        end
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
  end
  return false
end

function bobmods.lib.tech.get_prerequisites(technology)
  local prerequisites = {}
  if
    type(technology) == "string" and
    data.raw.technology[technology]
  then
    for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
      table.insert(prerequisites, prerequisite)
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
  end
  return prerequisites
end

function bobmods.lib.tech.replace_prerequisite(technology, old, new)
  if
    type(technology) == "string" and
    type(old) == "string" and
    type(new) == "string" and
    data.raw.technology[technology] and
--    data.raw.technology[old] and
    data.raw.technology[new]
  then
    for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
      if prerequisite == old then 
        bobmods.lib.tech.remove_prerequisite(technology, old)
        bobmods.lib.tech.add_prerequisite(technology, new)
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.technology(old, "Old prerequisite", "Old prerequisite technology")
    bobmods.lib.error.technology(new, "New prerequisite", "New prerequisite technology")
  end
end

function bobmods.lib.tech.add_prerequisite(technology, prerequisite)
  if
    type(technology) == "string" and
    type(prerequisite) == "string" and
    data.raw.technology[technology] and
    data.raw.technology[prerequisite]
  then
    local addit = true
    if data.raw.technology[technology].prerequisites then
      for i, check in ipairs(data.raw.technology[technology].prerequisites) do
        if check == prerequisite then addit = false end
      end
    else
      data.raw.technology[technology].prerequisites = {}
    end
    if addit then table.insert(data.raw.technology[technology].prerequisites, prerequisite) end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
  end
end

function bobmods.lib.tech.remove_prerequisite(technology, prerequisite)
  if
    type(technology) == "string" and
    type(prerequisite) == "string" and
    data.raw.technology[technology]
--    data.raw.technology[prerequisite]
  then
    local done_it = false
    for i, check in ipairs(data.raw.technology[technology].prerequisites) do
      if check == prerequisite then
        table.remove(data.raw.technology[technology].prerequisites, i)
        done_it = true
      end
    end
    if not done_it then
--      log("Technology " .. technology .. " does not have Prerequisite " .. prerequisite .. " to remove")
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
  end
end

function bobmods.lib.tech.get_prerequisites_in_tree(technology)
  local prerequisites = {}
  if
    type(technology) == "string" and
    data.raw.technology[technology]
  then
    local temp = {}
    if data.raw.technology[technology].prerequisites then
      for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
        if type(prerequisite) == "string" and data.raw.technology[prerequisite] then
          temp[prerequisite] = true
          if data.raw.technology[prerequisite].prerequisites then
            for j, prerequisite_in_tree in ipairs(bobmods.lib.tech.get_prerequisites_in_tree(prerequisite)) do
              temp[prerequisite_in_tree] = true
            end
          end
        else
          log(technology .. " has an invalid prerequisite.")
          bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
        end
      end
    end
    for prerequisite,_ in pairs(temp) do
      table.insert(prerequisites, prerequisite)
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
  end
  return prerequisites
end

function bobmods.lib.tech.has_prerequisite_in_tree(technology, prerequisite)
  if
    type(technology) == "string" and
    type(prerequisite) == "string" and
    data.raw.technology[technology] and
    data.raw.technology[prerequisite]
  then
    if data.raw.technology[technology].prerequisites then
      for i, check in pairs(data.raw.technology[technology].prerequisites) do
        if
          check == prerequisite or
          bobmods.lib.tech.has_prerequisite_in_tree(check, prerequisite)
        then
          return true
        end
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
  end
  return false
end

function bobmods.lib.tech.has_prerequisite_in_tree_only(technology, prerequisite)
  if
    type(technology) == "string" and
    type(prerequisite) == "string" and
    data.raw.technology[technology] and
    data.raw.technology[prerequisite]
  then
    if data.raw.technology[technology].prerequisites then
      for i, check in ipairs(data.raw.technology[technology].prerequisites) do
        if check ~= prerequisite and bobmods.lib.tech.has_prerequisite_in_tree(check, prerequisite) then
          return true
        end
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
  end
  return false
end

function bobmods.lib.tech.get_redundant_prerequisites(technology)
  local redundant = {}
  if
    type(technology) == "string" and
    data.raw.technology[technology]
  then
    if data.raw.technology[technology].prerequisites then
      for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
        if bobmods.lib.tech.has_prerequisite_in_tree_only(technology, prerequisite) then
          table.insert(redundant, prerequisite)
        end
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
  end
  return redundant
end

function bobmods.lib.tech.get_redundant_prerequisites_smart(technology)
  local redundant = {}
  if
    type(technology) == "string" and
    data.raw.technology[technology]
  then
    if data.raw.technology[technology].prerequisites then
      local technology_trunc = string.gsub(technology, "%A", "")
      for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
        local prerequisite_trunc = string.gsub(prerequisite, "%A", "")
        if
          technology_trunc ~= prerequisite_trunc and
          bobmods.lib.tech.has_prerequisite_in_tree_only(technology, prerequisite)
        then
          table.insert(redundant, prerequisite)
        end
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
  end
  return redundant
end



local prerequisites_cache = {}
--Cache holds prerequisites as tags instead of keys for faster sorting and checking.

local function get_prerequisites_in_tree_cached(technology)
  if
    type(technology) == "string" and
    data.raw.technology[technology]
  then
    if not prerequisites_cache[technology] then
      prerequisites_cache[technology] = {}
      if data.raw.technology[technology].prerequisites then
        for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
          if type(prerequisite) == "string" and data.raw.technology[prerequisite] then
            prerequisites_cache[technology][prerequisite] = true
            if data.raw.technology[prerequisite].prerequisites then
              for prerequisite_in_tree,_ in pairs(get_prerequisites_in_tree_cached(prerequisite)) do
                prerequisites_cache[technology][prerequisite_in_tree] = true
              end
            end
          else
            log(technology .. " has an invalid prerequisite.")
            bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
          end
        end
      end
    end
    return prerequisites_cache[technology]
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    return {}
  end
end

local function has_prerequisite_in_tree_only_cached(technology, prerequisite)
  if
    type(technology) == "string" and
    type(prerequisite) == "string" and
    data.raw.technology[technology] and
    data.raw.technology[prerequisite]
  then
    if data.raw.technology[technology].prerequisites then
      for i, check in ipairs(data.raw.technology[technology].prerequisites) do
        if check ~= prerequisite and get_prerequisites_in_tree_cached(check)[prerequisite] then
          return true
        end
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
    bobmods.lib.error.technology(prerequisite, "Prerequisite", "Prerequisite technology")
  end
  return false
end

local function get_redundant_prerequisites_smart_cached(technology)
  local redundant = {}
  if
    type(technology) == "string" and
    data.raw.technology[technology]
  then
    if data.raw.technology[technology].prerequisites then
      local technology_trunc = string.gsub(technology, "%A", "")
      for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
        local prerequisite_trunc = string.gsub(prerequisite, "%A", "")
        if
          technology_trunc ~= prerequisite_trunc and
          has_prerequisite_in_tree_only_cached(technology, prerequisite)
        then
          table.insert(redundant, prerequisite)
        end
      end
    end
  else
    log(debug.traceback())
    bobmods.lib.error.technology(technology)
  end
  return redundant
end



function bobmods.lib.tech.prerequisite_cleanup()
  log("Running technology prerequisite cleanup...")
  for technology_name, technology in pairs(data.raw.technology) do
    for i, prerequisite in pairs(get_redundant_prerequisites_smart_cached(technology_name)) do
      bobmods.lib.tech.remove_prerequisite(technology_name, prerequisite)
--      log("removed " .. prerequisite .. " from " .. technology_name)
    end
  end
end
