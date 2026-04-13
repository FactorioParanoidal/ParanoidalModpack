local DLL = require("prototypes.globals")

table.insert(data.raw.technology.lamp.effects, {
    type = "unlock-recipe",
    recipe = DLL.name  -- deadlock-large-lamp
})

table.insert(data.raw.technology.lamp.effects, {
    type = "unlock-recipe",
    recipe = DLL.floor_name  -- deadlock-floor-lamp
})

table.insert(data.raw.technology.lamp.effects, {
    type = "unlock-recipe",
    recipe = DLL.electric_copper_name  -- deadlock-electric-copper-lamp
})