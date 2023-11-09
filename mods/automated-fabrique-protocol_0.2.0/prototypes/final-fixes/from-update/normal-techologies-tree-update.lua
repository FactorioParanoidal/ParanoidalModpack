local function technologyNotFound()
	error('technology is null!!')
end
local function removeSciencePackFrom(technology, science_pack_name)
	technology.unit.ingredients = _table.filter(technology.unit.ingredients,
		function(v)
			return v[1] ~= science_pack_name
		end)
end

local function addPrerequisitesToTechnology(technology, prerequisites)
	if not technology then technologyNotFound() end
	if technology.prerequisites then
		_table.insert_all_if_not_exists(technology.prerequisites, prerequisites)
	else
		technology.prerequisites = prerequisites
	end
	if technology.normal then
		if technology.normal.prerequisites then
			_table.insert_all_if_not_exists(
				technology.normal.prerequisites, prerequisites)
		end
	end
	if technology.expensive then
		if technology.expensive.prerequisites then
			_table.insert_all_if_not_exists(
				technology.expensive.prerequisites, prerequisites)
		end
	end
end

local function resetTechnologyPrerequisites(technology, prerequisites)
	if not technology then technologyNotFound() end
	if technology.prerequisites then technology.prerequisites = nil end
	if technology.normal and technology.normal.prerequisites then technology.prerequisites = nil end
	if technology.expensive and technology.expensive.prerequisites then technology.prerequisites = nil end
	addPrerequisitesToTechnology(technology, prerequisites)
end
local function addRecipeEffectToTechnologyEffects(technology, recipe_name)
	if not technology then technologyNotFound() end
	if not technology.effects then technology.effects = {} end
	table.insert(technology.effects, { type = 'unlock-recipe', recipe = recipe_name })
	if data.raw.recipe[recipe_name] then
		local recipe = data.raw.recipe[recipe_name]
		recipe.enabled = false
		if recipe.normal then recipe.normal.enabled = false end
		if recipe.expensive then recipe.expensive.enabled = false end
		return
	end
end

local function addSciencePackToTechnologyUnit(technology, ingredient_value)
	local ingredient = {
		type = "item",
		name = ingredient_value[1],
		amount = ingredient_value[2]
	}
	if not technology then technologyNotFound() end
	if technology.unit and technology.unit.ingredients then
		_table.insert_all_if_not_exists(technology.unit.ingredients, { ingredient })
	end
	if technology.normal and technology.normal.unit and technology.normal.unit.ingredients then
		_table.insert_all_if_not_exists(
			technology.normal.unit.ingredients, { ingredient })
	end
	if technology.expensive and technology.expensive.unit and technology.expensive.unit.ingredients then
		_table.insert_all_if_not_exists(
			technology.expensive.unit.ingredients, { ingredient })
	end
end
local function addSciencePackToTechnologyUnits(technology, ingredients)
	if not technology then technologyNotFound() end
	if not ingredients then return end
	_table.each(ingredients,
		function(ingredient)
			addSciencePackToTechnologyUnit(technology, ingredient)
		end)
end
local function removeRecipeEffectFromTechnologyEffects(technology, recipe_name)
	if not technology then technologyNotFound() end
	if technology.effects then
		_table.remove_item(technology.effects, { type = 'unlock-recipe', recipe = recipe_name })
	end
	if technology.normal and technology.normal.effects then
		_table.remove_item(technology.normal.effects, { type = 'unlock-recipe', recipe = recipe_name })
	end
	if technology.expensive and technology.expensive.effects then
		_table.remove_item(technology.expensive.effects, { type = 'unlock-recipe', recipe = recipe_name })
	end
end
local function hideTechnology(technology)
	if not technology then technologyNotFound() end
	technology.hidden = true
	if technology.normal then technology.normal.hidden = true end
	if technology.expensive then technology.expensive.hidden = true end
end
function updateTechnologyNormalTree()
	local technologies = data.raw["technology"]
	-- железнодорожные сигналы теперь зависят от простейшей автоматики, так же, как и железные дороги.
	if mods["JunkTrain3"] then
		resetTechnologyPrerequisites(technologies["fluid-wagon"], { "JunkTrain_tech", "fluid-handling" })
		addPrerequisitesToTechnology(technologies["rail-signals"], { "automated-scrap-rail-transportation" })
		addPrerequisitesToTechnology(technologies["railway"], { "automated-scrap-rail-transportation" })
	end

	if mods["factorissimo-2-notnotmelon"] then
		local connection_chest_tech = technologies["factory-connection-type-chest"]
		resetTechnologyPrerequisites(connection_chest_tech, { "factory-architecture-t1", "basic-logistics" })
		local connection_fluid_tech = technologies["factory-connection-type-fluid"]
		resetTechnologyPrerequisites(connection_fluid_tech, { "factory-architecture-t1", "basic-fluid-handling" })
		local connection_circuit_tech = technologies["factory-connection-type-circuit"]
		resetTechnologyPrerequisites(connection_circuit_tech,
			{ "factory-architecture-t1", "circuit-network" })
		local connection_lights_tech = technologies["factory-interior-upgrade-lights"]
		resetTechnologyPrerequisites(connection_lights_tech, { "factory-architecture-t1", "optics" })
		local connection_display_tech = technologies["factory-interior-upgrade-display"]
		resetTechnologyPrerequisites({ "factory-architecture-t1", "factory-connection-type-circuit" })
		removeSciencePackFrom(connection_chest_tech, "logistic-science-pack")
		removeSciencePackFrom(connection_fluid_tech, "logistic-science-pack")
		removeSciencePackFrom(connection_circuit_tech, "logistic-science-pack")
		removeSciencePackFrom(connection_lights_tech, "logistic-science-pack")
		removeSciencePackFrom(connection_display_tech, "logistic-science-pack")
		local archtecture_t2_tech = technologies["factory-architecture-t2"]
		archtecture_t2_tech.unit = {
			ingredients = {
				{ "automation-science-pack", 2 },
				{ "logistic-science-pack",   3 }
			},
			count = 500,
			time = 60
		}
		addPrerequisitesToTechnology(technologies["military-science-pack"], { "factory-architecture-t2" })
		addPrerequisitesToTechnology(technologies["chemical-science-pack"], { "factory-architecture-t2" })
		addPrerequisitesToTechnology(technologies["production-science-pack"], { "factory-recursion-t1" })
		if mods["bobpower"] then
			addPrerequisitesToTechnology(technologies["factory-connection-type-heat"], { "bob-heat-pipe-1" })
		end
		--
		local architecture_t3_tech = technologies["factory-architecture-t3"]
		addPrerequisitesToTechnology(architecture_t3_tech, { "utility-science-pack" })
		removeSciencePackFrom(architecture_t3_tech, "production-science-pack")
		addSciencePackToTechnologyUnit(architecture_t3_tech, { "utility-science-pack", 1 })
		addPrerequisitesToTechnology(technologies["space-science-pack"], { "factory-recursion-t2" })

		--attp technologies
		addPrerequisitesToTechnology(technologies[ATTP_1_TECHNOLOGY_NAME],
			{ "factory-architecture-t1", "factory-connection-type-chest", "factory-connection-type-fluid",
				"factory-connection-type-circuit", "factory-interior-upgrade-lights", "factory-interior-upgrade-display" })
		addPrerequisitesToTechnology(technologies[ATTP_2_TECHNOLOGY_NAME],
			{ "factory-architecture-t2" })
		addPrerequisitesToTechnology(technologies[ATTP_3_TECHNOLOGY_NAME], { "factory-recursion-t1" })
		addPrerequisitesToTechnology(technologies[ATTP_4_TECHNOLOGY_NAME], { "factory-recursion-t2" })
	end
end

function linkBasicTechnologiesToNormalTree()
	local technologies = data.raw["technology"]
	resetTechnologyPrerequisites(technologies["factory-architecture-t1"], { 'basic-researching' })
	resetTechnologyPrerequisites(technologies['basic-automation'], { "factory-architecture-t1", 'basic-researching' })
	resetTechnologyPrerequisites(technologies['stone-wall'], { 'military-0', 'basic-automation' })
	resetTechnologyPrerequisites(technologies['water-pumpjack-1'], { 'basic-automation', 'basic-metal-processing',
		'angels-copper-smelting-1', 'electricity', 'coal-ore-smelting' })
	resetTechnologyPrerequisites(technologies['basic-logistics'], { 'logistics-0', 'basic-automation', 'iron-storage' })
	resetTechnologyPrerequisites(technologies['logistics-0'],
		{ 'basic-automation', 'coal-ore-smelting', 'basic-wood-production',
			'basic-metal-processing', 'basic-researching' })
	resetTechnologyPrerequisites(technologies['armor-absorb-1'], { 'basic-automation' })
	resetTechnologyPrerequisites(technologies['bi-dart-turret'], { 'basic-automation', 'basic-metal-processing',
		'basic-wood-production' })
	resetTechnologyPrerequisites(technologies['military'], { 'basic-automation', 'military-0' })
	resetTechnologyPrerequisites(technologies['electricity'], { 'basic-automation', 'electricity-0' })
	_table.each(technologies,
		function(technology)
			if string.find(technology.name, 'qol-', 1, true) then
				hideTechnology(technology)
			end
		end)
end

local function updateBasicEffects()
	local technologies = data.raw["technology"]
	addRecipeEffectToTechnologyEffects(technologies['logistics-0'], 'basic-transport-belt')
	addRecipeEffectToTechnologyEffects(technologies['military-2'], 'copper-nickel-firearm-magazine')
	addRecipeEffectToTechnologyEffects(technologies['basic-fluid-handling'], 'offshore-pump-0')
	local ore_crushing_technology = technologies['ore-crushing']
	addPrerequisitesToTechnology(ore_crushing_technology, { 'burner-ore-crushing' })
	addPrerequisitesToTechnology(technologies['electric-mining'], { 'burner-ore-mining' })
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore5-crushed')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore6-crushed')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'iron-plate')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'copper-plate')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'lead-plate')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'tin-plate')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'glass-from-ore4')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore5-crushed-smelting')
	addRecipeEffectToTechnologyEffects(ore_crushing_technology, 'angelsore6-crushed-smelting')
	removeRecipeEffectFromTechnologyEffects(technologies['basic-automation'], 'steam-inserter')
	addRecipeEffectToTechnologyEffects(technologies['steam-power'], 'steam-inserter')
	addRecipeEffectToTechnologyEffects(technologies['steam-power'], createSteamRecipe())
end
local function updateNotFoundEffectesAndSciencePacks()
	local technologies = data.raw["technology"]
	removeRecipeEffectFromTechnologyEffects(technologies['water-treatment'], 'bi-mineralized-sulfuric-waste')
	removeRecipeEffectFromTechnologyEffects(technologies['alloy-processing'], 'nickel-piercing-rounds-magazine')
	removeRecipeEffectFromTechnologyEffects(technologies['chlorine-processing-2'], 'vinyl-chloride-synthesis')
	removeRecipeEffectFromTechnologyEffects(technologies['nuclear-power'], 'RITEG-1')
	removeRecipeEffectFromTechnologyEffects(technologies['nuclear-power'], 'RITEG-1-from-used-up-RITEG-1')
	--
	addRecipeEffectToTechnologyEffects(technologies['water-treatment-2'], 'bi-mineralized-sulfuric-waste')
	addRecipeEffectToTechnologyEffects(technologies['military-2'], 'nickel-piercing-rounds-magazine')
	addSciencePackToTechnologyUnit(technologies['uranium-ammo'], { "utility-science-pack", 1 })
	addRecipeEffectToTechnologyEffects(technologies['chlorine-processing-3'], 'vinyl-chloride-synthesis')
	addRecipeEffectToTechnologyEffects(technologies['angels-manganese-smelting-2'], 'angels-plate-manganese')
	--
	addSciencePackToTechnologyUnits(technologies['modules'], { { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-ironworks-2'], { { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['w93-modular-turrets-lcannon'], { { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['w93-modular-turrets'], { { "chemical-science-pack", 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['bio-nutrient-paste'],
		{ { "token-bio", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnit(technologies['phosphorus-processing-1'], { "logistic-science-pack", 1 })
	addSciencePackToTechnologyUnits(technologies['bio-farm-1'],
		{ { "logistic-science-pack", 1 }, { "token-bio", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['gardens'], { { "logistic-science-pack", 1 }, { "token-bio", 1 } })
	addSciencePackToTechnologyUnits(technologies['bio-processing-paste'],
		{ { "chemical-science-pack", 1 }, { "production-science-pack", 1 }, { "productivity-processor", 1 },
			{ 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['bio-desert-farming-1'], { { "logistic-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['bio-swamp-farming-1'], { { "logistic-science-pack", 1 } })
	addPrerequisitesToTechnology(technologies['bio-nutrient-paste'],
		{ 'bio-temperate-farming-2', 'bio-desert-farming-2', 'bio-swamp-farming-2' })
	addSciencePackToTechnologyUnits(technologies['bio-temperate-farming-1'],
		{ { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['bio-farm-2'], { { "token-bio", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['bio-fermentation'], { { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['gardens-2'], { { "token-bio", 1 } })
	addSciencePackToTechnologyUnits(technologies['bio-farm-alien'], { { "token-bio", 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['productivity-module'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['effectivity-module'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['speed-module'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['speed-module-2'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['speed-module-3'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['speed-module-4'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['speed-module-5'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['effectivity-module-2'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['effectivity-module-3'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['effectivity-module-4'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['raw-speed-module-1'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['raw-speed-module-3'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['raw-speed-module-5'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['raw-speed-module-7'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['module-merging'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { "production-science-pack", 1 },
			{ 'science-pack-gold',       1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['raw-speed-module-2'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { "production-science-pack", 1 },
			{ 'science-pack-gold',       1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 },
			{ 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['raw-speed-module-4'],
		{ { "automation-science-pack", 1 }, { "logistic-science-pack", 1 }, { "chemical-science-pack", 1 }, { "production-science-pack", 1 },
			{ 'science-pack-gold',       1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 },
			{ 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['production-science-pack'],
		{ { 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['utility-science-pack'],
		{ { 'productivity-processor', 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-tungsten-smelting-1'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['ore-refining'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-gold-smelting-2'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-metallurgy-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['ore-processing-3'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-titanium-smelting-2'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['powder-metallurgy-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['military-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['advanced-depleted-uranium-smelting-1'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['uranium-ammo'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['nuclear-power'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['bob-boiler-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['tungsten-processing'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-tungsten-carbide-smelting-1'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-ironworks-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-nitinol-smelting-1'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-ironworks-3'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 } })
	addSciencePackToTechnologyUnits(technologies['utility-science-pack'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-zinc-smelting-3'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['w93-modular-turrets-hcannon'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['bet-fuel-3'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['battery-3'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['nitinol-processing'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['tungsten-alloy-processing'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-copper-tungsten-smelting-1'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['advanced-electronics-3'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['advanced-probe'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['space-science-pack'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['rocket-fuel'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-advanced-chemistry-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-advanced-chemistry-5'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-stone-smelting-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['angels-nitrogen-processing-4'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	addSciencePackToTechnologyUnits(technologies['rocket-control-unit'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })

	--
	addSciencePackToTechnologyUnits(technologies['logistics-4'],
		{ { 'utility-science-pack', 1 },
			{ "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['w93-modular-turrets-dcannon'],
		{ { 'speed-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['bet-charger-3'],
		{ { 'speed-processor', 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['bet-fuel-4'],
		{ { "module-circuit-board", 1 }, { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }, { "production-science-pack", 1 },
			{ 'science-pack-gold',    1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 } })
	addSciencePackToTechnologyUnits(technologies['bet-fuel-recycling'],
		{ { "module-circuit-board", 1 }, { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 }, { "production-science-pack", 1 },
			{ 'science-pack-gold',    1 }, { 'alien-science-pack-blue', 1 }, { 'military-science-pack', 1 }, { 'pollution-clean-processor', 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['alien-blue-research'], { { 'automation-science-pack', 1 },
		{ "productivity-processor",  1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
		{ "production-science-pack", 1 }, { 'chemical-science-pack', 1 }, { 'logistic-science-pack', 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['advanced-research'], { { 'advanced-logistic-science-pack', 1 },
		{ "productivity-processor",         1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
		{ "production-science-pack", 1 }, { 'utility-science-pack', 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['bob-shotgun-shells'],
		{ { "productivity-processor", 1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ 'production-science-pack', 1 }, { 'utility-science-pack', 1 }, { 'chemical-science-pack', 1 } })
	--
	addSciencePackToTechnologyUnits(technologies['advanced-machining'],
		{ { 'advanced-logistic-science-pack', 1 },
			{ "productivity-processor",         1 }, { 'effectivity-processor', 1 }, { 'speed-processor', 1 },
			{ "production-science-pack", 1 } })
	--
end
function updateTechnologyEffectsNormalTree()
	updateBasicEffects()
	updateNotFoundEffectesAndSciencePacks()
end
