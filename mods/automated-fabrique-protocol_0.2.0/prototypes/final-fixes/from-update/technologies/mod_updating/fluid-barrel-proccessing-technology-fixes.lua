local function filterFillEmptyFluidBarrelRecipeNames(recipe_name)
    local fluid_names = getBasicFluidNames()
    return not _table.contains(_table.map(fluid_names,
                function(fluid_name)
                    local target_fluid_name = fluid_name
                    if (target_fluid_name and target_fluid_name ~= '') then target_fluid_name = '-' .. target_fluid_name end
                    return 'empty' .. target_fluid_name .. '-barrel'
                end),
            recipe_name)
        and not _table.contains(_table.map(fluid_names,
                function(fluid_name)
                    local target_fluid_name = fluid_name
                    if (target_fluid_name and target_fluid_name ~= '') then target_fluid_name = '-' .. target_fluid_name end
                    return 'fill' .. target_fluid_name .. '-barrel'
                end),
            recipe_name)
        and recipe_name ~= 'barreling-pump'
        and recipe_name ~= 'empty-barrel'
end
local function updateFluidBarrelProcessingTechnologyEffects(technologies, mode)
    if not technologies['fluid-barrel-processing'] then return end
    local recipe_names = _table.filter(
        techUtil.getAllRecipesNamesForSpecifiedTechnology('fluid-barrel-processing', mode),
        filterFillEmptyFluidBarrelRecipeNames)
    log('fluid barrel recipes available: ' .. Utils.dump_to_console(recipe_names))
    _table.each(recipe_names,
        function(recipe_name)
            techUtil.removeRecipeEffectFromTechnologyEffects(technologies['fluid-barrel-processing'], recipe_name, mode)
            local technology_names = techUtil
                .getAllTechnologiesWithRecipeFluidIngredientsSpecifiedInAnotherRecipeByName(recipe_name, mode)
            log('for recipe ' ..
                recipe_name ..
                ' found following technologies with fluid result ' .. Utils.dump_to_console(technology_names))
            _table.each(technology_names,
                function(technology_name)
                    techUtil.addRecipeEffectToTechnologyEffects(technologies[technology_name], recipe_name, mode)
                end)
        end)
end

local technologies = data.raw["technology"]
_table.each(GAME_MODES,
    function(mode)
        updateFluidBarrelProcessingTechnologyEffects(technologies, mode)
    end)
