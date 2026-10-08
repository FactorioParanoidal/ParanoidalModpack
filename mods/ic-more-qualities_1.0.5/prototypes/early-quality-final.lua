local quality_module_1_tech = data.raw.technology["quality-module"]
quality_module_1_tech.prerequisites = { "logistic-science-pack" }

local quality_module_1_recipe = data.raw.recipe["quality-module"]
quality_module_1_recipe.ingredients = {
    { type = "item", name = "electronic-circuit", amount = 5 }
}
