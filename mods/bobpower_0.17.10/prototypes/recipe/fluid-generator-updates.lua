if settings.startup["bobmods-power-fluidgenerator"].value == true then

if data.raw.item["steel-gear-wheel"] then
  bobmods.lib.recipe.replace_ingredient("fluid-generator", "iron-gear-wheel", "steel-gear-wheel")
end


if data.raw.item["steel-bearing"] then
  bobmods.lib.recipe.add_difficulty_ingredient("fluid-generator-2", "normal", {"steel-bearing", 5})
  bobmods.lib.recipe.add_difficulty_ingredient("fluid-generator-2", "expensive", {"steel-bearing", 10})
else
  bobmods.lib.recipe.add_ingredient("fluid-generator-2", {"iron-gear-wheel", 5})
end

if data.raw.item["brass-gear-wheel"] then
  bobmods.lib.recipe.replace_ingredient("fluid-generator-2", "iron-gear-wheel", "brass-gear-wheel")
  bobmods.lib.tech.add_prerequisite("fluid-generator-2", "zinc-processing")
end

if data.raw.item["aluminium-plate"] then
  bobmods.lib.recipe.replace_ingredient("fluid-generator-2", "steel-plate", "aluminium-plate")
  bobmods.lib.tech.add_prerequisite("fluid-generator-2", "aluminium-processing")
end

if data.raw.item["steel-pipe"] then
  bobmods.lib.recipe.add_ingredient("fluid-generator-2", {"steel-pipe", 5})
end


if data.raw.item["titanium-bearing"] then
  bobmods.lib.recipe.add_difficulty_ingredient("fluid-generator-3", "normal", {"titanium-bearing", 5})
  bobmods.lib.recipe.add_difficulty_ingredient("fluid-generator-3", "expensive", {"titanium-bearing", 10})
else
  if data.raw.item["steel-bearing"] then
    bobmods.lib.recipe.add_difficulty_ingredient("fluid-generator-3", "normal", {"steel-bearing", 5})
    bobmods.lib.recipe.add_difficulty_ingredient("fluid-generator-3", "expensive", {"steel-bearing", 10})
  else
    bobmods.lib.recipe.add_ingredient("steam-engine-3", {"iron-gear-wheel", 5})
  end
end

if data.raw.item["titanium-gear-wheel"] then
  bobmods.lib.recipe.replace_ingredient("fluid-generator-3", "iron-gear-wheel", "titanium-gear-wheel")
else
  if data.raw.item["steel-gear-wheel"] then
    bobmods.lib.recipe.replace_ingredient("fluid-generator-3", "iron-gear-wheel", "steel-gear-wheel")
  end
end

if data.raw.item["titanium-plate"] then
  bobmods.lib.recipe.replace_ingredient("fluid-generator-3", "steel-plate", "titanium-plate")
  bobmods.lib.tech.add_prerequisite("fluid-generator-3", "titanium-processing")
end

if data.raw.item["titanium-pipe"] then
  bobmods.lib.recipe.add_ingredient("fluid-generator-3", {"titanium-pipe", 5})
end


if mods["bobrevamp"] and data.raw.fluid.hydrogen and data.raw.fluid.oxygen and data.raw.fluid.nitrogen then
  if data.raw.item["nitinol-bearing"] then
    bobmods.lib.recipe.add_difficulty_ingredient("hydrazine-generator", "normal", {"nitinol-bearing", 5})
    bobmods.lib.recipe.add_difficulty_ingredient("hydrazine-generator", "expensive", {"nitinol-bearing", 10})
  else
    bobmods.lib.recipe.add_ingredient("hydrazine-generator", {"iron-gear-wheel", 5})
  end

  if data.raw.item["nitinol-gear-wheel"] then
    bobmods.lib.recipe.replace_ingredient("hydrazine-generator", "iron-gear-wheel", "nitinol-gear-wheel")
  end

  if data.raw.item["nitinol-alloy"] then
    bobmods.lib.recipe.replace_ingredient("hydrazine-generator", "steel-plate", "nitinol-alloy")
    bobmods.lib.tech.add_prerequisite("hydrazine-generator", "nitinol-processing")
  end

  if data.raw.item["nitinol-pipe"] then
    bobmods.lib.recipe.add_ingredient("hydrazine-generator", {"nitinol-pipe", 5})
    bobmods.lib.tech.add_prerequisite("hydrazine-generator", "nitinol-processing")
  elseif data.raw.item["tungsten-pipe"] then
    bobmods.lib.recipe.add_ingredient("hydrazine-generator", {"tungsten-pipe", 5})
    bobmods.lib.tech.add_prerequisite("hydrazine-generator", "tungsten-processing")
  end
end

end
