local DLL = require("prototypes.globals")

-- Define the copper lamp recipe
data:extend({
    {
        name = DLL.copper_name,
        type = "recipe",
        enabled = true,
        ingredients = {
            { type = "item", name = "copper-plate", amount = 6 },
        },
        results = {
            { type = "item", name = DLL.copper_name, amount = 1 }
        },
        subgroup = "circuit-network",  -- Copper lamp under circuit-network
        order = "a[lamp]-b[copper-lamp]",  -- Place after large lamp
        category = "crafting"  -- Category for crafting
    },
    -- Define the hidden burning recipe for the copper lamp
    {
        name = DLL.copper_name.."-burning",  -- Make sure this name matches the recipe you are referencing
        type = "recipe",
        enabled = true,
        hidden = true,
        hide_from_stats = true,
        icon = string.format("%s/copper-lamp.png", DLL.icon_path),  -- Icon path for the recipe
        icon_size = 64,
        icon_mipmaps = 4,
        category = "lamp-burning",  -- Custom category for lamp burning
        ingredients = {},
        results = {},
        subgroup = "other",  -- Optional: Adjust this if needed
        energy_required = 25000 / 60,  -- Represents one "Factorio day"
    }
})

-- Define recipe category for lamp-burning (if not already defined elsewhere)
data:extend({
    {
        type = "recipe-category",
        name = "lamp-burning"
    }
})
