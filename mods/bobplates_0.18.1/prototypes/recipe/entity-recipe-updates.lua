if data.raw.item["basic-circuit-board"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser", "electronic-circuit", "basic-circuit-board")
end

if data.raw.item["stone-pipe"] then
  bobmods.lib.recipe.replace_ingredient("electrolyser", "pipe", "stone-pipe")
end

if data.raw.item["copper-pipe"] then
  bobmods.lib.recipe.replace_ingredient("air-pump", "pipe", "copper-pipe")
  bobmods.lib.recipe.replace_ingredient("water-pump", "pipe", "copper-pipe")
  bobmods.lib.recipe.replace_ingredient("void-pump", "pipe", "copper-pipe")
  if data.raw.recipe["bob-distillery"] then
    bobmods.lib.recipe.replace_ingredient("bob-distillery", "pipe", "copper-pipe")
  end
end

if data.raw.item["steel-pipe"] then
  bobmods.lib.recipe.replace_ingredient("chemical-furnace", "pipe", "steel-pipe")
  bobmods.lib.recipe.replace_ingredient("chemical-steel-furnace", "pipe", "steel-pipe")
end

if data.raw.item["bronze-pipe"] then
  bobmods.lib.recipe.replace_ingredient("air-pump-2", "pipe", "bronze-pipe")
  bobmods.lib.recipe.replace_ingredient("water-pump-2", "pipe", "bronze-pipe")
end

if data.raw.item["brass-pipe"] then
  bobmods.lib.recipe.replace_ingredient("air-pump-3", "pipe", "brass-pipe")
  bobmods.lib.recipe.replace_ingredient("water-pump-3", "pipe", "brass-pipe")
end

