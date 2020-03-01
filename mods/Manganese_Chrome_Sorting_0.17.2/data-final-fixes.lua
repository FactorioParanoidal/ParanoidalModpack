local rawmulti = angelsmods.marathon.rawmulti

data:extend({
	{
        type = "recipe",
        name = "angelsore-crushed-manganese-processing",
        category = "ore-sorting",
        subgroup = "ore-sorting-advanced",
        enabled = false,
        allow_decomposition = false,
        normal =
        {
            energy_required = 1,
            ingredients =
            {
                {type="item", name="angels-ore8-crushed", amount=2},
                {type="item", name="angels-ore5-crushed", amount=2},
                {type="item", name="catalysator-brown", amount=1},
            },
            results=
            {
                {type="item", name="manganese-ore", amount=4},
            },
        },
        expensive =
        {
            energy_required = 1,
            ingredients =
            {
                {type="item", name="angels-ore8-crushed", amount=3 * rawmulti},
                {type="item", name="angels-ore5-crushed", amount=3 * rawmulti},
                {type="item", name="catalysator-brown", amount=1},
            },
            results=
            {
                {type="item", name="manganese-ore", amount=4},
            },
        },
        icon_size = 32,
        icon = "__Manganese_Chrome_Sorting__/graphics/icons/manganese-sorting.png",
        order = "e-a",
	},
	{
        type = "recipe",
        name = "angelsore-pure-chrome-processing",
        category = "ore-sorting",
        subgroup = "ore-sorting-advanced",
        enabled = false,
        allow_decomposition = false,
        normal =
        {
            energy_required = 1.5,
            ingredients =
            {
                {type="item", name="angels-ore8-crystal", amount=2},
                {type="item", name="angels-ore4-crystal", amount=2},
                {type="item", name="angels-ore6-crystal", amount=2},
                {type="item", name="catalysator-orange", amount=1},
            },
            results=
            {
                {type="item", name="chrome-ore", amount=6},
            },
        },
        expensive =
        {
            energy_required = 1.5,
            ingredients =
            {
                {type="item", name="angels-ore8-crystal", amount=3 * rawmulti},
                {type="item", name="angels-ore4-crystal", amount=3 * rawmulti},
                {type="item", name="angels-ore6-crystal", amount=3 * rawmulti},
                {type="item", name="catalysator-orange", amount=1},
            },
            results=
            {
                {type="item", name="chrome-ore", amount=6},
            },
        },
        icon = "__Manganese_Chrome_Sorting__/graphics/icons/chrome-sorting.png",
        icon_size = 32,
        order = "o-a",
	},
    {
        type = "technology",
        name = "manganese-ore-refining",
        icon = "__angelsrefining__/graphics/technology/ore-sorting.png",
        icon_size = 128,
        prerequisites = {
            "advanced-ore-refining-1",
            "ore-advanced-crushing"
        },
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "angelsore-crushed-manganese-processing"
            },
        },
        unit =
        {
            count = 75,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
            },
            time = 15
        },
        order = "a-a-a1"
    },
    {
        type = "technology",
        name = "chrome-ore-refining",
        icon = "__angelsrefining__/graphics/technology/ore-sorting.png",
        icon_size = 128,
        prerequisites = {
            "advanced-ore-refining-3",
            "ore-electro-whinning-cell"
        },
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "angelsore-pure-chrome-processing"
            },
        },
        unit =
        {
            count = 75,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
            time = 15
        },
        order = "a-a-a1"
    },
})