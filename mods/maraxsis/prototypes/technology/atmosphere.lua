data:extend {{
    type = "fluid",
    name = "maraxsis-atmosphere",
    default_temperature = 0,
    max_temperature = 100,
    heat_capacity = "1kJ",
    base_flow_rate = data.raw.fluid.steam.base_flow_rate,
    base_color = {1, 1, 1},
    flow_color = {0.5, 0.5, 1},
    icon = "__maraxsis__/graphics/icons/atmosphere.png",
    icon_size = 64,
    gas_temperature = 25,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-atmosphere",
    categories = {"chemistry"},
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "fluid", name = "maraxsis-atmosphere", amount = 100, temperature = 25}
    },
    enabled = false,
    auto_recycle = false,
    main_product = "maraxsis-atmosphere",
    surface_conditions = {{
        property = "pressure",
        min = 100,
        max = 4000,
    }}
}}

data:extend {{
    type = "technology",
    name = "maraxsis-liquid-atmosphere",
    icon = "__maraxsis__/graphics/technology/liquid-atmosphere.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-liquid-atmosphere"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-liquid-atmosphere-decompression"
        },
        {
            type = "unlock-recipe",
            recipe = "empty-maraxsis-liquid-atmosphere-barrel"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-liquid-atmosphere-barrel"
        }
    },
    prerequisites = {"cryogenic-science-pack", "maraxsis-project-seadragon"},
    unit = {
        count = 5000,
        ingredients = {
            {"hydraulic-science-pack", 1},
            {"cryogenic-science-pack", 1},
        },
        time = 60
    },
    order = "eb[liquid-atmosphere]",
    localised_name = {"fluid-name.maraxsis-liquid-atmosphere"}
}}

data:extend {{
    type = "fluid",
    name = "maraxsis-liquid-atmosphere",
    default_temperature = -200,
    max_temperature = -196,
    heat_capacity = "1kJ",
    base_flow_rate = data.raw.fluid.steam.base_flow_rate,
    flow_color = {1, 1, 1},
    base_color = {0.5, 0.5, 1},
    icon = "__maraxsis__/graphics/icons/liquid-atmosphere.png",
    icon_size = 64,
    gas_temperature = -196,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-liquid-atmosphere",
    categories = {"cryogenics"},
    energy_required = 10,
    ingredients = {
        {type = "fluid", name = "maraxsis-atmosphere", amount = 100},
        {type = "fluid", name = "fluoroketone-cold",   amount = 20}
    },
    results = {
        {type = "fluid", name = "maraxsis-liquid-atmosphere", amount = 1},
        {type = "fluid", name = "fluoroketone-hot",           amount = 20, ignored_by_stats = 20, ignored_by_productivity = 20}
    },
    enabled = false,
    main_product = "maraxsis-liquid-atmosphere",
    show_amount_in_title = true,
    auto_recycle = false,
    allow_decomposition = false,
    allow_productivity = true,
    surface_conditions = {{
        property = "pressure",
        min = 100,
        max = 600,
    }}
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-liquid-atmosphere-decompression",
    categories = {"chemistry"},
    energy_required = 9,
    ingredients = {
        {type = "fluid", name = "maraxsis-liquid-atmosphere", amount = 1}
    },
    results = {
        {type = "fluid", name = "maraxsis-atmosphere", amount = 90, temperature = 25, ignored_by_stats = 90, ignored_by_productivity = 90}
    },
    enabled = false,
    main_product = "maraxsis-atmosphere",
    show_amount_in_title = true,
    allow_decomposition = false,
    allow_productivity = true,
    auto_recycle = false,
}}
