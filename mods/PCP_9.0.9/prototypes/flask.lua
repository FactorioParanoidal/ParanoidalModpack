data:extend({
{type = "item",
 name = "flask",
 icon = "__PCP__/graphics/icons/flask.png",
 icon_size = 32,
 --flags = {},
 subgroup = "intermediate-product",
 order = "z[flask]",
 stack_size = 200
 },
{type = "recipe",
 name = "flask",
 enabled = "false",
 energy_required = 1,
 ingredients = {{type = "item", name = "glass", amount = 1}},
 results = {{type = "item", name = "flask", amount = 1}},
 }
})
table.insert(data.raw.recipe["chemical-science-pack"].ingredients,{type="item",name="flask",amount=1})
table.insert(data.raw.recipe["military-science-pack"].ingredients,{type="item",name="flask",amount=1})
table.insert(data.raw.recipe["production-science-pack"].ingredients,{type="item",name="flask",amount=1})
table.insert(data.raw.recipe["utility-science-pack"].ingredients,{type="item",name="flask",amount=1})
table.insert(data.raw.technology["advanced-electronics"].effects,{type="unlock-recipe",recipe="flask"})
if data.raw.item["logistic-science-pack"] then
bobmods.lib.recipe.add_ingredient("logistic-science-pack", {"flask",1})
end