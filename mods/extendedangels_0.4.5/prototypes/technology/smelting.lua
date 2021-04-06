data:extend({
    -- Angels copper tungsten smelting 1
    {
        type = "technology",
        name = "angels-copper-tungsten-smelting-1",
        icon = "__extendedangels__/graphics/technology/smelting-copper-tungsten.png",
        icon_size = 128,
        prerequisites = {
            "angels-copper-smelting-1",
            "angels-tungsten-smelting-1",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "copper-tungsten-smelting-1"
            },
            {
                type = "unlock-recipe",
                recipe = "molten-copper-tungsten-smelting-1"
            },
        },
        unit = {
            count = 75,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
            },
            time = 30
        },
        order = "c-a"
    },

    -- Angels copper tungsten smelting 2
    {
        type = "technology",
        name = "angels-copper-tungsten-smelting-2",
        icon = "__extendedangels__/graphics/technology/smelting-copper-tungsten.png",
        icon_size = 128,
        prerequisites = {
            "angels-copper-tungsten-smelting-1",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "copper-tungsten-smelting-2"
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
            time = 30
        },
        order = "c-a"
    },

    -- Angels stone smelting 4
    {
        type = "technology",
        name = "angels-stone-smelting-4",
        icon = "__angelssmelting__/graphics/technology/cement-tech.png",
        icon_size = 128,
        upgrade = true,
        prerequisites = {
            "angels-stone-smelting-3",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "angels-titanium-concrete-brick"
            },
        },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
            },
            time = 30
        },
        order = "c-a"
    },

    -- Slag processing 3
    {
        type = "technology",
        name = "slag-processing-3",
        icon = "__angelsrefining__/graphics/technology/slag-processing.png",
        icon_size = 64,
        prerequisites = {
            "slag-processing-2",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "filtration-unit-3"
            },
            {
                type = "unlock-recipe",
                recipe = "crystallizer-3"
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
            time = 30
        },
        order = "a-a-a1"
    },

    -- Angels tungsten carbide smelting 1
    {
        type = "technology",
        name = "angels-tungsten-carbide-smelting-1",
        icon = "__extendedangels__/graphics/technology/smelting-tungsten-carbide.png",
        icon_size = 128,
        prerequisites = {
            "angels-tungsten-smelting-1",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tungsten-carbide-smelting-1"
            },
            {
                type = "unlock-recipe",
                recipe = "angels-plate-tungsten-carbide"
            },
        },
        unit = {
            count = 75,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
            },
            time = 30
        },
        order = "c-a"
    },

    -- Angels tungsten carbide smelting 2
    {
        type = "technology",
        name = "angels-tungsten-carbide-smelting-2",
        icon = "__extendedangels__/graphics/technology/smelting-tungsten-carbide.png",
        icon_size = 128,
        prerequisites = {
            "angels-tungsten-smelting-2",
            "angels-tungsten-carbide-smelting-1",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tungsten-carbide-smelting-2"
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
            time = 30
        },
        order = "c-a"
    },

    -- Angels tungsten carbide smelting 3
    {
        type = "technology",
        name = "angels-tungsten-carbide-smelting-3",
        icon = "__extendedangels__/graphics/technology/smelting-tungsten-carbide.png",
        icon_size = 128,
        prerequisites = {
            "angels-tungsten-smelting-3",
            "angels-tungsten-carbide-smelting-2",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "tungsten-carbide-smelting-3"
            },
            {
                type = "unlock-recipe",
                recipe = "solid-tungsten-oxide-smelting-2"
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
            time = 30
        },
        order = "c-a"
    },
})