local function updateNotFoundEffectesAndSciencePacksNormal()
    local mode = "normal"
    TechnologyCycleRemovingBean.removePrerequisitesForCycleNormal(mode)
    TechnologyUnitAddBean.addAutomationSciencePackToTechnologyUnits(
        {
            'productivity-module'
        },
        mode
    )
    TechnologyUnitAddBean.addLogisticSciencePackToTechnologyUnits(
        {
            'alloy-processing',
            'water-treatment',
            'productivity-module'
        },
        mode)
    TechnologyUnitAddBean.addChemicalSciencePackToTechnologyUnits(
        {
            'chlorine-processing-2',
            'bio-nutrient-paste'
        },
        mode)
    TechnologyUnitAddBean.addProductionSciencePackToTechnologyUnits(
        {
            'utility-science-pack'
        },
        mode
    )
    TechnologyUnitAddBean.addProductivityProcessorToTechnologyUnits(
        {
            'production-science-pack',
            'utility-science-pack',
            'angels-tungsten-smelting-1',
            'ore-refining'
        },
        mode)
    TechnologyUnitAddBean.addEffectivityProcessorToTechnologyUnits(
        {
            'production-science-pack',
            'utility-science-pack',
            'angels-tungsten-smelting-1',
            'ore-refining'
        },
        mode)
    TechnologyUnitAddBean.addSpeedProcessorToTechnologyUnits(
        {
            'production-science-pack',
            'utility-science-pack',
            'angels-tungsten-smelting-1',
            'ore-refining'
        },
        mode)
    TechnologyUnitAddBean.addTokenBioToTechnologyUnits(
        {
            'bio-nutrient-paste'
        },
        mode)
    --[[
    removeRecipeEffectFromTechnologyEffects(technologies['nuclear-power'], 'RITEG-1')
    removeRecipeEffectFromTechnologyEffects(technologies['nuclear-power'], 'RITEG-1-from-used-up-RITEG-1')
    --
    addSciencePackToTechnologyUnit(technologies['uranium-ammo'], { "utility-science-pack", 1 })
    addRecipeEffectToTechnologyEffects(technologies['angels-manganese-smelting-2'], 'angels-plate-manganese')
    --
    addPrerequisitesToTechnology(technologies['bet-fuel-recycling'],
        { 'bet-fuel-3', 'bet-fuel-4' })

    addPrerequisitesToTechnology(technologies['raw-speed-module-6'],
        { 'modules-3', 'module-merging', 'raw-speed-module-5' })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['modules'], { { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-ironworks-2'], { { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['w93-modular-turrets-lcannon'], { { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['w93-modular-turrets'], { { "chemical-science-pack", 1 } })
    --

    addSciencePackToTechnologyUnit(technologies['phosphorus-processing-1'], { "logistic-science-pack", 1 })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-farm-1'],
        { { "logistic-science-pack", 1 }, { "token-bio", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['gardens'], { { "logistic-science-pack", 1 }, { "token-bio", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-processing-paste'],
        { { "chemical-science-pack", 1 }, { "productivity-processor", 1 },
            { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-desert-farming-1'], { { "logistic-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-swamp-farming-1'], { { "logistic-science-pack", 1 } })
    addPrerequisitesToTechnology(technologies['bio-nutrient-paste'],
        { 'bio-temperate-farming-2', 'bio-desert-farming-2', 'bio-swamp-farming-2' })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-temperate-farming-1'],
        { { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-farm-2'], { { "token-bio", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-fermentation'], { { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['gardens-2'], { { "token-bio", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-farm-alien'], { { "token-bio", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['modules-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['advanced-electronics-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-advanced-chemistry-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['productivity-module'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['effectivity-module'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['speed-module'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['speed-module-2'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['speed-module-3'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['speed-module-4'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['speed-module-5'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['speed-module-6'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['effectivity-module-2'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['effectivity-module-3'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['effectivity-module-4'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['effectivity-module-5'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['raw-speed-module-1'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['raw-speed-module-3'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['raw-speed-module-5'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['raw-speed-module-7'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['effectivity-module-6'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { 'token-bio', 1 },
            { "productivity-processor",  1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['module-merging'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 },
            { 'science-pack-gold',       1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['raw-speed-module-2'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 },
            { 'science-pack-gold',       1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 },
            { 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['raw-speed-module-4'],
        { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 },
            { 'science-pack-gold',       1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 },
            { 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    --[[techUtil.addSciencePacksToTechnologyUnits(technologies['raw-speed-module-6'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { 'military-science-pack', 1 },
			{ "productivity-processor",  1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			, { 'science-pack-gold', 1 }, { 'alien-science-pack-blue', 1 }, { 'pollution-clean-processor', 1 }, { 'token-bio', 1 }, { 'module-case', 1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['production-science-pack'],
        { { 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['utility-science-pack'],
        { { 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })

    techUtil.addSciencePacksToTechnologyUnits(technologies['ore-refining'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-gold-smelting-2'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-metallurgy-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['ore-processing-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-titanium-smelting-2'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['powder-metallurgy-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['military-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['advanced-depleted-uranium-smelting-1'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['uranium-ammo'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['nuclear-power'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bob-boiler-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['tungsten-processing'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-tungsten-carbide-smelting-1'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-ironworks-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-nitinol-smelting-1'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-ironworks-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['utility-science-pack'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-zinc-smelting-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['w93-modular-turrets-hcannon'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bet-fuel-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['battery-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['nitinol-processing'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['tungsten-alloy-processing'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-copper-tungsten-smelting-1'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['advanced-probe'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['space-science-pack'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['rocket-fuel'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-advanced-chemistry-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-stone-smelting-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['logistics-4'],
        { { 'utility-science-pack', 1 },
            { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['w93-modular-turrets-dcannon'],
        { { 'speed-processor', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bet-charger-3'],
        { { 'speed-processor', 1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['bet-fuel-4'],
        { { "module-circuit-board", 1 }, { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'science-pack-gold',    1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 }, { 'token-bio', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bet-fuel-recycling'],
        { { "module-circuit-board", 1 }, { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'science-pack-gold',    1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 }, { 'token-bio', 1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-advanced-chemistry-5'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['angels-nitrogen-processing-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['rocket-control-unit'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'token-bio',              1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-processing-crystal-full'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-refugium-biter-2'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-refugium-biter-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-refugium-puffer-3'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    techUtil.addSciencePacksToTechnologyUnits(technologies['bio-refugium-puffer-4'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
        , { 'token-bio',            1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['alien-blue-research'], { { 'automation-science-pack', 1 },
        { "productivity-processor",  1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
    , { 'chemical-science-pack', 1 }, { 'logistic-science-pack', 1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['advanced-research'], { { 'advanced-logistic-science-pack', 1 },
        { "productivity-processor",         1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }
    , { 'utility-science-pack', 1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['bob-shotgun-shells'],
        { { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
            { 'production-science-pack', 1 }, { 'utility-science-pack', 1 }, { 'chemical-science-pack', 1 } })
    --
    techUtil.addSciencePacksToTechnologyUnits(technologies['advanced-machining'],
        { { 'advanced-logistic-science-pack', 1 },
            { "productivity-processor",         1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
        })
    --]]
end
local function updateNotFoundEffectesAndSciencePacksExpensive()

end
updateNotFoundEffectesAndSciencePacksNormal()
updateNotFoundEffectesAndSciencePacksExpensive()
