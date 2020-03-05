table.insert(data.raw.technology['automated-rail-transportation'].effects,{type = "unlock-recipe",recipe = "fuel-train-stop"})

local train_stop_entity = table.deepcopy(data.raw['train-stop']['train-stop'])
train_stop_entity.name = "fuel-train-stop"
train_stop_entity.minable.result = "fuel-train-stop"

local train_stop_item = table.deepcopy(data.raw['item']['train-stop'])
train_stop_item.name = "fuel-train-stop"
train_stop_item.icon = nil
train_stop_item.icons = { {icon = "__base__/graphics/icons/train-stop.png", tint = {r=0, g=0.7, b=1, a=1}} }
train_stop_item.order = "a[train-system]-c[train-stop]-a[fuel-train-stop]"
train_stop_item.place_result = "fuel-train-stop"

local train_stop_recipe = table.deepcopy(data.raw['recipe']['train-stop'])
train_stop_recipe.name = "fuel-train-stop"
train_stop_recipe.result = "fuel-train-stop"

data:extend({train_stop_entity,train_stop_item,train_stop_recipe})