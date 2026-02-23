local DLL = require("prototypes.globals")

data:extend({
    {
        name = DLL.floor_name,
        type = "recipe",
        enabled = false,
        ingredients = {
            { type = "item", name = "electronic-circuit", amount = 1 },
            { type = "item", name = "copper-cable", amount = 4 },
            { type = "item", name = "iron-plate", amount = 6 },
        },
        results = {
            { type = "item", name = DLL.floor_name, amount = 1 }
        },
        subgroup = "circuit-network",  -- Floor lamp under circuit-network
        order = "a[lamp]-d[floor-lamp]",  -- Place after electric copper lamp
        category = "crafting"  -- Category for crafting
    }
})