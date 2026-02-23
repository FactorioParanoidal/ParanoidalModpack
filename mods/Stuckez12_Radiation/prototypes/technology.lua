data:extend({
    {
        type = "technology",
        name = "radiation-protection",
        icon = "__Stuckez12_Radiation__/graphics/icon/tech.png",
        icon_size = 128,
        prerequisites = {"uranium-mining", "power-armor"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "radiation-absorption-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-reduction-recipe"
            }
        },
        unit = {
            count = 400,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        },
        localised_name = {"technology-name.radiation-protection"},
        localised_description = {"technology-description.radiation-protection"},
        order = "g-e-a"
    },
    {
        type = "technology",
        name = "advanced-radiation-protection",
        icon = "__Stuckez12_Radiation__/graphics/icon/tech.png",
        icon_size = 128,
        prerequisites = {"radiation-protection", "power-armor-mk2", "nuclear-power"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "radiation-absorption-mk2-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-reduction-mk2-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-wall-recipe"
            }
        },
        unit = {
            count = 1200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 45
        },
        localised_name = {"technology-name.advanced-radiation-protection"},
        localised_description = {"technology-description.advanced-radiation-protection"},
        order = "g-e-a"
    },
    {
        type = "technology",
        name = "near-total-radiation-protection",
        icon = "__Stuckez12_Radiation__/graphics/icon/tech.png",
        icon_size = 128,
        prerequisites = {"advanced-radiation-protection", "efficiency-module-3", "fission-reactor-equipment"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "radiation-absorption-mk3-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-reduction-mk3-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-suit-recipe"
            }
        },
        unit = {
            count = 2000,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 60
        },
        localised_name = {"technology-name.near-total-radiation-protection"},
        localised_description = {"technology-description.near-total-radiation-protection"},
        order = "g-e-a"
    }
})
