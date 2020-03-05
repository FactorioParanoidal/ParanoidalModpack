if data.raw.fluid.ammonia and data.raw.fluid.hydrazine and data.raw.fluid["nitric-oxide"] and data.raw.fluid["dinitrogen-tetroxide"] then

if data.raw.fluid["pure-water"] then
  bobmods.lib.recipe.add_result("hydrazine", {type = "fluid", name = "pure-water", amount = 4})
  bobmods.lib.recipe.add_result("nitric-oxide", {type = "fluid", name = "pure-water", amount = 12})
else
  bobmods.lib.recipe.add_result("hydrazine", {type = "fluid", name = "water", amount = 4})
  bobmods.lib.recipe.add_result("nitric-oxide", {type = "fluid", name = "water", amount = 12})
end

bobmods.lib.recipe.difficulty_split("rocket-fuel")

data.raw.recipe["rocket-fuel"].expensive.ingredients = {
  {type = "fluid", name = "hydrazine", amount = 240},
  {type = "fluid", name = "dinitrogen-tetroxide", amount = 120}
}
data.raw.recipe["rocket-fuel"].normal.ingredients = {
  {type = "fluid", name = "hydrazine", amount = 160},
  {type = "fluid", name = "dinitrogen-tetroxide", amount = 80}
}

data.raw.recipe["rocket-fuel"].category = "chemistry"
data.raw.recipe["rocket-fuel"].crafting_machine_tint = {
  primary = {r = 0.7, g = 0.7, b = 0.3, a = 0.000},
  secondary = {r = 0.5, g = 0.5, b = 1.0, a = 0.000},
  tertiary = {r = 0.2, g = 1.0, b = 0.2, a = 0.000}
}

data.raw.item["rocket-fuel"].fuel_emissions_multiplier = 1.2


if data.raw.technology["nitrogen-processing"] then
  bobmods.lib.tech.add_recipe_unlock("nitrogen-processing", "ammonia")
  bobmods.lib.tech.add_recipe_unlock("nitrogen-processing", "nitric-oxide")
  bobmods.lib.tech.add_prerequisite("hydrazine", "nitrogen-processing")
else
  bobmods.lib.tech.add_recipe_unlock("chemical-plant", "ammonia")
  bobmods.lib.tech.add_recipe_unlock("chemical-plant", "nitric-oxide")
  bobmods.lib.tech.add_recipe_unlock("chemical-plant", "nitrogen-dioxide")
  bobmods.lib.tech.add_prerequisite("hydrazine", "chemical-plant")
end

bobmods.lib.tech.add_prerequisite("rocket-silo", "rocket-fuel")
bobmods.lib.tech.remove_recipe_unlock("rocket-silo", "rocket-fuel")
bobmods.lib.tech.remove_prerequisite("rocket-silo", "rocket-speed-5")


bobmods.lib.create_gas_bottle(data.raw.fluid["ammonia"])
bobmods.lib.create_gas_bottle(data.raw.fluid["nitric-oxide"])
bobmods.lib.create_gas_bottle(data.raw.fluid["nitrogen-dioxide"])


bobmods.lib.module.add_productivity_limitation("ammonia")
bobmods.lib.module.add_productivity_limitation("dinitrogen-tetroxide")
bobmods.lib.module.add_productivity_limitation("hydrazine")
bobmods.lib.module.add_productivity_limitation("hydrogen-peroxide")
bobmods.lib.module.add_productivity_limitation("nitric-oxide")
bobmods.lib.module.add_productivity_limitation("nitrogen-dioxide")
end

