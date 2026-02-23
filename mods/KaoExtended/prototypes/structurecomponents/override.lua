local function replaceMachine()
	KaoExtended.recipe.add_to_recipe("warehouse-basic", { type = "item", name = "basic-structure-components", amount = 5})

	KaoExtended.recipe.add_to_recipe("factory-2", { type = "item", name = "basic-structure-components", amount = 50})
	KaoExtended.recipe.add_to_recipe("factory-2", { type = "item", name = "factory-1", amount = 2})
	KaoExtended.recipe.add_to_recipe("factory-3", { type = "item", name = "intermediate-structure-components", amount = 50})
	KaoExtended.recipe.add_to_recipe("factory-3", { type = "item", name = "factory-2", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-salination-plant", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-salination-plant-2", { type = "item", name = "advanced-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-salination-plant-2", { type = "item", name = "angels-salination-plant", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-washing-plant-2", { type = "item", name = "intermediate-structure-components", amount = 3})

	KaoExtended.recipe.add_to_recipe("centrifuge", { type = "item", name = "intermediate-structure-components", amount = 3})
	KaoExtended.recipe.add_to_recipe("bob-centrifuge-2", { type = "item", name = "advanced-structure-components", amount = 3})
	KaoExtended.recipe.add_to_recipe("bob-centrifuge-3", { type = "item", name = "advanced-structure-components", amount = 10})

	KaoExtended.recipe.add_to_recipe("assembling-machine-2", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("assembling-machine-3", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-assembling-machine-4", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("bob-assembling-machine-5", { type = "item", name = "advanced-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-assembling-machine-6", { type = "item", name = "advanced-structure-components", amount = 10})

	KaoExtended.recipe.add_to_recipe("rocket-silo", { type = "item", name = "bob-assembling-machine-6", amount = 100})

	KaoExtended.recipe.add_to_recipe("bob-electronics-machine-1", { type = "item", name = "basic-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-electronics-machine-2", { type = "item", name = "intermediate-structure-components", amount = 3})
	KaoExtended.recipe.add_to_recipe("bob-electronics-machine-3", { type = "item", name = "advanced-structure-components", amount = 3})

	KaoExtended.recipe.add_to_recipe("bob-electronics-machine-1", { type = "item", name = "inserter", amount = 4})
	KaoExtended.recipe.add_to_recipe("bob-electronics-machine-2", { type = "item", name = "long-handed-inserter", amount = 4})
	KaoExtended.recipe.add_to_recipe("bob-electronics-machine-3", { type = "item", name = "bob-turbo-inserter", amount = 4})

	KaoExtended.recipe.add_to_recipe("oil-refinery", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-oil-refinery-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-oil-refinery-3", { type = "item", name = "intermediate-structure-components", amount = 8})
	KaoExtended.recipe.add_to_recipe("angels-oil-refinery-4", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("chemical-plant", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-chemical-plant-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-chemical-plant-3", { type = "item", name = "intermediate-structure-components", amount = 8})
	KaoExtended.recipe.add_to_recipe("angels-chemical-plant-4", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("steel-furnace", { type = "item", name = "stone-furnace", amount = 2})
	KaoExtended.recipe.add_to_recipe("electric-furnace", { type = "item", name = "steel-furnace", amount = 2})

	KaoExtended.recipe.add_to_recipe("electric-furnace", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-electric-furnace-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-electric-furnace-3", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-electrolyser", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-electrolyser-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-electrolyser-3", { type = "item", name = "intermediate-structure-components", amount = 8})
	KaoExtended.recipe.add_to_recipe("angels-electrolyser-4", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("bob-electric-chemical-mixing-furnace", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-electric-chemical-mixing-furnace-2", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("bob-electric-mixing-furnace", { type = "item", name = "bob-electric-chemical-furnace", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-electric-mixing-furnace", { type = "item", name = "basic-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("bob-electric-chemical-furnace", { type = "item", name = "bob-stone-chemical-furnace", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-electric-chemical-furnace", { type = "item", name = "basic-structure-components", amount = 2})
end
local function replaceMining()
	KaoExtended.recipe.add_to_recipe("bob-mining-drill-1", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-mining-drill-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-mining-drill-3", { type = "item", name = "advanced-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-mining-drill-4", { type = "item", name = "anotherworld-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-1", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-3", { type = "item", name = "advanced-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-area-mining-drill-4", { type = "item", name = "anotherworld-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("bob-pumpjack-1", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-pumpjack-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-pumpjack-3", { type = "item", name = "advanced-structure-components", amount = 2})
end
local function replacePower()
	KaoExtended.recipe.add_to_recipe("bob-steam-engine-2", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-steam-engine-3", { type = "item", name = "intermediate-structure-components", amount = 1})

	if data.raw["item"]["petroleum-generator"] then
		KaoExtended.recipe.add_to_recipe("petroleum-generator", { type = "item", name = "bob-steam-engine-3", amount = 1})
		KaoExtended.recipe.add_to_recipe("petroleum-generator", { type = "item", name = "advanced-structure-components", amount = 1})
	end
	if data.raw["item"]["steam-turbine"] then
		KaoExtended.recipe.add_to_recipe("steam-turbine", { type = "item", name = "advanced-structure-components", amount = 3})
		KaoExtended.recipe.add_to_recipe("bob-steam-turbine-2", { type = "item", name = "advanced-structure-components", amount = 5})
		KaoExtended.recipe.add_to_recipe("bob-steam-turbine-3", { type = "item", name = "anotherworld-structure-components", amount = 1})
		KaoExtended.recipe.add_to_recipe("nuclear-reactor", { type = "item", name = "bob-boiler-4", amount = 1})
		KaoExtended.recipe.add_to_recipe("nuclear-reactor", { type = "item", name = "advanced-structure-components", amount = 10})
	end

	KaoExtended.recipe.add_to_recipe("bob-solar-panel-small", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("solar-panel", { type = "item", name = "basic-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-solar-panel-large", { type = "item", name = "basic-structure-components", amount = 3})

	KaoExtended.recipe.add_to_recipe("bob-solar-panel-small-2", { type = "item", name = "intermediate-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-solar-panel-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-solar-panel-large-2", { type = "item", name = "intermediate-structure-components", amount = 3})

	KaoExtended.recipe.add_to_recipe("bob-solar-panel-small-3", { type = "item", name = "advanced-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-solar-panel-3", { type = "item", name = "advanced-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-solar-panel-large-3", { type = "item", name = "advanced-structure-components", amount = 3})
end

local function replaceAngelRefi()
	KaoExtended.recipe.add_to_recipe("angels-thermal-extractor", { type = "item", name = "basic-structure-components", amount = 1})

	KaoExtended.recipe.add_to_recipe("angels-ore-crusher-2", { type = "item", name = "intermediate-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-ore-crusher-2", { type = "item", name = "engine-unit", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-ore-crusher-3", { type = "item", name = "advanced-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-ore-crusher-3", { type = "item", name = "electric-engine-unit", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-ore-sorting-facility-2", { type = "item", name = "basic-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-ore-sorting-facility-3", { type = "item", name = "intermediate-structure-components", amount = 3})
	KaoExtended.recipe.add_to_recipe("angels-ore-sorting-facility-4", { type = "item", name = "advanced-structure-components", amount = 4})

	KaoExtended.recipe.add_to_recipe("angels-ore-floatation-cell", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-ore-floatation-cell-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-ore-floatation-cell-3", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-ore-leaching-plant", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-ore-leaching-plant-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-ore-leaching-plant-3", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-ore-refinery", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-ore-refinery-2", { type = "item", name = "advanced-structure-components", amount = 4})

	KaoExtended.recipe.add_to_recipe("angels-filtration-unit", { type = "item", name = "basic-structure-components", amount = 4})
	KaoExtended.recipe.add_to_recipe("angels-filtration-unit-2", { type = "item", name = "intermediate-structure-components", amount = 4})

	KaoExtended.recipe.add_to_recipe("angels-crystallizer", { type = "item", name = "basic-structure-components", amount = 4})
	KaoExtended.recipe.add_to_recipe("angels-crystallizer-2", { type = "item", name = "intermediate-structure-components", amount = 4})

	KaoExtended.recipe.add_to_recipe("angels-hydro-plant", { type = "item", name = "basic-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-hydro-plant-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-hydro-plant-3", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-algae-farm-2", { type = "item", name = "basic-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-algae-farm-3", { type = "item", name = "intermediate-structure-components", amount = 5})
end

local function replaceAngelPetro()
	KaoExtended.recipe.add_to_recipe("angels-electrolyser", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-electrolyser-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-electrolyser-3", { type = "item", name = "intermediate-structure-components", amount = 8})
	KaoExtended.recipe.add_to_recipe("angels-electrolyser-4", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-advanced-chemical-plant", { type = "item", name = "intermediate-structure-components", amount = 3})
	KaoExtended.recipe.add_to_recipe("angels-advanced-chemical-plant-2", { type = "item", name = "advanced-structure-components", amount = 3})

	KaoExtended.recipe.add_to_recipe("angels-gas-refinery-small", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-gas-refinery-small-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-gas-refinery-small-3", { type = "item", name = "intermediate-structure-components", amount = 8})
	KaoExtended.recipe.add_to_recipe("angels-gas-refinery-small-4", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-gas-refinery", { type = "item", name = "basic-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-gas-refinery-2", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-gas-refinery-3", { type = "item", name = "intermediate-structure-components", amount = 10})
	KaoExtended.recipe.add_to_recipe("angels-gas-refinery-4", { type = "item", name = "advanced-structure-components", amount = 5})

	KaoExtended.recipe.add_to_recipe("angels-separator", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-separator-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-separator-3", { type = "item", name = "intermediate-structure-components", amount = 8})
	KaoExtended.recipe.add_to_recipe("angels-separator-4", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-steam-cracker", { type = "item", name = "basic-structure-components", amount = 1})
	KaoExtended.recipe.add_to_recipe("angels-steam-cracker-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("angels-steam-cracker-3", { type = "item", name = "intermediate-structure-components", amount = 8})
	KaoExtended.recipe.add_to_recipe("angels-steam-cracker-4", { type = "item", name = "advanced-structure-components", amount = 2})

	KaoExtended.recipe.add_to_recipe("angels-storage-tank-2", { type = "item", name = "basic-structure-components", amount = 4})
	KaoExtended.recipe.add_to_recipe("angels-storage-tank-1", { type = "item", name = "intermediate-structure-components", amount = 6})
end

local function replaceAngelMe()
	KaoExtended.recipe.add_to_recipe("angels-blast-furnace", { type = "item", name = "basic-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-blast-furnace-2", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-blast-furnace-3", { type = "item", name = "advanced-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-blast-furnace-4", { type = "item", name = "advanced-structure-components", amount = 10})

	KaoExtended.recipe.add_to_recipe("angels-induction-furnace", { type = "item", name = "basic-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-induction-furnace-2", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-induction-furnace-3", { type = "item", name = "advanced-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-induction-furnace-4", { type = "item", name = "advanced-structure-components", amount = 10})

	KaoExtended.recipe.add_to_recipe("angels-casting-machine", { type = "item", name = "basic-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-casting-machine-2", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-casting-machine-3", { type = "item", name = "advanced-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-casting-machine-4", { type = "item", name = "advanced-structure-components", amount = 10})

	KaoExtended.recipe.add_to_recipe("angels-ore-processing-machine", { type = "item", name = "basic-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-ore-processing-machine-2", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-ore-processing-machine-3", { type = "item", name = "advanced-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-ore-processing-machine-4", { type = "item", name = "advanced-structure-components", amount = 10})

	KaoExtended.recipe.add_to_recipe("angels-pellet-press", { type = "item", name = "basic-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-pellet-press-2", { type = "item", name = "intermediate-structure-components", amount = 5})
	KaoExtended.recipe.add_to_recipe("angels-pellet-press-3", { type = "item", name = "advanced-structure-components", amount = 5})
end

local function replaceRobot()
	KaoExtended.recipe.add_to_recipe("bob-roboport-2", { type = "item", name = "intermediate-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-roboport-3", { type = "item", name = "advanced-structure-components", amount = 2})
	KaoExtended.recipe.add_to_recipe("bob-roboport-4", { type = "item", name = "anotherworld-structure-components", amount = 1})
end

local function addtoPowerarmor()
	KaoExtended.recipe.add_to_recipe("bob-power-armor-mk3", { type = "item", name = "space-science-pack", amount = 100})
	KaoExtended.recipe.add_to_recipe("bob-power-armor-mk4", { type = "item", name = "planetary-data", amount = 1})
	KaoExtended.recipe.add_to_recipe("bob-power-armor-mk5", { type = "item", name = "station-science", amount = 1})
end

replaceMachine()
replaceMining()
replacePower()
replaceAngelRefi()
replaceAngelPetro()
replaceAngelMe()
replaceRobot()
addtoPowerarmor()
