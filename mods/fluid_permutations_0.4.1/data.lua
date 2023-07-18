local common = require("common")

local function createPermutationsInputs()
    data:extend({
    {
        type = "custom-input",
        name = common.NEXT_INGREDIENTS_PERMUTATION_INPUT,
        key_sequence = "CONTROL + SHIFT + I",
        consuming = "none"
    },{
        type = "custom-input",
        name = common.PREVIOUS_INGREDIENTS_PERMUTATION_INPUT,
        key_sequence = "CONTROL + ALT + I",
        consuming = "none"
    },
    {
        type = "custom-input",
        name = common.NEXT_RESULTS_PERMUTATION_INPUT,
        key_sequence = "CONTROL + SHIFT + R",
        consuming = "none"
    },{
        type = "custom-input",
        name = common.PREVIOUS_RESULTS_PERMUTATION_INPUT,
        key_sequence = "CONTROL + ALT + R",
        consuming = "none"
    },
    })
end

createPermutationsInputs()

data:extend({
 {
    type = "item-group",
    name = common.FP_ITEM_GROUP_NAME,
    order = "z",
    inventory_order = "z",
    icon = "__fluid_permutations__/graphics/FluidPermutations.png",
    icon_size = 128,
  }
})
