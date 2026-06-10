local productionCost = settings.startup["SpaceX-production"].value or 1
local classicMode = settings.startup["SpaceX-classic-mode"].value or false

data:extend({
	{
		type = "recipe",
		name = "assembly-robot",
		enabled = false,
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "construction-robot", amount = 5 * productionCost },
			{ type = "item", name = "speed-module-3", amount = math.ceil(1 * productionCost) },
			{ type = "item", name = "efficiency-module-3", amount = math.ceil(1 * productionCost) },
			{ type = "item", name = "low-density-structure", amount = 5 * productionCost },
		},
		results = {
			{ type = "item", name = "assembly-robot", amount = 1 }
		},
		main_product = "assembly-robot",
	},
	{
		type = "recipe",
		name = "drydock-assembly",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "assembly-robot", amount = 50 * productionCost },
			{ type = "item", name = "roboport", amount = 10 * productionCost },
			{ type = "item", name = "processing-unit", amount = 200 * productionCost },
			{ type = "item", name = "solar-panel", amount = 200 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "drydock-assembly", amount = 1 }
		},
		main_product = "drydock-assembly",
	},
	{
		type = "recipe",
		name = "drydock-structural",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "low-density-structure", amount = 200 * productionCost },
		},
		results = {
			{ type = "item", name = "drydock-structural", amount = 1 }
		},
		main_product = "drydock-structural",
	},
	{
		type = "recipe",
		name = "fusion-reactor",
		enabled = false,
		energy_required = 100,
		ingredients = {
			{ type = "item", name = "fission-reactor-equipment", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "fusion-reactor", amount = 1 }
		},
		main_product = "fusion-reactor",
	},
	{
		type = "recipe",
		name = "hull-component",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "low-density-structure", amount = 250 * productionCost },
			{ type = "item", name = "steel-plate", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "hull-component", amount = 1 }
		},
		main_product = "hull-component",
	},
	{
		type = "recipe",
		name = "protection-field",
		enabled = false,
		energy_required = 100,
		ingredients = {
			{ type = "item", name = "energy-shield-mk2-equipment", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "protection-field", amount = 1 }
		},
		main_product = "protection-field",
	},
	{
		type = "recipe",
		name = "space-thruster",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "speed-module-3", amount = 50 * productionCost },
			{ type = "item", name = "pipe", amount = 100 * productionCost },
			{ type = "item", name = "processing-unit", amount = 100 * productionCost },
			{ type = "item", name = "electric-engine-unit", amount = 100 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "space-thruster", amount = 1 }
		},
		main_product = "space-thruster",
	},
	{
		type = "recipe",
		name = "fuel-cell",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 100 * productionCost },
			{ type = "item", name = "processing-unit", amount = 100 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
			{ type = "item", name = "nuclear-reactor", amount = math.ceil(1 * productionCost) },
		},
		results = {
			{ type = "item", name = "fuel-cell", amount = 1 }
		},
		main_product = "fuel-cell",
	},
	{
		type = "recipe",
		name = "habitation",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 100 * productionCost },
			{ type = "item", name = "plastic-bar", amount = 500 * productionCost },
			{ type = "item", name = "processing-unit", amount = 100 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "habitation", amount = 1 }
		},
		main_product = "habitation",
	},
	{
		type = "recipe",
		name = "life-support",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "productivity-module-3", amount = 50 * productionCost },
			{ type = "item", name = "pipe", amount = 200 * productionCost },
			{ type = "item", name = "processing-unit", amount = 100 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "life-support", amount = 1 }
		},
		main_product = "life-support",
	},
	{
		type = "recipe",
		name = "command",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "speed-module-3", amount = 50 * productionCost },
			{ type = "item", name = "efficiency-module-3", amount = 50 * productionCost },
			{ type = "item", name = "productivity-module-3", amount = 50 * productionCost },
			{ type = "item", name = "plastic-bar", amount = 200 * productionCost },
			{ type = "item", name = "processing-unit", amount = 100 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "command", amount = 1 }
		},
		main_product = "command",
	},
	{
		type = "recipe",
		name = "laser-cannon",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "arithmetic-combinator", amount = 100 * productionCost },
			{ type = "item", name = "decider-combinator", amount = 100 * productionCost },
			{ type = "item", name = "laser-turret", amount = 200 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
			{ type = "item", name = "processing-unit", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "laser-cannon", amount = 1 }
		},
		main_product = "laser-cannon",
	},
	{
		type = "recipe",
		name = "astrometrics",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "speed-module-3", amount = 50 * productionCost },
			{ type = "item", name = "processing-unit", amount = 300 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
			{ type = "item", name = "lab", amount = 100 * productionCost },
		},
		results = {
			{ type = "item", name = "astrometrics", amount = 1 }
		},
		main_product = "astrometrics",
	},
	{
		type = "recipe",
		name = "ftl-drive",
		enabled = false,
		energy_required = 50,
		ingredients = {
			{ type = "item", name = "productivity-module-3", amount = 500 * productionCost },
			{ type = "item", name = "speed-module-3", amount = 500 * productionCost },
			{ type = "item", name = "efficiency-module-3", amount = 500 * productionCost },
			{ type = "item", name = "low-density-structure", amount = 100 * productionCost },
			{ type = "item", name = "processing-unit", amount = 500 * productionCost },
		},
		results = {
			{ type = "item", name = "ftl-drive", amount = 1 }
		},
		main_product = "ftl-drive",
	},
	{
		type = "recipe",
		name = "spacex-combinator",
		enabled = false,
		energy_required = 5,
		ingredients = {
			{ type = "item", name = "copper-cable", amount = 5 },
			{ type = "item", name = "electronic-circuit", amount = 5 },
			{ type = "item", name = "advanced-circuit", amount = 1 },
		},
		results = {
			{ type = "item", name = "spacex-combinator", amount = 1 }
		},
		main_product = "spacex-combinator",
	},
	{
		type = "recipe",
		name = "spacex-combinator-stage",
		enabled = false,
		energy_required = 5,
		ingredients = {
			{ type = "item", name = "copper-cable", amount = 5 },
			{ type = "item", name = "electronic-circuit", amount = 5 },
			{ type = "item", name = "advanced-circuit", amount = 1 },
		},
		results = {
			{ type = "item", name = "spacex-combinator-stage", amount = 1 }
		},
		main_product = "spacex-combinator-stage",
	},
})

if not classicMode then
	data:extend({
		{
			type = "recipe",
			name = "exploration-satellite",
			enabled = false,
			energy_required = 50,
			ingredients = {
				{ type = "item", name = "satellite", amount = 5 * productionCost },
				{ type = "item", name = "space-thruster", amount = math.ceil(1 * productionCost) },
				{ type = "item", name = "nuclear-fuel", amount = 10 * productionCost },
			},
			results = {
				{ type = "item", name = "exploration-satellite", amount = 1 }
			},
			main_product = "exploration-satellite",
		},
		{
			type = "recipe",
			name = "space-ai-robot",
			enabled = false,
			energy_required = 50,
			ingredients = {
				{ type = "item", name = "exoskeleton-equipment", amount = 75 * productionCost },
				{ type = "item", name = "belt-immunity-equipment", amount = 75 * productionCost },
				{ type = "item", name = "radar", amount = 50 * productionCost },
				{ type = "item", name = "processing-unit", amount = 100 * productionCost },
				{ type = "item", name = "productivity-module-3", amount = 100 * productionCost },
				{ type = "item", name = "battery-mk2-equipment", amount = 50 * productionCost },
				{ type = "item", name = "space-ai-robot-frame", amount = 5 * productionCost },
				{ type = "item", name = "fission-reactor-equipment", amount = 20 * productionCost },
			},
			results = {
				{ type = "item", name = "space-ai-robot", amount = 1 }
			},
			main_product = "space-ai-robot",
		},
		{
			type = "recipe",
			name = "space-ai-robot-frame",
			enabled = false,
			energy_required = 20,
			ingredients = {
				{ type = "item", name = "power-armor-mk2", amount = 1 },
				{ type = "item", name = "construction-robot", amount = 50 * productionCost },
				{ type = "item", name = "logistic-robot", amount = 50 * productionCost },
				{ type = "item", name = "personal-roboport-mk2-equipment", amount = math.ceil(1 * productionCost) },
				{ type = "item", name = "personal-laser-defense-equipment", amount = math.ceil(1 * productionCost) },
			},
			results = {
				{ type = "item", name = "space-ai-robot-frame", amount = 1 }
			},
			main_product = "space-ai-robot-frame",
		},
		{
			type = "recipe",
			name = "space-water-tank",
			enabled = false,
			energy_required = 50,
			ingredients = {
				{ type = "item", name = "water-barrel", amount = 2000 * productionCost },
				{ type = "item", name = "pump", amount = 100 * productionCost },
				{ type = "item", name = "storage-tank", amount = 100 * productionCost },
				{ type = "item", name = "pipe", amount = 500 * productionCost },
			},
			results = {
				{ type = "item", name = "space-water-tank", amount = 1 }
			},
			main_product = "space-water-tank",
		},
		{
			type = "recipe",
			name = "space-fuel-tank",
			enabled = false,
			energy_required = 50,
			ingredients = {
				{ type = "item", name = "nuclear-fuel", amount = 500 * productionCost },
				{ type = "item", name = "pump", amount = 100 * productionCost },
				{ type = "item", name = "storage-tank", amount = 100 * productionCost },
				{ type = "item", name = "pipe", amount = 500 * productionCost },
			},
			results = {
				{ type = "item", name = "space-fuel-tank", amount = 1 }
			},
			main_product = "space-fuel-tank",
		},
		{
			type = "recipe",
			name = "space-oxygen-tank",
			enabled = false,
			energy_required = 50,
			ingredients = {
				{ type = "item", name = "space-oxygen-barrel", amount = 2000 * productionCost },
				{ type = "item", name = "pump", amount = 100 * productionCost },
				{ type = "item", name = "storage-tank", amount = 100 * productionCost },
				{ type = "item", name = "pipe", amount = 500 * productionCost },
			},
			results = {
				{ type = "item", name = "space-oxygen-tank", amount = 1 }
			},
			main_product = "space-oxygen-tank",
		},
		{
			type = "recipe",
			name = "space-oxygen-barrel",
			enabled = false,
			energy_required = 0.2,
			ingredients = {
				{ type = "item", name = "barrel", amount = 1 },
			},
			results = {
				{ type = "item", name = "space-oxygen-barrel", amount = 1 }
			},
			main_product = "space-oxygen-barrel",
		},
		{
			type = "recipe",
			name = "space-map",
			enabled = false,
			energy_required = 50,
			ingredients = {
				{ type = "item", name = "exploration-data-disk", amount = 25 * productionCost },
			},
			results = {
				{ type = "item", name = "space-map", amount = 1 }
			},
			main_product = "space-map",
		},
	})
end

local cheapFusion = settings.startup["SpaceX-cheaper-fusion-reactor"].value
if cheapFusion then
	local fix = data.raw.recipe["fusion-reactor"]
	fix.ingredients = {
		{ type = "item", name = "fission-reactor-equipment", amount = 40 * productionCost },
	}
end

local replaceNuclear = settings.startup["SpaceX-no-nuclear"].value
if replaceNuclear or classicMode then
	for _, ingridient in pairs(data.raw["recipe"]["fuel-cell"].ingredients) do
		if ingridient[1] == "nuclear-reactor" then
			ingridient[1] = "rocket-fuel"
			ingridient[2] = 500 * productionCost
		end
	end
	for _, tech in pairs({ "exploration-satellite", "space-fuel-tank" }) do
		local rootTech = data.raw["recipe"][tech]
		if rootTech ~= nil then
			for _, ingridient in pairs(rootTech.ingredients) do
				if ingridient[1] == "nuclear-fuel" then
					ingridient[1] = "rocket-fuel"
				end
			end
		end
	end
end
