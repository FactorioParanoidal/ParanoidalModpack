if data.raw.item["invar-alloy"] then
  bobmods.lib.recipe.replace_ingredient("storage-tank-2", "steel-plate", "invar-alloy")
  bobmods.lib.tech.add_prerequisite("bob-fluid-handling-2", "invar-processing")
end

if data.raw.item["titanium-plate"] then
  bobmods.lib.recipe.replace_ingredient("storage-tank-3", "steel-plate", "titanium-plate")
  bobmods.lib.tech.add_prerequisite("bob-fluid-handling-3", "titanium-processing")
end

if data.raw.item["nitinol-alloy"] then
  bobmods.lib.recipe.replace_ingredient("storage-tank-4", "steel-plate", "nitinol-alloy")
  bobmods.lib.tech.add_prerequisite("bob-fluid-handling-4", "nitinol-processing")
end

