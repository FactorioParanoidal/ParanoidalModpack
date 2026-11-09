local function add_to_tech(recipe)
    table.insert(data.raw.technology["maraxsis-hydro-plant"].effects, {
        type = "unlock-recipe",
        recipe = recipe,
    })
end

data:extend {{
    type = "fluid",
    name = "maraxsis-saline-water",
    icon = "__maraxsis__/graphics/icons/saline-water.png",
    icon_size = 64,
    base_flow_rate = data.raw.fluid.water.base_flow_rate,
    default_temperature = data.raw.fluid["water"].default_temperature,
    heat_capacity = data.raw.fluid["water"].heat_capacity,
    base_color = {5, 9, 83},
    flow_color = {105, 109, 183},
    max_temperature = data.raw.fluid["water"].max_temperature,
    pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
    flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
}}

data:extend {{
    type = "fluid",
    name = "maraxsis-brackish-water",
    icon = "__maraxsis__/graphics/icons/brackish-water.png",
    icon_size = 64,
    base_flow_rate = data.raw.fluid.water.base_flow_rate,
    default_temperature = data.raw.fluid["water"].default_temperature,
    heat_capacity = data.raw.fluid["water"].heat_capacity,
    flow_color = {105, 109, 183},
    base_color = {5, 9, 83},
    max_temperature = data.raw.fluid["water"].max_temperature,
    pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
    flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
}}

data:extend {{
    type = "fluid",
    name = "oxygen",
    icon = "__maraxsis__/graphics/icons/oxygen.png",
    icon_size = 64,
    base_flow_rate = data.raw.fluid.steam.base_flow_rate,
    default_temperature = data.raw.fluid["water"].default_temperature,
    heat_capacity = data.raw.fluid["water"].heat_capacity,
    base_color = {0.75, 0.40, 0.40},
    flow_color = {0.80, 0.60, 0.60},
    max_temperature = data.raw.fluid["water"].max_temperature,
    pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
    flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
}}

data:extend {{
    type = "fluid",
    name = "hydrogen",
    icon = "__maraxsis__/graphics/icons/hydrogen.png",
    icon_size = 64,
    base_flow_rate = data.raw.fluid.steam.base_flow_rate,
    default_temperature = data.raw.fluid["water"].default_temperature,
    heat_capacity = data.raw.fluid["water"].heat_capacity,
    base_color = {0.50, 0.50, 0.50},
    flow_color = {1, 1, 1},
    max_temperature = data.raw.fluid["water"].max_temperature,
    pressure_to_speed_ratio = data.raw.fluid["water"].pressure_to_speed_ratio,
    flow_to_energy_ratio = data.raw.fluid["water"].flow_to_energy_ratio,
}}

local electrolysis_recipe_name = "salt"
if mods.shchierbin then
    electrolysis_recipe_name = "maraxsis-salt"
end

data:extend {{
    type = "recipe",
    name = electrolysis_recipe_name,
    enabled = false,
    energy_required = 5,
    ingredients = {
        {type = "fluid", name = "maraxsis-brackish-water", amount = 300},
    },
    results = {
        {type = "item",  name = "salt",     amount = 3, quality_change = 1},
        {type = "fluid", name = "oxygen",   amount = 100},
        {type = "fluid", name = "hydrogen", amount = 200},
    },
    categories = {"maraxsis-hydro-plant", "electromagnetics", mods.Krastorio2 and "kr-electrolysis" or nil},
    icon = "__maraxsis__/graphics/icons/saline-electrolysis.png",
    icon_size = 64,
    auto_recycle = false,
    allow_productivity = true,
    main_product = "salt",
    localised_name = {"recipe-name.salt"},
}}
add_to_tech(electrolysis_recipe_name)

data:extend {{
    type = "recipe",
    name = "maraxsis-water",
    icon = "__maraxsis__/graphics/icons/maraxsis-water.png",
    icon_size = 64,
    enabled = false,
    energy_required = 2,
    ingredients = {
        {type = "fluid", name = "oxygen",   amount = 100},
        {type = "fluid", name = "hydrogen", amount = 200},
    },
    results = {
        {type = "fluid", name = "water", amount = 300},
    },
    allow_productivity = true,
    auto_recycle = false,
    categories = {"chemistry", "cryogenics"},
    main_product = "water",
    hidden = not not mods.skewer_planet_vesta,
}}
add_to_tech(data.raw.recipe["ske_h2o"] and "ske_h2o" or "maraxsis-water")

data:extend {{
    type = "item",
    name = "maraxsis-saturated-salt-filter",
    icon = "__maraxsis__/graphics/icons/saturated-salt-filter.png",
    icon_size = 64,
    stack_size = 10,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-brackish-water",
    enabled = false,
    energy_required = 2.5,
    ingredients = {
        {type = "item",  name = "maraxsis-salt-filter",  amount = 1},
        {type = "fluid", name = "maraxsis-saline-water", amount = 100},
    },
    results = {
        {type = "fluid", name = "maraxsis-brackish-water",        amount = 100},
        {type = "item",  name = "maraxsis-saturated-salt-filter", amount = 1,  ignored_by_stats = 1, ignored_by_productivity = 1},
    },
    categories = {"maraxsis-hydro-plant", "chemistry"},
    auto_recycle = false,
    main_product = "maraxsis-brackish-water",
    allow_productivity = true,
}}
add_to_tech("maraxsis-brackish-water")

local salt_variants = {}
for i = 1, 3 do
    salt_variants[i] = {
        filename = "__maraxsis__/graphics/icons/salt-" .. i .. ".png",
        width = 64,
        height = 64,
        scale = 1 / 2,
        flags = {"icon"}
    }
end

data:extend {{
    type = "item",
    name = "salt",
    icon = "__maraxsis__/graphics/icons/salt-2.png",
    pictures = salt_variants,
    icon_size = 64,
    stack_size = 200,
}}

data:extend {{
    type = "item",
    name = "maraxsis-salt-filter",
    icon = "__maraxsis__/graphics/icons/salt-filter.png",
    icon_size = 64,
    stack_size = 50,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-salt-filter",
    enabled = false,
    energy_required = 1,
    ingredients = {
        {type = "item", name = "steel-plate",  amount = 2},
        {type = "item", name = "carbon-fiber", amount = 1},
    },
    results = {
        {type = "item", name = "maraxsis-salt-filter", amount = 1},
    },
    categories = {"maraxsis-hydro-plant", "crafting"},
    allow_productivity = true,
    auto_recycle = false,
}}
add_to_tech("maraxsis-salt-filter")

data:extend {{
    type = "recipe",
    name = "maraxsis-salt-filter-cleaning",
    enabled = false,
    energy_required = 1.25,
    ingredients = {
        {type = "item",  name = "maraxsis-saturated-salt-filter", amount = 1},
        {type = "fluid", name = "water",                          amount = 20},
    },
    results = {
        {type = "item",  name = "maraxsis-salt-filter",    amount = 1, independent_probability = 0.95, ignored_by_productivity = 1, ignored_by_stats = 1, quality_change = 1},
        {type = "item",  name = "carbon-fiber",            amount = 1, independent_probability = 0.025},
        {type = "fluid", name = "maraxsis-brackish-water", amount = 20},
    },
    categories = {"maraxsis-hydro-plant", "chemistry"},
    main_product = "maraxsis-salt-filter",
    allow_productivity = false,
    icon = "__maraxsis__/graphics/icons/salt-filter-cleaning.png",
    icon_size = 64,
    allow_decomposition = false,
    auto_recycle = false,
}}
add_to_tech("maraxsis-salt-filter-cleaning")

data:extend {{
    type = "recipe",
    name = "maraxsis-hydrolox-rocket-fuel",
    enabled = false,
    energy_required = 10,
    ingredients = {
        {type = "fluid", name = "oxygen",   amount = 200},
        {type = "fluid", name = "hydrogen", amount = 200},
    },
    results = {
        {type = "item", name = "rocket-fuel", amount = 1},
    },
    icon = "__maraxsis__/graphics/icons/hydrolox-rocket-fuel.png",
    icon_size = 64,
    allow_productivity = true,
    categories = {"maraxsis-hydro-plant"},
    main_product = "rocket-fuel",
    auto_recycle = false,
}}
add_to_tech("maraxsis-hydrolox-rocket-fuel")

