local DLL = require("prototypes.globals")

data:extend({
    {
        name = DLL.electric_copper_name,
        type = "recipe",
        enabled = true,
        ingredients = {
            { type = "item", name = "advanced-circuit", amount = 2 },
            { type = "item", name = "copper-cable", amount = 4 },
            { type = "item", name = "iron-plate", amount = 6 },
        },
        results = {
            { type = "item", name = DLL.electric_copper_name, amount = 1 }
        },
        subgroup = "circuit-network",  -- Electric copper lamp under circuit-network
        order = "a[lamp]-c[electric-copper-lamp]",  -- Place after copper lamp
        category = "crafting"  -- Category for crafting
    }
})
