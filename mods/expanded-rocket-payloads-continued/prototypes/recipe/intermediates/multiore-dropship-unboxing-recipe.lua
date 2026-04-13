data:extend({
    {
        type = "recipe",
        name = "multiore-dropship-unboxing",
        category = "satellite-crafting",
        energy_required = 5,
        enabled = false,
        icon = "__expanded-rocket-payloads-continued__/graphic/multiore-dropship-unboxing.png",
        icon_size = 32,
        auto_recycle = false,
        ingredients =
        {
            { type = "item", name = "multiore-dropship", amount = 1 },
        },
        results = { 
            { type = "item", name = "tungsten-ore", amount_min=10, amount_max=30 }, 
            { type = "item", name = "holmium-ore", amount_min=10, amount_max=30,  },
            { type = "item", name = "calcite", amount_min=5, amount_max=10 },
            { type = "item", name = "sulfur", amount_min=5, amount_max=10 },
            { type = "item", name = "carbon", amount_min=10, amount_max=30 },
            { type = "item", name = "scrap", amount_min=5, amount_max=10 },
        },
        subgroup = "space-mining",
    }
})
