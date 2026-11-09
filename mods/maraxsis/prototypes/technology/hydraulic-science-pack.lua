data:extend {{
    type = "item",
    name = "hydraulic-science-pack",
    localised_description = maraxsis_constants.DEGRADATION_ENABLED and {"", {"item-description.hydraulic-science-pack"}, "\n", {"description.degradation", "maraxsis-fish-oil"}} or {"item-description.hydraulic-science-pack"},
    icon = "__maraxsis__/graphics/icons/hydraulic-science-pack.png",
    icon_size = 64,
    subgroup = "science-pack",
    order = "j-a[hydraulic-science-pack]",
    stack_size = data.raw.item["automation-science-pack"].stack_size,
    durability = data.raw.item["automation-science-pack"].durability,
    durability_description_key = data.raw.item["automation-science-pack"].durability_description_key,
    durability_description_value = data.raw.item["automation-science-pack"].durability_description_value,
    weight = data.raw.item["automation-science-pack"].weight,
}}

if mods["Krastorio2-spaced-out"] then
    data:extend {{
        type = "item",
        name = "hydraulic-research-data",
        stack_size = 200,
        icon = "__maraxsis__/graphics/icons/hydraulic-research-data.png",
        icon_size = 64,
        subgroup = "science-pack",
        weight = 1000,
        order = "ao75[hydraulic-research-data]"
    }}
end

data:extend {{
    type = "technology",
    name = "hydraulic-science-pack",
    icon = "__maraxsis__/graphics/technology/hydraulic-science-pack.png",
    icon_size = 256,
    essential = true,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "hydraulic-science-pack",
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-fish-oil",
        }
    },
    research_trigger = {
        type = "craft-item",
        item = "maraxsis-wyrm-specimen",
        amount = 1,
    },
    prerequisites = {
        "maraxsis-wyrm-confinement",
    },
    order = "eg-a[hydraulic-science-pack]",
}}

data:extend {{
    type = "recipe",
    name = "hydraulic-science-pack",
    enabled = false,
    energy_required = 30,
    ingredients = {
        {type = "item",  name = "maraxsis-wyrm-specimen", amount = 1},
        {type = "item",  name = "salt",                   amount = 1, quality_change = 1},
        {type = "fluid", name = "maraxsis-supercritical-steam",  amount = 300},
    },
    results = {
        {type = "item", name = "hydraulic-science-pack", amount = 1},
    },
    allow_productivity = true,
    categories = {"maraxsis-hydro-plant"},
    auto_recycle = false,
    surface_conditions = maraxsis.trench_surface_conditions(),
}}

data:extend {{
    type = "item",
    name = "maraxsis-fish-oil",
    stack_size = data.raw.item["hydraulic-science-pack"].stack_size,
    weight = data.raw.item["hydraulic-science-pack"].weight,
    icon = "__maraxsis__/graphics/icons/fish-oil.png",
    icon_size = 64,
    subgroup = "science-pack",
    order = "j-b[fish-oil]",
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-fish-oil",
    localised_name = {"recipe-name.maraxsis-fish-oil"},
    enabled = false,
    energy_required = 0.1,
    ingredients = {
        {type = "item", name = "hydraulic-science-pack", amount = 1},
    },
    results = {
        {type = "item", name = "maraxsis-fish-oil", amount = 1, quality_min = "normal", quality_max = "normal"},
    },
    allow_productivity = false,
    allow_quality = false,
    auto_recycle = false,
    categories = {"hand-crafting"},
    always_show_made_in = true,
    hide_from_signal_gui = true,
}}
