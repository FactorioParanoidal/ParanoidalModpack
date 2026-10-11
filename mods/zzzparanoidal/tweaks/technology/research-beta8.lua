-- Цена исследований как в Beta 8 normal: число циклов/формула, наука, время цикла.
-- Источник: локальные решения Р-1…Р-11 (review/research-beta8-alignment/cat*.json), применяется одной пачкой.
-- Поздняя стадия: после OV.execute и всех поздних правок дерева; эффект эволюции пересчитывается позже.
-- Остальные поля (предки, открытия, бонусы) не меняются, кроме явно согласованных ниже.

local technologies = data.raw.technology

-- [id 2.0] = {count | formula, time, ingredients}; комментарий — решение и исследование Beta 8.
local units = {
    ["advanced-depleted-uranium-smelting-1"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-3: advanced-depleted-uranium-smelting-1
    ["advanced-depleted-uranium-smelting-2"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-3: advanced-depleted-uranium-smelting-2
    ["advanced-magnesium-smelting"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-2: advanced-magnesium-smelting
    ["advanced-osmium-smelting"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-2: advanced-osmium-smelting
    ["advanced-uranium-processing-1"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-3: advanced-uranium-processing-1
    ["advanced-uranium-processing-2"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-3: advanced-uranium-processing-2
    ["angels-advanced-bio-processing"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-6: angels-advanced-bio-processing
    ["angels-bio-desert-farming-1"] = {count = 32, time = 30, ingredients = {{"automation-science-pack", 4}, {"angels-token-bio", 1}}}, -- Р-6: bio-desert-farming-1
    ["angels-bio-farm-advanced-upgrade-2"] = {count = 256, time = 30, ingredients = {{"automation-science-pack", 4}, {"logistic-science-pack", 4}, {"chemical-science-pack", 4}, {"production-science-pack", 4}, {"angels-token-bio", 1}}}, -- Р-6: bio-farm-advanced-upgrade
    ["angels-bio-swamp-farming-1"] = {count = 32, time = 30, ingredients = {{"automation-science-pack", 4}, {"angels-token-bio", 1}}}, -- Р-6: bio-swamp-farming-1
    ["angels-bio-temperate-farming-1"] = {count = 32, time = 30, ingredients = {{"automation-science-pack", 4}, {"angels-token-bio", 1}}}, -- Р-6: bio-temperate-farming-1
    ["angels-bio-wood-processing-2"] = {count = 50, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-6: bio-wood-processing-2
    ["angels-chrome-smelting-1"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-2: angels-chrome-smelting-1
    ["angels-chrome-smelting-2"] = {count = 250, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-2: angels-chrome-smelting-2
    ["angels-chrome-smelting-3"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-2: angels-chrome-smelting-3
    ["angels-cobalt-casting-2"] = {count = 250, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-2: angels-cobalt-casting-2
    ["angels-ironworks-4"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-2: angels-ironworks-4
    ["angels-ironworks-5"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-2: angels-ironworks-5
    ["angels-ore-electro-whinning-cell"] = {count = 75, time = 15, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-2: ore-electro-whinning-cell
    ["angels-ore-processing-5"] = {count = 250, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-2: ore-processing-5
    ["angels-tungsten-carbide-smelting-3"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-2: angels-tungsten-carbide-smelting-3
    ["angels-tungsten-smelting-3"] = {count = 350, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-2: angels-tungsten-smelting-3
    ["automation-4"] = {count = 80, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-8: automation-4
    ["automation-5"] = {count = 120, time = 60, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-8: automation-5
    ["automation-6"] = {count = 150, time = 75, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-8: automation-6
    ["automation-7"] = {count = 200, time = 100, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"utility-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-8: automation-7
    ["automation-8"] = {count = 250, time = 150, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"utility-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-8: automation-8
    ["automation-9"] = {count = 500, time = 200, ingredients = {{"automation-science-pack", 2}, {"logistic-science-pack", 1}, {"utility-science-pack", 1}, {"production-science-pack", 2}}}, -- Р-8: automation-9
    ["battery-mk3-equipment"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-1: bob-battery-equipment-3
    ["bob-advanced-research"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-10: advanced-research
    ["bob-alien-research"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-10: alien-research
    ["bob-area-drills-1"] = {count = 50, time = 30, ingredients = {{"automation-science-pack", 1}}}, -- Р-5: bob-area-drills-1
    ["bob-area-drills-3"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-5: bob-area-drills-3
    ["bob-area-drills-4"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-5: bob-area-drills-4
    ["bob-battery-equipment-5"] = {count = 250, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-purple", 1}, {"bob-alien-science-pack-yellow", 1}}}, -- Р-1: bob-battery-equipment-5
    ["bob-drills-2"] = {count = 50, time = 30, ingredients = {{"automation-science-pack", 1}}}, -- Р-5: bob-drills-1
    ["bob-drills-4"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-5: bob-drills-3
    ["bob-drills-5"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-5: bob-drills-4
    ["bob-electronics-machine-3"] = {count = 100, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-8: electronics-machine-3
    ["bob-fission-reactor-equipment-2"] = {count = 250, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-1: fusion-reactor-equipment-2
    ["bob-fission-reactor-equipment-3"] = {count = 300, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-blue", 1}, {"bob-alien-science-pack-orange", 1}}}, -- Р-1: fusion-reactor-equipment-3
    ["bob-fission-reactor-equipment-4"] = {count = 350, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-purple", 1}, {"bob-alien-science-pack-yellow", 1}}}, -- Р-1: fusion-reactor-equipment-4
    ["bob-fluid-handling-3"] = {count = 75, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-7: bob-fluid-handling-3
    ["bob-fluid-handling-4"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"bob-advanced-logistic-science-pack", 1}}}, -- Р-7: bob-fluid-handling-4
    ["bob-fluid-wagon-3"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 2}, {"logistic-science-pack", 2}, {"chemical-science-pack", 1}}}, -- Р-7: bob-fluid-wagon-3
    ["bob-more-inserters-2"] = {count = 900, time = 15, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 2}, {"chemical-science-pack", 1}}}, -- Р-7: more-inserters-2
    ["bob-plasma-turrets-1"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: bob-plasma-turrets-1
    ["bob-plasma-turrets-2"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: bob-plasma-turrets-2
    ["bob-plasma-turrets-3"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-4: bob-plasma-turrets-3
    ["bob-plasma-turrets-4"] = {count = 400, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-4: bob-plasma-turrets-4
    ["bob-pumpjacks-2"] = {count = 50, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-5: bob-pumpjacks-1
    ["bob-pumpjacks-3"] = {count = 75, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 2}}}, -- Р-5: bob-pumpjacks-2
    ["bob-pumpjacks-4"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-5: bob-pumpjacks-4
    ["bob-railway-3"] = {count = 100, time = 20, ingredients = {{"automation-science-pack", 2}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-7: bob-railway-3
    ["bob-repair-pack-4"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-11: bob-repair-pack-4
    ["bob-repair-pack-5"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-11: bob-repair-pack-5
    ["bob-rtg"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: rtg
    ["bob-solar-panel-equipment-2"] = {count = 75, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-1: solar-panel-equipment-2
    ["bob-solar-panel-equipment-3"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-1: solar-panel-equipment-3
    ["bob-solar-panel-equipment-4"] = {count = 100, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-1: solar-panel-equipment-4
    ["bob-vehicle-big-turret-equipment-1"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: vehicle-big-turret-equipment-1
    ["bob-vehicle-big-turret-equipment-2"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: vehicle-big-turret-equipment-2
    ["bob-vehicle-big-turret-equipment-3"] = {count = 250, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-4: vehicle-big-turret-equipment-3
    ["bob-vehicle-big-turret-equipment-4"] = {count = 400, time = 30, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-green", 1}, {"bob-alien-science-pack-red", 1}}}, -- Р-4: vehicle-big-turret-equipment-6
    ["bob-vehicle-fission-cell-equipment-1"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-1: vehicle-fusion-cell-equipment-1
    ["bob-vehicle-fission-cell-equipment-2"] = {count = 125, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-1: vehicle-fusion-cell-equipment-2
    ["bob-vehicle-fission-cell-equipment-3"] = {count = 150, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-1: vehicle-fusion-cell-equipment-3
    ["bob-vehicle-fission-cell-equipment-4"] = {count = 200, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-blue", 1}, {"bob-alien-science-pack-orange", 1}}}, -- Р-1: vehicle-fusion-cell-equipment-4
    ["bob-vehicle-fission-cell-equipment-5"] = {count = 250, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-purple", 1}, {"bob-alien-science-pack-yellow", 1}}}, -- Р-1: vehicle-fusion-cell-equipment-5
    ["bob-vehicle-fission-cell-equipment-6"] = {count = 300, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-green", 1}, {"bob-alien-science-pack-red", 1}}}, -- Р-1: vehicle-fusion-cell-equipment-6
    ["bob-vehicle-fission-reactor-equipment-1"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-1: vehicle-fusion-reactor-equipment-1
    ["bob-vehicle-fission-reactor-equipment-2"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-1: vehicle-fusion-reactor-equipment-2
    ["bob-vehicle-fission-reactor-equipment-3"] = {count = 300, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-1: vehicle-fusion-reactor-equipment-3
    ["bob-vehicle-fission-reactor-equipment-4"] = {count = 350, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-blue", 1}, {"bob-alien-science-pack-orange", 1}}}, -- Р-1: vehicle-fusion-reactor-equipment-4
    ["bob-vehicle-fission-reactor-equipment-5"] = {count = 400, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-purple", 1}, {"bob-alien-science-pack-yellow", 1}}}, -- Р-1: vehicle-fusion-reactor-equipment-5
    ["bob-vehicle-fission-reactor-equipment-6"] = {count = 450, time = 45, ingredients = {{"bob-science-pack-gold", 1}, {"bob-alien-science-pack", 1}, {"bob-alien-science-pack-green", 1}, {"bob-alien-science-pack-red", 1}}}, -- Р-1: vehicle-fusion-reactor-equipment-6
    ["bob-vehicle-solar-panel-equipment-1"] = {count = 50, time = 15, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-1: vehicle-solar-panel-equipment-1
    ["bob-vehicle-solar-panel-equipment-2"] = {count = 75, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-1: vehicle-solar-panel-equipment-2
    ["bob-vehicle-solar-panel-equipment-3"] = {count = 90, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-1: vehicle-solar-panel-equipment-3
    ["bob-vehicle-solar-panel-equipment-4"] = {count = 100, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-1: vehicle-solar-panel-equipment-4
    ["bob-vehicle-solar-panel-equipment-5"] = {count = 125, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-1: vehicle-solar-panel-equipment-5
    ["burner-mechanics"] = {count = 1, time = 60, ingredients = {{"automation-science-pack", 1}}}, -- Р-5: basic-automation
    ["chrome-ore-refining"] = {count = 75, time = 15, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-2: chrome-ore-refining
    ["cybersyn-train-network"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-11: logistic-train-network
    ["fission-reactor-equipment"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-1: fusion-reactor-equipment
    ["fluid-handling"] = {count = 30, time = 15, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-7: fluid-handling
    ["follower-robot-count-1"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: follower-robot-count-1
    ["follower-robot-count-2"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: follower-robot-count-2
    ["follower-robot-count-3"] = {count = 400, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: follower-robot-count-3
    ["follower-robot-count-4"] = {count = 600, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: follower-robot-count-4
    ["mixed-oxide-fuel"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: mixed-oxide-fuel
    ["nuclear-fuel-1"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: nuclear-fuel-1
    ["nuclear-fuel-2"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: nuclear-fuel-2
    ["nuclear-fuel-3"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: nuclear-fuel-3
    ["oil-gathering"] = {count = 50, time = 15, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-5: oil-gas-extraction
    ["phosphorus-processing-2"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}}}, -- Р-2: phosphorus-processing-2
    ["platinum-ore-refining"] = {count = 75, time = 15, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-2: platinum-ore-refining
    ["radiothermal-fuel-1"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: radiothermal-fuel-1
    ["radiothermal-fuel-2"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: radiothermal-fuel-2
    ["radiothermal-fuel-3"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-3: radiothermal-fuel-3
    ["steam-power"] = {count = 100, time = 10, ingredients = {{"automation-science-pack", 1}}}, -- Р-5: steam-power
    ["thermonuclear-bomb"] = {count = 10000, time = 45, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}, {"production-science-pack", 1}, {"utility-science-pack", 1}}}, -- Р-4: thermonuclear-bomb
    ["thorium-nuclear-fuel-reprocessing-2"] = {count = 2000, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-3: thorium-nuclear-fuel-reprocessing-2
    ["thorium-ore-processing"] = {count = 100, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"production-science-pack", 1}}}, -- Р-3: thorium-ore-processing
    ["toolbelt-2"] = {count = 150, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}}}, -- Р-1: toolbelt-2
    ["toolbelt-3"] = {count = 200, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"bob-advanced-logistic-science-pack", 1}}}, -- Р-1: toolbelt-3
    ["toolbelt-4"] = {count = 250, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}, {"bob-advanced-logistic-science-pack", 1}}}, -- Р-1: toolbelt-4
    ["toolbelt-5"] = {formula = "2^(L-4)*150", time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1}, {"bob-advanced-logistic-science-pack", 1}}}, -- Р-1: toolbelt-5
    ["uranium-ammo"] = {count = 300, time = 30, ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}}, -- Р-4: uranium-ammo
    ["zcs-trash-landfill-tech"] = {count = 20, time = 30, ingredients = {{"automation-science-pack", 1}}}, -- Р-7: zcs-trash-landfill
}

-- Предок, открывающий колбу Beta 8, которой нет среди предков 2.0 (Р-1 п.2, Р-2 п.2, Р-3 п.2).
local prerequisites = {
    ["advanced-depleted-uranium-smelting-1"] = {"utility-science-pack"},
    ["advanced-osmium-smelting"] = {"utility-science-pack"},
    ["bob-vehicle-fission-cell-equipment-3"] = {"utility-science-pack"},
    ["bob-vehicle-fission-cell-equipment-4"] = {"bob-alien-research"},
    ["bob-vehicle-fission-reactor-equipment-2"] = {"utility-science-pack"},
    ["bob-vehicle-fission-reactor-equipment-4"] = {"bob-alien-research"},
    ["toolbelt-3"] = {"bob-advanced-logistic-science-pack"},
    ["toolbelt-5"] = {"space-science-pack"},
}

for name, unit in pairs(units) do
    local technology = technologies[name]
    if technology then
        technology.unit = technology.unit or {}
        technology.unit.count = not unit.formula and unit.count or nil
        technology.unit.count_formula = unit.formula
        technology.unit.time = unit.time
        technology.unit.ingredients = unit.ingredients
        -- Подсказка эволюции посчитана по старой цене: убрать, research-evolution-icon создаст заново.
        for i = #(technology.effects or {}), 1, -1 do
            local effect = technology.effects[i]
            local description = effect.type == "nothing" and type(effect.effect_description) == "table" and effect.effect_description[1]
            if description == "research-evolution-factor-effect" or description == "research-evolution-factor-effect-unknown" then
                table.remove(technology.effects, i)
            end
        end
    else
        log("research-beta8: нет технологии " .. name)
    end
end

for name, list in pairs(prerequisites) do
    local technology = technologies[name]
    if technology then
        technology.prerequisites = technology.prerequisites or {}
        for _, prerequisite in ipairs(list) do
            local present = false
            for _, existing in ipairs(technology.prerequisites) do
                if existing == prerequisite then present = true end
            end
            if technologies[prerequisite] and not present then
                table.insert(technology.prerequisites, prerequisite)
            end
        end
    end
end

-- Р-1 п.3: пояс для инструментов полностью как Beta 8.
local toolbelt_bonus = 10
for _, name in ipairs({"toolbelt", "toolbelt-2", "toolbelt-3", "toolbelt-4", "toolbelt-5"}) do
    local technology = technologies[name]
    for _, effect in ipairs(technology and technology.effects or {}) do
        if effect.type == "character-inventory-slots-bonus" then effect.modifier = toolbelt_bonus end
    end
end
if technologies["toolbelt-5"] then technologies["toolbelt-5"].max_level = 13 end
-- toolbelt-6 из 2.0 пересекается с уровнями 5–13: движок не принимает даже скрытый прототип, поэтому удаляем.
-- На него не ссылаются предки и control/миграции модов; aai-industry меняет его max_level раньше, на стадии данных.
if technologies["toolbelt-5"] then technologies["toolbelt-6"] = nil end
