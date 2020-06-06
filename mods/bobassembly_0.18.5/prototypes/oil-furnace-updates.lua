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

  if settings.startup["bobmods-plates-convert-recipes"] and settings.startup["bobmods-plates-convert-recipes"].value == true then
    if data.raw.item["steel-pipe"] then
      bobmods.lib.recipe.remove_result("steel-furnace-from-oil-steel-furnace", "pipe")
      bobmods.lib.recipe.add_result("steel-furnace-from-oil-steel-furnace", {"steel-pipe", 2})
    end
    if data.raw.recipe["oil-mixing-steel-furnace"] then
      if data.raw.item["steel-pipe"] then
        bobmods.lib.recipe.replace_ingredient("oil-mixing-steel-furnace-from-oil-steel-furnace", "pipe", "steel-pipe")

        bobmods.lib.recipe.remove_result("mixing-steel-furnace-from-oil-mixing-steel-furnace", "pipe")
        bobmods.lib.recipe.add_result("mixing-steel-furnace-from-oil-mixing-steel-furnace", {"steel-pipe", 2})

        bobmods.lib.recipe.remove_result("oil-steel-furnace-from-oil-mixing-steel-furnace", "pipe")
        bobmods.lib.recipe.add_result("oil-steel-furnace-from-oil-mixing-steel-furnace", {"steel-pipe", 5})
      end
    end
    if data.raw.recipe["oil-chemical-steel-furnace"] then
      if data.raw.item["steel-pipe"] then
        bobmods.lib.recipe.replace_ingredient("oil-chemical-steel-furnace-from-oil-steel-furnace", "pipe", "steel-pipe")

        bobmods.lib.recipe.remove_result("chemical-steel-furnace-from-oil-chemical-steel-furnace", "pipe")
        bobmods.lib.recipe.add_result("chemical-steel-furnace-from-oil-chemical-steel-furnace", {"steel-pipe", 2})

        bobmods.lib.recipe.remove_result("oil-steel-furnace-from-oil-chemical-steel-furnace", "pipe")
        bobmods.lib.recipe.add_result("oil-steel-furnace-from-oil-chemical-steel-furnace", {"steel-pipe", 5})
      end
    end
  end
end
