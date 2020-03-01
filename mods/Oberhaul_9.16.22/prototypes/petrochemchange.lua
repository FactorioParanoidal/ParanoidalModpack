--Only hand craft resin
data:extend({
{
    type = "recipe-category",
    name = "crafting-handonly"
},
})

data.raw.recipe["bob-resin-wood"].category = "crafting-handonly"
data.raw.recipe["bob-resin-wood"].result_count = 1
data.raw.recipe["bob-resin-wood"].ingredients = {{"wood",1}}
data.raw.recipe["bob-resin-wood"].energy_required = 4
table.insert(data.raw.character.character.crafting_categories, "crafting-handonly")

--Remove smelting resin to rubber
data.raw.recipe["bob-rubber"].hidden = true