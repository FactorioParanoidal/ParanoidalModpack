data:extend {{
    type = "technology",
    name = "maraxsis-wyrm-confinement",
    icon = "__maraxsis__/graphics/technology/wyrm-confinement.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-wyrm-confinement-cell",
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-wyrm-specimen",
        }
    },
    prerequisites = {"maraxsis-piscary", "ducts", "maraxsis-geothermal-energy"},
    research_trigger = {
        type = "craft-item",
        item = "maraxsis-fish-food",
        count = 20
    },
    order = "ee[wyrm-confinement]",
}}

data:extend {{
    type = "item",
    name = "maraxsis-wyrm-confinement-cell",
    icon = "__maraxsis__/graphics/icons/wyrm-confinement-cell.png",
    icon_size = 64,
    stack_size = 10,
}}

local wyrm_variants = {}
for i = 1, 3 do
    wyrm_variants[i] = {
        filename = "__maraxsis__/graphics/icons/wyrm-specimen-" .. i .. ".png",
        width = 64,
        height = 64,
        scale = 1 / 2,
        flags = {"icon"}
    }
end

data:extend {{
    type = "item",
    name = "maraxsis-wyrm-specimen",
    icon = "__maraxsis__/graphics/icons/wyrm-specimen-2.png",
    pictures = wyrm_variants,
    icon_size = 64,
    stack_size = 10,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-wyrm-confinement-cell",
    enabled = false,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "maraxsis-glass-panes", amount = 5},
        {type = "item", name = "steel-plate",          amount = 1},
    },
    results = {
        {type = "item", name = "maraxsis-wyrm-confinement-cell", amount = 1},
    },
    auto_recycle = true,
    allow_productivity = true
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-wyrm-specimen",
    enabled = false,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "maraxsis-wyrm-confinement-cell", amount = 1},
        {type = "item", name = "maraxsis-fish-food",             amount = 1},
    },
    results = {
        {type = "item", name = "maraxsis-wyrm-specimen", amount = 1},
    },
    auto_recycle = false,
    categories = {"maraxsis-hydro-plant"},
    surface_conditions = maraxsis.trench_surface_conditions(),
    allow_productivity = true
}}
