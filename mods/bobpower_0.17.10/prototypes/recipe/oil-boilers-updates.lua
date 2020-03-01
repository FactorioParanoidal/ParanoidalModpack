if settings.startup["bobmods-power-steam"].value == true then

if data.raw.item["steel-pipe"] then
  bobmods.lib.recipe.replace_ingredient("oil-boiler", "pipe", "steel-pipe")
end


if data.raw.item["invar-alloy"] then
  bobmods.lib.recipe.replace_ingredient("oil-boiler-2", "steel-plate", "invar-alloy")
  bobmods.lib.tech.add_prerequisite("bob-oil-boiler-2", "invar-processing")
end

if data.raw.item["brass-pipe"] then
  bobmods.lib.recipe.add_ingredient("oil-boiler-2", {"brass-pipe", 6})
  bobmods.lib.tech.add_prerequisite("bob-oil-boiler-2", "zinc-processing")
end


if data.raw.item["tungsten-plate"] then
  bobmods.lib.recipe.replace_ingredient("oil-boiler-3", "steel-plate", "tungsten-plate")
  bobmods.lib.tech.add_prerequisite("bob-oil-boiler-3", "tungsten-processing")
end

if data.raw.item["ceramic-pipe"] then
  bobmods.lib.recipe.add_ingredient("oil-boiler-3", {"ceramic-pipe", 6})
  bobmods.lib.tech.add_prerequisite("bob-oil-boiler-3", "ceramics")
end


if data.raw.item["copper-tungsten-alloy"] then
  bobmods.lib.recipe.replace_ingredient("oil-boiler-4", "steel-plate", "copper-tungsten-alloy")
  bobmods.lib.tech.add_prerequisite("bob-oil-boiler-4", "tungsten-alloy-processing")
end

if data.raw.item["copper-tungsten-pipe"] then
  bobmods.lib.recipe.add_ingredient("oil-boiler-4", {"copper-tungsten-pipe", 6})
elseif data.raw.item["tungsten-pipe"] then
  bobmods.lib.recipe.add_ingredient("oil-boiler-4", {"tungsten-pipe", 6})
end

end
