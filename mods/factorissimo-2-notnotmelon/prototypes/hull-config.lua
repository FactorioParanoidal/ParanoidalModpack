-- Paranoidal: levels of the reinforced hull of factory buildings. Plain data, shared by
-- prototypes/hull.lua (data) and prototypes/hull-icons.lua (data-final-fixes).

return {
    {
        level = 1,
        reduction = 20,
        prerequisites = {"factory-architecture-t1", "stone-wall"},
        optional_prerequisites = {},
        count = 100,
        time = 30,
        ingredients = {{"automation-science-pack", 1}},
        walls = {"stone-wall"},
    },
    {
        level = 2,
        reduction = 35,
        prerequisites = {"factory-hull-1", "factory-architecture-t2", "military-science-pack"},
        optional_prerequisites = {"steel-walls"},
        count = 250,
        time = 45,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}},
        walls = {"steel-wall", "concrete-wall", "stone-wall"},
    },
    {
        level = 3,
        reduction = 50,
        prerequisites = {"factory-hull-2", "factory-architecture-t3"},
        optional_prerequisites = {"bob-reinforced-wall", "military-3"},
        count = 500,
        time = 60,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}},
        walls = {"bob-reinforced-wall", "steel-wall", "concrete-wall", "stone-wall"},
    },
}
