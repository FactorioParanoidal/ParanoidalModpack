data:extend({
    {
        type = "technology",
        name = "flat-lamp-t",
        icon = "__InlaidLampsExtended__/graphics/flat-lamp-technology.png",
        icon_size = 128,
        prerequisites = { "optics" },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "flat-lamp-c"
            },
            {
                type = "unlock-recipe",
                recipe = "flat-lamp-big"
            }
        },
        unit = {
            count = 20,
            ingredients =
            {
                { "automation-science-pack", 1 }
            },
            time = 15
        },
        order = "a-h-a"
    }
})