if data.raw.item["copper-pipe"] then
  bobmods.lib.recipe.replace_ingredient("pump", "pipe", "copper-pipe")
end

if data.raw.item["aluminium-plate"] then
  bobmods.lib.recipe.replace_ingredient("bob-pump-2", "steel-plate", "aluminium-plate")
end

if data.raw.item["bronze-pipe"] then
  bobmods.lib.recipe.replace_ingredient("bob-pump-2", "copper-pipe", "bronze-pipe")
end

if data.raw.item["titanium-plate"] then
  bobmods.lib.recipe.replace_ingredient("bob-pump-3", "steel-plate", "titanium-plate")
end

if data.raw.item["brass-pipe"] then
  bobmods.lib.recipe.replace_ingredient("bob-pump-3", "copper-pipe", "brass-pipe")
end

if data.raw.item["nitinol-alloy"] then
  bobmods.lib.recipe.replace_ingredient("bob-pump-4", "steel-plate", "nitinol-alloy")
end

if data.raw.item["copper-tungsten-pipe"] then
  bobmods.lib.recipe.replace_ingredient("bob-pump-4", "copper-pipe", "copper-tungsten-pipe")
end


