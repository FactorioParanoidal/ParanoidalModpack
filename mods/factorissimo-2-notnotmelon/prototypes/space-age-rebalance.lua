-- this file rebalances the factorissimo tech tree for space age
-- t3 factory buildings are unlocked on vulcanus now!

if not mods["space-age"] then return end
if mods["space-is-fake"] then return end
if settings.startup["Factorissimo2-cheap-research"].value then return end

data.raw.technology["factory-architecture-t2"].unit = {
    count = 600,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"chemical-science-pack",   1},
    },
    time = 45
}
data.raw.technology["factory-architecture-t2"].prerequisites = {
    "factory-architecture-t1",
    "chemical-science-pack",
    "electric-energy-distribution-1",
}

data.raw.technology["factory-architecture-t3"].unit = {
    count = 2000,
    ingredients = {
        {"automation-science-pack",  1},
        {"logistic-science-pack",    1},
        {"chemical-science-pack",    1},
        {"space-science-pack",       1},
        {"utility-science-pack",     1},
        {"metallurgic-science-pack", 1},
    },
    time = 60
}
data.raw.technology["factory-architecture-t3"].prerequisites = {
    "metallurgic-science-pack",
    "factory-architecture-t2",
    "utility-science-pack",
}

data.raw.recipe["factory-3"].ingredients[2] = {type = "item", name = "tungsten-plate", amount = 2000} -- swap out the steel for tungsten

data.raw.technology["factory-recursion-t2"].unit = {
    count = 5000,
    ingredients = {
        {"automation-science-pack",  1},
        {"logistic-science-pack",    1},
        {"chemical-science-pack",    1},
        {"space-science-pack",       1},
        {"production-science-pack",  1},
        {"utility-science-pack",     1},
        {"metallurgic-science-pack", 1},
    },
    time = 60
}
data.raw.technology["factory-recursion-t2"].prerequisites = {
    "factory-architecture-t3",
    "production-science-pack",
    "factory-recursion-t1",
}

data.raw.technology["factory-connection-type-heat"].unit = {
    count = 5000,
    ingredients = {
        {"automation-science-pack",      1},
        {"logistic-science-pack",        1},
        {"chemical-science-pack",        1},
        {"space-science-pack",           1},
        {"production-science-pack",      1},
        {"utility-science-pack",         1},
        {"metallurgic-science-pack",     1},
        {"agricultural-science-pack",    1},
        {"electromagnetic-science-pack", 1},
        {"cryogenic-science-pack",       1},
    },
    time = 60
}
data.raw.technology["factory-connection-type-heat"].prerequisites = {
    "factory-architecture-t3",
    "cryogenic-science-pack",
}

data.raw.technology["factory-connection-type-chest"].unit = {
    count = 1000,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"chemical-science-pack",   1},
    },
    time = 45
}
data.raw.technology["factory-connection-type-chest"].prerequisites = {
    "factory-architecture-t2",
    "logistic-system"
}

data.raw.technology["factory-connection-type-circuit"].unit = {
    count = 200,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
    },
    time = 30
}
data.raw.technology["factory-connection-type-circuit"].prerequisites = {
    "factory-architecture-t1",
    "circuit-network"
}

data.raw.technology["factory-recursion-t1"].unit = {
    count = 2000,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"chemical-science-pack",   1},
        {"space-science-pack",      1},
    },
    time = 45
}
data.raw.technology["factory-recursion-t1"].prerequisites = {
    "factory-architecture-t2",
}

data.raw.technology["factory-interior-upgrade-display"].unit = {
    count = 200,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
    },
    time = 30
}
data.raw.technology["factory-interior-upgrade-display"].prerequisites = {
    "factory-interior-upgrade-lights",
    "logistic-science-pack"
}

data.raw.technology["factory-interior-upgrade-roboport"].unit = {
    count = 1000,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"chemical-science-pack",   1},
    },
    time = 45
}

data.raw.technology["factory-upgrade-greenhouse"].prerequisites = {
    "factory-architecture-t3",
    "electromagnetic-science-pack",
    "overgrowth-soil",
    "factory-interior-upgrade-lights",
}
data.raw.technology["factory-upgrade-greenhouse"].unit = {
    count = 2000,
    ingredients = {
        {"automation-science-pack",      1},
        {"logistic-science-pack",        1},
        {"chemical-science-pack",        1},
        {"space-science-pack",           1},
        {"production-science-pack",      1},
        {"utility-science-pack",         1},
        {"agricultural-science-pack",    1},
        {"electromagnetic-science-pack", 1},
    },
    time = 60
}

data.raw["storage-tank"]["factory-1"].surface_conditions = {{
    property = "gravity",
    min = 0.1
}}
data.raw["storage-tank"]["factory-2"].surface_conditions = {{
    property = "gravity",
    min = 0.1
}}
data.raw["storage-tank"]["factory-3"].surface_conditions = {{
    property = "gravity",
    min = 0.1
}}
data.raw["electric-pole"]["factory-circuit-connector"].surface_conditions = {{
    property = "gravity",
    min = 0.1
}}

if not settings.startup["Factorissimo2-space-architecture"].value then return end

-- https://github.com/notnotmelon/factorissimo-2-notnotmelon/issues/247
data.raw["electric-pole"]["factory-circuit-connector"].surface_conditions = {}

data.raw["storage-tank"]["space-factory-1"].surface_conditions = {{
    property = "gravity",
    max = 0.1
}}
data.raw["storage-tank"]["space-factory-2"].surface_conditions = {{
    property = "gravity",
    max = 0.1
}}
data.raw["storage-tank"]["space-factory-3"].surface_conditions = {{
    property = "gravity",
    max = 0.1
}}
data.raw["recipe"]["space-factory-1"].surface_conditions = {{
    property = "gravity",
    max = 0.1
}}
data.raw["recipe"]["space-factory-2"].surface_conditions = {{
    property = "gravity",
    max = 0.1
}}
data.raw["recipe"]["space-factory-3"].surface_conditions = {{
    property = "gravity",
    max = 0.1
}}
