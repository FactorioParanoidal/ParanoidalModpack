data:extend({
{type = "item",
 name = "flask",
 icon = "__PCP__/graphics/icons/flask.png",
 icon_size = 32,
 subgroup = "intermediate-product",
 order = "z[flask]",
 stack_size = 200
 },
{type = "recipe",
 name = "flask",
 enabled = "false",
 energy_required = 1,
 ingredients = {{type = "item", name = "solid-sodium-hydroxide", amount = 1}},
 results = {{type = "item", name = "flask", amount = 1}},
 }
})
if type(data.raw.recipe["chemical-science-pack"].ingredients)=="table" then table.insert(data.raw.recipe["chemical-science-pack"].ingredients,{type="item",name="flask",amount=1}) end
if type(data.raw.recipe["military-science-pack"].ingredients)=="table" then table.insert(data.raw.recipe["military-science-pack"].ingredients,{type="item",name="flask",amount=1}) end
if type(data.raw.recipe["production-science-pack"].ingredients)=="table" then table.insert(data.raw.recipe["production-science-pack"].ingredients,{type="item",name="flask",amount=1}) end
if type(data.raw.recipe["utility-science-pack"].ingredients)=="table" then table.insert(data.raw.recipe["utility-science-pack"].ingredients,{type="item",name="flask",amount=1}) end
if data.raw.item["omnipack"] then
  table.insert(data.raw.technology["omnipack-technology"].effects,{type="unlock-recipe",recipe="flask"})
else
  table.insert(data.raw.technology["advanced-electronics"].effects,{type="unlock-recipe",recipe="flask"})
end

if data.raw.recipe["advanced-logistic-science-pack"] then table.insert(data.raw.recipe["advanced-logistic-science-pack"].ingredients,{type="item",name="flask",amount=1})
end
if data.raw.item["glass"] then
  bobmods.lib.recipe.replace_ingredient("flask", "solid-sodium-hydroxide", "glass")
end
