local common = require("common")

local generateRecipeName = common.functions.generateRecipeName

local permutations
local unlocks
local playerSettings

local NEXT_INGREDIENTS_PERMUTATION_INPUT = common.NEXT_INGREDIENTS_PERMUTATION_INPUT
local PREVIOUS_INGREDIENTS_PERMUTATION_INPUT = common.PREVIOUS_INGREDIENTS_PERMUTATION_INPUT
local NEXT_RESULTS_PERMUTATION_INPUT = common.NEXT_RESULTS_PERMUTATION_INPUT
local PREVIOUS_RESULTS_PERMUTATION_INPUT = common.PREVIOUS_RESULTS_PERMUTATION_INPUT

local NEXT_INGREDIENT_KEY = common.NEXT_INGREDIENT_KEY
local PREVIOUS_INGREDIENT_KEY = common.PREVIOUS_INGREDIENT_KEY
local NEXT_RESULT_KEY = common.NEXT_RESULT_KEY
local PREVIOUS_RESULT_KEY = common.PREVIOUS_RESULT_KEY

local NEXT_INGREDIENT_CROSS_KEY = common.NEXT_INGREDIENT_CROSS_KEY
local PREVIOUS_INGREDIENT_CROSS_KEY = common.PREVIOUS_INGREDIENT_CROSS_KEY
local NEXT_RESULT_CROSS_KEY = common.NEXT_RESULT_CROSS_KEY
local PREVIOUS_RESULT_CROSS_KEY = common.PREVIOUS_RESULT_CROSS_KEY

local CROSS_CYCLE_SETTING = common.CROSS_CYCLE_SETTING

local function change_fluid_recipe(event, change)
    local player = game.players[event.player_index]
    if not (player.selected and player.selected.type == "assembling-machine") then
        return
    end
    local building = player.selected
    local recipe = building.get_recipe()
    if not recipe then
        return
    end
    local recipePermutations = permutations[recipe.name]
    if not recipePermutations then
        return
    end

    local crossCycle = playerSettings[event.player_index][CROSS_CYCLE_SETTING]
    local invertChange = crossCycle

    local targetPermutation

    if crossCycle then
        targetPermutation = recipePermutations[change + 4]
    end

    if (not crossCycle) or (not targetPermutation) then
        targetPermutation = recipePermutations[change]
        invertChange = false
    end

    if not targetPermutation then
        return
    end

    local crafting_progress = building.crafting_progress
    local bonus_progress = building.bonus_progress
    local products_finished = building.products_finished

    local fluidsBefore = {}
    local fluidbox = building.fluidbox
    local start, stop, step
    if (change <= PREVIOUS_INGREDIENT_KEY) ~= invertChange then
        start, stop, step = 1, recipePermutations.ingredientsFluidCount, 1
    else
        start, stop, step = #fluidbox, #fluidbox - recipePermutations.resultsFluidCount + 1, -1
    end

    for i = start, stop, step do
        if fluidbox[i] ~=nil then
            fluidsBefore[fluidbox[i].name] = fluidbox[i]
        end
    end

    building.set_recipe(targetPermutation) -- ignore leftovers, since the crafting progress will be set

    building.crafting_progress = crafting_progress
    building.bonus_progress = bonus_progress
    building.products_finished = products_finished

    for i = start, stop, step do
        local filter = fluidbox.get_filter(i)
        if filter ~= nil then
            local filterName = filter.name;
            local before = fluidsBefore[filterName]
            if before ~= nil then
                fluidbox[i] = before
                fluidsBefore[filterName] = nil
            end
        end
    end
    local k, v = next(fluidsBefore)
    if k ~= nil then
        for i = start, stop, step do
            if fluidbox.get_filter(i) == nil then
                fluidbox[i] = v;
                k, v = next(fluidsBefore, k)
                if k == nil then
                    break
                end
            end
        end
    end
end

script.on_event(NEXT_INGREDIENTS_PERMUTATION_INPUT, function(event)
    change_fluid_recipe(event, NEXT_INGREDIENT_KEY)
end)
script.on_event(PREVIOUS_INGREDIENTS_PERMUTATION_INPUT, function(event)
    change_fluid_recipe(event, PREVIOUS_INGREDIENT_KEY)
end)
script.on_event(NEXT_RESULTS_PERMUTATION_INPUT, function(event)
    change_fluid_recipe(event, NEXT_RESULT_KEY)
end)

script.on_event(PREVIOUS_RESULTS_PERMUTATION_INPUT, function(event)
    change_fluid_recipe(event, PREVIOUS_RESULT_KEY)
end)

local function togglePermutations(effects, force, enabled)
    for i = 1, #effects do
        local effect = effects[i]
        if effect.type == "unlock-recipe" then
            local otherRecipes = unlocks[effect.recipe]
            if otherRecipes ~= nil then
                for j = 1, #otherRecipes do
                    local recipe = force.recipes[otherRecipes[j]]
                    if recipe ~= nil then
                        recipe.enabled = enabled
                    end
                end
            end
        end
    end
end

script.on_event(defines.events.on_research_finished, function(event)
    local effects = event.research.effects
    local force = event.research.force
    togglePermutations(effects, force, true)
end)

local function handleForceTechnologyEffectsReset(force)
    for _, technology in pairs(force.technologies) do
        togglePermutations(technology.effects, force, technology.researched)
    end
end

script.on_event(defines.events.on_technology_effects_reset, function(event)
    handleForceTechnologyEffectsReset(event.force)
end)

script.on_event(defines.events.on_force_created, function(event)
    handleForceTechnologyEffectsReset(event.force)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    handleForceTechnologyEffectsReset(event.destination)
end)

local reverseFactorial = {
    [0] = 0, [1] = 2, [2] = 2, [5] = 3, [6] = 3, [23] = 4, [24] = 4, [119] = 5, [120] = 5,
    [719] = 6, [720] = 6, [5039] = 7, [5040] = 7, [40319] = 8, [40320] = 8 }
local factorial = {}
for i = 0, 8 do
    factorial[i] = common.functions.factorial(i)
end

-- Temporary solution until a better algorithm is implemented
local function permutationByCount(ttable, n, target, counter)
    if n == 0 then
		counter[1] = counter[1] + 1
		return counter[1] == target
    end

    for i = 1, n do
        ttable[n], ttable[i] = ttable[i], ttable[n]
        if permutationByCount(ttable, n - 1, target, counter) then
			return true
		end
        ttable[n], ttable[i] = ttable[i], ttable[n]
    end
end

local function permutationNumberByTarget(ttable, n, target, counter, position)
    if position ~= nil and position == 0 then
		counter[1] = counter[1] + 1
		local equal = true
		for i = 1, #target do
			if ttable[i] ~= target[i] then
				equal = false
				break
			end
		end
		return equal
    end
	position = position or n
    for i = 1, position do
        ttable[position], ttable[i] = ttable[i], ttable[position]
        if permutationNumberByTarget(ttable, n, target, counter, position - 1) then
			return true
		end
        ttable[position], ttable[i] = ttable[i], ttable[position]
    end
end

local function flipOne(index, maxIndex)
    local count = reverseFactorial[maxIndex]
    local indexesHolder = {}
    local permutedIndexes = {}
    local counter = {0}
    for i = 1, count do
        indexesHolder[i] = i
        permutedIndexes[i] = i
    end

    permutationByCount(permutedIndexes, count, index, counter)

    for i = 1, math.floor((count + 1)/ 2) do
        permutedIndexes[i], permutedIndexes[count + 1 - i] = permutedIndexes[count + 1 - i], permutedIndexes[i]
    end

    counter[1] = 0
    permutationNumberByTarget(indexesHolder, count, permutedIndexes, counter)

    return counter[1]
end

local remote_interface = {}
function remote_interface.flip_recipe(recipeName)
    if permutations == nil then
        error("flip_recipe called too early. on_init/on_load/on_configuration_changed not yet called for Fluid_Permutations")
    end
    local recipePermutations = permutations[recipeName]
    if recipePermutations == nil then
        return nil
    end
    local groupName = recipePermutations.groupName
    local baseRecipe = permutations[groupName]
    local flippedI = flipOne(recipePermutations.ingredientRotation, baseRecipe.ingredientRotation)
    local flippedR = flipOne(recipePermutations.resultRotation, baseRecipe.resultRotation)
    if flippedI == baseRecipe.ingredientRotation and flippedR == baseRecipe.resultRotation then
        return groupName
    end
    return generateRecipeName(
        groupName,
        common.FP_RECIPE_AFFIX,
        baseRecipe.difficulty,
        flippedI,
        flippedR)
end

remote.add_interface(common.REMOTE_INTERFACE_NAME, remote_interface)


local function buildRegistry()
    local simpleMode = settings.startup["fluid-permutations-simple-mode"].value
    local difficulty = game.difficulty_settings.recipe_difficulty
    -- n - normal - '0', e - expensive - '1', a - all - '-1'
    local difficultyMap = { n = 0, e = 1, a = -1}
    local fpPatternString = "%"..common.FP_RECIPE_AFFIX.."%-d([ane])%-i(%d+)%-r(%d+)"
    local omnipermPattern = common.OMNIPERMUTE_AFFIX.."%-%d+-%d+"
    local groups = {}
    permutations = {}
    unlocks = {}

    for _, recipe in pairs(game.recipe_prototypes) do
        local start, _, recipeDifficulty, ingredientRotation, resultRotation = string.find(recipe.name, fpPatternString)
        if start then
            local omnipermuteStart = string.find(recipe.name, omnipermPattern)
            if omnipermuteStart then
                start = omnipermuteStart
            end
            local originalRecipeName = string.sub(recipe.name, 0, start - 1)
            if recipeDifficulty == "a" or difficultyMap[recipeDifficulty] == difficulty then
                local group = groups[originalRecipeName]
                if not group then
                    group = {
                        limits = {
                            maxI = 0,
                            maxR = 0,
                            difficulty = recipeDifficulty
                        }
                    }
                    groups[originalRecipeName] = group
                end

                ingredientRotation = tonumber(ingredientRotation)
                resultRotation = tonumber(resultRotation)

                group.limits.maxI = math.max(group.limits.maxI, ingredientRotation)
                group.limits.maxR = math.max(group.limits.maxR, resultRotation)

                group[recipe.name] = {
                    name = recipe.name,
                    groupName = originalRecipeName,
                    ingredientRotation = ingredientRotation,
                    resultRotation = resultRotation
                }
            end
        end
    end

    for name, group in pairs(groups) do
        local limits = group.limits
        group.limits = nil
        if limits.maxI == 0 and limits.maxR == 1 then
            limits.maxR = 2
        elseif limits.maxI == 1 and limits.maxR == 0 then
            limits.maxI = 2
        end

        local recipeUnlocks = {}

        local base = {
            name = name,
            groupName = name,
            ingredientRotation = limits.maxI,
            resultRotation = limits.maxR,
            difficulty = limits.difficulty,
        }
        local alternativeBaseName = generateRecipeName(name, common.FP_RECIPE_AFFIX, limits.difficulty, limits.maxI, limits.maxR)
        group[alternativeBaseName] = base

        local resultsFluidCount = 0
        local ingredientsFluidCount = 0
        resultsFluidCount = reverseFactorial[limits.maxR]
        ingredientsFluidCount = reverseFactorial[limits.maxI]
        for _, permutation in pairs(group) do
            recipeUnlocks[#recipeUnlocks + 1] = permutation.name

            if limits.maxR > 0 then
                local nextResultPermutationIndex
                if simpleMode and permutation.resultRotation < limits.maxR then
                    nextResultPermutationIndex = limits.maxR
                else
                    nextResultPermutationIndex = permutation.resultRotation % limits.maxR + 1
                end
                local nextPermutationName = generateRecipeName(name, common.FP_RECIPE_AFFIX, limits.difficulty,
                        permutation.ingredientRotation, nextResultPermutationIndex)
                local nextPermutationTable = group[nextPermutationName]

                permutation[NEXT_RESULT_KEY] = nextPermutationTable
                nextPermutationTable[PREVIOUS_RESULT_KEY] = permutation

                permutation.resultsFluidCount = resultsFluidCount
            end
            if limits.maxI > 0 then
                local nextIngredientPermutationIndex
                if simpleMode and permutation.ingredientRotation < limits.maxI then
                    nextIngredientPermutationIndex = limits.maxI
                else
                    nextIngredientPermutationIndex = permutation.ingredientRotation % limits.maxI + 1
                end
                local nextPermutationName = generateRecipeName(name, common.FP_RECIPE_AFFIX, limits.difficulty,
                        nextIngredientPermutationIndex, permutation.resultRotation)
                local nextPermutationTable = group[nextPermutationName]

                permutation[NEXT_INGREDIENT_KEY] = nextPermutationTable
                nextPermutationTable[PREVIOUS_INGREDIENT_KEY] = permutation

                permutation.ingredientsFluidCount = ingredientsFluidCount
            end
            permutations[permutation.name] = permutation
        end

        for _, permutation in pairs(group) do
            if limits.maxR == 0 then
                local other = permutation[NEXT_INGREDIENT_KEY]
                if other ~= nil then
                    permutation[NEXT_RESULT_CROSS_KEY] = other.name
                    other[PREVIOUS_RESULT_CROSS_KEY] = permutation.name
                end
            elseif limits.maxR > 0 and permutation.resultRotation == limits.maxR and limits.maxI > 0 then
                local other = permutation[NEXT_RESULT_KEY][NEXT_INGREDIENT_KEY]
                if other ~= nil then
                    permutation[NEXT_RESULT_CROSS_KEY] = other.name
                    other[PREVIOUS_RESULT_CROSS_KEY] = permutation.name
                end
            end
            if limits.maxI == 0 then
                local other = permutation[NEXT_RESULT_KEY]
                if other ~= nil then
                    permutation[NEXT_INGREDIENT_CROSS_KEY] = other.name
                    other[PREVIOUS_INGREDIENT_CROSS_KEY] = permutation.name
                end
            elseif limits.maxI > 0 and permutation.ingredientRotation == limits.maxI and limits.maxR > 0 then
                local other = permutation[NEXT_INGREDIENT_KEY][NEXT_RESULT_KEY]
                if other ~= nil then
                    permutation[NEXT_INGREDIENT_CROSS_KEY] = other.name
                    other[PREVIOUS_INGREDIENT_CROSS_KEY] = permutation.name
                end
            end
        end

        for _, permutation in pairs(group) do
            for i = NEXT_INGREDIENT_KEY,4 do
                local target = permutation[i]
                if target ~= nil then
                    permutation[i] = target.name
                end
            end
        end

        unlocks[name] = recipeUnlocks
    end
    global.permutations = permutations
    global.unlocks = unlocks
end

script.on_load(function()
    permutations = global.permutations or {}
    unlocks = global.unlocks or {}
    playerSettings = global.playerSettings or {}
end)

local function readPlayerSettings(playerIndex, player)
    player = player or game.get_player(playerIndex)
    local value = settings.get_player_settings(player)[CROSS_CYCLE_SETTING].value
    playerSettings[player.index][CROSS_CYCLE_SETTING] = value
end

script.on_configuration_changed(function(conf)
    playerSettings = {}
    global.playerSettings = playerSettings

    for _, player in pairs(game.connected_players) do
        playerSettings[player.index] = {}
        readPlayerSettings(nil, player)
    end

    buildRegistry()

    for _, force in pairs(game.forces) do
        handleForceTechnologyEffectsReset(force)
    end
end)

script.on_init(function(conf)
    buildRegistry()

    playerSettings = {}
    global.playerSettings = playerSettings
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    playerSettings[event.player_index] = {}
    readPlayerSettings(event.player_index)
end)

script.on_event(defines.events.on_player_left_game, function(event)
    playerSettings[event.player_index] = nil
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting_type ~= "runtime-per-user" or event.setting ~= CROSS_CYCLE_SETTING then
        return
    end
    readPlayerSettings(event.player_index)
end)
