data:extend { {
    type = "fluid",
    name = "maraxsis-supercritical-steam",
    icon = "__maraxsis__/graphics/icons/supercritical-steam.png",
    icon_size = 64,
    default_temperature = 0,
    max_temperature = 2000,
    heat_capacity = 0.3125 .. "kJ",
    base_flow_rate = data.raw.fluid.steam.base_flow_rate,
    base_color = { 1, 0.5, 0.5 },
    flow_color = { 1, 0.5, 0.75 },
    gas_temperature = 365,
    auto_barrel = false,
    fuel_value = "1J",
} }

data:extend { {
    type = "recipe",
    name = "maraxsis-supercritical-steam",
    enabled = false,
    energy_required = 4,
    ingredients = {
        { type = "fluid", name = "water", amount = 80, fluidbox_index = 0, optional_fluidbox_indexes = { 1 } },
        { type = "item",  name = "pipe",  amount = 1 },
    },
    results = {
        { type = "fluid", name = "maraxsis-supercritical-steam", amount = 80, temperature = 2000 },
    },
    allow_productivity = false,
    allow_quality = false,
    auto_recycle = false,
    categories = { "maraxsis-geothermal-generator" },
} }

data:extend { {
    type = "recipe",
    name = "maraxsis-supercritical-steam-cooling",
    enabled = false,
    energy_required = 1,
    icon = "__maraxsis__/graphics/icons/supercritical-steam-cooling.png",
    ingredients = {
        { type = "fluid", name = "maraxsis-supercritical-steam", amount = 50, temperature = 2000 },
        { type = "fluid", name = "fluoroketone-cold",            amount = 10 },
    },
    results = {
        { type = "fluid", name = "steam",            amount = 500, temperature = 500 },
        { type = "fluid", name = "fluoroketone-hot", amount = 10,  ignored_by_stats = 10, ignored_by_productivity = 10 },
    },
    allow_productivity = false,
    allow_quality = false,
    auto_recycle = false,
    categories = { "cryogenics" },
} }
