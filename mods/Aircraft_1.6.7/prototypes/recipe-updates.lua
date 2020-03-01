-- Replaces Iron Plates in the Flying Fortress recipe with Invar Plates if Bob's mods are detected.
if data.raw.item["invar-alloy"] then
  bobmods.lib.recipe.replace_ingredient("flying-fortress", "iron-plate", "invar-alloy")
end
-- Replaces Steel Plates in the Flying Fortress recipe with Copper-Tungsten Plates if Bob's mods are detected.
if data.raw.item["copper-tungsten-alloy"] then
  bobmods.lib.recipe.replace_ingredient("flying-fortress", "steel-plate", "copper-tungsten-alloy")
end
-- Replaces Iron Plates in the Jet recipe with Nitinol Plates if Bob's mods are detected.
if data.raw.item["nitinol-alloy"] then
  bobmods.lib.recipe.replace_ingredient("jet", "iron-plate", "nitinol-alloy")
end
-- Replaces Steel Plates in both the Jet and Gunship recipes with Alumin(i)um Plates if Bob's mods are detected.
if data.raw.item["aluminium-plate"] then
  bobmods.lib.recipe.replace_ingredient("jet", "steel-plate", "aluminium-plate")
  bobmods.lib.recipe.replace_ingredient("gunship", "steel-plate", "aluminium-plate")
end
-- Replaces Iron Plates in the Gunship recipe with Cobalt-Steel Plates if Bob's mods are detected.
if data.raw.item["cobalt-steel-alloy"] then
  bobmods.lib.recipe.replace_ingredient("gunship", "iron-plate", "cobalt-steel-alloy")
end