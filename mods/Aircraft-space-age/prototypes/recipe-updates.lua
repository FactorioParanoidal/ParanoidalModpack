local rro = require("lib.remove-replace-object")




-- Replaces Iron Plates in the Flying Fortress recipe with Invar Plates if Bob's mods are detected.
if data.raw.item["bob-invar-alloy"] then
  rro.replace_name(data.raw["recipe"]["flying-fortress"].ingredients, "iron-plate", "bob-invar-alloy")
  if data.raw["recipe"]["flying-fortress-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["flying-fortress-carbon-fiber"].ingredients, "iron-plate", "bob-invar-alloy") end
end
-- Replaces Steel Plates in the Flying Fortress recipe with Copper-Tungsten Plates if Bob's mods are detected.
if data.raw.item["bob-copper-tungsten-alloy"] then
  rro.replace_name(data.raw["recipe"]["flying-fortress"].ingredients, "steel-plate", "bob-copper-tungsten-alloy")
  if data.raw["recipe"]["flying-fortress-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["flying-fortress-carbon-fiber"].ingredients, "steel-plate", "bob-copper-tungsten-alloy") end
  --bobmods.lib.recipe.replace_ingredient("flying-fortress", "steel-plate", "copper-tungsten-alloy")
end
if data.raw.item["tungsten-plate"] and not data.raw.item["bob-copper-tungsten-alloy"] then
  rro.replace_name(data.raw["recipe"]["flying-fortress"].ingredients, "steel-plate", "tungsten-plate")
  if data.raw["recipe"]["flying-fortress-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["flying-fortress-carbon-fiber"].ingredients, "steel-plate", "tungsten-plate") end
  --bobmods.lib.recipe.replace_ingredient("flying-fortress", "steel-plate", "copper-tungsten-alloy")
end
-- Replaces Iron Plates in the Jet recipe with Nitinol Plates if Bob's mods are detected.
if data.raw.item["bob-nitinol-alloy"] then
  rro.replace_name(data.raw["recipe"]["jet"].ingredients, "iron-plate", "bob-nitinol-alloy")
  if data.raw["recipe"]["jet-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["jet-carbon-fiber"].ingredients, "iron-plate", "bob-nitinol-alloy") end
  --bobmods.lib.recipe.replace_ingredient("jet", "iron-plate", "nitinol-alloy")
end
-- -- Replaces Steel Plates in both the Jet and Gunship recipes with Alumin(i)um Plates if Bob's mods are detected.
-- if data.raw.item["bob-aluminium-plate"] then
--   if data.raw["recipe"]["jet-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["jet-carbon-fiber"].ingredients, "steel-plate", "bob-aluminium-plate") end
--   if data.raw["recipe"]["jet-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["gunship-carbon-fiber"].ingredients, "steel-plate", "bob-aluminium-plate") end
--   rro.replace_name(data.raw["recipe"]["jet"].ingredients, "steel-plate", "bob-aluminium-plate")
--   rro.replace_name(data.raw["recipe"]["gunship"].ingredients, "steel-plate", "bob-aluminium-plate")
--   --bobmods.lib.recipe.replace_ingredient("jet", "steel-plate", "aluminium-plate")
--   --bobmods.lib.recipe.replace_ingredient("gunship", "steel-plate", "aluminium-plate")
-- end

-- -- Replaces Steel Plates in the Jet recipe with Muluna's Alumin(i)um Plates if Muluna is detected. Gunships do not require aluminum because I believe they should be available before building a rocket.
-- if data.raw.item["aluminium-plate"] and not data.raw.item["bob-aluminium-plate"] then
--   if data.raw["recipe"]["jet-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["jet-carbon-fiber"].ingredients, "steel-plate", "aluminium-plate") end
--   --if data.raw["recipe"]["jet-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["gunship-carbon-fiber"].ingredients, "steel-plate", "aluminium-plate") end
--   rro.replace_name(data.raw["recipe"]["jet"].ingredients, "steel-plate", "aluminium-plate")
--   --rro.replace_name(data.raw["recipe"]["gunship"].ingredients, "steel-plate", "aluminium-plate")
--   --bobmods.lib.recipe.replace_ingredient("jet", "steel-plate", "aluminium-plate")
--   --bobmods.lib.recipe.replace_ingredient("gunship", "steel-plate", "aluminium-plate")
-- end



-- Replaces Iron Plates in the Gunship recipe with Cobalt-Steel Plates if Bob's mods are detected.
if data.raw.item["bob-cobalt-steel-alloy"] then
  rro.replace_name(data.raw["recipe"]["gunship"].ingredients, "iron-plate", "bob-cobalt-steel-alloy")
  if data.raw["recipe"]["jet-carbon-fiber"] then rro.replace_name(data.raw["recipe"]["gunship-carbon-fiber"].ingredients, "iron-plate", "bob-cobalt-steel-alloy") end
  --bobmods.lib.recipe.replace_ingredient("gunship", "iron-plate", "cobalt-steel-alloy")
end