if mods["Krastorio2-spaced-out"] then return end

data:extend {{
    type = "technology",
    name = "maraxsis-deepsea-research",
    icon = "__maraxsis__/graphics/technology/deepsea-research.png",
    icon_size = 256,
    effects = {},
    prerequisites = {
        "maraxsis-project-seadragon",
    },
    unit = {
        count = 2000,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack",   1},
            {"military-science-pack",   1},
            {"chemical-science-pack",   1},
            {"production-science-pack", 1},
            {"utility-science-pack",    1},
            {"hydraulic-science-pack",  1},
        },
        time = 60,
    },
    order = "ea[deepsea-research]",
}}
