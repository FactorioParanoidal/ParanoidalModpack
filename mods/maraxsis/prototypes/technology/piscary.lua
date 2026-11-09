data:extend {{
    type = "technology",
    name = "maraxsis-piscary",
    icon = "__maraxsis__/graphics/technology/piscary.png",
    icon_size = 256,
    effects = {},
    prerequisites = {"maraxsis-glassworking", "maraxsis-hydro-plant"},
    research_trigger = {
        type = "craft-item",
        item = "maraxsis-pressure-dome"
    },
    order = "ed[piscary]",
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-carbon",
    enabled = false,
    energy_required = 4,
    ingredients = {
        {type = "item", name = "maraxsis-tropical-fish", amount = 1},
    },
    results = {
        {type = "item", name = "carbon", amount = 8},
    },
    categories = {"organic", "smelting"},
    allow_productivity = true,
    main_product = "carbon",
    icon = "__maraxsis__/graphics/icons/burnt-fish.png",
    icon_size = 64,
    show_amount_in_title = false,
    auto_recycle = false,
    surface_conditions = maraxsis.surface_conditions(),
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-nutrients-from-tropical-fish",
    icon = "__maraxsis__/graphics/icons/nutrients-from-tropical-fish.png",
    icon_size = 64,
    enabled = false,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "maraxsis-tropical-fish", amount = 1},
    },
    results = {
        {type = "item", name = "nutrients", amount = 6, quality_change = -1},
    },
    auto_recycle = false,
    allow_decomposition = false,
    allow_productivity = true,
    categories = {"organic"},
    subgroup = "nauvis-agriculture",
    order = "g[maraxsis]"
}}

-- MICROPLASTICS --

local microplastics_variants = {}
for i = 1, 3 do
    microplastics_variants[i] = {
        filename = "__maraxsis__/graphics/icons/microplastics-" .. i .. ".png",
        width = 64,
        height = 64,
        scale = 1 / 2,
        flags = {"icon"},
    }
end

data:extend {{
    type = "item",
    name = "maraxsis-microplastics",
    icon = "__maraxsis__/graphics/icons/microplastics-1.png",
    icon_size = 64,
    pictures = microplastics_variants,
    stack_size = data.raw.item["plastic-bar"].stack_size / 2,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-microplastics",
    icon = "__maraxsis__/graphics/icons/fish-rendering.png",
    icon_size = 64,
    enabled = false,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "maraxsis-tropical-fish",   amount = 1},
        {type = "item", name = "piercing-rounds-magazine", amount = 1},
    },
    results = {
        {type = "item", name = "maraxsis-microplastics", amount = 10},
        {type = "item", name = "jelly",                  amount = 10},
    },
    categories = {"organic", "crafting"},
    localised_name = {"recipe-name.maraxsis-microplastics"},
    main_product = "maraxsis-microplastics",
    allow_productivity = true,
    auto_recycle = false,
    always_show_made_in = true,
    surface_conditions = maraxsis.surface_conditions(),
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-smelt-microplastics",
    icon = "__maraxsis__/graphics/icons/microplastics-to-plastic.png",
    icon_size = 64,
    enabled = false,
    energy_required = data.raw.recipe["iron-plate"].energy_required,
    ingredients = {
        {type = "item", name = "maraxsis-microplastics", amount = 2},
    },
    results = {
        {type = "item", name = "plastic-bar", amount = 1},
    },
    categories = {"smelting"},
    allow_productivity = true,
    main_product = "plastic-bar",
    emissions_multiplier = 3,
    auto_recycle = false,
}}

data:extend {{
    type = "item",
    name = "maraxsis-fish-food",
    icon = "__maraxsis__/graphics/icons/fish-food.png",
    icon_size = 64,
    stack_size = 100,
    plant_result = "maraxsis-fishing-plant",
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-fish-food",
    enabled = false,
    energy_required = 3,
    ingredients = {
        {type = "item", name = "maraxsis-tropical-fish", amount = 1},
        {type = "item", name = maraxsis_constants.SAND_ITEM_NAME,                   amount = 1},
        {type = "item", name = "jelly",                  amount = 1},
        {type = "item", name = "maraxsis-coral",         amount = 3},
        {type = "item", name = "plastic-bar",            amount = 1},
    },
    results = {
        {type = "item", name = "maraxsis-fish-food", amount = 3}
    },
    allow_productivity = true,
    auto_recycle = true,
    main_product = "maraxsis-fish-food",
    categories = {"maraxsis-hydro-plant", "organic"},
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-shrinkflation",
    enabled = false,
    energy_required = 3,
    ingredients = {
        {type = "item", name = maraxsis_constants.SAND_ITEM_NAME, amount = 1, quality_min = "normal", quality_max = "normal"},
        {type = "item", name = "maraxsis-fish-food", amount = 1, quality_min = "uncommon"},
    },
    results = {
        {type = "item", name = "maraxsis-fish-food", amount = 1, ignored_by_stats = 1, ignored_by_productivity = 1, quality_change = -1},
    },
    allow_productivity = false,
    allow_quality = false,
    auto_recycle = false,
    can_set_quality = true,
    main_product = "maraxsis-fish-food",
    icon = "__maraxsis__/graphics/icons/shrinkflation.png"
}}

local function add_to_tech(recipe)
    table.insert(data.raw.technology["maraxsis-piscary"].effects, {type = "unlock-recipe", recipe = recipe})
end

add_to_tech("maraxsis-carbon")
add_to_tech("maraxsis-fishing-tower")
add_to_tech("maraxsis-fish-food")
add_to_tech("maraxsis-shrinkflation")
add_to_tech("maraxsis-nutrients-from-tropical-fish")
add_to_tech("maraxsis-microplastics")
add_to_tech("maraxsis-smelt-microplastics")
