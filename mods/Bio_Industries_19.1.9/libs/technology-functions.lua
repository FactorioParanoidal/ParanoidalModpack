local BioInd = require('common')('Bio_Industries')

if not thxbob.lib.tech then thxbob.lib.tech = {} end


function thxbob.lib.tech.replace_science_pack(technology, old, new)
  if data.raw.technology[technology] and data.raw.tool[new] then
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
      thxbob.lib.tech.remove_science_pack(technology, old)
      thxbob.lib.tech.add_science_pack(technology, new, amount)
    end
  else
    if not data.raw.technology[technology] then
      BioInd.writeDebug("Technology %s does not exist.", {technology})
    end
    if not data.raw.tool[new] then
      BioInd.writeDebug("Science pack %s does not exist.", {new})
    end
  end
end

function thxbob.lib.tech.add_new_science_pack(technology, pack, amount)
  if data.raw.technology[technology] and data.raw.tool[pack] then
    local addit = true
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == pack or ingredient.name == pack then addit = false end
    end
    if addit then table.insert(data.raw.technology[technology].unit.ingredients, {pack, amount}) end
  else
    if not data.raw.technology[technology] then
      BioInd.writeDebug("Technology %s does not exist.", {technology})
    end
    if not data.raw.tool[pack] then
      BioInd.writeDebug("Science pack %s does not exist.", {pack})
    end
  end
end

function thxbob.lib.tech.add_science_pack(technology, pack, amount)
  if data.raw.technology[technology] and data.raw.tool[pack] then
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
    if addit then
      table.insert(data.raw.technology[technology].unit.ingredients, {pack, amount})
    end
  else
    if not data.raw.technology[technology] then
      BioInd.writeDebug("Technology " .. tostring(technology) .. " does not exist.")
    end
    if not data.raw.tool[pack] then
      BioInd.writeDebug("Science pack %s does not exist.", {pack})
    end
  end
end

function thxbob.lib.tech.remove_science_pack(technology, pack)
  if data.raw.technology[technology] then
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == pack or ingredient.name == pack then
        table.remove(data.raw.technology[technology].unit.ingredients, i)
      end
    end
  else
    BioInd.writeDebug("Technology %s does not exist.", {technology})
  end
end


function thxbob.lib.tech.add_recipe_unlock(technology, recipe)
  if data.raw.technology[technology] and data.raw.recipe[recipe] then
    local addit = true
    if not data.raw.technology[technology].effects then
      data.raw.technology[technology].effects = {}
    end
    for i, effect in pairs(data.raw.technology[technology].effects) do
      if effect.type == "unlock-recipe" and effect.recipe == recipe then addit = false end
    end
    if addit then table.insert(data.raw.technology[technology].effects, {type = "unlock-recipe", recipe = recipe}) end
  else
    if not data.raw.technology[technology] then
      BioInd.writeDebug("Technology %s does not exist.", {technology})
    end
    if not data.raw.recipe[recipe] then
      BioInd.writeDebug("Recipe %s does not exist.", {recipe})
    end
  end
end

function thxbob.lib.tech.remove_recipe_unlock(technology, recipe)
  if data.raw.technology[technology] and data.raw.technology[technology].effects then
    for i, effect in pairs(data.raw.technology[technology].effects) do
      if effect.type == "unlock-recipe" and effect.recipe == recipe then
        table.remove(data.raw.technology[technology].effects, i)
      end
    end
  else
    if not data.raw.technology[technology] then
      BioInd.writeDebug("Technology %s does not exist.", {technology})
    end
  end
end

function thxbob.lib.tech.replace_prerequisite(technology, old, new)
  if data.raw.technology[technology] and data.raw.technology[new] then
    for i, prerequisite in ipairs(data.raw.technology[technology].prerequisites) do
      if prerequisite == old then
        thxbob.lib.tech.remove_prerequisite(technology, old)
        thxbob.lib.tech.add_prerequisite(technology, new)
      end
    end
  else
    if not data.raw.technology[technology] then
      BioInd.writeDebug("Technology %s does not exist.", {technology})
    end
    if not data.raw.technology[new] then
      BioInd.writeDebug("Technology %s does not exist.", {new})
    end
  end
end

function thxbob.lib.tech.add_prerequisite(technology, prerequisite)
  if data.raw.technology[technology] and data.raw.technology[prerequisite] then
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
    if not data.raw.technology[technology] then
      BioInd.writeDebug("Technology %s does not exist.", {technology})
    end
    if not data.raw.technology[prerequisite] then
      BioInd.writeDebug("Technology %s does not exist.", {prerequisite})
    end
  end
end

function thxbob.lib.tech.remove_prerequisite(technology, prerequisite)
  if data.raw.technology[technology] then
    for i, check in ipairs(data.raw.technology[technology].prerequisites) do
      if check == prerequisite then
        table.remove(data.raw.technology[technology].prerequisites, i)
      end
    end
  else
    BioInd.writeDebug("Technology %s does not exist.", {technology})
  end
end
