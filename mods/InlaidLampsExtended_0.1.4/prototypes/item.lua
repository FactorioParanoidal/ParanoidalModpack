data:extend({
    -- Flat Lamp Item
    {
        type = "item",
        name = "flat-lamp",
        icon = "__InlaidLampsExtended__/graphics/icon/flat-lamp.png",
		icon_size = 32,
        subgroup = "circuit-network",
        order = "a[light]-u[flat-lamp]",
        place_result = "flat-lamp",
        stack_size = 50
    }, 
    -- 2x2 Flat Lamp Item
    {
        type = "item",
        name = "flat-lamp-big",
        icon = "__InlaidLampsExtended__/graphics/icon/flat-lamp-big.png",
		icon_size = 32,
        subgroup = "circuit-network",
        order = "a[light]-v[flat-lamp-big]",
        place_result = "flat-lamp-big",
        stack_size = 50
    }
})