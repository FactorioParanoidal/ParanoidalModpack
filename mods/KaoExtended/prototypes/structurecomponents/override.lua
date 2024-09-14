local function replaceMachine()

  --KaoExtended.recipe.addtorecipe("bi_recipe_giga_wooden_chest", {"basic-structure-components", 5})
  KaoExtended.recipe.addtorecipe("warehouse-basic", {"basic-structure-components", 5})
  
  KaoExtended.recipe.addtorecipe("factory-2", {"basic-structure-components", 50})
  KaoExtended.recipe.addtorecipe("factory-2", {"factory-1-raw", 2})
  KaoExtended.recipe.addtorecipe("factory-3", {"intermediate-structure-components", 50})
  KaoExtended.recipe.addtorecipe("factory-3", {"factory-2-raw", 2})
    
  KaoExtended.recipe.addtorecipe("salination-plant", {"intermediate-structure-components", 5})
  KaoExtended.recipe.addtorecipe("salination-plant-2", {"advanced-structure-components", 5})
  KaoExtended.recipe.addtorecipe("salination-plant-2", {"salination-plant", 2})
  KaoExtended.recipe.addtorecipe("salination-plant-3", {"salination-plant-2", 2})
  
  KaoExtended.recipe.addtorecipe("washing-plant-2", {"intermediate-structure-components", 3})
  
  KaoExtended.recipe.addtorecipe("centrifuge", {"intermediate-structure-components", 3})
  KaoExtended.recipe.addtorecipe("centrifuge-mk2", {"advanced-structure-components", 3})
  KaoExtended.recipe.addtorecipe("centrifuge-mk3", {"advanced-structure-components", 10})

  KaoExtended.recipe.addtorecipe("assembling-machine-2", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("assembling-machine-3", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("assembling-machine-4", {"intermediate-structure-components", 5})
  KaoExtended.recipe.addtorecipe("assembling-machine-5", {"advanced-structure-components", 2})
  KaoExtended.recipe.addtorecipe("assembling-machine-6", {"advanced-structure-components", 10})

  KaoExtended.recipe.addtorecipe("rocket-silo", {"assembling-machine-6", 100})
  
  KaoExtended.recipe.addtorecipe("electronics-machine-1", {"basic-structure-components", 2})
  KaoExtended.recipe.addtorecipe("electronics-machine-2", {"intermediate-structure-components", 3})
  KaoExtended.recipe.addtorecipe("electronics-machine-3", {"advanced-structure-components", 3})
  
  KaoExtended.recipe.addtorecipe("electronics-machine-1", {"inserter", 4})
  KaoExtended.recipe.addtorecipe("electronics-machine-2", {"long-handed-inserter", 4})
  KaoExtended.recipe.addtorecipe("electronics-machine-3", {"turbo-inserter", 4})
  
  KaoExtended.recipe.addtorecipe("oil-refinery", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("oil-refinery-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("oil-refinery-3", {"intermediate-structure-components", 8})
  KaoExtended.recipe.addtorecipe("oil-refinery-4", {"advanced-structure-components", 2})
  
  KaoExtended.recipe.addtorecipe("chemical-plant", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("chemical-plant-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("chemical-plant-3", {"intermediate-structure-components", 8})
  KaoExtended.recipe.addtorecipe("chemical-plant-4", {"advanced-structure-components", 2})

  KaoExtended.recipe.addtorecipe("steel-furnace", {"stone-furnace", 2})
  KaoExtended.recipe.addtorecipe("electric-furnace", {"steel-furnace", 2})
  
  KaoExtended.recipe.addtorecipe("electric-furnace", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("electric-furnace-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("electric-furnace-3", {"advanced-structure-components", 2})
  
  KaoExtended.recipe.addtorecipe("electrolyser", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("electrolyser-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("electrolyser-3", {"intermediate-structure-components", 8})
  KaoExtended.recipe.addtorecipe("electrolyser-4", {"advanced-structure-components", 2})
  
  KaoExtended.recipe.addtorecipe("electric-chemical-mixing-furnace", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("electric-chemical-mixing-furnace-2", {"advanced-structure-components", 2})
  
  KaoExtended.recipe.addtorecipe("electric-mixing-furnace", {"electric-chemical-furnace", 2})
  KaoExtended.recipe.addtorecipe("electric-mixing-furnace", {"basic-structure-components", 2})
  
  KaoExtended.recipe.addtorecipe("electric-chemical-furnace", {"stone-chemical-furnace", 2})
  KaoExtended.recipe.addtorecipe("electric-chemical-furnace", {"basic-structure-components", 2})
end
local function replaceMining()
  KaoExtended.recipe.addtorecipe("bob-mining-drill-1", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("bob-mining-drill-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-mining-drill-3", {"advanced-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-mining-drill-4", {"anotherworld-structure-components", 2})
  
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-1", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-3", {"advanced-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-area-mining-drill-4", {"anotherworld-structure-components", 2})
  
  KaoExtended.recipe.addtorecipe("bob-pumpjack-1", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("bob-pumpjack-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-pumpjack-3", {"advanced-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-pumpjack-4", {"anotherworld-structure-components", 2})
end
local function replacePower()
  KaoExtended.recipe.addtorecipe("steam-engine-2", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("steam-engine-3", {"intermediate-structure-components", 1})
  
  if data.raw["item"]["petroleum-generator"] then
    KaoExtended.recipe.addtorecipe("petroleum-generator", {"steam-engine-3", 1})
    KaoExtended.recipe.addtorecipe("petroleum-generator", {"advanced-structure-components", 1})
  end
  if data.raw["item"]["steam-turbine"] then
    KaoExtended.recipe.addtorecipe("steam-turbine", {"advanced-structure-components", 3})
	KaoExtended.recipe.addtorecipe("steam-turbine-2", {"advanced-structure-components", 5})
	KaoExtended.recipe.addtorecipe("steam-turbine-3", {"anotherworld-structure-components", 1})
    KaoExtended.recipe.addtorecipe("nuclear-reactor", {"boiler-4", 1})
    KaoExtended.recipe.addtorecipe("nuclear-reactor", {"advanced-structure-components", 10})
  end
  
  KaoExtended.recipe.addtorecipe("solar-panel-small", {"basic-structure-components", 1})
  KaoExtended.recipe.addtorecipe("solar-panel", {"basic-structure-components", 2})
  KaoExtended.recipe.addtorecipe("solar-panel-large", {"basic-structure-components", 3})
  
  KaoExtended.recipe.addtorecipe("solar-panel-small-2", {"intermediate-structure-components", 1})
  KaoExtended.recipe.addtorecipe("solar-panel-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("solar-panel-large-2", {"intermediate-structure-components", 3})
  
  KaoExtended.recipe.addtorecipe("solar-panel-small-3", {"advanced-structure-components", 1})
  KaoExtended.recipe.addtorecipe("solar-panel-3", {"advanced-structure-components", 2})
  KaoExtended.recipe.addtorecipe("solar-panel-large-3", {"advanced-structure-components", 3})
end

local function replaceAngelRefi()

    KaoExtended.recipe.addtorecipe("thermal-extractor", {"basic-structure-components", 1})	
	
    KaoExtended.recipe.addtorecipe("ore-crusher-2", {"intermediate-structure-components", 1})
	KaoExtended.recipe.addtorecipe("ore-crusher-2", {"engine-unit", 2})
    KaoExtended.recipe.addtorecipe("ore-crusher-3", {"advanced-structure-components", 2})
	KaoExtended.recipe.addtorecipe("ore-crusher-3", {"electric-engine-unit", 2})
    
    KaoExtended.recipe.addtorecipe("ore-sorting-facility-2", {"basic-structure-components", 2})
    KaoExtended.recipe.addtorecipe("ore-sorting-facility-3", {"intermediate-structure-components", 3})
    KaoExtended.recipe.addtorecipe("ore-sorting-facility-4", {"advanced-structure-components", 4})
    
    KaoExtended.recipe.addtorecipe("ore-floatation-cell", {"basic-structure-components", 1})
    KaoExtended.recipe.addtorecipe("ore-floatation-cell-2", {"intermediate-structure-components", 2})
    KaoExtended.recipe.addtorecipe("ore-floatation-cell-3", {"advanced-structure-components", 2})
    
    KaoExtended.recipe.addtorecipe("ore-leaching-plant", {"basic-structure-components", 1})
    KaoExtended.recipe.addtorecipe("ore-leaching-plant-2", {"intermediate-structure-components", 2})
    KaoExtended.recipe.addtorecipe("ore-leaching-plant-3", {"advanced-structure-components", 2})
    
    KaoExtended.recipe.addtorecipe("ore-refinery", {"intermediate-structure-components", 2})
    KaoExtended.recipe.addtorecipe("ore-refinery-2", {"advanced-structure-components", 4})
    
    KaoExtended.recipe.addtorecipe("filtration-unit", {"basic-structure-components", 4})
    KaoExtended.recipe.addtorecipe("filtration-unit-2", {"intermediate-structure-components", 4})
    
    KaoExtended.recipe.addtorecipe("crystallizer", {"basic-structure-components", 4})
    KaoExtended.recipe.addtorecipe("crystallizer-2", {"intermediate-structure-components", 4})
    
    KaoExtended.recipe.addtorecipe("hydro-plant", {"basic-structure-components", 2})
    KaoExtended.recipe.addtorecipe("hydro-plant-2", {"intermediate-structure-components", 2})
	KaoExtended.recipe.addtorecipe("hydro-plant-3", {"advanced-structure-components", 2})
	
	KaoExtended.recipe.addtorecipe("algae-farm-2", {"basic-structure-components", 5})
	KaoExtended.recipe.addtorecipe("algae-farm-3", {"intermediate-structure-components", 5})
	
end

local function replaceAngelPetro()

    KaoExtended.recipe.addtorecipe("angels-electrolyser", {"basic-structure-components", 1})
    KaoExtended.recipe.addtorecipe("angels-electrolyser-2", {"intermediate-structure-components", 2})
    KaoExtended.recipe.addtorecipe("angels-electrolyser-3", {"intermediate-structure-components", 8})
    KaoExtended.recipe.addtorecipe("angels-electrolyser-4", {"advanced-structure-components", 2})
	
    KaoExtended.recipe.addtorecipe("advanced-chemical-plant", {"intermediate-structure-components", 3})
    KaoExtended.recipe.addtorecipe("advanced-chemical-plant-2", {"advanced-structure-components", 3})
	
    KaoExtended.recipe.addtorecipe("gas-refinery-small", {"basic-structure-components", 1})
    KaoExtended.recipe.addtorecipe("gas-refinery-small-2", {"intermediate-structure-components", 2})
    KaoExtended.recipe.addtorecipe("gas-refinery-small-3", {"intermediate-structure-components", 8})
    KaoExtended.recipe.addtorecipe("gas-refinery-small-4", {"advanced-structure-components", 2})	
	
    KaoExtended.recipe.addtorecipe("gas-refinery", {"basic-structure-components", 5})
    KaoExtended.recipe.addtorecipe("gas-refinery-2", {"intermediate-structure-components", 5})
    KaoExtended.recipe.addtorecipe("gas-refinery-3", {"intermediate-structure-components", 10})
    KaoExtended.recipe.addtorecipe("gas-refinery-4", {"advanced-structure-components", 5})
	
    KaoExtended.recipe.addtorecipe("separator", {"basic-structure-components", 1})
    KaoExtended.recipe.addtorecipe("separator-2", {"intermediate-structure-components", 2})
    KaoExtended.recipe.addtorecipe("separator-3", {"intermediate-structure-components", 8})
    KaoExtended.recipe.addtorecipe("separator-4", {"advanced-structure-components", 2})
	
    KaoExtended.recipe.addtorecipe("steam-cracker", {"basic-structure-components", 1})
    KaoExtended.recipe.addtorecipe("steam-cracker-2", {"intermediate-structure-components", 2})
    KaoExtended.recipe.addtorecipe("steam-cracker-3", {"intermediate-structure-components", 8})
    KaoExtended.recipe.addtorecipe("steam-cracker-4", {"advanced-structure-components", 2})
	
    --KaoExtended.recipe.addtorecipe("angels-storage-tank-3", {"basic-structure-components", 2})
    KaoExtended.recipe.addtorecipe("angels-storage-tank-2", {"basic-structure-components", 4})
    KaoExtended.recipe.addtorecipe("angels-storage-tank-1", {"intermediate-structure-components", 6})
	
end

local function replaceAngelMe()

    KaoExtended.recipe.addtorecipe("blast-furnace", {"basic-structure-components", 5})
    KaoExtended.recipe.addtorecipe("blast-furnace-2", {"intermediate-structure-components", 5})
    KaoExtended.recipe.addtorecipe("blast-furnace-3", {"advanced-structure-components", 5})
    KaoExtended.recipe.addtorecipe("blast-furnace-4", {"advanced-structure-components", 10})
	
    KaoExtended.recipe.addtorecipe("induction-furnace", {"basic-structure-components", 5})
    KaoExtended.recipe.addtorecipe("induction-furnace-2", {"intermediate-structure-components", 5})
    KaoExtended.recipe.addtorecipe("induction-furnace-3", {"advanced-structure-components", 5})
    KaoExtended.recipe.addtorecipe("induction-furnace-4", {"advanced-structure-components", 10})
	
    KaoExtended.recipe.addtorecipe("casting-machine", {"basic-structure-components", 5})
    KaoExtended.recipe.addtorecipe("casting-machine-2", {"intermediate-structure-components", 5})
    KaoExtended.recipe.addtorecipe("casting-machine-3", {"advanced-structure-components", 5})
    KaoExtended.recipe.addtorecipe("casting-machine-4", {"advanced-structure-components", 10})
	
    KaoExtended.recipe.addtorecipe("ore-processing-machine", {"basic-structure-components", 5})
    KaoExtended.recipe.addtorecipe("ore-processing-machine-2", {"intermediate-structure-components", 5})
    KaoExtended.recipe.addtorecipe("ore-processing-machine-3", {"advanced-structure-components", 5})
    KaoExtended.recipe.addtorecipe("ore-processing-machine-4", {"advanced-structure-components", 10})
	
    KaoExtended.recipe.addtorecipe("pellet-press", {"basic-structure-components", 5})
    KaoExtended.recipe.addtorecipe("pellet-press-2", {"intermediate-structure-components", 5})
    KaoExtended.recipe.addtorecipe("pellet-press-3", {"advanced-structure-components", 5})
end

local function replaceRobot()
  KaoExtended.recipe.addtorecipe("bob-roboport-2", {"intermediate-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-roboport-3", {"advanced-structure-components", 2})
  KaoExtended.recipe.addtorecipe("bob-roboport-4", {"anotherworld-structure-components", 1})
end

local function addtoRailloader()
  KaoExtended.recipe.addtorecipe("railloader", {"miniloader", 8})
  KaoExtended.recipe.addtorecipe("railunloader", {"miniloader", 8})
end

local function addtoPowerarmor()
  KaoExtended.recipe.addtorecipe("bob-power-armor-mk3", {"space-science-pack", 100})
  KaoExtended.recipe.addtorecipe("bob-power-armor-mk4", {"planetary-data", 1})
  KaoExtended.recipe.addtorecipe("bob-power-armor-mk5", {"station-science", 1})
end

replaceMachine()
replaceMining()
replacePower()
replaceAngelRefi()
replaceAngelPetro()
replaceAngelMe()
replaceRobot()
addtoRailloader()
addtoPowerarmor()