data:extend({
    -- Angels advanced gas processing 2
    {
        type = "technology",
        name = "angels-advanced-gas-processing-2",
        icon = "__angelspetrochem__/graphics/technology/gas-refinery-tech.png",
        icon_size = 128,
        prerequisites = {
            "angels-advanced-gas-processing",
            "angels-advanced-chemistry-4"
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "gas-refinery-4"
            },
        },
        unit = {
            count = 150,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
            },
            time = 15
        },
        order = "c-a"
    },

    -- Sodium processing 2
    {
        type = "technology",
        name = "sodium-processing-2",
        icon = "__angelspetrochem__/graphics/technology/sodium-tech.png",
        icon_size = 128,
        prerequisites = {
            "sodium-processing",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "solid-sodium-floride-1"
            },
            {
                type = "unlock-recipe",
                recipe = "solid-sodium-floride-2"
            },
        },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
            },
            time = 15
        },
        order = "c-a"
    },
})