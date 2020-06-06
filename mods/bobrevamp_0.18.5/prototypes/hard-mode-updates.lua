if data.raw.fluid["carbon-dioxide"] then
  bobmods.lib.create_gas_bottle(data.raw.fluid["carbon-dioxide"])
end

if bobmods.plates and settings.startup["bobmods-revamp-hardmode"].value == true then
  bobmods.lib.recipe.replace_ingredient("calcium-chloride", "stone", "limestone")
  bobmods.lib.recipe.set_ingredient("calcium-chloride", {type = "fluid", name = "hydrogen-chloride", amount = 50})
  bobmods.lib.recipe.add_result("calcium-chloride", {type = "fluid", name = "hydrogen", amount = 20})
  data.raw.recipe["calcium-chloride"].main_product = "calcium-chloride"
  if data.raw.recipe["calcium-chloride"].normal then
    data.raw.recipe["calcium-chloride"].normal.main_product = "calcium-chloride"
  end
  if data.raw.recipe["calcium-chloride"].expensive then
    data.raw.recipe["calcium-chloride"].expensive.main_product = "calcium-chloride"
  end

  bobmods.lib.recipe.set_ingredient("petroleum-gas-cracking", {type = "fluid", name = "water", amount = 20})
--  bobmods.lib.recipe.add_result("petroleum-gas-cracking", {type = "fluid", name = "carbon-dioxide", amount = 25})
--  data.raw.recipe["petroleum-gas-cracking"].emissions_multiplier = 0.2

  bobmods.lib.tech.add_recipe_unlock("chemical-processing-2", "limestone")

  bobmods.lib.tech.add_recipe_unlock("lithium-processing", "sodium-chlorate")
  bobmods.lib.tech.add_recipe_unlock("lithium-processing", "sodium-perchlorate")
  if data.raw.fluid["pure-water"] then
    bobmods.lib.recipe.replace_ingredient("sodium-chlorate", "water", "pure-water")
    bobmods.lib.recipe.replace_ingredient("sodium-perchlorate", "water", "pure-water")
  end

  bobmods.lib.module.add_productivity_limitation("limestone")
  bobmods.lib.module.add_productivity_limitation("sodium-chlorate")
  bobmods.lib.module.add_productivity_limitation("sodium-perchlorate")
end
