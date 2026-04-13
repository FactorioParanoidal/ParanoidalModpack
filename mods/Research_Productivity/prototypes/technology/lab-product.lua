data:extend({{
    type = "technology",
    name = "laboratory-productivity-1",
    icon_size = 128,
    icon = "__Research_Productivity__/graphics/technology/lab-product-tech.png",
    effects = {{
        type = "laboratory-productivity",
        modifier = 0.1
    }},
    prerequisites = {"automation-2"},
    unit = {
        count_formula = "250*L",
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
        time = 60
    },
    upgrade = true,
    max_level = 1,
    order = "c-k-f-f"
}, {
    type = "technology",
    name = "laboratory-productivity-2",
    icon_size = 128,
    icon = "__Research_Productivity__/graphics/technology/lab-product-tech.png",
    effects = {{
        type = "laboratory-productivity",
        modifier = 0.1
    }},
    prerequisites = {"chemical-science-pack", "laboratory-productivity-1"},
    unit = {
        count_formula = "250*L",
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
        time = 60
    },
    upgrade = true,
    max_level = 2,
    order = "c-k-f-f"
}, {
    type = "technology",
    name = "laboratory-productivity-3",
    icon_size = 128,
    icon = "__Research_Productivity__/graphics/technology/lab-product-tech.png",
    effects = {{
        type = "laboratory-productivity",
        modifier = 0.1
    }},
    prerequisites = {"production-science-pack", "utility-science-pack", "laboratory-productivity-2"},
    unit = {
        count_formula = "1000",
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
                       {"production-science-pack", 1}, {"utility-science-pack", 1}},
        time = 60
    },
    upgrade = true,
    max_level = 3,
    order = "c-k-f-f"
}})

-- enable exponential growth for infinite levels if the user enabled the setting 
if settings.startup["researchproductivity-exponential"].value then
    data:extend({{
        type = "technology",
        name = "laboratory-productivity-4",
        icon_size = 128,
        icon = "__Research_Productivity__/graphics/technology/lab-product-tech.png",
        effects = {{
            type = "laboratory-productivity",
            modifier = 0.1
        }},
        prerequisites = {"space-science-pack", "laboratory-productivity-3"},
        unit = {
            count_formula = "2^(L-3)*1000",
            ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
                           {"production-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1}},
            time = 60
        },
        upgrade = true,
        max_level = "infinite",
        order = "c-k-f-f"
    }})
else 
    data:extend({{
        type = "technology",
        name = "laboratory-productivity-4",
        icon_size = 128,
        icon = "__Research_Productivity__/graphics/technology/lab-product-tech.png",
        effects = {{
            type = "laboratory-productivity",
            modifier = 0.1
        }},
        prerequisites = {"space-science-pack", "laboratory-productivity-3"},
        unit = {
            count_formula = "2500*(L-3)",
            ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
                           {"production-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1}},
            time = 60
        },
        upgrade = true,
        max_level = "infinite",
        order = "c-k-f-f"
    }})
end
