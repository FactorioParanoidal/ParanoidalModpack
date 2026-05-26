data:extend(
    {
        {
            type = "technology",
            name = "braking-force-8",
            icon = "__All-infinit-tech__/graphics/braking-tech.png",
            icon_size = 256,
            prerequisites = {"braking-force-7"},
            effects = {
                {
                    type = "train-braking-force-bonus",
                    modifier = 0.2
                }
            },
            unit = {
                count_formula = settings.startup["Infinite-Formula"].value,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"chemical-science-pack", 1},
                    {"production-science-pack", 1},
                    {"utility-science-pack", 1},
                    {"space-science-pack", 1}
                },
                time = 60
            },
            upgrade = true,
            order = "b-f-h",
            max_level = "infinite"
        }
    }
)
