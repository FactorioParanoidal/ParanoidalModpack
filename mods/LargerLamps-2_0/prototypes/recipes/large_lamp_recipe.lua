local DLL = require("prototypes.globals")

data:extend({
    {
        name = DLL.name,
        type = "recipe",
        enabled = false,
        ingredients = {
            { type = "item", name = "electronic-circuit", amount = 1 },
            { type = "item", name = "copper-cable", amount = 4 },
            { type = "item", name = "iron-plate", amount = 6 },
        },
        results = {
            { type = "item", name = DLL.name, amount = 1 }
        },
        subgroup = "circuit-network",  -- All lamps under circuit-network
        order = "a[lamp]-a[large-lamp]",  -- Place it first in the list
        category = "crafting"  -- Category for crafting
    }
})
