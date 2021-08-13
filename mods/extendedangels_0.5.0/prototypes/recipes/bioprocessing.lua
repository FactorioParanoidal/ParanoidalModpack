if not angelsmods.bioprocessing then return end

-- Fetch marathon mode settings
local buildingmulti = angelsmods.marathon.buildingmulti
local buildingtime = angelsmods.marathon.buildingtime

angelsmods.functions.RB.build({
    -- Algae farm 5
    {
        type = "recipe",
        name = "algae-farm-5",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"algae-farm-4", 1},
                {"t5-plate", 11},
                {"t5-circuit", 4},
                {"t5-brick", 11},
                {"t5-pipe", 18},
            },
            result = "algae-farm-5",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"algae-farm-4", 1},
                {"t5-plate", 11 * buildingmulti},
                {"t5-circuit", 4 * buildingmulti},
                {"t5-brick", 11 * buildingmulti},
                {"t5-pipe", 18 * buildingmulti},
            },
            result = "algae-farm-5",
        },
    },

    -- Temperate tree seed generator 2
    {
        type = "recipe",
        name = "bio-generator-temperate-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-generator-temperate-1", 1},
                {"temperate-tree", 1},
                {"t2-plate", 2},
                {"t2-circuit", 2},
                {"t2-brick", 1},
                {"t2-pipe", 3},
            },
            result = "bio-generator-temperate-2",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-generator-temperate-1", 1},
                {"temperate-tree", 1 * buildingmulti},
                {"t2-plate", 2 * buildingmulti},
                {"t2-circuit", 2 * buildingmulti},
                {"t2-brick", 1 * buildingmulti},
                {"t2-pipe", 3 * buildingmulti},
            },
            result = "bio-generator-temperate-2",
        },
    },

    -- Swamp tree seed generator 2
    {
        type = "recipe",
        name = "bio-generator-swamp-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-generator-swamp-1", 1},
                {"swamp-tree", 1},
                {"t2-plate", 2},
                {"t2-circuit", 2},
                {"t2-brick", 1},
                {"t2-pipe", 3},
            },
            result = "bio-generator-swamp-2",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-generator-swamp-1", 2},
                {"swamp-tree", 1 * buildingmulti},
                {"t2-plate", 2 * buildingmulti},
                {"t2-circuit", 2 * buildingmulti},
                {"t2-brick", 1 * buildingmulti},
                {"t2-pipe", 3 * buildingmulti},
            },
            result = "bio-generator-swamp-2",
        },
    },

    -- Desert tree seed generator 2
    {
        type = "recipe",
        name = "bio-generator-desert-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-generator-desert-1", 1},
                {"desert-tree", 1},
                {"t2-plate", 2},
                {"t2-circuit", 2},
                {"t2-brick", 1},
                {"t2-pipe", 3},
            },
            result = "bio-generator-desert-2",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-generator-desert-1", 1},
                {"desert-tree", 1 * buildingmulti},
                {"t2-plate", 2 * buildingmulti},
                {"t2-circuit", 2 * buildingmulti},
                {"t2-brick", 1 * buildingmulti},
                {"t2-pipe", 3 * buildingmulti},
            },
            result = "bio-generator-desert-2",
        },
    },

    -- Arboretum 2
    {
        type = "recipe",
        name = "bio-arboretum-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-arboretum-1", 1},
                {"t2-plate", 6},
                {"t2-circuit", 2},
                {"t2-brick", 6},
                {"t2-pipe", 8},
            },
            result = "bio-arboretum-2",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-arboretum-1", 1},
                {"t2-plate", 6 * buildingmulti},
                {"t2-circuit", 2 * buildingmulti},
                {"t2-brick", 6 * buildingmulti},
                {"t2-pipe", 8 * buildingmulti},
            },
            result = "bio-arboretum-2",
        },
    },

    -- Temperate tree seed generator 3
    {
        type = "recipe",
        name = "bio-generator-temperate-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-generator-temperate-2", 1},
                {"temperate-tree", 1},
                {"t3-plate", 2},
                {"t3-circuit", 2},
                {"t3-brick", 1},
                {"t3-pipe", 3},
            },
            result = "bio-generator-temperate-3",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-generator-temperate-2", 1},
                {"temperate-tree", 1 * buildingmulti},
                {"t3-plate", 2 * buildingmulti},
                {"t3-circuit", 2 * buildingmulti},
                {"t3-brick", 1 * buildingmulti},
                {"t3-pipe", 3 * buildingmulti},
            },
            result = "bio-generator-temperate-3",
        },
    },

    -- Swamp tree seed generator 3
    {
        type = "recipe",
        name = "bio-generator-swamp-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-generator-swamp-2", 1},
                {"swamp-tree", 1},
                {"t3-plate", 2},
                {"t3-circuit", 2},
                {"t3-brick", 1},
                {"t3-pipe", 3},
            },
            result = "bio-generator-swamp-3",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-generator-swamp-2", 1},
                {"swamp-tree", 1 * buildingmulti},
                {"t3-plate", 2 * buildingmulti},
                {"t3-circuit", 2 * buildingmulti},
                {"t3-brick", 1 * buildingmulti},
                {"t3-pipe", 3 * buildingmulti},
            },
            result = "bio-generator-swamp-3",
        },
    },

    -- Desert tree seed generator 3
    {
        type = "recipe",
        name = "bio-generator-desert-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-generator-desert-2", 1},
                {"desert-tree", 1},
                {"t3-plate", 2},
                {"t3-circuit", 2},
                {"t3-brick", 1},
                {"t3-pipe", 3},
            },
            result = "bio-generator-desert-3",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-generator-desert-2", 1},
                {"desert-tree", 1 * buildingmulti},
                {"t3-plate", 2 * buildingmulti},
                {"t3-circuit", 2 * buildingmulti},
                {"t3-brick", 1 * buildingmulti},
                {"t3-pipe", 3 * buildingmulti},
            },
            result = "bio-generator-desert-3",
        },
    },

    --Arboretum 3
    {
        type = "recipe",
        name = "bio-arboretum-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-arboretum-2", 1},
                {"t3-plate", 6},
                {"t3-circuit", 2},
                {"t3-brick", 6},
                {"t3-pipe", 8},
            },
            result = "bio-arboretum-3",
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-arboretum-2", 1},
                {"t3-plate", 6 * buildingmulti},
                {"t3-circuit", 2 * buildingmulti},
                {"t3-brick", 6 * buildingmulti},
                {"t3-pipe", 8 * buildingmulti},
            },
            result = "bio-arboretum-3",
        },
    },

    --Bio press 2
    {
        type = "recipe",
        name = "bio-press-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-press", 1},
                {"t2-plate", 2},
                {"t2-circuit", 2},
                {"t2-brick", 1},
                {"t2-pipe", 1},
                {"t2-gears", 2}
            },
            result = "bio-press-2"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-press", 1},
                {"t2-plate", 2 * buildingmulti},
                {"t2-circuit", 2 * buildingmulti},
                {"t2-brick", 1 * buildingmulti},
                {"t2-pipe", 1 * buildingmulti},
                {"t2-gears", 2 * buildingmulti}
            },
            result = "bio-press-2"
        }
    },

    -- Bio press 3
    {
        type = "recipe",
        name = "bio-press-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-press-2", 1},
                {"t3-plate", 2},
                {"t3-circuit", 2},
                {"t3-brick", 1},
                {"t3-pipe", 1},
                {"t3-gears", 2}
            },
            result = "bio-press-3"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-press-2", 1},
                {"t3-plate", 2 * buildingmulti},
                {"t3-circuit", 2 * buildingmulti},
                {"t3-brick", 1 * buildingmulti},
                {"t3-pipe", 1 * buildingmulti},
                {"t3-gears", 2 * buildingmulti}
            },
            result = "bio-press-3"
        }
    },

    -- Bio processor 2
    {
        type = "recipe",
        name = "bio-processor-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-processor", 1},
                {"t2-plate", 5},
                {"t2-circuit", 8},
                {"t2-brick", 5},
                {"t2-gears", 4}
            },
            result = "bio-processor-2"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-processor", 1},
                {"t2-plate", 5 * buildingmulti},
                {"t2-circuit", 8 * buildingmulti},
                {"t2-brick", 5 * buildingmulti},
                {"t2-gears", 4 * buildingmulti}
            },
            result = "bio-processor-2"
        }
    },

    -- Bio processor 3
    {
        type = "recipe",
        name = "bio-processor-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-processor-2", 1},
                {"t3-plate", 5},
                {"t3-circuit", 8},
                {"t3-brick", 5},
                {"t3-gears", 4}
            },
            result = "bio-processor-3"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-processor-2", 1},
                {"t3-plate", 5 * buildingmulti},
                {"t3-circuit", 8 * buildingmulti},
                {"t3-brick", 5 * buildingmulti},
                {"t3-gears", 4 * buildingmulti}
            },
            result = "bio-processor-3"
        }
    },

    -- Butchery 2
    {
        type = "recipe",
        name = "bio-butchery-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-butchery", 1},
                {"t2-plate", 3},
                {"t2-circuit", 1},
                {"t2-brick", 2},
                {"t2-gears", 2}
            },
            result = "bio-butchery-2"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-butchery", 1},
                {"t2-plate", 3 * buildingmulti},
                {"t2-circuit", 1 * buildingmulti},
                {"t2-brick", 2 * buildingmulti},
                {"t2-gears", 2 * buildingmulti}
            },
            result = "bio-butchery-2"
        }
    },

    -- Butcher 3
    {
        type = "recipe",
        name = "bio-butchery-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"bio-butchery-2", 1},
                {"t3-plate", 3},
                {"t3-circuit", 1},
                {"t3-brick", 2},
                {"t3-gears", 2}
            },
            result = "bio-butchery-3"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"bio-butchery-2", 1},
                {"t3-plate", 3 * buildingmulti},
                {"t3-circuit", 1 * buildingmulti},
                {"t3-brick", 2 * buildingmulti},
                {"t3-gears", 2 * buildingmulti}
            },
            result = "bio-butchery-3"
        }
    },

    -- Composter 2
    {
        type = "recipe",
        name = "composter-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"composter", 1},
                {"t2-plate", 2},
                {"t2-circuit", 2},
                {"t2-brick", 2},
                {"t2-gears", 2}
            },
            result = "composter-2"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"composter", 1},
                {"t2-plate", 2 * buildingmulti},
                {"t2-circuit", 2 * buildingmulti},
                {"t2-brick", 2 * buildingmulti},
                {"t2-gears", 2 * buildingmulti}
            },
            result = "composter-2"
        }
    },

    -- Composter 3
    {
        type = "recipe",
        name = "composter-3",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"composter-2", 1},
                {"t3-plate", 2},
                {"t3-circuit", 2},
                {"t3-brick", 2},
                {"t3-gears", 2}
            },
            result = "composter-3"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"composter-2", 1},
                {"t3-plate", 2 * buildingmulti},
                {"t3-circuit", 2 * buildingmulti},
                {"t3-brick", 2 * buildingmulti},
                {"t3-gears", 2 * buildingmulti}
            },
            result = "composter-3"
        }
    },

    -- Basic farm 2
    {
        type = "recipe",
        name = "crop-farm-2",
        normal = {
            energy_required = 5,
            enabled = false,
            ingredients = {
                {"crop-farm", 1},
                {"t1-plate", 8},
                {"t1-circuit", 2},
                {"t1-brick", 9},
                {"t1-pipe", 3}
            },
            result = "crop-farm-2"
        },
        expensive = {
            energy_required = 5 * buildingtime,
            enabled = false,
            ingredients = {
                {"crop-farm", 1},
                {"t1-plate", 8 * buildingmulti},
                {"t1-circuit", 2 * buildingmulti},
                {"t1-brick", 9 * buildingmulti},
                {"t1-pipe", 3 * buildingmulti}
            },
            result = "crop-farm-2"
        }
    },

    -- Basic farm 3
    {
        type = "recipe",
        name = "crop-farm-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"crop-farm-2", 1},
            {"t2-plate", 8},
            {"t2-circuit", 2},
            {"t2-brick", 9},
            {"t2-pipe", 3}
        },
        result = "crop-farm-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"crop-farm-2", 1},
            {"t2-plate", 8 * buildingmulti},
            {"t2-circuit", 2 * buildingmulti},
            {"t2-brick", 9 * buildingmulti},
            {"t2-pipe", 3 * buildingmulti}
        },
        result = "crop-farm-3"
        }
    },

    -- Temperate-environment farm 2
    {
        type = "recipe",
        name = "temperate-farm-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"temperate-farm", 1},
            {"temperate-upgrade", 1},
            {"t3-plate", 8},
            {"t3-circuit", 2},
            {"t3-brick", 9},
            {"t3-pipe", 3}
        },
        result = "temperate-farm-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"temperate-farm", 1},
            {"temperate-upgrade", 1},
            {"t3-plate", 8 * buildingmulti},
            {"t3-circuit", 2 * buildingmulti},
            {"t3-brick", 9 * buildingmulti},
            {"t3-pipe", 3 * buildingmulti}
        },
        result = "temperate-farm-2"
        }
    },

    -- Temperate-environment farm 3
    {
        type = "recipe",
        name = "temperate-farm-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"temperate-farm-2", 1},
            {"temperate-upgrade", 1},
            {"t4-plate", 8},
            {"t4-circuit", 2},
            {"t4-brick", 9},
            {"t4-pipe", 3}
        },
        result = "temperate-farm-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"temperate-farm-2", 1},
            {"temperate-upgrade", 1},
            {"t4-plate", 8 * buildingmulti},
            {"t4-circuit", 2 * buildingmulti},
            {"t4-brick", 9 * buildingmulti},
            {"t4-pipe", 3 * buildingmulti}
        },
        result = "temperate-farm-3"
        }
    },

    -- Desert-environment farm 2
    {
        type = "recipe",
        name = "desert-farm-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"desert-farm", 1},
            {"desert-upgrade", 1},
            {"t3-plate", 8},
            {"t3-circuit", 2},
            {"t3-brick", 9},
            {"t3-pipe", 3}
        },
        result = "desert-farm-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"desert-farm", 1},
            {"desert-upgrade", 1},
            {"t3-plate", 8 * buildingmulti},
            {"t3-circuit", 2 * buildingmulti},
            {"t3-brick", 9 * buildingmulti},
            {"t3-pipe", 3 * buildingmulti}
        },
        result = "desert-farm-2"
        }
    },

    -- Desert-environment farm 3
    {
        type = "recipe",
        name = "desert-farm-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"desert-farm-2", 1},
            {"desert-upgrade", 1},
            {"t4-plate", 8},
            {"t4-circuit", 2},
            {"t4-brick", 9},
            {"t4-pipe", 3}
        },
        result = "desert-farm-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"desert-farm-2", 1},
            {"desert-upgrade", 1},
            {"t4-plate", 8 * buildingmulti},
            {"t4-circuit", 2 * buildingmulti},
            {"t4-brick", 9 * buildingmulti},
            {"t4-pipe", 3 * buildingmulti}
        },
        result = "desert-farm-3"
        }
    },

    -- Swamp-environment farm 2
    {
        type = "recipe",
        name = "swamp-farm-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"swamp-farm", 1},
            {"swamp-upgrade", 1},
            {"t3-plate", 8},
            {"t3-circuit", 2},
            {"t3-brick", 9},
            {"t3-pipe", 3}
        },
        result = "swamp-farm-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"swamp-farm", 1},
            {"swamp-upgrade", 1},
            {"t3-plate", 8 * buildingmulti},
            {"t3-circuit", 2 * buildingmulti},
            {"t3-brick", 9 * buildingmulti},
            {"t3-pipe", 3 * buildingmulti}
        },
        result = "swamp-farm-2"
        }
    },

    -- Swamp-environment farm 3
    {
        type = "recipe",
        name = "swamp-farm-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"swamp-farm-2", 1},
            {"swamp-upgrade", 1},
            {"t4-plate", 8},
            {"t4-circuit", 2},
            {"t4-brick", 9},
            {"t4-pipe", 3}
        },
        result = "swamp-farm-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"swamp-farm-2", 1},
            {"swamp-upgrade", 1},
            {"t4-plate", 8 * buildingmulti},
            {"t4-circuit", 2 * buildingmulti},
            {"t4-brick", 9 * buildingmulti},
            {"t4-pipe", 3 * buildingmulti}
        },
        result = "swamp-farm-3"
        }
    },

    -- Hatchery 2
    {
        type = "recipe",
        name = "bio-hatchery-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-hatchery", 1},
            {"t2-plate", 2},
            {"t2-circuit", 4},
            {"t2-brick", 2}
        },
        result = "bio-hatchery-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-hatchery", 1},
            {"t2-plate", 2 * buildingmulti},
            {"t2-circuit", 4 * buildingmulti},
            {"t2-brick", 2 * buildingmulti}
        },
        result = "bio-hatchery-2"
        }
    },

    -- Hatchery 3
    {
        type = "recipe",
        name = "bio-hatchery-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-hatchery-2", 1},
            {"t3-plate", 2},
            {"t3-circuit", 4},
            {"t3-brick", 2}
        },
        result = "bio-hatchery-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-hatchery-2", 1},
            {"t3-plate", 2 * buildingmulti},
            {"t3-circuit", 4 * buildingmulti},
            {"t3-brick", 2 * buildingmulti}
        },
        result = "bio-hatchery-3"
        }
    },

    -- Nutrient extractor 2
    {
        type = "recipe",
        name = "nutrient-extractor-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"nutrient-extractor", 1},
            {"t2-plate", 1},
            {"t2-circuit", 2},
            {"t2-brick", 1},
            {"t2-pipe", 2},
            {"t2-gears", 2}
        },
        result = "nutrient-extractor-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"nutrient-extractor", 1},
            {"t2-plate", 1 * buildingmulti},
            {"t2-circuit", 2 * buildingmulti},
            {"t2-brick", 1 * buildingmulti},
            {"t2-pipe", 2 * buildingmulti},
            {"t2-gears", 2 * buildingmulti}
        },
        result = "nutrient-extractor-2"
        }
    },

    -- Nutrient extractor 3
    {
        type = "recipe",
        name = "nutrient-extractor-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"nutrient-extractor-2", 1},
            {"t3-plate", 1},
            {"t3-circuit", 2},
            {"t3-brick", 1},
            {"t3-pipe", 2},
            {"t3-gears", 2}
        },
        result = "nutrient-extractor-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"nutrient-extractor-2", 1},
            {"t3-plate", 1 * buildingmulti},
            {"t3-circuit", 2 * buildingmulti},
            {"t3-brick", 1 * buildingmulti},
            {"t3-pipe", 2 * buildingmulti},
            {"t3-gears", 2 * buildingmulti}
        },
        result = "nutrient-extractor-3"
        }
    },

    -- Fish tank 2
    {
        type = "recipe",
        name = "bio-refugium-fish-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-refugium-fish", 1},
            {"t2-plate", 2},
            {"t2-circuit", 5},
            {"t2-brick", 4},
            {"t2-pipe", 25}
        },
        result = "bio-refugium-fish-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-refugium-fish", 1},
            {"t2-plate", 10 * buildingmulti},
            {"t2-circuit", 5 * buildingmulti},
            {"t2-brick", 4 * buildingmulti},
            {"t2-pipe", 25 * buildingmulti}
        },
        result = "bio-refugium-fish-2"
        }
    },

    -- Fish tank 3
    {
        type = "recipe",
        name = "bio-refugium-fish-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-refugium-fish-2", 1},
            {"t3-plate", 2},
            {"t3-circuit", 5},
            {"t3-brick", 4},
            {"t3-pipe", 25}
        },
        result = "bio-refugium-fish-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-refugium-fish", 1},
            {"t3-plate", 10 * buildingmulti},
            {"t3-circuit", 5 * buildingmulti},
            {"t3-brick", 4 * buildingmulti},
            {"t3-pipe", 25 * buildingmulti}
        },
        result = "bio-refugium-fish-3"
        }
    },

    -- Puffer refugium 2
    {
        type = "recipe",
        name = "bio-refugium-puffer-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-refugium-puffer", 1},
            {"t4-plate", 4},
            {"t4-circuit", 4},
            {"t4-brick", 3},
            {"t4-pipe", 11}
        },
        result = "bio-refugium-puffer-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-refugium-puffer", 1},
            {"t4-plate", 4 * buildingmulti},
            {"t4-circuit", 4 * buildingmulti},
            {"t4-brick", 3 * buildingmulti},
            {"t4-pipe", 11 * buildingmulti}
        },
        result = "bio-refugium-puffer-2"
        }
    },

    -- Puffer refugium 3
    {
        type = "recipe",
        name = "bio-refugium-puffer-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-refugium-puffer-2", 1},
            {"t5-plate", 4},
            {"t5-circuit", 4},
            {"t5-brick", 3},
            {"t5-pipe", 11}
        },
        result = "bio-refugium-puffer-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-refugium-puffer-2", 1},
            {"t5-plate", 4 * buildingmulti},
            {"t5-circuit", 4 * buildingmulti},
            {"t5-brick", 3 * buildingmulti},
            {"t5-pipe", 11 * buildingmulti}
        },
        result = "bio-refugium-puffer-3"
        }
    },

    -- Biter refugium 2
    {
        type = "recipe",
        name = "bio-refugium-biter-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-refugium-biter", 1},
            {"t5-plate", 10},
            {"t5-circuit", 4},
            {"t5-brick", 19},
            {"t5-pipe", 11}
        },
        result = "bio-refugium-biter-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-refugium-biter", 1},
            {"t5-plate", 10 * buildingmulti},
            {"t5-circuit", 4 * buildingmulti},
            {"t5-brick", 19 * buildingmulti},
            {"t5-pipe", 11 * buildingmulti}
        },
        result = "bio-refugium-biter-2"
        }
    },

    -- Biter refugium 3
    {
        type = "recipe",
        name = "bio-refugium-biter-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"bio-refugium-biter-2", 1},
            {"t6-plate", 10},
            {"t5-circuit", 4},
            {"t6-brick", 19},
            {"t6-pipe", 11}
        },
        result = "bio-refugium-biter-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"bio-refugium-biter-2", 1},
            {"t6-plate", 10 * buildingmulti},
            {"t5-circuit", 4 * buildingmulti},
            {"t6-brick", 19 * buildingmulti},
            {"t6-pipe", 11 * buildingmulti}
        },
        result = "bio-refugium-biter-3"
        }
    },

    -- Seed extractor 2
    {
        type = "recipe",
        name = "seed-extractor-2",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"seed-extractor", 1},
            {"t2-plate", 1},
            {"t2-circuit", 4},
            {"t2-brick", 1},
            {"t2-gears", 2}
        },
        result = "seed-extractor-2"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"seed-extractor", 1},
            {"t2-plate", 1 * buildingmulti},
            {"t2-circuit", 4 * buildingmulti},
            {"t2-brick", 1 * buildingmulti},
            {"t2-gears", 2 * buildingmulti}
        },
        result = "seed-extractor-2"
        }
    },

    -- Seed extractor 3
    {
        type = "recipe",
        name = "seed-extractor-3",
        normal = {
        energy_required = 5,
        enabled = false,
        ingredients = {
            {"seed-extractor-2", 1},
            {"t3-plate", 1},
            {"t3-circuit", 4},
            {"t3-brick", 1},
            {"t3-gears", 2}
        },
        result = "seed-extractor-3"
        },
        expensive = {
        energy_required = 5 * buildingtime,
        enabled = false,
        ingredients = {
            {"seed-extractor-2", 1},
            {"t3-plate", 1 * buildingmulti},
            {"t3-circuit", 4 * buildingmulti},
            {"t3-brick", 1 * buildingmulti},
            {"t3-gears", 2 * buildingmulti}
        },
        result = "seed-extractor-3"
        }
    },
})