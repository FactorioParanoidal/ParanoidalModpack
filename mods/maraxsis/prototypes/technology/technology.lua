data:extend {{
    type = "technology",
    name = "planet-discovery-maraxsis",
    icons = util.technology_icon_constant_planet("__maraxsis__/graphics/technology/maraxsis.png"),
    icon_size = 256,
    essential = true,
    localised_description = {"space-location-description.maraxsis"},
    effects = {
        {
            type = "unlock-space-location",
            space_location = "maraxsis",
            use_icon_overlay_constant = true
        },
        {
            type = "unlock-space-location",
            space_location = "maraxsis-trench",
            use_icon_overlay_constant = true
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-diesel-submarine",
        },
    },
    prerequisites = {
        "advanced-asteroid-processing",
        "rocket-turret",
        "cliff-explosives",
        "electromagnetic-science-pack",
        "quality-module-3",
        "fish-breeding"
    },
    unit = {
        count = 3000,
        ingredients = {
            {"automation-science-pack",      1},
            {"logistic-science-pack",        1},
            {"chemical-science-pack",        1},
            {"space-science-pack",           1},
            {"production-science-pack",      1},
            {"utility-science-pack",         1},
            {"metallurgic-science-pack",     1},
            {"electromagnetic-science-pack", 1},
            {"agricultural-science-pack",    1},
        },
        time = 60,
    },
    order = "ea[maraxsis]",
}}

if data.raw.technology["quality-module"] then
    table.insert(data.raw.technology["planet-discovery-maraxsis"].prerequisites, "quality-module")
end

if settings.startup["sp-enable-spiderling"].value then
    table.insert(data.raw.technology["planet-discovery-maraxsis"].prerequisites, "sp-spidertron-automation")
end

data:extend {{
    type = "technology",
    name = "cargo-landing-pad-capacity",
    icons = util.technology_icon_constant_capacity(data.raw.technology["space-platform"].icon),
    icon_size = data.raw.technology["space-platform"].icon_size,
    effects = {
        {
            type = "cargo-landing-pad-count",
            modifier = 1,
            icons = {
                {
                    icon = "__maraxsis__/graphics/icons/cargo-landing-pad-capacity.png",
                    icon_size = 64,
                }
            }
        }
    },
    prerequisites = {"maraxsis-project-seadragon", "space-science-pack", "production-science-pack", "utility-science-pack", "metallurgic-science-pack", "electromagnetic-science-pack", "agricultural-science-pack"},
    unit = {
        count_formula = "5^(L-1)*5000",
        ingredients = {
            {"automation-science-pack",      1},
            {"logistic-science-pack",        1},
            {"chemical-science-pack",        1},
            {"space-science-pack",           1},
            {"production-science-pack",      1},
            {"utility-science-pack",         1},
            {"metallurgic-science-pack",     1},
            {"electromagnetic-science-pack", 1},
            {"agricultural-science-pack",    1},
            {"hydraulic-science-pack",       1},
        },
        time = 60
    },
    max_level = "infinite",
    order = "ex[maraxsis]",
}}
