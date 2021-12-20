if mods.boblogistics then
--Trains
data.raw["cargo-wagon"]["cargo-wagon"].inventory_size = 20
data.raw["cargo-wagon"]["bob-cargo-wagon-2"].inventory_size = 40
data.raw["cargo-wagon"]["bob-cargo-wagon-3"].inventory_size = 60
--data.raw.recipe["bob-fluid-wagon-2"].hidden = true --DrD
--data.raw.recipe["bob-fluid-wagon-3"].hidden = true --DrD

data.raw["cargo-wagon"]["bob-armoured-cargo-wagon"].inventory_size = 40
data.raw["cargo-wagon"]["bob-armoured-cargo-wagon-2"].inventory_size = 60
--data.raw["fluid-wagon"]["bob-armoured-fluid-wagon"].total_capacity = 75000
--data.raw["fluid-wagon"]["bob-armoured-fluid-wagon-2"].total_capacity = 75000
--data.raw["fluid-wagon"]["bob-armoured-fluid-wagon"].capacity = 75000
--data.raw["fluid-wagon"]["bob-armoured-fluid-wagon-2"].capacity = 75000

data.raw["cargo-wagon"]["bob-armoured-cargo-wagon"].weight = 1000
data.raw["cargo-wagon"]["bob-armoured-cargo-wagon-2"].weight = 1500 --DrD 1000
--data.raw["fluid-wagon"]["bob-armoured-fluid-wagon"].weight = 3000
--data.raw["fluid-wagon"]["bob-armoured-fluid-wagon-2"].weight = 3000

bobmods.lib.recipe.add_ingredient("bob-armoured-cargo-wagon",{"steel-gear-wheel",12})
bobmods.lib.recipe.add_ingredient("bob-armoured-cargo-wagon",{"steel-bearing",12})

bobmods.lib.recipe.add_ingredient("bob-armoured-locomotive",{"advanced-circuit",5})
bobmods.lib.recipe.add_ingredient("bob-armoured-locomotive",{"steel-gear-wheel",20})
bobmods.lib.recipe.add_ingredient("bob-armoured-locomotive",{"steel-bearing",16})
end