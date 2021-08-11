local rawmulti = angelsmods.marathon.rawmulti

data:extend({
	{
        type = "recipe",
        name = "angelsore-pure-chrome-processing",
        category = "ore-sorting",
        subgroup = "ore-sorting-advanced",
        enabled = "false",
        allow_decomposition = false,
        normal =
        {
            energy_required = 1.5,
            ingredients =
            {
                {type="item", name="angels-ore1-pure", amount=2},
                {type="item", name="angels-ore4-pure", amount=2},
                {type="item", name="angels-ore5-pure", amount=2},
                {type="item", name="catalysator-orange", amount=1},
            },
            results=
            {
                {type="item", name="platinum-ore", amount=1},
            },
        },
        expensive =
        {
            energy_required = 1.5,
            ingredients =
            {
                {type="item", name="angels-ore1-pure", amount=3 * rawmulti},
                {type="item", name="angels-ore4-pure", amount=3 * rawmulti},
                {type="item", name="angels-ore5-pure", amount=3 * rawmulti},
                {type="item", name="catalysator-orange", amount=1},
            },
            results=
            {
                {type="item", name="platinum-ore", amount=1},
            },
        },
        icon_size = 32,
        icon = "__Platinum_Sorting__/graphics/icons/platinum-sorting.png",
        order = "p-a",
	},
})

local tech_unlocks = data.raw["technology"]["advanced-ore-refining-4"].effects
tech_unlocks[#tech_unlocks+1] =
{
    type = "unlock-recipe",
    recipe = "angelsore-pure-chrome-processing",
}