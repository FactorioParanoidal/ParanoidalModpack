if not angelsmods.bioprocessing then return end

data:extend({
    -- Advanced angel's bioprocessing
    {
        type = "technology",
        name = "angels-advanced-bio-processing",
        icon = "__angelsbioprocessing__/graphics/technology/algae-farm-tech.png",
        icon_size = 128,
        prerequisites = {
            "bio-processing-red",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "algae-farm-4"
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
    },

    -- Bio farm 3
    {
        type = "technology",
        name = "bio-farm-3",
        icon = "__angelsbioprocessing__/graphics/technology/base-farm-tech.png",
        icon_size = 128,
        prerequisites = {
            "bio-farm-2",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "crop-farm-3"
            },
            {
                type = "unlock-recipe",
                recipe = "composter-3"
            },
            {
                type = "unlock-recipe",
                recipe = "bio-processor-3"
            },
        },
        unit = {
            count = 150,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
            time = 15
        },
    },

    -- Bio refugium butchery 3
    {
        type = "technology",
        name = "bio-refugium-butchery-3",
        icon = "__angelsbioprocessing__/graphics/technology/bio-refugium-butchery-tech.png",
        icon_size = 160,
        order = "c-a",
        prerequisites = {
            "bio-refugium-butchery-2",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "bio-butchery-3"
            },
        },
        unit = {
            count = 150,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
            time = 30
        },
    },

    -- Bio farm advanced upgrade
    {
        type = "technology",
        name = "bio-farm-advanced-upgrade",
        icon = "__angelsbioprocessing__/graphics/technology/base-farm-tech.png",
        icon_size = 128,
        order = "c-a",
        prerequisites = {
            "bio-temperate-farm",
            "bio-desert-farm",
            "bio-swamp-farm"
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "temperate-farm-2"
            },
            {
                type = "unlock-recipe",
                recipe = "desert-farm-2"
            },
            {
                type = "unlock-recipe",
                recipe = "swamp-farm-2"
            },
        },
        unit = {
            count = 128,
            ingredients = {
                {"automation-science-pack", 4},
                {"logistic-science-pack", 4},
                {"chemical-science-pack", 4},
                {"token-bio", 1}
            },
            time = 30
        }
    },

    -- Bio farm advanced upgrade 2
    {
        type = "technology",
        name = "bio-farm-advanced-upgrade-2",
        icon = "__angelsbioprocessing__/graphics/technology/base-farm-tech.png",
        icon_size = 128,
        order = "c-a",
        prerequisites = {
            "bio-farm-advanced-upgrade",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "temperate-farm-3"
            },
            {
                type = "unlock-recipe",
                recipe = "desert-farm-3"
            },
            {
                type = "unlock-recipe",
                recipe = "swamp-farm-3"
            },
        },
        unit = {
            count = 256,
            ingredients = {
                {"automation-science-pack", 4},
                {"logistic-science-pack", 4},
                {"chemical-science-pack", 4},
                {"production-science-pack", 4},
                {"token-bio", 1}
            },
            time = 30
        }
    },

    -- Bio refugium hatchery 2
    {
        type = "technology",
        name = "bio-refugium-hatchery-2",
        icon = "__angelsbioprocessing__/graphics/technology/bio-refugium-puffer-hatchery-tech.png",
        icon_size = 160,
        order = "c-a",
        prerequisites = {
            "bio-refugium-hatchery"
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "bio-hatchery-2"
            },
            {
                type = "unlock-recipe",
                recipe = "bio-hatchery-3"
            },
        },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"token-bio", 1}
            },
            time = 30
        },
    },

    -- Bio nutrient paste 2
    {
        type = "technology",
        name = "bio-nutrient-paste-2",
        icon = "__angelsbioprocessing__/graphics/technology/nutrient-extractor-tech.png",
        icon_size = 128,
        order = "c-a",
        prerequisites = {
            "bio-nutrient-paste"
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "nutrient-extractor-2"
            },
            {
                type = "unlock-recipe",
                recipe = "nutrient-extractor-3"
            }
        },
        unit = {
            count = 80,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        }
    },

    -- Bio refugium fish 3
    {
        type = "technology",
        name = "bio-refugium-fish-3",
        icon = "__angelsbioprocessing__/graphics/technology/bio-refugium-fish-tech.png",
        icon_size = 128,
        order = "c-a",
        prerequisites = {
            "bio-refugium-fish-2",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "bio-refugium-fish-3"
            },
        },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        },
    },

    -- Advanced seed extraction
    {
        type = "technology",
        name = "adv-seed-extraction",
        icon = "__angelsbioprocessing__/graphics/technology/seed-extractor-tech.png",
        icon_size = 128,
        order = "c-a",
        prerequisites = {
            "gardens",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "seed-extractor-2"
            },
            {
                type = "unlock-recipe",
                recipe = "seed-extractor-3"
            }
        },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            },
            time = 30
        }
    },
})