local function linkBasicTechnologiesToNormalTree(mode)
    local technologies = data.raw["technology"]
    techUtil.resetTechnologyPrerequisites(technologies["factory-architecture-t1"], { 'basic-researching' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['basic-automation'],
        { "factory-architecture-t1", 'basic-researching' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['stone-wall'], { 'military-0', 'basic-automation' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['water-pumpjack-1'],
        { 'basic-automation', 'basic-metal-processing',
            'angels-copper-smelting-1', 'electricity', 'coal-ore-smelting' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['basic-logistics'],
        { 'logistics-0', 'basic-automation', 'iron-storage' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['logistics-0'],
        { 'basic-automation', 'coal-ore-smelting', 'basic-wood-production',
            'basic-metal-processing', 'basic-researching' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['armor-absorb-1'], { 'basic-automation' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['bi-dart-turret'], { 'basic-automation', 'basic-metal-processing',
        'basic-wood-production' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['military'], { 'basic-automation', 'military-0' }, mode)
    techUtil.resetTechnologyPrerequisites(technologies['electricity'], { 'basic-automation', 'electricity-0' }, mode)
    _table.each(technologies,
        function(technology)
            if string.find(technology.name, 'qol-', 1, true) then
                techUtil.hideTechnology(technology, mode)
            end
        end)
end
local function updateBasicEffects(mode)
    local technologies = data.raw["technology"]
    techUtil.addRecipeEffectToTechnologyEffects(technologies['logistics-0'], 'basic-transport-belt', mode)
    techUtil.addRecipeEffectToTechnologyEffects(technologies['military-2'], 'copper-nickel-firearm-magazine', mode)
    techUtil.addRecipeEffectToTechnologyEffects(technologies['basic-fluid-handling'], 'offshore-pump-0', mode)
    local ore_crushing_technology = technologies['ore-crushing']
    techUtil.addPrerequisitesToTechnology(ore_crushing_technology, { 'burner-ore-crushing' }, mode)
    techUtil.addPrerequisitesToTechnology(technologies['electric-mining'], { 'burner-ore-mining' }, mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore5-crushed', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore6-crushed', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'iron-plate', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'copper-plate', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'lead-plate', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'tin-plate', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'glass-from-ore4', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore5-crushed-smelting', mode)
    techUtil.addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore6-crushed-smelting', mode)
    techUtil.removeRecipeEffectFromTechnologyEffects(technologies['basic-automation'], 'steam-inserter', mode)
    techUtil.addRecipeEffectToTechnologyEffects(technologies['steam-power'], 'steam-inserter', mode)
    techUtil.addRecipeEffectToTechnologyEffects(technologies['steam-power'], createSteamRecipe(), mode)
end

linkBasicTechnologiesToNormalTree("normal")
linkBasicTechnologiesToNormalTree("expensive")
updateBasicEffects("normal")
updateBasicEffects("expensive")
