local techUtil = require("__automated-utility-protocol__.util.technology-util")
local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")

local function resetBasicTechnologyPrerequisitesToNormalTree(mode)
	local technologies = data.raw["technology"]
	techUtil.resetTechnologyPrerequisites(
		technologies["basic-automation"],
		{ "factory-architecture-t1", "automation-science-pack" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(
		technologies["stone-wall"],
		{ "military-0", "basic-automation", "basic-metal-processing" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(
		technologies["water-pumpjack-1"],
		{ "basic-automation", "basic-metal-processing", "angels-copper-smelting-1", "electricity", "coal-ore-smelting" },
		mode
	)
	techUtil.resetTechnologyPrerequisites(technologies["basic-logistics"], { --[["basic-automation",]]
		"iron-storage",
	}, mode)
	techUtil.resetTechnologyPrerequisites(technologies["logistics-0"], {
		"basic-automation",
		"coal-ore-smelting",
		"basic-wood-production",
		"basic-metal-processing",
		"automation-science-pack",
	}, mode)
	techUtil.resetTechnologyPrerequisites(technologies["armor-absorb-1"], { "basic-automation" }, mode)
	techUtil.resetTechnologyPrerequisites(technologies["bi-dart-turret"], {
		"basic-automation",
		"basic-metal-processing",
		"basic-wood-production",
		"coal-ore-smelting",
		"automation-science-pack",
	}, mode)
	techUtil.resetTechnologyPrerequisites(technologies["electricity"], { "basic-automation", "electricity-0" }, mode)

	techUtil.resetTechnologyPrerequisites(
		technologies["factory-architecture-t1"],
		{ "coal-stone-processing", "coal-ore-smelting", "automation-science-pack" },
		mode
	)
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
	techUtil.addPrerequisitesToTechnology(technologies["physical-projectile-damage-7"], {
		"automation-science-pack",
		"chemical-science-pack",
		"logistic-science-pack",
		"military-science-pack",
		"utility-science-pack",
	}, mode)
	techUtil.addPrerequisitesToTechnology(technologies["physical-projectile-damage-6"], {
		"automation-science-pack",
		"chemical-science-pack",
		"logistic-science-pack",
		"military-science-pack",
		"utility-science-pack",
	}, mode)
	techUtil.addPrerequisitesToTechnology(
		technologies["physical-projectile-damage-5"],
		{ "automation-science-pack", "logistic-science-pack", "military-science-pack" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["physical-projectile-damage-4"],
		{ "automation-science-pack", "logistic-science-pack", "military-science-pack" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["physical-projectile-damage-3"],
		{ "automation-science-pack", "logistic-science-pack", "military-science-pack" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["physical-projectile-damage-2"],
		{ "automation-science-pack", "logistic-science-pack" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["physical-projectile-damage-1"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(technologies["military"], {
		"basic-metal-processing",
		"coal-ore-smelting",
		"basic-wood-production",
		"automation-science-pack",
		"military-0",
	}, mode)
	techUtil.addPrerequisitesToTechnology(
		technologies["basic-automation"],
		{ "coal-ore-smelting", "coal-stone-smelting", "basic-electronics" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["basic-electronics"],
		{ "basic-wood-production", "coal-ore-smelting" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(technologies["electronics"], {
		"basic-electronics",
		"angels-tin-smelting-1",
		"bi-tech-timber",
		"bio-wood-processing",
		"automation-science-pack",
	}, mode)
	techUtil.addPrerequisitesToTechnology(
		technologies["military-0"],
		{ "coal-detected-resource-technology", "salvaged-automation-tech" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(technologies["basic-wood-production"], {
		"basic-metal-processing",
		"water-detected-resource-technology",
		"coal-detected-resource-technology",
		"wood-detected-resource-technology",
		"salvaged-automation-tech",
	}, mode)
	techUtil.addPrerequisitesToTechnology(technologies["coal-stone-smelting"], { "salvaged-automation-tech" }, mode)
	techUtil.addPrerequisitesToTechnology(technologies["coal-ore-smelting"], { "salvaged-automation-tech" }, mode)
	techUtil.addPrerequisitesToTechnology(technologies["coal-ore-crushing"], {
		"wood-detected-resource-technology",
		"salvaged-automation-tech",
		"coal-wooden-fluid-handling",
		"water-detected-resource-technology",
	}, mode)
	techUtil.addPrerequisitesToTechnology(technologies["coal-ore-mining"], {
		"wood-detected-resource-technology",
		"salvaged-automation-tech",
		"coal-wooden-fluid-handling",
		"water-detected-resource-technology",
	}, mode)
	techUtil.addPrerequisitesToTechnology(
		technologies["angels-ore1-detected-resource-technology"],
		{ "water-detected-resource-technology" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["angels-ore3-detected-resource-technology"],
		{ "water-detected-resource-technology" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["coal-lighting"],
		{ "wood-detected-resource-technology", "coal-detected-resource-technology" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["basic-logistics"],
		{ "salvaged-automation-tech", "basic-electronics" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(technologies["coal-stone-processing"], { "salvaged-automation-tech" }, mode)
	techUtil.addPrerequisitesToTechnology(
		technologies["automation-science-pack"],
		{ "coal-detected-resource-technology" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(technologies["logistics"], { "electricity" }, mode)
	techUtil.addPrerequisitesToTechnology(
		technologies["logistic-science-pack"],
		{ "logistics", "automation-science-pack", "angels-lead-smelting-1", "angels-tin-smelting-1" },
		mode
	)
	techUtil.addPrerequisitesToTechnology(
		technologies["electric-engine"],
		{ "coal-detected-resource-technology" },
		mode
	)
end

local function removePrerequisitesFromTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.removePrerequisitesFromTechnology(technologies["modules-3"], { "advanced-electronics-3" }, mode)
	techUtil.removePrerequisitesFromTechnology(technologies["advanced-electronics"], { "offshore-pump-2" }, mode)
end

local function removeRecipeEffectsFromTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.removeRecipeEffectFromTechnologyEffects(technologies["sulfur-processing"], "sulfuric-acid-2", mode)
	techUtil.removeRecipeEffectFromTechnologyEffects(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-copper-plate",
		mode
	)
	techUtil.removeRecipeEffectFromTechnologyEffects(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-iron-plate",
		mode
	)
	techUtil.removeRecipeEffectFromTechnologyEffects(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-lead-plate",
		mode
	)
	techUtil.removeRecipeEffectFromTechnologyEffects(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-silver-plate",
		mode
	)
	techUtil.removeRecipeEffectFromTechnologyEffects(
		technologies["ober-nuclear-processing"],
		"nuclear-smelting-tin-plate",
		mode
	)
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
	techUtil.moveRecipeEffectsToTechnology("electricity", "repair-pack", "repair-pack", mode)
	techUtil.moveRecipeEffectsToTechnology("electricity", "basic-logistics", "burner-filter-inserter", mode)
	techUtil.moveRecipeEffectsToTechnology("basic-automation", "basic-logistics", "burner-inserter", mode)
	techUtil.moveRecipeEffectsToTechnology("electricity", "basic-electronics", "condensator", mode)
	techUtil.moveRecipeEffectsToTechnology("electricity", "basic-electronics", "wooden-board", mode)
	techUtil.moveRecipeEffectsToTechnology("electricity", "basic-electronics", "basic-circuit-board", mode)
	techUtil.moveRecipeEffectsToTechnology("electricity", "logistics", "inserter", mode)
	techUtil.moveRecipeEffectsToTechnology("electronics", "logistics", "yellow-filter-inserter", mode)
end

local function addRecipeRecipeEffectsToTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.addRecipeEffectToTechnologyEffects(
		technologies["salvaged-automation-tech"],
		"salvaged-mining-drill-bit-mk0",
		mode
	)
	techUtil.addRecipeEffectToTechnologyEffects(
		technologies["salvaged-automation-tech"],
		"salvaged-mining-drill-bit-mk0",
		mode
	)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-wooden-fluid-handling"], "bi-wood-pipe", mode)
	techUtil.addRecipeEffectToTechnologyEffects(
		technologies["coal-wooden-fluid-handling"],
		"salvaged-offshore-pump-0",
		mode
	)
	techUtil.addRecipeEffectToTechnologyEffects(
		technologies["coal-wooden-fluid-handling"],
		"bi-wood-pipe-to-ground",
		mode
	)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-ore-crushing"], "salvaged-ore-crusher", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-ore-crushing"], "angelsore1-crushed", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-ore-crushing"], "angelsore3-crushed", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-stone-processing"], "stone-crushed", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-ore-smelting"], "angelsore1-crushed-smelting", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-ore-smelting"], "angelsore3-crushed-smelting", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["coal-lighting"], "deadlock-copper-lamp", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["basic-wood-production"], "coal-bi-bio-farm", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["basic-wood-production"], "coal-bi-bio-greenhouse", mode)
	techUtil.addRecipeEffectToTechnologyEffects(
		technologies["basic-wood-production"],
		"basic-coal-production-wood",
		mode
	)
	techUtil.addRecipeEffectToTechnologyEffects(
		technologies["basic-wood-production"],
		"basic-coal-production-seedling",
		mode
	)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["electricity-0"], "texugo-wind-turbine", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["basic-electronics"], "motor", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["electric-lab"], "electric-motor", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["military-0"], "pistol-rearm-ammo", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["military-0"], "bi-wooden-fence", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["military-0"], "respirator", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["burner-ore-mining"], "mining-drill-bit-mk0", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["burner-ore-crushing"], "burner-ore-crusher", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["automation-science-pack"], "burner-lab", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["automation-science-pack"], "sci-component-1", mode)
	techUtil.addRecipeEffectToTechnologyEffects(technologies["logistics"], "transport-belt", mode)
end
local function createResourceDetectedTechnologiesAndAddItToNormalTechnologyByRecipeName(mode)
	local resource_recipes = createResourceRecipes()
	local active_technology_names = techUtil.getAllActiveTechnologyNames(mode)
	_table.each(resource_recipes, function(resource_recipe)
		local resource_recipe_name = resource_recipe.name
		local results = recipeUtil.getAllRecipeResults(resource_recipe_name, mode)
		local recipe_result = results[1]
		local recipe_result_name = recipe_result.name or recipe_result[1]
		local recipe_result_data = data.raw[recipe_result.type][recipe_result_name]
		--log("recipe_result_data " .. Utils.dump_to_console(recipe_result_data))
		local resource_detected_technology = createResourceDetectedTechnology(
			recipe_result_name,
			recipe_result_data.icon or recipe_result_data.icons[1].icon,
			recipe_result_data.icon_size or recipe_result_data.icons[1].icon_size,
			resource_recipe_name
		)
		--log("resource_detected_technology " .. Utils.dump_to_console(resource_detected_technology))
		data:extend({
			resource_detected_technology,
		})
		_table.each(active_technology_names, function(active_technology_name)
			local recipe_ingredients =
				techUtil.getAllRecipesIngredientsForSpecifiedTechnology(active_technology_name, mode)
			local active_technology = data.raw["technology"][active_technology_name]
			if _table.contains_f_deep(recipe_ingredients, recipe_result) then
				techUtil.addRecipeEffectToTechnologyEffects(active_technology, resource_recipe_name, mode)
				techUtil.addPrerequisitesToTechnology(active_technology, { resource_detected_technology.name }, mode)
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
local function hide_recipes(mode)
	local recipes = data.raw["recipe"]
	techUtil.hideRecipe(recipes["torch"], mode)
end
_table.each(GAME_MODES, function(mode)
	createResourceDetectedTechnologiesAndAddItToNormalTechnologyByRecipeName(mode)
	resetBasicTechnologyPrerequisitesToNormalTree(mode)
	removePrerequisitesFromTechnologies(mode)
	addPrerequisitesToTechnologies(mode)
	removeRecipeEffectsFromTechnologies(mode)
	addRecipeRecipeEffectsToTechnologies(mode)
	moveRecipesToNewTechnologies(mode)
	hide_recipes(mode)
end)
