if settings.startup["coppermine-bob-module-space-packs-for-god-modules"].value then
  -- Add space science packs as an ingredient for god module 1
  if data.raw.recipe["god-module-1"] then
    bobmods.lib.recipe.add_ingredient("god-module-1", {"space-science-pack", 1})
    --bobmods.lib.recipe.add_ingredient("god-module-2", {"space-science-pack", 2})  -- from DrD
    --bobmods.lib.recipe.add_ingredient("god-module-3", {"space-science-pack", 3})  -- from DrD
    --bobmods.lib.recipe.add_ingredient("god-module-4", {"space-science-pack", 4})  -- from DrD
    --bobmods.lib.recipe.add_ingredient("god-module-5", {"space-science-pack", 5})  -- from DrD
    bobmods.lib.tech.add_prerequisite("god-module-1", "rocket-silo")
  end
end
