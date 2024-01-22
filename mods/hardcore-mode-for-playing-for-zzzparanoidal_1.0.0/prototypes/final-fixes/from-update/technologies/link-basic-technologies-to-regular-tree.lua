local techUtil = require("__automated-utility-protocol__.util.technology-util")
local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
require("__hardcore-mode-for-playing__.prototypes.basic-technologies")
local function resetBasicTechnologyPrerequisitesToNormalTree(mode)
	local technologies = data.raw["technology"]
	techUtil.resetTechnologyPrerequisites(technologies["factory-architecture-t1"], { "basic-researching" }, mode)
	techUtil.resetTechnologyPrerequisites(
		technologies["basic-automation"],
		{ "factory-architecture-t1", "basic-researching" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(technologies["stone-wall"], { "military-0", "basic-automation" }, mode)
	techUtil.resetTechnologyPrerequisites(
		technologies["water-pumpjack-1"],
		{ "basic-automation", "basic-metal-processing", "angels-copper-smelting-1", "electricity", "coal-ore-smelting" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(
		technologies["basic-logistics"],
		{ "logistics-0", "basic-automation", "iron-storage" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(technologies["logistics-0"], {
		"basic-automation",
		"coal-ore-smelting",
		"basic-wood-production",
		"basic-metal-processing",
		"basic-researching",
	}, mode)
	techUtil.resetTechnologyPrerequisites(technologies["armor-absorb-1"], { "basic-automation" }, mode)
	techUtil.resetTechnologyPrerequisites(
		technologies["bi-dart-turret"],
		{ "basic-automation", "basic-metal-processing", "basic-wood-production" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(technologies["military"], { "basic-automation", "military-0" }, mode)
	techUtil.resetTechnologyPrerequisites(technologies["electricity"], { "basic-automation", "electricity-0" }, mode)
end

local function addPrerequisitesToTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.addPrerequisitesToTechnology(technologies["ore-crushing"], { "burner-ore-crushing" }, mode)
	techUtil.addPrerequisitesToTechnology(technologies["electric-mining"], { "burner-ore-mining" }, mode)
	techUtil.addPrerequisitesToTechnology(technologies["electric-chemical-furnace"], { "basic-chemistry" }, mode)
	techUtil.addPrerequisitesToTechnology(
		technologies["electric-mixing-furnace"],
		{ "electric-chemical-furnace" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(technologies["angels-solder-smelting-basic"], { "ore-crushing" }, mode)
end

local function removeRecipeEffectsFromTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.removeRecipeEffectFromTechnologyEffects(technologies["sulfur-processing"], "sulfuric-acid-2", mode)
end
local function moveRecipesToNewTechnologies(mode)
	techUtil.moveRecipeEffectsToTechnology("resins", "resin-1", "solid-resin", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-1", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-2", "puffer-egg-2", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-3", "puffer-egg-3", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-4", mode)
	techUtil.moveRecipeEffectsToTechnology("bio-refugium-hatchery", "bio-refugium-puffer-4", "puffer-egg-5", mode)
	techUtil.moveRecipeEffectsToTechnology("w93-modular-turrets", "w93-modular-turrets2", "w93-hmg-turret2", mode)
	techUtil.moveRecipeEffectsToTechnology("rubber", "rubbers", "liquid-rubber-1", mode)
	techUtil.moveRecipeEffectsToTechnology(
		"phosphorus-processing-1",
		"phosphorus-processing-2",
		"solid-tetrasodium-pyrophosphate",
		mode
	)
	techUtil.moveRecipeEffectsToTechnology("basic-automation", "steam-power", "steam-inserter", mode)
	techUtil.moveRecipeEffectsToTechnology(
		"water-treatment",
		"water-treatment-2",
		"bi-mineralized-sulfuric-waste",
		mode
	)
	techUtil.moveRecipeEffectsToTechnology(
		"angels-advanced-chemistry-3",
		"angels-advanced-chemistry-4",
		"catalyst-metal-violet",
		mode
	)
end
local function removePrerequisitesFromTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.removePrerequisitesFromTechnology(technologies["modules-3"], { "advanced-electronics-3" }, mode)
	techUtil.removePrerequisitesFromTechnology(technologies["advanced-electronics"], { "offshore-pump-2" }, mode)
end

local function createResourceDetectedTechnologiesAndAddItToNormalTechnologyByRecipeName(mode)
	local resource_recipes = createResourceRecipes()
	local active_technology_names = techUtil.getAllActiveTechnologyNames(mode)
	_table.each(resource_recipes, function(resource_recipe)
		local resource_recipe_name = resource_recipe.name
		local results = recipeUtil.getAllRecipeResults(resource_recipe_name, mode)
		local recipe_result = results[1]
		_table.each(active_technology_names, function(active_technology_name)
			local recipe_ingredients =
				techUtil.getAllRecipesIngredientsForSpecifiedTechnology(active_technology_name, mode)
			if _table.contains_f_deep(recipe_ingredients, recipe_result) then
				techUtil.addRecipeEffectToTechnologyEffects(
					data.raw["technology"][active_technology_name],
					resource_recipe_name,
					mode
				)
				log(
					"for technology "
						.. active_technology_name
						.. " mode "
						.. mode
						.. " added recipe effect "
						.. resource_recipe_name
				)
			end
		end)
	end)
end

_table.each(GAME_MODES, function(mode)
	resetBasicTechnologyPrerequisitesToNormalTree(mode)
	addPrerequisitesToTechnologies(mode)
	removePrerequisitesFromTechnologies(mode)
	removeRecipeEffectsFromTechnologies(mode)
	moveRecipesToNewTechnologies(mode)
	createResourceDetectedTechnologiesAndAddItToNormalTechnologyByRecipeName(mode)
end)
