local OMNIPERMUTE_AFFIX = "-omniperm"

local common = {
    ["FP_RECIPE_AFFIX"] = "-fp",
    ["FP_ITEM_GROUP_NAME"] = "fluidpermutations",

    ["NEXT_INGREDIENT_KEY"] = 1,
    ["PREVIOUS_INGREDIENT_KEY"] = 2,
    ["NEXT_RESULT_KEY"] = 3,
    ["PREVIOUS_RESULT_KEY"] = 4,
    ["NEXT_INGREDIENT_CROSS_KEY"] = 5,
    ["PREVIOUS_INGREDIENT_CROSS_KEY"] = 6,
    ["NEXT_RESULT_CROSS_KEY"] = 7,
    ["PREVIOUS_RESULT_CROSS_KEY"] = 8,

    ["PERMUTATION_THRESHOLD_SETTING"] = "fluid-permutations-threshold",
    ["SIMPLE_MODE_SETTING"] = "fluid-permutations-simple-mode",
    ["CROSS_CYCLE_SETTING"] = "fluid-permutations-cross-cycle",

    ["NEXT_INGREDIENTS_PERMUTATION_INPUT"] = "next-ingredients-fluid-recipe",
    ["PREVIOUS_INGREDIENTS_PERMUTATION_INPUT"] = "previous-ingredients-fluid-recipe",
    ["NEXT_RESULTS_PERMUTATION_INPUT"] = "next-results-fluid-recipe",
    ["PREVIOUS_RESULTS_PERMUTATION_INPUT"] = "previous-results-fluid-recipe",

    ["OMNIPERMUTE_AFFIX"] = OMNIPERMUTE_AFFIX,

    ["REMOTE_INTERFACE_NAME"] = "fluid_permutations",

    ["functions"] = {
        generateRecipeName = function(base, affix, difficulty, ingredientPermutation, resultPermutation, control)
            local prefix = base
            if (control == nil or control == false) and select(1, string.find(base, "omnirec")) ~= nil then
                prefix = prefix..OMNIPERMUTE_AFFIX.."-"..ingredientPermutation.."-"..resultPermutation
            end
            return prefix..affix.."-d"..difficulty.."-i"..ingredientPermutation.."-r"..resultPermutation
        end,

        factorial = function(num)
            local result = 1
            for i = 2, num do
                result = result * i
            end
            return result
        end,
    }
}

return common
