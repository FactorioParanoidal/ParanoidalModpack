data:extend {{
    type = "recipe",
    name = "maraxsis-geothermal-sulfur",
    ingredients = {
        {type = "fluid", name = "maraxsis-supercritical-steam", amount = 30},
        {type = "fluid", name = "maraxsis-brackish-water",  amount = 30},
    },
    results = {
        {type = "item", name = "sulfur", amount = 2},
    },
    energy_required = 3,
    enabled = false,
    categories = {"maraxsis-geothermal-generator"},
    icon = "__maraxsis__/graphics/icons/geothermal-sulfur.png",
    icon_size = 64,
    allow_productivity = true,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-bio-oil",
    categories = {"chemistry", "organic"},
    ingredients = {
        {type = "fluid", name = "steam", amount = 100},
        {type = "item", name = "carbon", amount = 2},
        {type = "item", name = "maraxsis-fish-oil", amount = 1},
    },
    results = {
        {type = "fluid", name = "heavy-oil", amount = 200},
    },
    main_product = "heavy-oil",
    allow_productivity = true,
    auto_recycle = false,
    energy_required = 5,
    enabled = false,
    icon = "__maraxsis__/graphics/icons/bio-oil.png"
}}

data:extend { {
    type = "recipe",
    name = "maraxsis-holmium-recrystalization",
    categories = { "maraxsis-hydro-plant" },
    ingredients = {
        { type = "fluid", name = "holmium-solution", amount = 50 },
        { type = "item",  name = "holmium-ore",      amount = 1 },
    },
    results = {
        { type = "item", name = "holmium-plate", amount = 5 },
    },
    energy_required = data.raw.recipe["holmium-plate"].energy_required * 5,
    caregories = { "maraxsis-hydro-plant" },
    enabled = false,
    auto_recycle = false,
    icons = {
        {
            icon = "__space-age__/graphics/icons/holmium-plate.png",
            icon_size = 64,
        },
        {
            icon = "__space-age__/graphics/icons/fluid/holmium-solution.png",
            icon_size = 64,
            size = 0.5,
            shift = { -8, -8 }
        },
    }
} }
