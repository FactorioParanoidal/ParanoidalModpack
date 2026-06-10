if not bobmods.modules then
	bobmods.modules = {}
end

local productionCost = settings.startup["SpaceX-production"].value or 1
local classicMode = settings.startup["SpaceX-classic-mode"].value or false

data:extend({
	{
		type = "recipe",
		name = "protection-field-goopless",
		enabled = false,
		energy_required = 100,
		ingredients = {
			{ type = "item", name = "bob-energy-shield-mk3-equipment", amount = 1000 * productionCost },
			{ type = "item", name = "bob-advanced-processing-unit", amount = 3500 * productionCost },
			{ type = "item", name = "efficiency-module-3", amount = 400 * productionCost },
			{ type = "item", name = "productivity-module-3", amount = 400 * productionCost },
			{ type = "item", name = "bob-efficiency-module-4", amount = 200 * productionCost },
			{ type = "item", name = "bob-productivity-module-4", amount = 200 * productionCost },
			{ type = "item", name = "bob-efficiency-module-5", amount = 100 * productionCost },
			{ type = "item", name = "bob-productivity-module-5", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "protection-field", amount = 1 }
		},
		main_product = "protection-field",
	},
})

if bobmods.modules.EnableGodModules == true then
	-- assembly-robot
	bobmods.lib.recipe.replace_ingredient("assembly-robot", "speed-module-3", "bob-god-module")
	bobmods.lib.recipe.replace_ingredient("assembly-robot", "efficiency-module-3", "bob-god-module")
	-- space-thruster
	bobmods.lib.recipe.replace_ingredient("space-thruster", "speed-module-3", "bob-god-module")

	-- life-support
	bobmods.lib.recipe.replace_ingredient("life-support", "productivity-module-3", "bob-god-module")
	-- command
	bobmods.lib.recipe.replace_ingredient("command", "speed-module-3", "bob-god-module")
	bobmods.lib.recipe.replace_ingredient("command", "efficiency-module-3", "bob-god-module")
	bobmods.lib.recipe.replace_ingredient("command", "productivity-module-3", "bob-god-module")
	-- astrometrics
	bobmods.lib.recipe.replace_ingredient("astrometrics", "speed-module-3", "bob-god-module")
	-- ftl-drive
	bobmods.lib.recipe.replace_ingredient("ftl-drive", "speed-module-3", "bob-god-module")
	bobmods.lib.recipe.replace_ingredient("ftl-drive", "efficiency-module-3", "bob-god-module")
	bobmods.lib.recipe.replace_ingredient("ftl-drive", "productivity-module-3", "bob-god-module")
else
	-- assembly-robot
	bobmods.lib.recipe.replace_ingredient("assembly-robot", "speed-module-3", "bob-speed-module-5")
	bobmods.lib.recipe.replace_ingredient("assembly-robot", "efficiency-module-3", "bob-efficiency-module-5")
	-- space-thruster
	bobmods.lib.recipe.replace_ingredient("space-thruster", "speed-module-3", "bob-speed-module-5")
	-- life-support
	bobmods.lib.recipe.replace_ingredient("life-support", "productivity-module-3", "bob-productivity-module-5")
	-- command
	bobmods.lib.recipe.replace_ingredient("command", "speed-module-3", "bob-speed-module-5")
	bobmods.lib.recipe.replace_ingredient("command", "efficiency-module-3", "bob-efficiency-module-5")
	bobmods.lib.recipe.replace_ingredient("command", "productivity-module-3", "bob-productivity-module-5")
	-- astrometrics
	bobmods.lib.recipe.replace_ingredient("astrometrics", "speed-module-3", "bob-speed-module-5")
	-- ftl-drive
	bobmods.lib.recipe.replace_ingredient("ftl-drive", "speed-module-3", "bob-speed-module-5")
	bobmods.lib.recipe.replace_ingredient("ftl-drive", "efficiency-module-3", "bob-efficiency-module-5")
	bobmods.lib.recipe.replace_ingredient("ftl-drive", "productivity-module-3", "bob-productivity-module-5")
end
-- assembly-robot
bobmods.lib.recipe.replace_ingredient("assembly-robot", "construction-robot", "bob-construction-robot-4")
-- space-thruster
bobmods.lib.recipe.replace_ingredient("space-thruster", "pipe", "bob-titanium-pipe")
bobmods.lib.recipe.replace_ingredient("space-thruster", "processing-unit", "bob-advanced-processing-unit")
-- life-support
bobmods.lib.recipe.replace_ingredient("life-support", "pipe", "bob-titanium-pipe")
bobmods.lib.recipe.replace_ingredient("life-support", "processing-unit", "bob-advanced-processing-unit")
-- command
bobmods.lib.recipe.replace_ingredient("command", "processing-unit", "bob-advanced-processing-unit")
-- astrometrics
bobmods.lib.recipe.replace_ingredient("astrometrics", "processing-unit", "bob-advanced-processing-unit")
bobmods.lib.recipe.replace_ingredient("astrometrics", "lab", "bob-lab-2")
-- ftl-drive
bobmods.lib.recipe.replace_ingredient("ftl-drive", "processing-unit", "bob-advanced-processing-unit")
-- drydock-assembly
bobmods.lib.recipe.replace_ingredient("drydock-assembly", "solar-panel", "bob-solar-panel-large-3")
bobmods.lib.recipe.replace_ingredient("drydock-assembly", "processing-unit", "bob-advanced-processing-unit")
if settings.startup["bobmods-logistics-disableroboports"].value then
	bobmods.lib.recipe.replace_ingredient("drydock-assembly", "roboport", "bob-personal-roboport-mk4-equipment")
else
	bobmods.lib.recipe.replace_ingredient("drydock-assembly", "roboport", "bob-roboport-4")
end
-- fusion-reactor
bobmods.lib.recipe.replace_ingredient("fusion-reactor", "fission-reactor-equipment", "bob-fission-reactor-equipment-4")
-- hull-component
bobmods.lib.recipe.replace_ingredient("hull-component", "steel-plate", "bob-titanium-plate")
-- protection-field
bobmods.lib.recipe.replace_ingredient("protection-field", "energy-shield-mk2-equipment", "bob-energy-shield-mk6-equipment")
-- fuel-cell
bobmods.lib.recipe.replace_ingredient("fuel-cell", "steel-plate", "bob-titanium-plate")
bobmods.lib.recipe.replace_ingredient("fuel-cell", "processing-unit", "bob-advanced-processing-unit")
-- habitation
bobmods.lib.recipe.replace_ingredient("habitation", "steel-plate", "bob-titanium-plate")
bobmods.lib.recipe.replace_ingredient("habitation", "processing-unit", "bob-advanced-processing-unit")
-- laser-cannon
data.raw.recipe["laser-cannon"].ingredients = {
	{ type = "item", name = "arithmetic-combinator", amount = 50 * productionCost },
	{ type = "item", name = "decider-combinator", amount = 50 * productionCost },
	{ type = "item", name = "bob-personal-laser-defense-equipment-6", amount = 100 * productionCost },
}

if not classicMode then
	-- space tanks
	for _, tech in pairs({ "space-fuel-tank", "space-water-tank", "space-oxygen-tank" }) do
		bobmods.lib.recipe.replace_ingredient(tech, "storage-tank", "bob-storage-tank-4")
		bobmods.lib.recipe.replace_ingredient(tech, "pump", "bob-pump-4")
		bobmods.lib.recipe.replace_ingredient(tech, "pipe", "bob-titanium-pipe")
	end
	-- space ai robot
	bobmods.lib.recipe.replace_ingredient("space-ai-robot", "fission-reactor-equipment", "bob-fission-reactor-equipment-4")
	bobmods.lib.recipe.replace_ingredient("space-ai-robot", "exoskeleton-equipment", "bob-exoskeleton-equipment-3")
	bobmods.lib.recipe.replace_ingredient("space-ai-robot", "battery-mk2-equipment", "bob-battery-mk6-equipment")
	-- space ai robot frame
	bobmods.lib.recipe.replace_ingredient(
		"space-ai-robot-frame",
		"personal-roboport-mk2-equipment",
		"bob-personal-roboport-mk4-equipment"
	)
	bobmods.lib.recipe.replace_ingredient(
		"space-ai-robot-frame",
		"personal-laser-defense-equipment",
		"bob-personal-laser-defense-equipment-6"
	)
	bobmods.lib.recipe.replace_ingredient("space-ai-robot-frame", "construction-robot", "bob-construction-robot-4")
	bobmods.lib.recipe.replace_ingredient("space-ai-robot-frame", "logistic-robot", "bob-logistic-robot-4")
end
