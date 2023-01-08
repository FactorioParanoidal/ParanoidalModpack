if not mods["Clowns-Extended-Minerals"] then
    local prerequisite = data.raw.technology["water-washing-2"]
    if prerequisite then
        data:extend({
            -- Water washing 3
            {
                type = "technology",
                name = "water-washing-3",
                icons = util.copy(prerequisite.icons),
                icon = util.copy(prerequisite.icon),
                icon_size = util.copy(prerequisite.icon_size),
                icon_mipmaps = util.copy(prerequisite.icon_mipmaps),
                prerequisites = {
                    "water-washing-2",
                },
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = "washing-plant-3"
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
                    time = 15
                },
                order = "c-a"
            },
        })
    end
end

if not mods["Clowns-Processing"] then
    local prerequisite = data.raw.technology["water-treatment-4"]
    if prerequisite then
        data:extend({
            {
                type = "technology",
                name = "water-treatment-5",
                icons = util.copy(prerequisite.icons),
                icon = util.copy(prerequisite.icon),
                icon_size = util.copy(prerequisite.icon_size),
                icon_mipmaps = util.copy(prerequisite.icon_mipmaps),
                prerequisites = {
                    "water-treatment-4",
                },
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = "hydro-plant-4"
                    },
                    {
                        type = "unlock-recipe",
                        recipe = "salination-plant-3"
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
    end
end


local prerequisite = data.raw.technology["water-washing-3"]
if prerequisite then
    data:extend({
        -- Water washing 4
        {
            type = "technology",
            name = "water-washing-4",
            icons = util.copy(prerequisite.icons),
            icon = util.copy(prerequisite.icon),
            icon_size = util.copy(prerequisite.icon_size),
            icon_mipmaps = util.copy(prerequisite.icon_mipmaps),
            prerequisites = {
                "water-washing-3",
            },
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "washing-plant-4"
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
    })
end

local prerequisite = data.raw.technology["advanced-ore-refining-4"]
if prerequisite then
    data:extend({
        -- Advanced ore refining 5
        {
            type = "technology",
            name = "advanced-ore-refining-5",
            icons = util.copy(prerequisite.icons),
            icon = util.copy(prerequisite.icon),
            icon_size = util.copy(prerequisite.icon_size),
            icon_mipmaps = util.copy(prerequisite.icon_mipmaps),
            prerequisites = {
                "advanced-ore-refining-4",
            },
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "ore-crusher-4"
                },
                {
                    type = "unlock-recipe",
                    recipe = "ore-floatation-cell-4"
                },
                {
                    type = "unlock-recipe",
                    recipe = "ore-leaching-plant-4"
                },
                {
                    type = "unlock-recipe",
                    recipe = "ore-refinery-3"
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
    })
end