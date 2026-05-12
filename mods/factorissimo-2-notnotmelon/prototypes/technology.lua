local F = "__factorissimo-2-notnotmelon__"
local pf = "p-q-"

local starting_planet = "nauvis"
if mods["any-planet-start"] then
    starting_planet = settings.startup["aps-planet"].value
    if starting_planet == "none" then starting_planet = "nauvis" end
elseif mods["pystellarexpedition"] then
    starting_planet = "frans-orbit"
end

local effects = {
    {
        type = "unlock-recipe",
        recipe = "factory-1"
    }
}

if not mods["solarsystemplusplus"] then
    effects[#effects + 1] = {
        type = "unlock-space-location",
        space_location = starting_planet .. "-factory-floor",
        use_icon_overlay_constant = false,
    }
end

-- Factory buildings

data:extend {{
    type = "technology",
    name = "factory-architecture-t1",
    icon = F .. "/graphics/technology/factory-architecture-1.png",
    icon_size = 256,
    prerequisites = {"stone-wall", "logistics"},
    effects = effects,
    unit = {
        count = 200,
        ingredients = {{"automation-science-pack", 1}},
        time = 30
    },
    order = pf .. "a-a",
}}
data:extend {{
    type = "technology",
    name = "factory-architecture-t2",
    icon = F .. "/graphics/technology/factory-architecture-2.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t1", "steel-processing", "electric-energy-distribution-1"},
    effects = {
        {
            type = "unlock-recipe",
            recipe = "factory-2",
        }
    },
    unit = {
        count = 600,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
        time = 45
    },
    order = pf .. "a-b",
}}
data:extend {{
    type = "technology",
    name = "factory-architecture-t3",
    icon = F .. "/graphics/technology/factory-architecture-3.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t2", "concrete", "electric-energy-distribution-2", "production-science-pack"},
    effects = {
        {
            type = "unlock-recipe",
            recipe = "factory-3",
        }
    },
    unit = {
        count = 2000,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}},
        time = 60
    },
    order = pf .. "a-c",
}}

if (mods["space-exploration"] or mods["space-age"]) and settings.startup["Factorissimo2-space-architecture"].value then
    local unit
    local prerequisites = {"factory-architecture-t3", "production-science-pack", "utility-science-pack"}
    if mods["space-exploration"] then
        unit = {
            count = 3000,
            ingredients = {
                {"automation-science-pack",      1},
                {"logistic-science-pack",        1},
                {"chemical-science-pack",        1},
                {"se-rocket-science-pack",       1},
                {"space-science-pack",           1},
                {"production-science-pack",      1},
                {"utility-science-pack",         1},
                {"se-astronomic-science-pack-1", 1},
            },
            time = 60
        }
        prerequisites[#prerequisites + 1] = "se-aeroframe-pole"
        prerequisites[#prerequisites + 1] = "se-space-solar-panel"
        prerequisites[#prerequisites + 1] = "se-space-platform-scaffold"
    elseif mods["space-age"] and not mods["space-is-fake"] then
        unit = {
            count = 5000,
            ingredients = {
                {"automation-science-pack",      1},
                {"logistic-science-pack",        1},
                {"chemical-science-pack",        1},
                {"production-science-pack",      1},
                {"utility-science-pack",         1},
                {"space-science-pack",           1},
                {"metallurgic-science-pack",     1},
                {"electromagnetic-science-pack", 1},
                {"agricultural-science-pack",    1},
                {"cryogenic-science-pack",       1},
                {"promethium-science-pack",      1},
            },
            time = 120
        }
        prerequisites[#prerequisites + 1] = "promethium-science-pack"
        prerequisites[#prerequisites + 1] = "factory-upgrade-greenhouse"
        prerequisites[#prerequisites + 1] = "factory-connection-type-heat"
        prerequisites[#prerequisites + 1] = "factory-upgrade-borehole-pump"
        prerequisites[#prerequisites + 1] = "solar-energy"
    else
        error("unreachable")
    end

    data:extend {{
        type = "technology",
        name = "factory-space-architecture",
        icon = F .. "/graphics/technology/factory-space-architecture.png",
        icon_size = 256,
        prerequisites = prerequisites,
        effects = {
            {
                type = "unlock-recipe",
                recipe = "space-factory-1",
            },
            {
                type = "unlock-recipe",
                recipe = "space-factory-2",
            },
            {
                type = "unlock-recipe",
                recipe = "space-factory-3",
            },
        },
        unit = unit,
        order = pf .. "a-d",
    }}
end

-- Connection types

data:extend {{
    type = "technology",
    name = "factory-connection-type-fluid",
    icon = F .. "/graphics/technology/factory-connection-type-fluid.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t1"}, -- 'fluid-handling'
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 100,
        ingredients = {{"automation-science-pack", 1}},
        time = 30
    },
    order = pf .. "c-a",
}}
data:extend {{
    type = "technology",
    name = "factory-connection-type-chest",
    icon = F .. "/graphics/technology/factory-connection-type-chest.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t2", "logistics-2"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 200,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
        time = 30
    },
    order = pf .. "c-b",
}}
data:extend {{
    type = "technology",
    name = "factory-connection-type-circuit",
    icon = F .. "/graphics/technology/factory-connection-type-circuit.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t2", "circuit-network", "logistic-science-pack"},
    effects = {{type = "unlock-recipe", recipe = "factory-circuit-connector"}},
    unit = {
        count = 300,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
        time = 30
    },
    order = pf .. "c-c",
}}
data:extend {{
    type = "technology",
    name = "factory-connection-type-heat",
    icon = F .. "/graphics/technology/factory-connection-type-heat.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t2"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 600,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
        time = 45
    },
    order = pf .. "c-d",
}}

-- Utility upgrades

data:extend {{
    type = "technology",
    name = "factory-interior-upgrade-lights",
    icon = F .. "/graphics/technology/factory-interior-upgrade-lights.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t1", "lamp"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 50,
        ingredients = {{"automation-science-pack", 1}},
        time = 30
    },
    order = pf .. "d-a",
}}
data:extend {{
    type = "technology",
    name = "factory-interior-upgrade-display",
    icon = F .. "/graphics/technology/factory-interior-upgrade-display.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t2", "lamp"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 100,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
        time = 30
    },
    order = pf .. "d-b",
}}
data:extend {{
    type = "technology",
    name = "factory-interior-upgrade-roboport",
    icon = F .. "/graphics/technology/factory-interior-upgrade-roboport.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t2", "construction-robotics"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 1000,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
        time = 45
    },
    order = pf .. "d-d",
}}
-- Recursion!
data:extend {{
    type = "technology",
    name = "factory-recursion-t1",
    icon = F .. "/graphics/technology/factory-recursion-1.png",
    icon_size = 256,
    prerequisites = {"factory-architecture-t2", "logistics-2"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 2000,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
        time = 60
    },
    order = pf .. "b-a",
}}
data:extend {{
    type = "technology",
    name = "factory-recursion-t2",
    icon = F .. "/graphics/technology/factory-recursion-2.png",
    icon_size = 256,
    prerequisites = {"factory-recursion-t1", "factory-architecture-t3"},
    effects = {{
        type = "nothing",
        effect_description = ""
    }},
    unit = {
        count = 5000,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}},
        time = 60
    },
    order = pf .. "b-b",
}}
