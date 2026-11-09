require "maraxsis-start.prototypes.a-breath-of-fresh-air"

data:extend {{
    type = "space-connection",
    name = "nauvis-maraxsis",
    from = "nauvis",
    to = "maraxsis",
    length = 20000,
    asteroid_spawn_definitions = table.deepcopy(data.raw["space-connection"]["nauvis-gleba"].asteroid_spawn_definitions),
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-tungsten-ore-dissolution",
    categories = {"chemistry"},
    enabled = false,
    energy_required = 5,
    ingredients = {
        {type = "item",  name = "tungsten-carbide",      amount = 10},
        {type = "fluid", name = "maraxsis-saline-water", amount = 300},
    },
    results = {
        {type = "item", name = "tungsten-ore", amount = 5},
    },
    main_product = "tungsten-ore",
    auto_recycle = false,
    allow_decomposition = false,
    allow_productivity = false,
    surface_conditions = maraxsis.surface_conditions(),
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-carbon-fiber-from-jelly",
    categories = {"hand-crafting"},
    enabled = false,
    energy_required = 5,
    ingredients = {
        {type = "item", name = "tungsten-carbide", amount = 1},
        {type = "item", name = "jelly",            amount = 10},
    },
    results = {
        {type = "item", name = "carbon-fiber", amount = 10},
    },
    main_product = "carbon-fiber",
    allow_recycling = false,
    allow_decomposition = false,
    allow_productivity = true,
    always_show_made_in = true,
    localised_name = {"item-name.carbon-fiber"},
    auto_recycle = false,
    surface_conditions = maraxsis.surface_conditions(),
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-fiber-degradation",
    enabled = false,
    energy_required = 3,
    ingredients = {
        {type = "item", name = maraxsis_constants.SAND_ITEM_NAME, amount = 1, quality_min = "normal", quality_max = "normal"},
        {type = "item", name = "carbon-fiber", amount = 1, quality_min = "uncommon"},
    },
    results = {
        {type = "item", name = "carbon-fiber", amount = 1, ignored_by_stats = 1, ignored_by_productivity = 1, quality_min = "normal", quality_max = "normal"},
    },
    allow_productivity = false,
    allow_quality = false,
    auto_recycle = false,
    can_set_quality = true,
    main_product = "carbon-fiber",
    surface_conditions = maraxsis.surface_conditions(),
}}

data:extend {{
    type = "technology",
    name = "maraxsis-casting",
    icon = data.raw.technology["foundry"].icon,
    icon_size = data.raw.technology["foundry"].icon_size,
    effects = {},
    prerequisites = {},
    unit = {
        count = 0,
        ingredients = {},
        time = 0,
    },
    order = "ea[maraxsis]",
}}

-- Starting on Maraxsis changes what the lubricant technology does.
-- Use dedicated locale keys and override their descriptions here,
-- so the vanilla descriptions are not clobbered for
-- other planets and for players who do not use Any Planet Start.
data.raw["technology"]["lubricant"].localised_description = {"technology-description.lubricant-maraxsis-start"}
