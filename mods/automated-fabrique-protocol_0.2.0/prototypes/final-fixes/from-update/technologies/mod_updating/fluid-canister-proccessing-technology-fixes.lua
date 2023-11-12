local function filterFillEmptyFluidCanisterRecipeNames(recipeName)
    local fluid_names = getBasicFluidNames()
    return not _table.contains(_table.map(fluid_names,
            function(fluid_name)
                local target_fluid_name = fluid_name
                if (target_fluid_name and target_fluid_name ~= '') then target_fluid_name = '-' .. target_fluid_name end
                return 'empty' .. target_fluid_name .. '-barrel'
            end), recipeName)
        and not _table.contains(_table.map(fluid_names,
            function(fluid_name)
                local target_fluid_name = fluid_name
                if (target_fluid_name and target_fluid_name ~= '') then target_fluid_name = '-' .. target_fluid_name end
                return 'fill' .. target_fluid_name .. '-barrel'
            end), recipeName)
        and recipeName ~= 'barreling-pump'
        and recipeName ~= 'empty-canister'
end
local function updateFluidCanisterProcessingTechnologyEffects(technologies, mode)
    if not technologies['fluid-canister-processing'] then return end
    local result = _table.filter(techUtil.getAllRecipesNamesForSpecifiedTechnology('fluid-canister-processing'),
        filterFillEmptyFluidCanisterRecipeNames)
    log('fluid canister recipes available: ' .. Utils.dump_to_console(result))
end

local technologies = data.raw["technology"]
updateFluidCanisterProcessingTechnologyEffects(technologies, "normal")
updateFluidCanisterProcessingTechnologyEffects(technologies, "expensive")
