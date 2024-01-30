data:extend({
    {
        type = "technology",
        name = "pipe-meter",
        icon = "__PipeMeterWLK__/graphics/tech-pipe_meter.png",
        icon_size = 128,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "pipe-meter"
            }
        },
        prerequisites = {"fluid-handling"},
        unit = {
            count = 25,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            },
            time = 10
        },
        order = "d-a-a"
    }
})
