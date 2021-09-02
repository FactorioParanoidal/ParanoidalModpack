data:extend({
--###############################################################################################
{
    type = "recipe",
    name = "angelsore-pure-platinum-processing",
    icon = "__KaoExtended__/graphics/Platinum_Sorting/platinum-sorting.png",
    icon_size = 32,
    subgroup = "ore-sorting-advanced",
    order = "p-a",
    category = "ore-sorting",
    enabled = false,
    allow_decomposition = false,
    always_show_products = true,
    ingredients =
        {
            {type="item", name="angels-ore1-pure", amount=2},
            {type="item", name="angels-ore4-pure", amount=2},
            {type="item", name="angels-ore5-pure", amount=2},
            {type="item", name="catalysator-orange", amount=1},
        },
    energy_required = 1.5,
    results = {{type="item", name="platinum-ore", amount=1}},
},
-------------------------------------------------------------------------------------------------
{
    type = "technology",
    name = "platinum-ore-refining",
    icon = "__angelsrefining__/graphics/technology/ore-sorting.png",
    icon_size = 128,
    order = "a-a-a1",
    prerequisites = 
        {
            "advanced-ore-refining-3",
            "ore-electro-whinning-cell"
        },
    effects = {{type = "unlock-recipe", recipe = "angelsore-pure-platinum-processing"}},
    unit =
    {
        count = 75,
        time = 15,
        ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
    },
},
--###############################################################################################
{
    type = "recipe",
    name = "angelsore-crushed-manganese-processing",
    icon = "__KaoExtended__/graphics/Manganese_Chrome_Sorting/manganese-sorting.png",
    icon_size = 32,
    subgroup = "ore-sorting-advanced",
    order = "e-a",
    category = "ore-sorting",
    enabled = false,
    allow_decomposition = false,
    always_show_products=true,
    ingredients =
        {
            {type="item", name="angels-ore8-crushed", amount=2},
            {type="item", name="angels-ore5-crushed", amount=2},
            {type="item", name="catalysator-brown", amount=1},
        },
    energy_required = 1,
    results = {{type="item", name="manganese-ore", amount=1}},
},
-------------------------------------------------------------------------------------------------
{
    type = "technology",
    name = "manganese-ore-refining",
    icon = "__angelsrefining__/graphics/technology/ore-sorting.png",
    icon_size = 128,
    order = "a-a-a1",
    prerequisites = 
        {
            "advanced-ore-refining-1",
            "ore-advanced-crushing"
        },
    effects = {{type = "unlock-recipe", recipe = "angelsore-crushed-manganese-processing"}},
    unit =
    {
        count = 75,
        time = 15,
        ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
            },
    },
},
--###############################################################################################
{
    type = "recipe",
    name = "angelsore-pure-chrome-processing",
    icon = "__KaoExtended__/graphics/Manganese_Chrome_Sorting/chrome-sorting.png",
    icon_size = 32,
    subgroup = "ore-sorting-advanced",
    order = "o-a",
    category = "ore-sorting",
    enabled = false,
    allow_decomposition = false,
    always_show_products=true,
    ingredients =
        {
            {type="item", name="angels-ore8-crystal", amount=2},
            {type="item", name="angels-ore4-crystal", amount=2},
            {type="item", name="angels-ore6-crystal", amount=2},
            {type="item", name="catalysator-orange", amount=1},
    },
    energy_required = 1.5,
    results = {{type="item", name="chrome-ore", amount=1}},
},
-------------------------------------------------------------------------------------------------
{
    type = "technology",
    name = "chrome-ore-refining",
    icon = "__angelsrefining__/graphics/technology/ore-sorting.png",
    icon_size = 128,
    order = "a-a-a1",
    prerequisites = 
        {
            "advanced-ore-refining-3",
            "ore-electro-whinning-cell"
        },
    effects = {{type = "unlock-recipe", recipe = "angelsore-pure-chrome-processing"}},
    unit =
    {
        count = 75,
        time = 15,
        ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
    },
},
--###############################################################################################
})