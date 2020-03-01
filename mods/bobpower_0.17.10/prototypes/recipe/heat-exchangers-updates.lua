if settings.startup["bobmods-power-steam"].value == true then

if data.raw.item["tungsten-plate"] then
  bobmods.lib.recipe.replace_ingredient("heat-exchanger-2", "steel-plate", "tungsten-plate")
  bobmods.lib.tech.add_prerequisite("bob-heat-exchanger-2", "tungsten-processing")
end

if data.raw.item["ceramic-pipe"] then
  bobmods.lib.recipe.add_ingredient("heat-exchanger-2", {"ceramic-pipe", 4})
  bobmods.lib.tech.add_prerequisite("bob-heat-exchanger-2", "ceramics")
end

if data.raw.item["heat-pipe-2"] then
  bobmods.lib.recipe.add_ingredient("heat-exchanger-2", {"heat-pipe-2", 4})
end



if data.raw.item["copper-tungsten-alloy"] then
  bobmods.lib.recipe.replace_ingredient("heat-exchanger-3", "steel-plate", "copper-tungsten-alloy")
  bobmods.lib.tech.add_prerequisite("bob-heat-exchanger-3", "tungsten-alloy-processing")
end

if data.raw.item["copper-tungsten-pipe"] then
  bobmods.lib.recipe.add_ingredient("heat-exchanger-3", {"copper-tungsten-pipe", 4})
elseif data.raw.item["tungsten-pipe"] then
  bobmods.lib.recipe.add_ingredient("heat-exchanger-3", {"tungsten-pipe", 4})
end

if data.raw.item["heat-pipe-3"] then
  bobmods.lib.recipe.add_ingredient("heat-exchanger-3", {"heat-pipe-3", 4})
end


end
