local techUtil = require("__automated-utility-protocol__.util.technology-util")
local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
require("__hardcore-mode-for-playing__.prototypes.basic-technologies")
local function resetBasicTechnologyPrerequisitesToNormalTree(mode)
	local technologies = data.raw["technology"]
	techUtil.reset_prerequisites_for_technology(
		technologies["factory-architecture-t1"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.reset_prerequisites_for_technology(
		technologies["automation"],
		{ "factory-architecture-t1", "automation-science-pack" },
		mode
	)
	techUtil.reset_prerequisites_for_technology(technologies["stone-wall"], { "military-0", "automation" }, mode)
	techUtil.reset_prerequisites_for_technology(technologies["military"], { "automation", "military-0" }, mode)
	techUtil.reset_prerequisites_for_technology(technologies["logistics"], { "automation", "electricity-0" }, mode)
	techUtil.reset_prerequisites_for_technology(
		technologies["electronics"],
		_table.deep_copy(Utils.getModedObject(technologies["automation"], mode).prerequisites),
		mode
	)
	techUtil.reset_prerequisites_for_technology(technologies["automation"], { "electronics" }, mode)
end

local function addPrerequisitesToTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.add_prerequisites_to_technology(technologies["steel-processing"], { "automation" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["logistic-science-pack"], { "logistics", "automation" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["optics"], { "coal-lighting" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["gun-turret"], { "military" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["logistics"], { "iron-storage" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["burner-ore-mining"], { "electricity-0" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-7"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-7"],
		{ "logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-7"],
		{ "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-7"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-7"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-6"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-5"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-5"],
		{ "logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-5"],
		{ "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-5"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-3"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-3"],
		{ "logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-3"],
		{ "military-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-2"],
		{ "logistic-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["physical-projectile-damage-1"],
		{ "automation-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["factory-architecture-t1"],
		{ "stone-detected-resource-technology" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["military"], { "basic-metal-processing" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["military"], { "coal-ore-smelting" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["military"], { "basic-wood-production" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["optics"], { "basic-electronics" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["optics"], { "automation-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["logistics"], { "basic-logistics" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["space-science-pack"], { "military" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-7"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-5"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-5"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-5"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-4"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-3"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-3"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["stronger-explosives-2"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["refined-flammables-5"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["refined-flammables-5"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["refined-flammables-4"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["refined-flammables-3"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["energy-weapons-damage-5"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-6"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-6"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-6"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-5"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-4"], { "logistic-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-4"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-3"], { "military-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["weapon-shooting-speed-2"], { "logistic-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["laser-shooting-speed-7"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["laser-shooting-speed-5"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["artillery"], { "concrete" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["follower-robot-count-3"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-7"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-7"],
		{ "production-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-7"],
		{ "utility-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-5"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-5"],
		{ "production-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-4"],
		{ "production-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-3"],
		{ "chemical-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["fast-inserter"], { "logistics" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["inserter-capacity-bonus-4"],
		{ "production-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["braking-force-7"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["braking-force-7"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["braking-force-6"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["braking-force-5"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["braking-force-3"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-6"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-6"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-6"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-5"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-4"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["research-speed-3"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["worker-robots-speed-5"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["worker-robots-speed-4"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["worker-robots-speed-3"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["worker-robots-storage-3"],
		{ "production-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["worker-robots-storage-3"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(
		technologies["worker-robots-storage-2"],
		{ "production-science-pack" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["mining-productivity-3"], { "production-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["mining-productivity-3"], { "utility-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["mining-productivity-2"], { "chemical-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["spidertron"], { "space-science-pack" }, mode)
	techUtil.add_prerequisites_to_technology(technologies["factory-preview"], { "logistic-science-pack" }, mode)
end

local function createResourceDetectedTechnologiesAndAddItToNormalTechnologyByRecipeName(mode)
	local resource_recipes = create_resource_recipes()
	table.insert(resource_recipes, create_basic_resource_recipe({ type = "item", name = "iron-ore" }, "minable"))
	table.insert(resource_recipes, create_basic_resource_recipe({ type = "item", name = "copper-ore" }, "minable"))
	table.insert(resource_recipes, create_basic_resource_recipe({ type = "item", name = "uranium-ore" }, "minable"))
	local active_technology_names = techUtil.get_all_active_technology_names(mode)
	_table.each(resource_recipes, function(resource_recipe)
		local resource_recipe_name = resource_recipe.name
		local results = recipeUtil.get_all_recipe_results(resource_recipe_name, mode)
		local recipe_result = results[1]
		_table.each(active_technology_names, function(active_technology_name)
			local recipe_ingredients =
				techUtil.get_all_recipe_ingredients_for_specified_technology(active_technology_name, mode)
			if _table.contains_f_deep(recipe_ingredients, recipe_result) then
				techUtil.add_recipe_effect_to_technology(
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

local function addRecipeEffectsToTechnologies(mode)
	local technologies = data.raw["technology"]
	techUtil.add_recipe_effect_to_technology(technologies["logistics"], "inserter", mode)
	techUtil.add_recipe_effect_to_technology(technologies["logistics"], "pipe-to-ground", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-logistics"], "transport-belt", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-logistics"], "pipe", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-logistics"], "burner-inserter", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-electronics"], "electronic-circuit", mode)
	techUtil.add_recipe_effect_to_technology(technologies["fluid-handling"], "offshore-pump", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-ore-smelting"], "iron-plate", mode)
	techUtil.add_recipe_effect_to_technology(technologies["coal-ore-smelting"], "copper-plate", mode)
	techUtil.add_recipe_effect_to_technology(technologies["basic-metal-processing"], "iron-gear-wheel", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military"], "radar", mode)
	techUtil.add_recipe_effect_to_technology(technologies["military"], "light-armor", mode)
	techUtil.add_recipe_effect_to_technology(technologies["electric-energy-distribution-1"], "steam-engine", mode)
	techUtil.add_recipe_effect_to_technology(technologies["electric-energy-distribution-1"], "boiler", mode)
	techUtil.add_recipe_effect_to_technology(technologies["repair-pack"], "repair-pack", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-mining"], "burner-mining-drill", mode)
	techUtil.add_recipe_effect_to_technology(technologies["burner-ore-mining"], "electric-mining-drill", mode)
	techUtil.add_recipe_effect_to_technology(technologies["space-science-pack"], "satellite-raw-fish", mode)
	techUtil.add_recipe_effect_to_technology(technologies["automation-science-pack"], "lab", mode)
end
local function removeRecipeEffectsFromTechnologies(mode) end
local function moveRecipesToNewTechnologies(mode)
	techUtil.move_recipe_effects_to_another_technology("automation", "logistics", "long-handed-inserter", mode)
end

_table.each(GAME_MODES, function(mode)
	resetBasicTechnologyPrerequisitesToNormalTree(mode)
	addPrerequisitesToTechnologies(mode)
	createResourceDetectedTechnologiesAndAddItToNormalTechnologyByRecipeName(mode)
	addRecipeEffectsToTechnologies(mode)
	removeRecipeEffectsFromTechnologies(mode)
	moveRecipesToNewTechnologies(mode)
end)
