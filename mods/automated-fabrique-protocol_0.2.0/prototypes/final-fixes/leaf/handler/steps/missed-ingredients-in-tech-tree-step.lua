local TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep = {}

local function handleIngredientInTechnologyIngredientsList(ingredient, products, technology_name, mode)
    if not _table.contains_f(products,
            function(product)
                return ingredient.type == product.type and ingredient.name == product.name
            end)
    then
        EvaluatingStepStatusHolder.addNotFoundIngredientToTechnologyStatus(mode, technology_name, ingredient)
    end
end
local function writeMissedIngredientsInTechnologyTreeToTechnologyStatus(technology_name, mode)
    local recipe_ingredients = EvaluatingStepStatusHolder.getEffectIngredientsFromTechnologyStatus(mode, technology_name)
    local technology_unit_ingredients = EvaluatingStepStatusHolder.getUnitsFromTechnologyStatus(mode, technology_name)
    local all_need_ingredients_for_technology_research = {}
    _table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, recipe_ingredients)
    _table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, technology_unit_ingredients)
    local products = EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(mode, technology_name)
    _table.each(all_need_ingredients_for_technology_research,
        function(ingredient)
            handleIngredientInTechnologyIngredientsList(ingredient, products, technology_name, mode)
        end)
end
local function handleRootTechnologyTreeForNotFoundIngredientResolved(root_technology_name, technology_name, mode)
    local products = EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(mode, technology_name)
    local effect_ingredients_not_found_in_current_tree = EvaluatingStepStatusHolder
        .getNotFoundIngredientsFromTechnologyStatus(
            mode,
            root_technology_name)
    _table.each(effect_ingredients_not_found_in_current_tree,
        function(effect_ingredient_not_found_in_current_tree)
            if _table.contains_f(products,
                    function(product)
                        return effect_ingredient_not_found_in_current_tree.type == product.type and
                            effect_ingredient_not_found_in_current_tree.name == product.name
                    end)
            then
                EvaluatingStepStatusHolder.resolveNotFoundIngredientsFromTechnologyStatus(mode, root_technology_name,
                    effect_ingredient_not_found_in_current_tree)
            end
        end)
end
local function removeIngredientFromNotFoundListInTechnologyTree(root_technology_names, technology_name, mode)
    _table.each(root_technology_names,
        function(root_technology_name)
            handleRootTechnologyTreeForNotFoundIngredientResolved(root_technology_name, technology_name, mode)
        end)
end
TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate = function(
    technology_name, mode, root_technology_names)
    if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
        return
    end
    EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)

    table.insert(root_technology_names, #root_technology_names + 1, technology_name)
    writeMissedIngredientsInTechnologyTreeToTechnologyStatus(technology_name, mode)
    removeIngredientFromNotFoundListInTechnologyTree(root_technology_names, technology_name, mode)

    local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)
    if not dependencies then
        table.remove(root_technology_names, #root_technology_names)
        return
    end
    _table.each(dependencies,
        function(dependency_name)
            TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate(
                dependency_name,
                mode,
                root_technology_names)
        end)
    table.remove(root_technology_names,
        #root_technology_names)
end

return TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep
