local DLL = require("prototypes.globals")

-- Large Lamp Item
data:extend({
    {
        type = "item",
        name = DLL.name,  -- deadlock-large-lamp
        icon = string.format("%s/large-lamp.png", DLL.icon_path),
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "circuit-network",  -- All lamps are now under circuit-network
        order = "a[lamp]-a[large-lamp]",  -- Large lamp first in the list
        place_result = DLL.name,  -- deadlock-large-lamp
        stack_size = 50
    },
    -- Copper Lamp Item
    {
        type = "item",
        name = DLL.copper_name,  -- deadlock-copper-lamp
        icon = string.format("%s/copper-lamp.png", DLL.icon_path),
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "circuit-network",  -- Copper lamp under circuit-network
        order = "a[lamp]-b[copper-lamp]",  -- Copper lamp after large lamp
        place_result = DLL.copper_name,  -- deadlock-copper-lamp
        stack_size = 50
    },
    -- Electric Copper Lamp Item
    {
        type = "item",
        name = DLL.electric_copper_name,
        icon = string.format("%s/copper-lampelect.png", DLL.icon_path),
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "circuit-network",  -- Electric copper lamp under circuit-network
        order = "a[lamp]-c[electric-copper-lamp]",  -- Electric copper lamp after copper lamp
        place_result = DLL.electric_copper_name,
        stack_size = 50
    },
    -- Floor Lamp Item
    {
        type = "item",
        name = DLL.floor_name,  -- deadlock-floor-lamp
        icon = string.format("%s/floor-lamp.png", DLL.icon_path),
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "circuit-network",  -- Floor lamp under circuit-network
        order = "a[lamp]-d[floor-lamp]",  -- Floor lamp after electric copper lamp
        place_result = DLL.floor_name,  -- deadlock-floor-lamp
        stack_size = 50
    }
})