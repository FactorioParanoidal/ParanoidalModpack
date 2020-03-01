if not bobmods.lib.module then bobmods.lib.module = {} end


function bobmods.lib.module.add_productivity_limitation(recipe)
  if data.raw.recipe[recipe] then
    for i, module in pairs(data.raw.module) do
      if module.limitation and module.effect.productivity then
        table.insert(module.limitation, recipe)
      end
    end
  else
    log("Recipe " .. recipe .. " does not exist.")
  end
end

-- Although this version in theory takes longer because it will check each module multiple times, instead of once
-- it does a recipe exist check only once, intead of multiple times, and allows a single error message, instead of once per module with a limitation.
function bobmods.lib.module.add_productivity_limitations(recipes)
  for j, recipe in pairs(recipes) do
    bobmods.lib.module.add_productivity_limitation(recipe)
  end
end

--[[
function bobmods.lib.module.add_productivity_limitations(intermediates)
  for i, module in pairs(data.raw.module) do
    if module.limitation and module.effect.productivity then
      for j, intermediate in pairs(intermediates) do
        table.insert(module.limitation, intermediate)
      end
    end
  end
end
]]--