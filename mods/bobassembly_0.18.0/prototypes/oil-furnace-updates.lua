if settings.startup["bobmods-assembly-oilfurnaces"].value == true then
  if data.raw.item["steel-pipe"] then
    bobmods.lib.recipe.replace_ingredient("oil-steel-furnace", "pipe", "steel-pipe")
  end
  if data.raw.recipe["oil-mixing-steel-furnace"] then
    if data.raw.item["steel-pipe"] then
      bobmods.lib.recipe.replace_ingredient("oil-mixing-steel-furnace", "pipe", "steel-pipe")
    end
  end
  if data.raw.recipe["oil-chemical-steel-furnace"] then
    if data.raw.item["steel-pipe"] then
      bobmods.lib.recipe.replace_ingredient("oil-chemical-steel-furnace", "pipe", "steel-pipe")
    end
  end
end
